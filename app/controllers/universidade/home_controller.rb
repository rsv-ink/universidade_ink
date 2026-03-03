module Universidade
  class HomeController < ApplicationController
    def index
      @secoes = Secao.visivel
                     .order(Arel.sql("COALESCE(ordem, id)"))
                     .includes(secao_itens: :item)

      # Fallback quando não há seções configuradas
      if @secoes.empty?
        @trilhas = Trilha.visivel.order(Arel.sql("COALESCE(ordem, id)"))

        # Conteúdos soltos são aqueles que não estão vinculados a nenhuma trilha
        @conteudos_soltos = Conteudo.visivel
                                     .left_joins(:trilha_conteudos)
                                     .where(universidade_trilha_conteudos: { id: nil })
                                     .order(Arel.sql("COALESCE(universidade_conteudos.ordem, universidade_conteudos.id)"))
      end
    end
  end
end
