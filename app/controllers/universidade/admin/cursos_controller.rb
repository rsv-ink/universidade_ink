module Universidade
  module Admin
    class CursosController < BaseController
      before_action :set_curso, only: %i[show edit update destroy toggle_visivel mover_acima mover_abaixo]

      def index
        @cursos = Curso.order(Arel.sql("COALESCE(ordem, id)"))
                       .includes(modulos: { trilhas: :artigos })
        @modulos_avulsos = Modulo.where(curso_id: nil)
                                 .order(Arel.sql("COALESCE(ordem, id)"))
                                 .includes(trilhas: :artigos)
        @trilhas_avulsas = Trilha.where(modulo_id: nil)
                                 .order(Arel.sql("COALESCE(ordem, id)"))
                                 .includes(:artigos)
        @artigos_avulsos = Artigo.where(trilha_id: nil)
                                 .order(Arel.sql("COALESCE(ordem, id)"))
      end

      def show
        redirect_to admin_root_path
      end

      def new
        @curso = Curso.new(visivel: true)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @curso = Curso.new(curso_params)
        apply_status_action(@curso)
        if @curso.save
          redirect_to admin_root_path, notice: "Curso criado com sucesso."
        else
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def update
        @curso.assign_attributes(curso_params)
        apply_status_action(@curso)
        if @curso.save
          redirect_to admin_root_path, notice: "Curso atualizado com sucesso."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        nome = @curso.nome
        @curso.destroy
        redirect_to admin_root_path, notice: "\"#{nome}\" excluído com sucesso."
      end

      def toggle_visivel
        @curso.update!(visivel: !@curso.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "curso_#{@curso.id}",
              partial: "universidade/admin/cursos/curso",
              locals: { curso: @curso }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        cursos = Curso.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = cursos.find_index { |c| c.id == @curso.id }
        if idx&.positive?
          cursos[idx], cursos[idx - 1] = cursos[idx - 1], cursos[idx]
          Curso.transaction { cursos.each_with_index { |c, i| c.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        cursos = Curso.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = cursos.find_index { |c| c.id == @curso.id }
        if idx && idx < cursos.length - 1
          cursos[idx], cursos[idx + 1] = cursos[idx + 1], cursos[idx]
          Curso.transaction { cursos.each_with_index { |c, i| c.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Curso.transaction do
          ids.each_with_index { |id, i| Curso.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_curso
        @curso = Curso.find(params[:id])
      end

      def curso_params
        permitted = params.require(:curso).permit(:nome, :descricao, :ordem, :visivel, :tags_text, :imagem)
        tags_text = permitted.delete(:tags_text)
        tags_array = tags_text.to_s.split(",").map(&:strip).reject(&:blank?)
        permitted.to_h.merge(tags: tags_array)
      end

      def apply_status_action(curso)
        actions = Array(params.dig(:curso, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          curso.rascunho = true
        when "publicar"
          curso.rascunho = false
        end
      end
    end
  end
end
