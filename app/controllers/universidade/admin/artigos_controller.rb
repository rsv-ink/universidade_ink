module Universidade
  module Admin
    class ArtigosController < BaseController
      before_action :set_artigo, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @artigo = Artigo.new(visivel: true, trilha_id: params[:trilha_id])
        @trilhas = Trilha.order(:nome)
      end

      def create
        @artigo = Artigo.new(artigo_params)
        apply_status_action(@artigo)
        if @artigo.save
          redirect_to admin_root_path, notice: "Artigo criado com sucesso."
        else
          @trilhas = Trilha.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @trilhas = Trilha.order(:nome)
      end

      def update
        @artigo.assign_attributes(artigo_params)
        apply_status_action(@artigo)
        if @artigo.save
          redirect_to admin_root_path, notice: "Artigo atualizado com sucesso."
        else
          @trilhas = Trilha.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @artigo.destroy
        redirect_to admin_root_path, notice: "Artigo excluído com sucesso."
      end

      def toggle_visivel
        new_visivel = !@artigo.visivel?
        @artigo.update!(visivel: new_visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "artigo_#{@artigo.id}",
              partial: "universidade/admin/artigos/artigo_row",
              locals: { artigo: @artigo }
            )
          end
          format.html { redirect_to admin_root_path }
        end
      end

      def mover_acima
        scope = @artigo.trilha_id ? Artigo.where(trilha_id: @artigo.trilha_id) : Artigo.where(trilha_id: nil)
        artigos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = artigos.find_index { |a| a.id == @artigo.id }
        if idx&.positive?
          artigos[idx], artigos[idx - 1] = artigos[idx - 1], artigos[idx]
          Artigo.transaction { artigos.each_with_index { |a, i| a.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def mover_abaixo
        scope = @artigo.trilha_id ? Artigo.where(trilha_id: @artigo.trilha_id) : Artigo.where(trilha_id: nil)
        artigos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = artigos.find_index { |a| a.id == @artigo.id }
        if idx && idx < artigos.length - 1
          artigos[idx], artigos[idx + 1] = artigos[idx + 1], artigos[idx]
          Artigo.transaction { artigos.each_with_index { |a, i| a.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_root_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        trilha_id = params[:trilha_id].presence

        scope = trilha_id ? Artigo.where(trilha_id: trilha_id) : Artigo.where(trilha_id: nil)
        artigos = scope.where(id: ids)

        Artigo.transaction do
          ids.each_with_index do |id, i|
            next unless artigos.exists?(id: id)
            Artigo.where(id: id).update_all(ordem: i + 1)
          end
        end

        head :ok
      end

      private

      def set_artigo
        @artigo = Artigo.find(params[:id])
      end

      def artigo_params
        params.require(:artigo).permit(:titulo, :ordem, :tempo_estimado_minutos, :visivel, :trilha_id, :corpo)
      end

      def apply_status_action(artigo)
        actions = Array(params.dig(:artigo, :status_action)).map(&:to_s)
        action = if actions.include?("publicar")
                   "publicar"
                 elsif actions.include?("rascunho")
                   "rascunho"
                 else
                   ""
                 end
        case action
        when "rascunho"
          artigo.rascunho = true
          artigo.visivel = false
        when "publicar"
          artigo.rascunho = false
        end
      end
    end
  end
end
