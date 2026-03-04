module Universidade
  module Admin
    class TagsController < BaseController
      before_action :set_tag, only: %i[edit update destroy]

      def index
        @busca = params[:q].presence
        @ordem = params[:ordem].presence || "mais_usadas"
        
        @tags = @ordem == "alfabetica" ? Tag.ordem_alfabetica : Tag.mais_usadas
        @tags = @tags.where("lower(nome) LIKE lower(?)", "%#{@busca}%") if @busca
      end

      def new
        @tag = Tag.new
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @tag = Tag.new(tag_params)
        
        if @tag.save
          respond_to do |format|
            format.json { render json: @tag, status: :created }
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_tags_path, notice: "Tag criada com sucesso." }
          end
        else
          respond_to do |format|
            format.json { render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity }
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
        if @tag.update(tag_params)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_tags_path, notice: "Tag atualizada com sucesso." }
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

      def destroy
        @tag.destroy
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.remove("tag_#{@tag.id}")
          end
          format.html { redirect_to admin_tags_path, notice: "Tag excluída com sucesso." }
        end
      end

      def buscar_sugestoes
        titulo = params[:titulo].to_s
        corpo = params[:corpo].to_s
        
        # Extrai texto do corpo EditorJS
        texto_corpo = extrair_texto_do_corpo(corpo)
        texto_completo = "#{titulo} #{texto_corpo}".downcase
        
        # Busca categorias e tags que aparecem no texto
        categorias_sugeridas = Categoria.all.select do |cat|
          texto_completo.include?(cat.nome.downcase)
        end
        
        tags_sugeridas = Tag.all.select do |tag|
          texto_completo.include?(tag.nome.downcase)
        end
        
        render json: {
          categorias: categorias_sugeridas.map { |c| { id: c.id, nome: c.nome } },
          tags: tags_sugeridas.map { |t| { id: t.id, nome: t.nome } }
        }
      end

      private

      def set_tag
        @tag = Tag.find(params[:id])
      end

      def tag_params
        params.require(:tag).permit(:nome)
      end

      def extrair_texto_do_corpo(corpo_json)
        return "" if corpo_json.blank?
        
        begin
          corpo = JSON.parse(corpo_json)
          blocos = corpo.dig("blocks") || []
          texto = []
          
          blocos.each do |bloco|
            case bloco["type"]
            when "paragraph", "header"
              texto << bloco.dig("data", "text")
            when "list"
              items = bloco.dig("data", "items") || []
              texto.concat(items)
            end
          end
          
          texto.compact.join(" ")
        rescue JSON::ParserError
          ""
        end
      end
    end
  end
end
