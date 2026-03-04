module Universidade
  module Admin
    class CategoriasController < BaseController
      before_action :set_categoria, only: %i[edit update destroy]

      def index
        @busca = params[:q].presence
        
        @categorias = Categoria.ordem_alfabetica
        @categorias = @categorias.where("lower(nome) LIKE lower(?)", "%#{@busca}%") if @busca
        
        respond_to do |format|
          format.html
          format.json do
            render json: @categorias.map { |c| { id: c.id, nome: c.nome, slug: c.slug } }
          end
        end
      end

      def new
        @categoria = Categoria.new
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @categoria = Categoria.new(categoria_params)
        
        if @categoria.save
          respond_to do |format|
            format.json { render json: { id: @categoria.id, nome: @categoria.nome, slug: @categoria.slug }, status: :created }
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_categorias_path, notice: "Categoria criada com sucesso." }
          end
        else
          respond_to do |format|
            format.json { render json: { error: @categoria.errors.full_messages.join(", ") }, status: :unprocessable_entity }
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
        if @categoria.update(categoria_params)
          respond_to do |format|
            format.json do
              render json: { id: @categoria.id, nome: @categoria.nome, slug: @categoria.slug }
            end
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_categorias_path, notice: "Categoria atualizada com sucesso." }
          end
        else
          respond_to do |format|
            format.json do
              render json: { error: @categoria.errors.full_messages.join(", ") }, status: :unprocessable_entity
            end
            format.turbo_stream do
              html = render_to_string(:edit, formats: [:html], layout: false)
              render turbo_stream: turbo_stream.replace("modal-content", html), status: :unprocessable_entity
            end
            format.html { render :edit, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        # Desvincular conteúdos antes de excluir
        @categoria.conteudos.update_all(categoria_id: nil)
        
        @categoria.destroy
        respond_to do |format|
          format.json { head :ok }
          format.turbo_stream do
            render turbo_stream: turbo_stream.remove("categoria_#{@categoria.id}")
          end
          format.html { redirect_to admin_categorias_path, notice: "Categoria excluída com sucesso." }
        end
      end

      private

      def set_categoria
        @categoria = Categoria.find(params[:id])
      end

      def categoria_params
        params.require(:categoria).permit(:nome, :descricao)
      end
    end
  end
end
