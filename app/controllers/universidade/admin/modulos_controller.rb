module Universidade
  module Admin
    class ModulosController < BaseController
      before_action :set_modulo, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @modulo = Modulo.new(visivel: true, curso_id: params[:curso_id])
        @cursos = Curso.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @modulo = Modulo.new(modulo_params)
        apply_status_action(@modulo)
        if @modulo.save
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Módulo criado com sucesso." }
          end
        else
          @cursos = Curso.order(:nome)
          respond_to do |format|
            format.turbo_stream do
              html = render_to_string(:new, formats: [:html], layout: false)
              render turbo_stream: turbo_stream.replace("modal-content", html), status: :unprocessable_entity
            end
            format.html { render :new, status: :unprocessable_entity }
          end
        end
      end

      def edit
        @cursos = Curso.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def update
        @modulo.assign_attributes(modulo_params)
        apply_status_action(@modulo)
        if @modulo.save
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.replace("modal-content", "")
            end
            format.html { redirect_to admin_root_path, notice: "Módulo atualizado com sucesso." }
          end
        else
          @cursos = Curso.order(:nome)
          respond_to do |format|
            format.turbo_stream do
              html = render_to_string(:edit, formats: [:html], layout: false)
              render turbo_stream: turbo_stream.replace("modal-content", html), status: :unprocessable_entity
            end
            format.html { render :edit, status: :unprocessable_entity }
          end
        end
      end

      def destroy
        @modulo.destroy
        redirect_to admin_root_path, notice: "Módulo excluído com sucesso."
      end

      def toggle_visivel
        @modulo.update!(visivel: !@modulo.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "modulo_#{@modulo.id}",
              partial: "universidade/admin/modulos/modulo_row",
              locals: { modulo: @modulo }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        scope = @modulo.curso_id ? Modulo.where(curso_id: @modulo.curso_id) : Modulo.where(curso_id: nil)
        modulos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = modulos.find_index { |m| m.id == @modulo.id }
        if idx&.positive?
          modulos[idx], modulos[idx - 1] = modulos[idx - 1], modulos[idx]
          Modulo.transaction { modulos.each_with_index { |m, i| m.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        scope = @modulo.curso_id ? Modulo.where(curso_id: @modulo.curso_id) : Modulo.where(curso_id: nil)
        modulos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = modulos.find_index { |m| m.id == @modulo.id }
        if idx && idx < modulos.length - 1
          modulos[idx], modulos[idx + 1] = modulos[idx + 1], modulos[idx]
          Modulo.transaction { modulos.each_with_index { |m, i| m.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Modulo.transaction do
          ids.each_with_index { |id, i| Modulo.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_modulo
        @modulo = Modulo.find(params[:id])
      end

      def modulo_params
        params.require(:modulo).permit(:nome, :descricao, :ordem, :visivel, :curso_id)
      end

      def apply_status_action(modulo)
        actions = Array(params.dig(:modulo, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          modulo.rascunho = true
        when "publicar"
          modulo.rascunho = false
        end
      end
    end
  end
end
