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
        
        @conteudos = @conteudos.order(created_at: :desc)
                               .includes(:trilha_conteudos, :trilhas)
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
        params.require(:conteudo).permit(:titulo, :corpo, :tempo_estimado_minutos, :visivel).merge(
          user_id: current_user_id || 1,
          store_id: current_store_id || 1
        )
      end

      def current_user_id
        # Retorna o ID do usuário atual se disponível
        Universidade.current_user(self)&.id || Universidade.current_user_id(self)
      end

      def current_store_id
        # Retorna o ID da loja atual se disponível
        Universidade.current_store_id(self)
      end

      def load_trilhas_e_modulos
        @trilhas = Trilha.order(:nome)
        @modulos = Modulo.includes(:trilha).order(:nome)
        @modulos_json = @modulos.map { |m| { id: m.id, nome: m.nome, trilha_id: m.trilha_id } }.to_json
      end
    end
  end
end
