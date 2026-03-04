module Universidade
  module Admin
    class BibliotecaController < BaseController
      before_action :set_conteudo, only: %i[edit update destroy toggle_visivel desvincular_trilha]

      def index
        @conteudos = Conteudo.all
        
        # Filtro de busca opcional
        if params[:q].present?
          @conteudos = @conteudos.where("lower(titulo) LIKE lower(?)", "%#{params[:q]}%")
        end
        
        # Filtros de taxonomia
        if params[:categoria_id].present?
          @conteudos = @conteudos.por_categoria(params[:categoria_id])
        end

        @conteudos = @conteudos.order(created_at: :desc)
                               .includes(:trilha_conteudos, :trilhas, :categoria)

        # Para os filtros
        @categorias = Categoria.ordem_alfabetica
      end

      def new
        @conteudo = Conteudo.new(visivel: true)
        @trilha_id = params[:trilha_id]
        @modulo_id = params[:modulo_id]
        load_trilhas_e_modulos
      end

      def create
        @conteudo = Conteudo.new(conteudo_params)
        apply_status_action(@conteudo)
        
        if @conteudo.save
          # Sincronizar tags
          sincronizar_tags
          
          # Vincular trilhas selecionadas
          if params[:trilhas].present?
            trilha_ids = Array(params[:trilhas]).reject(&:blank?)
            modulos_hash = params[:modulos] || {}
            
            trilha_ids.each do |trilha_id|
              trilha = Trilha.find_by(id: trilha_id)
              next unless trilha
              
              proxima_posicao = TrilhaConteudo.proxima_posicao(trilha.id)
              modulo_id = modulos_hash[trilha_id].presence
              
              TrilhaConteudo.create!(
                trilha: trilha,
                conteudo: @conteudo,
                modulo_id: modulo_id,
                posicao: proxima_posicao
              )
            end
          end
          
          redirect_to admin_biblioteca_index_path, notice: "Conteúdo criado com sucesso."
        else
          load_trilhas_e_modulos
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @trilhas_vinculadas = @conteudo.trilha_conteudos.includes(:trilha, :modulo)
        load_trilhas_e_modulos
      end

      def update
        @conteudo.assign_attributes(conteudo_params)
        apply_status_action(@conteudo)
        
        if @conteudo.save
          # Sincronizar tags
          sincronizar_tags
          
          # Atualizar módulos das trilhas existentes
          if params[:trilha_modulos].present?
            params[:trilha_modulos].each do |trilha_conteudo_id, modulo_id|
              trilha_conteudo = @conteudo.trilha_conteudos.find_by(id: trilha_conteudo_id)
              trilha_conteudo&.update(modulo_id: modulo_id.presence)
            end
          end
          
          # Adicionar novas trilhas
          if params[:trilhas].present?
            trilha_ids = Array(params[:trilhas]).reject(&:blank?)
            modulos_hash = params[:modulos] || {}
            
            trilha_ids.each do |trilha_id|
              # Pular se já existe vínculo
              next if @conteudo.trilha_conteudos.exists?(trilha_id: trilha_id)
              
              trilha = Trilha.find_by(id: trilha_id)
              next unless trilha
              
              proxima_posicao = TrilhaConteudo.proxima_posicao(trilha.id)
              modulo_id = modulos_hash[trilha_id].presence
              
              TrilhaConteudo.create!(
                trilha: trilha,
                conteudo: @conteudo,
                modulo_id: modulo_id,
                posicao: proxima_posicao
              )
            end
          end
          
          redirect_to admin_biblioteca_index_path, notice: "Conteúdo atualizado com sucesso."
        else
          @trilhas_vinculadas = @conteudo.trilha_conteudos.includes(:trilha, :modulo)
          load_trilhas_e_modulos
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @conteudo.destroy
        redirect_to admin_biblioteca_index_path, notice: "Conteúdo excluído com sucesso."
      end

      def toggle_visivel
        new_visivel = !@conteudo.visivel?
        @conteudo.update!(visivel: new_visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "conteudo_#{@conteudo.id}",
              partial: "universidade/admin/biblioteca/conteudo_row",
              locals: { conteudo: @conteudo }
            )
          end
          format.html { redirect_to admin_biblioteca_index_path }
        end
      end

      def desvincular_trilha
        trilha_id = params[:trilha_id]
        trilha_conteudo = @conteudo.trilha_conteudos.find_by(trilha_id: trilha_id)
        
        if trilha_conteudo
          trilha_conteudo.destroy
          redirect_to edit_admin_biblioteca_path(@conteudo), notice: "Conteúdo desvinculado da trilha com sucesso."
        else
          redirect_to edit_admin_biblioteca_path(@conteudo), alert: "Vínculo não encontrado."
        end
      end

      private

      def set_conteudo
        @conteudo = Conteudo.find(params[:id])
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

      def conteudo_params
        params.require(:conteudo).permit(:titulo, :corpo, :tempo_estimado_minutos, :visivel, :categoria_id).merge(
          user_id: universidade_current_user.id,
          store_id: universidade_current_user.store_id
        )
      end

      def sincronizar_tags
        if params[:conteudo] && params[:conteudo][:tag_ids]
          tag_ids = Array(params[:conteudo][:tag_ids]).reject(&:blank?)
          @conteudo.tag_ids = tag_ids
        end
      end

      def load_trilhas_e_modulos
        @trilhas = Trilha.order(:nome)
        @modulos = Modulo.includes(:trilha).order(:nome)
        @modulos_json = @modulos.map { |m| { id: m.id, nome: m.nome, trilha_id: m.trilha_id } }.to_json
        
        # Preparar trilha pré-selecionada se vier dos params
        if @trilha_id.present?
          trilha = Trilha.find_by(id: @trilha_id)
          if trilha
            @trilha_inicial = { id: trilha.id, nome: trilha.nome }.to_json
            # Também passar o módulo_id se fornecido
            @modulo_inicial_id = @modulo_id if @modulo_id.present?
          end
        end
      end
    end
  end
end
