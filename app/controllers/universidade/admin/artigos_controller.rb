module Universidade
  module Admin
    class ArtigosController < BaseController
      before_action :set_artigo, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def new
        @artigo = Artigo.new(visivel: true, trilha_id: params[:trilha_id])
        @from_curso_id = params[:from_curso_id]
        @trilhas = Trilha.order(:nome)
      end

      def create
        @artigo = Artigo.new(artigo_params)
        from_curso_id = params[:from_curso_id] || @artigo.trilha&.modulo&.curso_id
        if @artigo.save
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Artigo criado com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @trilhas = Trilha.order(:nome)
          render :new, status: :unprocessable_entity
        end
      end

      def edit
        @from_curso_id = @artigo.trilha&.modulo&.curso_id
        @trilhas = Trilha.order(:nome)
      end

      def update
        from_curso_id = @artigo.trilha&.modulo&.curso_id
        if @artigo.update(artigo_params)
          from_curso_id = @artigo.trilha&.modulo&.curso_id || from_curso_id
          respond_to do |format|
            format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
            format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Artigo atualizado com sucesso." }
          end
        else
          @from_curso_id = from_curso_id
          @trilhas = Trilha.order(:nome)
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        from_curso_id = @artigo.trilha&.modulo&.curso_id
        @artigo.destroy
        respond_to do |format|
          format.turbo_stream { render turbo_stream: panel_stream_for(from_curso_id) }
          format.html         { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path, notice: "Artigo excluído com sucesso." }
        end
      end

      def toggle_visivel
        @artigo.update!(visivel: !@artigo.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "artigo_#{@artigo.id}",
              partial: "universidade/admin/artigos/avulso_item",
              locals: { artigo: @artigo }
            )
          end
          from_curso_id = @artigo.trilha&.modulo&.curso_id
          format.html { redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path }
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
        from_curso_id = @artigo.trilha&.modulo&.curso_id
        redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path
      end

      def mover_abaixo
        scope = @artigo.trilha_id ? Artigo.where(trilha_id: @artigo.trilha_id) : Artigo.where(trilha_id: nil)
        artigos = scope.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = artigos.find_index { |a| a.id == @artigo.id }
        if idx && idx < artigos.length - 1
          artigos[idx], artigos[idx + 1] = artigos[idx + 1], artigos[idx]
          Artigo.transaction { artigos.each_with_index { |a, i| a.update_column(:ordem, i + 1) } }
        end
        from_curso_id = @artigo.trilha&.modulo&.curso_id
        redirect_to from_curso_id.present? ? admin_curso_path(from_curso_id) : admin_root_path
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
    end
  end
end
