module Universidade
  class BuscaController < ApplicationController
    def index
      @q = params[:q].to_s.strip
      return if @q.blank?

      @cursos  = Curso.visivel.buscar(@q).order(Arel.sql("COALESCE(ordem, id)"))
      @trilhas = Trilha.visivel.buscar(@q).includes(modulo: :curso).order(Arel.sql("COALESCE(ordem, id)"))
      @artigos = Artigo.visivel.buscar(@q).includes(trilha: { modulo: :curso }).order(Arel.sql("COALESCE(ordem, id)"))
    end
  end
end
