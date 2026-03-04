module Universidade
  class TrilhasController < ApplicationController
    def show
      @trilha = Trilha.visivel.find(params[:id])

      # Módulos visíveis ordenados
      @modulos = @trilha.modulos
                        .visivel
                        .order(:id)

      # Para cada módulo, vamos buscar seus conteúdos ordenados
      @modulos_conteudos = {}
      @modulos.each do |modulo|
        @modulos_conteudos[modulo.id] = @trilha.trilha_conteudos
                                                .joins(:conteudo)
                                                .where(modulo_id: modulo.id)
                                                .where(universidade_conteudos: { visivel: true })
                                                .order(:posicao)
                                                .includes(:conteudo)
                                                .map(&:conteudo)
      end

      # Conteúdos soltos (sem módulo) ordenados por posicao
      @conteudos_soltos = @trilha.trilha_conteudos
                                  .joins(:conteudo)
                                  .where(modulo_id: nil)
                                  .where(universidade_conteudos: { visivel: true })
                                  .order(:posicao)
                                  .includes(:conteudo)
                                  .map(&:conteudo)
      
      # SEO meta tags
      set_meta_tags(
        title: @trilha.nome,
        description: @trilha.descricao || "Trilha de aprendizado",
        image: @trilha.imagem,
        type: "website",
        keywords: @trilha.tags.map(&:nome)
      )
    end
  end
end
