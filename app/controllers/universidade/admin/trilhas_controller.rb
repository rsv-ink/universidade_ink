module Universidade
  module Admin
    class TrilhasController < BaseController
      before_action :set_trilha, only: %i[show edit update destroy confirmar_exclusao toggle_visivel mover_acima mover_abaixo selecionar_conteudos_existentes adicionar_conteudos_existentes]

      def index
        @busca = params[:q].presence
        
        if @busca
          # Busca em trilhas, módulos e conteúdos
          @trilhas = Trilha.buscar(@busca)
                          .order(Arel.sql("COALESCE(ordem, id)"))
                          .includes(:trilha_conteudos, :modulos)
          @modulos_avulsos = Modulo.where(trilha_id: nil)
                                    .buscar(@busca)
                                    .order(Arel.sql("COALESCE(ordem, id)"))
        else
          # Exibir todos
          @trilhas = Trilha.order(Arel.sql("COALESCE(ordem, id)"))
                          .includes(:trilha_conteudos, :modulos)
          @modulos_avulsos = Modulo.where(trilha_id: nil)
                                    .order(Arel.sql("COALESCE(ordem, id)"))
        end
      end

      def show
        redirect_to admin_root_path
      end

      def new
        @trilha = Trilha.new(visivel: true)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @trilha = Trilha.new(trilha_params)
        apply_status_action(@trilha)
        if @trilha.save
          sincronizar_tags(@trilha)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Trilha criada com sucesso." }
          end
        else
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
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def update
        @trilha.assign_attributes(trilha_params)
        apply_status_action(@trilha)
        if @trilha.save
          sincronizar_tags(@trilha)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Trilha atualizada com sucesso." }
          end
        else
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
        nome = @trilha.nome
        excluir_conteudos = params[:excluir_conteudos] == "true"
        
        @trilha.excluir_com_opcoes(excluir_conteudos: excluir_conteudos)
        
        redirect_to admin_root_path, notice: "\"#{nome}\" excluída com sucesso."
      end

      def toggle_visivel
        @trilha.update!(visivel: !@trilha.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "trilha_#{@trilha.id}",
              partial: "universidade/admin/trilhas/trilha",
              locals: { trilha: @trilha }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        trilhas = Trilha.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = trilhas.find_index { |t| t.id == @trilha.id }
        if idx&.positive?
          trilhas[idx], trilhas[idx - 1] = trilhas[idx - 1], trilhas[idx]
          Trilha.transaction { trilhas.each_with_index { |t, i| t.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        trilhas = Trilha.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = trilhas.find_index { |t| t.id == @trilha.id }
        if idx && idx < trilhas.length - 1
          trilhas[idx], trilhas[idx + 1] = trilhas[idx + 1], trilhas[idx]
          Trilha.transaction { trilhas.each_with_index { |t, i| t.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Trilha.transaction do
          ids.each_with_index { |id, i| Trilha.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      def adicionar_conteudos_existentes
        @trilha = Trilha.find(params[:id])
        conteudo_ids = Array(params[:conteudo_ids]).map(&:to_i)
        
        conteudos_adicionados = []
        conteudo_ids.each do |conteudo_id|
          conteudo = Conteudo.find_by(id: conteudo_id)
          next unless conteudo
          
          # Verifica se já não está vinculado
          next if @trilha.trilha_conteudos.exists?(conteudo_id: conteudo_id)
          
          # Adiciona na última posição
          proxima_posicao = TrilhaConteudo.proxima_posicao(@trilha.id)
          TrilhaConteudo.create!(
            trilha: @trilha,
            conteudo: conteudo,
            modulo_id: params[:modulo_id].presence,
            posicao: proxima_posicao
          )
          conteudos_adicionados << conteudo.titulo
        end
        
        if conteudos_adicionados.any?
          redirect_to admin_root_path, notice: "#{conteudos_adicionados.size} conteúdo(s) adicionado(s) com sucesso."
        else
          redirect_to admin_root_path, alert: "Nenhum conteúdo foi adicionado. Eles já podem estar vinculados a esta trilha."
        end
      end

      def selecionar_conteudos_existentes
        @trilha = Trilha.find(params[:id])
        @conteudos_disponiveis = Conteudo.order(:titulo).includes(:trilha_conteudos)
        if turbo_frame_request? || request.xhr?
          render partial: "add_existing_content", layout: false
        else
          render :selecionar_conteudos_existentes
        end
      end

      private

      def set_trilha
        @trilha = Trilha.find(params[:id])
      end

      def trilha_params
        params.require(:trilha).permit(:nome, :descricao, :ordem, :visivel, :imagem).to_h.merge(
          user_id: universidade_current_user.id,
          store_id: universidade_current_user.store_id
        )
      end

      def sincronizar_tags(trilha)
        nomes = params.dig(:trilha, :tags_text).to_s.split(",").map(&:strip).reject(&:blank?)
        tags = nomes.map { |nome| Tag.find_by("lower(nome) = lower(?)", nome) || Tag.create!(nome: nome) }
        trilha.tags = tags
      end

      def apply_status_action(trilha)
        actions = Array(params.dig(:trilha, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          trilha.rascunho = true
        when "publicar"
          trilha.rascunho = false
        end
      end
    end
  end
end
