module Universidade
  class HomeController < ApplicationController
    def index
      @secoes = Secao.visivel
                     .order(Arel.sql("COALESCE(ordem, id)"))
                     .includes(secao_itens: :item)

      # Fallback quando não há seções configuradas
      if @secoes.empty?
        @cursos = Curso.visivel.order(Arel.sql("COALESCE(ordem, id)"))

        @trilhas_soltas = Trilha.visivel
                                 .where(modulo_id: nil)
                                 .order(Arel.sql("COALESCE(ordem, id)"))

        @artigos_soltos = Artigo.visivel
                                 .where(trilha_id: nil)
                                 .order(Arel.sql("COALESCE(ordem, id)"))
      end
    end
  end
end
