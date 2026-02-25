module Universidade
  module Admin
    class ModulosController < BaseController
      before_action :set_modulo, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @modulo = Modulo.new(visivel: true, curso_id: params[:curso_id])
        @from_curso_id = params[:from_curso_id] || params[:curso_id]
        @cursos = Curso.order(:nome)
        render layout: false if turbo_frame_request?
      end

      def create
        @modulo = Modulo.new(modulo_params)
        from_curso_id = params[:from_curso_id] || @modulo.curso_id
        if @modulo.save
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Módulo criado com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @cursos = Curso.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @from_curso_id = @modulo.curso_id
        @cursos = Curso.order(:nome)
        render layout: false if turbo_frame_request?
      end

      def update
        from_curso_id = @modulo.curso_id
        if @modulo.update(modulo_params)
          from_curso_id = @modulo.curso_id || from_curso_id
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Módulo atualizado com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @cursos = Curso.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        from_curso_id = @modulo.curso_id
        @modulo.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
          format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Módulo excluído com sucesso." }
        end
      end

      def toggle_visivel
        @modulo.update!(visivel: !@modulo.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "modulo_#{@modulo.id}",
              partial: "universidade/admin/modulos/accordion_item",
              locals: {
                modulo: @modulo,
                trilhas: @modulo.trilhas.order(Arel.sql("COALESCE(ordem, id)")),
                curso: @modulo.curso
              }
            )
          end
          format.html { redirect_to @modulo.curso_id ? admin_curso_path(@modulo.curso_id) : admin_root_path }
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
        redirect_to @modulo.curso_id ? admin_curso_path(@modulo.curso_id) : admin_root_path
      end

      def mover_abaixo
        scope = @modulo.curso_id ? Modulo.where(curso_id: @modulo.curso_id) : Modulo.where(curso_id: nil)
        modulos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = modulos.find_index { |m| m.id == @modulo.id }
        if idx && idx < modulos.length - 1
          modulos[idx], modulos[idx + 1] = modulos[idx + 1], modulos[idx]
          Modulo.transaction { modulos.each_with_index { |m, i| m.update_column(:ordem, i + 1) } }
        end
        redirect_to @modulo.curso_id ? admin_curso_path(@modulo.curso_id) : admin_root_path
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
    end
  end
end
