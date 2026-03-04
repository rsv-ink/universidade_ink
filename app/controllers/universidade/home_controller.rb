module Universidade
  class HomeController < ApplicationController
    def index
      @secoes = Secao.visivel
                     .order(Arel.sql("COALESCE(ordem, id)"))
                     .includes(secao_itens: :item)

      # Filtros de taxonomia
      @categoria_selecionada = params[:categoria_id]
      @tags_selecionadas = params[:tag_ids].present? ? Array(params[:tag_ids]).reject(&:blank?) : []

      # Fallback quando não há seções configuradas
      if @secoes.empty?
        @trilhas = Trilha.visivel.order(created_at: :desc)
        
        # Aplicar filtros de taxonomia às trilhas se houver
        if @categoria_selecionada.present? || @tags_selecionadas.any?
          # Filtrar trilhas que contêm conteúdos com a categoria/tags selecionadas
          @trilhas = @trilhas.joins(trilha_conteudos: :conteudo)
                            .where(universidade_conteudos: filter_conditions)
                            .distinct
        end

        # Conteúdos soltos são aqueles que não estão vinculados a nenhuma trilha
        @conteudos_soltos = Conteudo.visivel
                                     .left_joins(:trilha_conteudos)
                                     .where(universidade_trilha_conteudos: { id: nil })
        
        # Aplicar filtros de taxonomia aos conteúdos soltos
        @conteudos_soltos = @conteudos_soltos.where(filter_conditions) if @categoria_selecionada.present? || @tags_selecionadas.any?
        
        @conteudos_soltos = @conteudos_soltos.order(created_at: :desc)
      end
      
      # Carregar categorias e tags para os filtros
      @categorias = Categoria.ordem_alfabetica
      @tags = Tag.ordem_alfabetica
      
      # SEO meta tags
      set_meta_tags(
        title: "Universidade",
        description: "Plataforma de aprendizado com trilhas, cursos e conteúdos educacionais",
        type: "website"
      )
    end
    
    private
    
    def filter_conditions
      conditions = {}
      
      if @categoria_selecionada.present?
        conditions[:categoria_id] = @categoria_selecionada
      end
      
      # Para tags, precisamos de um join adicional
      if @tags_selecionadas.any?
        # Esta condição será aplicada após o join
        return nil # Será tratado via scope
      end
      
      conditions
    end
  end
end
