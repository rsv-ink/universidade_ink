module Universidade
  module Admin
    class CursosController < BaseController
      before_action :set_curso,         only: %i[show edit update destroy toggle_visivel mover_acima mover_abaixo]
      before_action :set_current_curso, only: %i[show]

      def index
        @current_curso = nil
      end

      def show
        @modulos = @curso.modulos.order(Arel.sql("COALESCE(ordem, id)")).includes(:trilhas)
      end

      def new
        @curso = Curso.new(visivel: true)
        render layout: false if turbo_frame_request?
      end

      def create
        @curso = Curso.new(curso_params)
        if @curso.save
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(@curso.id) }
            format.html         { redirect_to admin_curso_path(@curso), notice: "Curso criado com sucesso." }
          end
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        render layout: false if turbo_frame_request?
      end

      def update
        if @curso.update(curso_params)
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(@curso.id) }
            format.html         { redirect_to admin_curso_path(@curso), notice: "Curso atualizado com sucesso." }
          end
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        nome = @curso.nome
        @curso.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: panel_stream_for(nil) }
          format.html         { redirect_to admin_root_path, notice: "\"#{nome}\" excluído com sucesso." }
        end
      end

      def toggle_visivel
        @curso.update!(visivel: !@curso.visivel)
        respond_to do |format|
          format.turbo_stream do
            # The toggle is triggered from the panel, so @curso IS the current panel curso.
            render turbo_stream: turbo_stream.replace(
              "sidebar_curso_#{@curso.id}",
              partial: "universidade/admin/cursos/sidebar_item",
              locals: { curso: @curso, current_curso: @curso }
            )
          end
          format.html { redirect_to admin_curso_path(@curso) }
        end
      end

      def mover_acima
        cursos = Curso.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = cursos.find_index { |c| c.id == @curso.id }
        if idx&.positive?
          cursos[idx], cursos[idx - 1] = cursos[idx - 1], cursos[idx]
          Curso.transaction { cursos.each_with_index { |c, i| c.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_curso_path(@curso)
      end

      def mover_abaixo
        cursos = Curso.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = cursos.find_index { |c| c.id == @curso.id }
        if idx && idx < cursos.length - 1
          cursos[idx], cursos[idx + 1] = cursos[idx + 1], cursos[idx]
          Curso.transaction { cursos.each_with_index { |c, i| c.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_curso_path(@curso)
      end

      private

      def set_curso
        @curso = Curso.find(params[:id])
      end

      def set_current_curso
        @current_curso = @curso
      end

      def curso_params
        permitted = params.require(:curso).permit(:nome, :descricao, :ordem, :visivel, :tags_text)
        tags_text = permitted.delete(:tags_text)
        permitted[:tags] = tags_text.to_s.split(",").map(&:strip).reject(&:blank?)
        permitted
      end
    end
  end
end
