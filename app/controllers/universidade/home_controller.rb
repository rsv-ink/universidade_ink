module Universidade
  class HomeController < ApplicationController
    def index
      @cursos = Curso.visivel.order(Arel.sql("COALESCE(ordem, id)"))

      # Trilhas soltas: visíveis e sem módulo pai
      @trilhas_soltas = Trilha.visivel
                               .where(modulo_id: nil)
                               .order(Arel.sql("COALESCE(ordem, id)"))

      # Artigos soltos: visíveis e sem trilha pai
      @artigos_soltos = Artigo.visivel
                               .where(trilha_id: nil)
                               .order(Arel.sql("COALESCE(ordem, id)"))
    end
  end
end
