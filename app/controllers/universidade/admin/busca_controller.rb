module Universidade
  module Admin
    class BuscaController < BaseController
      def index
        @q = params[:q].to_s.strip
        return if @q.blank?

        @cursos  = Curso.buscar(@q).order(Arel.sql("COALESCE(ordem, id)"))
        @modulos = Modulo.buscar(@q).includes(:curso).order(Arel.sql("COALESCE(ordem, id)"))
        @trilhas = Trilha.buscar(@q).includes(modulo: :curso).order(Arel.sql("COALESCE(ordem, id)"))
        @artigos = Artigo.buscar(@q).includes(trilha: { modulo: :curso }).order(Arel.sql("COALESCE(ordem, id)"))
      end
    end
  end
end
