module Universidade
  module Admin
    class BaseController < ApplicationController
      layout "universidade/admin"
      before_action :set_sidebar_cursos

      private

      def set_sidebar_cursos
        @sidebar_cursos = Curso.order(Arel.sql("COALESCE(ordem, id)"))
      end

      # Re-renders the main panel + sidebar + closes modal via Turbo Streams.
      # curso_id: the course whose panel to display (nil → clears panel).
      def panel_stream_for(curso_id)
        # Reload sidebar after any CRUD changes
        sidebar_cursos = Curso.order(Arel.sql("COALESCE(ordem, id)"))

        streams = [turbo_stream.update("modal", "")]

        if curso_id.present? && (curso = Curso.find_by(id: curso_id.to_i))
          modulos = curso.modulos.order(Arel.sql("COALESCE(ordem, id)")).includes(:trilhas)

          streams << turbo_stream.update("main_panel",
            render_to_string(
              partial: "universidade/admin/cursos/panel",
              locals: { curso: curso, modulos: modulos }
            )
          )
          streams << turbo_stream.update("sidebar_cursos",
            render_to_string(
              partial: "universidade/admin/cursos/sidebar_list",
              locals: { cursos: sidebar_cursos, current_curso: curso }
            )
          )
        else
          streams << turbo_stream.update("main_panel", "")
          streams << turbo_stream.update("sidebar_cursos",
            render_to_string(
              partial: "universidade/admin/cursos/sidebar_list",
              locals: { cursos: sidebar_cursos, current_curso: nil }
            )
          )
        end

        streams
      end
    end
  end
end
