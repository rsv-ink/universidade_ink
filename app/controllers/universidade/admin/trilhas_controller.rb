module Universidade
  module Admin
    class TrilhasController < BaseController
      before_action :set_trilha, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @trilha = Trilha.new(visivel: true, modulo_id: params[:modulo_id])
        @from_curso_id = params[:from_curso_id]
        @modulos = Modulo.order(:nome)
        render layout: false if turbo_frame_request?
      end

      def create
        @trilha = Trilha.new(trilha_params)
        from_curso_id = params[:from_curso_id] || @trilha.modulo&.curso_id
        if @trilha.save
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Trilha criada com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @modulos = Modulo.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @from_curso_id = @trilha.modulo&.curso_id
        @modulos = Modulo.order(:nome)
        render layout: false if turbo_frame_request?
      end

      def update
        from_curso_id = @trilha.modulo&.curso_id
        if @trilha.update(trilha_params)
          from_curso_id = @trilha.modulo&.curso_id || from_curso_id
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Trilha atualizada com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @modulos = Modulo.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        from_curso_id = @trilha.modulo&.curso_id
        @trilha.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
          format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Trilha excluída com sucesso." }
        end
      end

      def toggle_visivel
        @trilha.update!(visivel: !@trilha.visivel)
        respond_to do |format|
          format.turbo_stream do
            # Choose partial based on context: inside module or standalone (avulsa)
            partial_name = @trilha.modulo_id.present? ? "hub_item" : "avulsa_item"
            render turbo_stream: turbo_stream.replace(
              "trilha_#{@trilha.id}",
              partial: "universidade/admin/trilhas/#{partial_name}",
              locals: { trilha: @trilha }
            )
          end
          from_curso_id = @trilha.modulo&.curso_id
          format.html { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path }
        end
      end

      def mover_acima
        scope = @trilha.modulo_id ? Trilha.where(modulo_id: @trilha.modulo_id) : Trilha.where(modulo_id: nil)
        trilhas = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = trilhas.find_index { |t| t.id == @trilha.id }
        if idx&.positive?
          trilhas[idx], trilhas[idx - 1] = trilhas[idx - 1], trilhas[idx]
          Trilha.transaction { trilhas.each_with_index { |t, i| t.update_column(:ordem, i + 1) } }
        end
        from_curso_id = @trilha.modulo&.curso_id
        redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path
      end

      def mover_abaixo
        scope = @trilha.modulo_id ? Trilha.where(modulo_id: @trilha.modulo_id) : Trilha.where(modulo_id: nil)
        trilhas = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = trilhas.find_index { |t| t.id == @trilha.id }
        if idx && idx < trilhas.length - 1
          trilhas[idx], trilhas[idx + 1] = trilhas[idx + 1], trilhas[idx]
          Trilha.transaction { trilhas.each_with_index { |t, i| t.update_column(:ordem, i + 1) } }
        end
        from_curso_id = @trilha.modulo&.curso_id
        redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Trilha.transaction do
          ids.each_with_index { |id, i| Trilha.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_trilha
        @trilha = Trilha.find(params[:id])
      end

      def trilha_params
        params.require(:trilha).permit(:nome, :tempo_estimado_minutos, :ordem, :visivel, :modulo_id)
      end
    end
  end
end
