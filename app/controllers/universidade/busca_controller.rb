module Universidade
  class BuscaController < ApplicationController
    def index
      @q             = params[:q].to_s.strip
      @categoria_slug = params[:categoria].to_s.strip

      if @categoria_slug.present?
        @categoria = Categoria.find_by(slug: @categoria_slug)
        return redirect_to busca_path unless @categoria

        @conteudos = Conteudo.visivel
                             .por_categoria(@categoria.id)
                             .includes(:categoria, :trilhas)
                             .order(created_at: :asc)

        set_meta_tags(
          title: @categoria.nome,
          description: "Conteúdos da categoria #{@categoria.nome}",
          type: "website"
        )

      elsif @q.present?
        @trilhas   = Trilha.visivel.buscar(@q).includes(:tags).order(created_at: :desc)
        @conteudos = Conteudo.visivel.buscar(@q).includes(:categoria, :trilhas).order(created_at: :desc)

        # Categorias presentes nos resultados (para chips de filtro)
        categoria_ids        = @conteudos.pluck(:categoria_id).compact.uniq
        @categorias_filtro   = Categoria.where(id: categoria_ids).ordem_alfabetica

        # Aplicar filtro de categoria se selecionado via ?cat=ID
        cat_id = params[:cat].to_i
        if cat_id > 0 && categoria_ids.include?(cat_id)
          @categoria_filtrada_id = cat_id
          @conteudos = @conteudos.por_categoria(cat_id)
        end

        set_meta_tags(
          title: "Busca: #{@q}",
          description: "Resultados da busca por '#{@q}' na Universidade",
          type: "website"
        )

      else
        @categorias = Categoria.ordem_alfabetica

        set_meta_tags(
          title: "Busca",
          description: "Busque ou navegue por categorias na Universidade",
          type: "website"
        )
      end
    end

    def rapida
      q = params[:q].to_s.strip

      if q.length >= 2
        trilhas   = Trilha.visivel.buscar(q).limit(3)
        conteudos = Conteudo.visivel.buscar(q).includes(:categoria).limit(3)

        render json: {
          trilhas:   trilhas.map   { |t| { titulo: t.nome,   url: trilha_path(t) } },
          conteudos: conteudos.map { |c| { titulo: c.titulo, url: conteudo_path(c), categoria: c.categoria&.nome } }
        }
      else
        render json: { trilhas: [], conteudos: [] }
      end
    end
  end
end
