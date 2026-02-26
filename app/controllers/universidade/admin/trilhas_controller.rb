module Universidade
  module Admin
    class TrilhasController < BaseController
      before_action :set_trilha, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @trilha = Trilha.new(visivel: true, modulo_id: params[:modulo_id])
        @modulos = Modulo.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def create
        @trilha = Trilha.new(trilha_params)
        apply_status_action(@trilha)
        if @trilha.save
          redirect_to admin_root_path, notice: "Trilha criada com sucesso."
        else
          @modulos = Modulo.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @modulos = Modulo.order(:nome)
        render layout: false if turbo_frame_request? || request.xhr?
      end

      def update
        @trilha.assign_attributes(trilha_params)
        apply_status_action(@trilha)
        if @trilha.save
          redirect_to admin_root_path, notice: "Trilha atualizada com sucesso."
        else
          @modulos = Modulo.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @trilha.destroy
        redirect_to admin_root_path, notice: "Trilha excluída com sucesso."
      end

      def toggle_visivel
        @trilha.update!(visivel: !@trilha.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "trilha_#{@trilha.id}",
              partial: "universidade/admin/trilhas/trilha_row",
              locals: { trilha: @trilha }
            )
          end
          format.html { redirect_to admin_root_path }
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
        redirect_to admin_root_path
      end

      def mover_abaixo
        scope = @trilha.modulo_id ? Trilha.where(modulo_id: @trilha.modulo_id) : Trilha.where(modulo_id: nil)
        trilhas = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = trilhas.find_index { |t| t.id == @trilha.id }
        if idx && idx < trilhas.length - 1
          trilhas[idx], trilhas[idx + 1] = trilhas[idx + 1], trilhas[idx]
          Trilha.transaction { trilhas.each_with_index { |t, i| t.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
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

      def apply_status_action(trilha)
        actions = Array(params.dig(:trilha, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          trilha.rascunho = true
        when "publicar"
          trilha.rascunho = false
        end
      end
    end
  end
end
