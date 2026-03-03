module Universidade
  class BuscaController < ApplicationController
    def index
      @q = params[:q].to_s.strip
      return if @q.blank?

      @trilhas  = Trilha.visivel.buscar(@q).order(Arel.sql("COALESCE(ordem, id)"))
      @modulos  = Modulo.visivel.buscar(@q).includes(:trilha).order(Arel.sql("COALESCE(ordem, id)"))
      @conteudos = Conteudo.visivel.buscar(@q).includes(modulo: :trilha).order(Arel.sql("COALESCE(ordem, id)"))
    end
  end
end
