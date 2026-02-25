module Universidade
  class TrilhasController < ApplicationController
    def show
      @trilha  = Trilha.visivel.find(params[:id])
      @artigos = @trilha.artigos.visivel.order(Arel.sql("COALESCE(ordem, id)"))

      # Mapa de conclusões do lojista para exibição eficiente (evita N+1)
      @concluidos_ids = concluidos_ids_for(@artigos)
    end

    private

    def concluidos_ids_for(artigos)
      return [] unless current_lojista_id

      Progresso.where(
        artigo_id:   artigos.map(&:id),
        lojista_id:  current_lojista_id
      ).where.not(concluido_em: nil).pluck(:artigo_id).to_set
    end
  end
end
