module Universidade
  class CursosController < ApplicationController
    def show
      @curso = Curso.visivel.find(params[:id])

      # Módulos visíveis com suas trilhas visíveis pré-carregadas
      @modulos = @curso.modulos
                       .visivel
                       .includes(:trilhas)
                       .order(Arel.sql("COALESCE(universidade_modulos.ordem, universidade_modulos.id)"))
    end
  end
end
