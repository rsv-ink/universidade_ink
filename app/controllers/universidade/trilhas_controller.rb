module Universidade
  class TrilhasController < ApplicationController
    def show
      @trilha = Trilha.visivel.find(params[:id])

      # Módulos visíveis com seus conteúdos visíveis pré-carregados
      @modulos = @trilha.modulos
                        .visivel
                        .includes(:conteudos)
                        .order(Arel.sql("COALESCE(universidade_modulos.ordem, universidade_modulos.id)"))

      # Conteúdos soltos (trilha_id direto, sem módulo)
      @conteudos_soltos = @trilha.conteudos
                                  .where(modulo_id: nil)
                                  .visivel
                                  .order(Arel.sql("COALESCE(ordem, id)"))
    end
  end
end
