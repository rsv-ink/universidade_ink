module Universidade
  module Admin
    class SecoesController < BaseController
      before_action :set_secao, only: %i[edit update destroy toggle_visivel mover_acima mover_abaixo]

      def index
        @secoes = Secao.order(Arel.sql("COALESCE(ordem, id)"))
                       .includes(secao_itens: :item)
      end

      def new
        @secao = Secao.new(visivel: true, tipo: "conteudo", formato_card: "quadrado", layout_exibicao: "galeria", colunas_galeria: 3)
        @cursos  = Curso.order(:nome)
        @artigos = Artigo.order(:titulo)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/secoes/form",
              locals: { secao: @secao, cursos: @cursos, artigos: @artigos, url: admin_secoes_path }
            )
          end
        end
      end

      def create
        @secao = Secao.new(secao_params)
        attach_imagens(@secao)
        if @secao.save
          sync_itens(@secao)
          sync_imagens_ordem(@secao)
          respond_to do |format|
            format.turbo_stream do
              streams = [
                turbo_stream.update("modal-content", ""),
                turbo_stream.prepend("secoes_lista", 
                  partial: "universidade/admin/secoes/secao",
                  locals: { secao: @secao }
                )
              ]
              # Remove empty state se existir
              if Secao.count == 1
                streams << turbo_stream.remove("secoes_empty_state")
              end
              render turbo_stream: streams
            end
          end
        else
          @cursos  = Curso.order(:nome)
          @artigos = Artigo.order(:titulo)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/secoes/form",
                locals: { secao: @secao, cursos: @cursos, artigos: @artigos, url: admin_secoes_path }
              ), status: :unprocessable_entity
            end
          end
        end
      end

      def edit
        @cursos  = Curso.order(:nome)
        @artigos = Artigo.order(:titulo)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/secoes/form",
              locals: { secao: @secao, cursos: @cursos, artigos: @artigos, url: admin_secao_path(@secao) }
            )
          end
        end
      end

      def update
        attach_imagens(@secao)
        if @secao.update(secao_params)
          sync_itens(@secao)
          sync_imagens_ordem(@secao)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: [
                turbo_stream.update("modal-content", ""),
                turbo_stream.replace(
                  "secao_#{@secao.id}",
                  partial: "universidade/admin/secoes/secao",
                  locals: { secao: @secao }
                )
              ]
            end
          end
        else
          @cursos  = Curso.order(:nome)
          @artigos = Artigo.order(:titulo)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/secoes/form",
                locals: { secao: @secao, cursos: @cursos, artigos: @artigos, url: admin_secao_path(@secao) }
              ), status: :unprocessable_entity
            end
          end
        end
      end

      def destroy
        titulo = @secao.titulo
        @secao.destroy
        redirect_to admin_secoes_path, notice: "\"#{titulo}\" excluída com sucesso."
      end

      def toggle_visivel
        @secao.update!(visivel: !@secao.visivel)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "secao_#{@secao.id}",
              partial: "universidade/admin/secoes/secao",
              locals: { secao: @secao }
            )
          end
          format.html { redirect_to admin_secoes_path }
        end
      end

      def mover_acima
        secoes = Secao.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = secoes.find_index { |s| s.id == @secao.id }
        if idx&.positive?
          secoes[idx], secoes[idx - 1] = secoes[idx - 1], secoes[idx]
          Secao.transaction { secoes.each_with_index { |s, i| s.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_secoes_path
      end

      def mover_abaixo
        secoes = Secao.order(Arel.sql("COALESCE(ordem, id)")).to_a
        idx = secoes.find_index { |s| s.id == @secao.id }
        if idx && idx < secoes.length - 1
          secoes[idx], secoes[idx + 1] = secoes[idx + 1], secoes[idx]
          Secao.transaction { secoes.each_with_index { |s, i| s.update_column(:ordem, i + 1) } }
        end
        redirect_to admin_secoes_path
      end

      def reorder
        ids = Array(params[:ids]).map(&:to_i)
        Secao.transaction do
          ids.each_with_index { |id, i| Secao.where(id: id).update_all(ordem: i + 1) }
        end
        head :ok
      end

      private

      def set_secao
        @secao = Secao.includes(:secao_itens).find(params[:id])
      end

      def secao_params
        params.require(:secao).permit(:titulo, :subtitulo, :tipo, :formato_card, :layout_exibicao, :colunas_galeria, :visivel, imagens_ordem: [], imagens_links: {})
      end

      def sync_itens(secao)
        curso_ids  = Array(params.dig(:secao, :curso_ids)).map(&:to_i).reject(&:zero?)
        artigo_ids = Array(params.dig(:secao, :artigo_ids)).map(&:to_i).reject(&:zero?)

        secao.secao_itens.destroy_all

        ordem = 0
        curso_ids.each do |id|
          curso = Curso.find_by(id: id)
          next unless curso
          ordem += 1
          secao.secao_itens.create!(item: curso, ordem: ordem)
        end

        artigo_ids.each do |id|
          artigo = Artigo.find_by(id: id)
          next unless artigo
          ordem += 1
          secao.secao_itens.create!(item: artigo, ordem: ordem)
        end
      end

      def sync_imagens_ordem(secao)
        ordem = Array(params.dig(:secao, :imagens_ordem)).map(&:to_s)
        anexos = secao.imagens.map { |img| img.blob_id.to_s }
        ordem = ordem.select { |id| anexos.include?(id) }
        ordem += (anexos - ordem)
        secao.update_column(:imagens_ordem, ordem)
      end

      def attach_imagens(secao)
        arquivos = Array(params.dig(:secao, :imagens)).compact
        return if arquivos.empty?

        secao.imagens.attach(arquivos)
      end
    end
  end
end
