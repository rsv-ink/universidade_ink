module Universidade
  module Admin
    class ConteudosController < BaseController
      before_action :set_conteudo, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        # Redireciona para o formulário da biblioteca
        redirect_to new_admin_biblioteca_path(trilha_id: params[:trilha_id], modulo_id: params[:modulo_id])
      end

      def create
        @conteudo = Conteudo.new(conteudo_params)
        apply_status_action(@conteudo)
        
        if @conteudo.save
          # Se foi criado a partir de uma trilha, vincular automaticamente
          if params[:trilha_id].present?
            trilha = Trilha.find(params[:trilha_id])
            proxima_posicao = TrilhaConteudo.proxima_posicao(trilha.id)
            TrilhaConteudo.create!(
              trilha: trilha,
              conteudo: @conteudo,
              modulo_id: params[:modulo_id].presence,
              posicao: proxima_posicao
            )
          end
          redirect_to admin_root_path, notice: "Conteúdo criado com sucesso."
        else
          @trilha_id = params[:trilha_id]
          @modulo_id = params[:modulo_id]
          @modulos = Modulo.order(:nome)
          @trilhas = Trilha.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        # Redireciona para o formulário da biblioteca
        redirect_to edit_admin_biblioteca_path(@conteudo)
      end

      def update
        @conteudo.assign_attributes(conteudo_params)
        apply_status_action(@conteudo)
        if @conteudo.save
          redirect_to admin_root_path, notice: "Conteúdo atualizado com sucesso."
        else
          @modulos = Modulo.order(:nome)
          @trilhas = Trilha.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @conteudo.destroy
        redirect_to admin_root_path, notice: "Conteúdo excluído com sucesso."
      end

      def toggle_visivel
        new_visivel = !@conteudo.visivel?
        @conteudo.update!(visivel: new_visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "conteudo_#{@conteudo.id}",
              partial: "universidade/admin/conteudos/conteudo_row",
              locals: { conteudo: @conteudo }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        # Working with TrilhaConteudo join records now
        trilha_id = params[:trilha_id]
        modulo_id = params[:modulo_id]
        
        return redirect_to(admin_root_path, alert: "Trilha não especificada") unless trilha_id
        
        scope = TrilhaConteudo.where(trilha_id: trilha_id)
        scope = scope.where(modulo_id: modulo_id) if modulo_id.present?
        
        trilha_conteudos = scope.order(:posicao).to_a
        idx = trilha_conteudos.find_index { |tc| tc.conteudo_id == @conteudo.id }
        
        if idx&.positive?
          trilha_conteudos[idx], trilha_conteudos[idx - 1] = trilha_conteudos[idx - 1], trilha_conteudos[idx]
          TrilhaConteudo.transaction { trilha_conteudos.each_with_index { |tc, i| tc.update_column(:posicao, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        # Working with TrilhaConteudo join records now
        trilha_id = params[:trilha_id]
        modulo_id = params[:modulo_id]
        
        return redirect_to(admin_root_path, alert: "Trilha não especificada") unless trilha_id
        
        scope = TrilhaConteudo.where(trilha_id: trilha_id)
        scope = scope.where(modulo_id: modulo_id) if modulo_id.present?
        
        trilha_conteudos = scope.order(:posicao).to_a
        idx = trilha_conteudos.find_index { |tc| tc.conteudo_id == @conteudo.id }
        
        if idx && idx < trilha_conteudos.length - 1
          trilha_conteudos[idx], trilha_conteudos[idx + 1] = trilha_conteudos[idx + 1], trilha_conteudos[idx]
          TrilhaConteudo.transaction { trilha_conteudos.each_with_index { |tc, i| tc.update_column(:posicao, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        # Working with TrilhaConteudo join records now
        ids = Array(params[:ids]).map(&:to_i)
        trilha_id = params[:trilha_id].presence
        modulo_id = params[:modulo_id].presence
        from_trilha_id = params[:from_trilha_id].presence

        return head(:bad_request) unless trilha_id
        return head(:ok) if ids.empty?

        TrilhaConteudo.transaction do
          ids.each_with_index do |conteudo_id, i|
            tc = TrilhaConteudo.find_or_initialize_by(trilha_id: trilha_id, conteudo_id: conteudo_id)
            tc.modulo_id = modulo_id
            tc.posicao = i + 1
            tc.save!

            if from_trilha_id.present? && from_trilha_id != trilha_id
              TrilhaConteudo.where(trilha_id: from_trilha_id, conteudo_id: conteudo_id)
                            .where.not(id: tc.id)
                            .delete_all
            end
          end

          if from_trilha_id.present? && from_trilha_id != trilha_id
            resequence_trilha_conteudos(from_trilha_id, modulo_id: nil)
          end
        end

        head :ok
      end

      private

      def resequence_trilha_conteudos(trilha_id, modulo_id: nil)
        scope = TrilhaConteudo.where(trilha_id: trilha_id, modulo_id: modulo_id)
        scope.order(:posicao, :id).each_with_index do |tc, index|
          tc.update_column(:posicao, index + 1)
        end
      end

      def set_conteudo
        @conteudo = Conteudo.find(params[:id])
      end

      def conteudo_params
        params.require(:conteudo).permit(:titulo, :ordem, :tempo_estimado_minutos, :visivel, :corpo).merge(
          user_id: universidade_current_user.id,
          store_id: universidade_current_user.store_id
        )
      end

      def apply_status_action(conteudo)
        actions = Array(params.dig(:conteudo, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          conteudo.rascunho = true
          conteudo.visivel = false
        when "publicar"
          conteudo.rascunho = false
        end
      end
    end
  end
end
