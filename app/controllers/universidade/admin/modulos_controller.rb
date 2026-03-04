module Universidade
  module Admin
    class ModulosController < BaseController
      before_action :set_modulo, only: %i[edit update destroy confirmar_exclusao toggle_visivel mover_acima mover_abaixo]

      def new
        @modulo = Modulo.new(visivel: true, trilha_id: params[:trilha_id])
        @trilhas = Trilha.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @modulo = Modulo.new(modulo_params)
        apply_status_action(@modulo)
        if @modulo.save
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Módulo criado com sucesso." }
          end
        else
          @trilhas = Trilha.order(:nome)
          respond_to do |format|
            format.turbo_stream do
              html = render_to_string(:new, formats: [:html], layout: false)
              render turbo_stream: turbo_stream.replace("modal-content", html), status: :unprocessable_entity
            end
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end

      def edit
        @trilhas = Trilha.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def update
        @modulo.assign_attributes(modulo_params)
        apply_status_action(@modulo)
        if @modulo.save
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Módulo atualizado com sucesso." }
          end
        else
          @trilhas = Trilha.order(:nome)
          respond_to do |format|
            format.turbo_stream do
              html = render_to_string(:edit, formats: [:html], layout: false)
              render turbo_stream: turbo_stream.replace("modal-content", html), status: :unprocessable_entity
            end
            format.html { render :edit, status: :unprocessable_entity }
          end
        end
      end

      def confirmar_exclusao
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def destroy
        nome = @modulo.nome
        excluir_conteudos = params[:excluir_conteudos] == "true"
        
        @modulo.excluir_com_opcoes(excluir_conteudos: excluir_conteudos)
        
        redirect_to admin_root_path, notice: "\"#{nome}\" excluído com sucesso."
      end

      def toggle_visivel
        @modulo.update!(visivel: !@modulo.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "modulo_#{@modulo.id}",
              partial: "universidade/admin/modulos/modulo_row",
              locals: { modulo: @modulo }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        scope = @modulo.trilha_id ? Modulo.where(trilha_id: @modulo.trilha_id) : Modulo.where(trilha_id: nil)
        modulos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = modulos.find_index { |m| m.id == @modulo.id }
        if idx&.positive?
          modulos[idx], modulos[idx - 1] = modulos[idx - 1], modulos[idx]
          Modulo.transaction { modulos.each_with_index { |m, i| m.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        scope = @modulo.trilha_id ? Modulo.where(trilha_id: @modulo.trilha_id) : Modulo.where(trilha_id: nil)
        modulos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = modulos.find_index { |m| m.id == @modulo.id }
        if idx && idx < modulos.length - 1
          modulos[idx], modulos[idx + 1] = modulos[idx + 1], modulos[idx]
          Modulo.transaction { modulos.each_with_index { |m, i| m.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Modulo.transaction do
          ids.each_with_index { |id, i| Modulo.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_modulo
        @modulo = Modulo.find(params[:id])
      end

      def modulo_params
        params.require(:modulo).permit(:nome, :descricao, :ordem, :visivel, :trilha_id).merge(
          user_id: universidade_current_user.id,
          store_id: universidade_current_user.store_id
        )
      end

      def apply_status_action(modulo)
        actions = Array(params.dig(:modulo, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          modulo.rascunho = true
        when "publicar"
          modulo.rascunho = false
        end
      end
    end
  end
end
