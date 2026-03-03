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
        @trilhas  = Trilha.order(:nome)
        @conteudos = Conteudo.order(:titulo)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/secoes/form",
              locals: { secao: @secao, trilhas: @trilhas, conteudos: @conteudos, url: admin_secoes_path }
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
          sync_new_imagens_links(@secao)
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
          @trilhas  = Trilha.order(:nome)
          @conteudos = Conteudo.order(:titulo)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/secoes/form",
                locals: { secao: @secao, trilhas: @trilhas, conteudos: @conteudos, url: admin_secoes_path }
              ), status: :unprocessable_entity
            end
          end
        end
      end

      def edit
        @trilhas  = Trilha.order(:nome)
        @conteudos = Conteudo.order(:titulo)
        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: turbo_stream.update(
              "modal-content",
              partial: "universidade/admin/secoes/form",
              locals: { secao: @secao, trilhas: @trilhas, conteudos: @conteudos, url: admin_secao_path(@secao) }
            )
          end
        end
      end

      def update
        attach_imagens(@secao)
        if @secao.update(secao_params)
          sync_itens(@secao)
          sync_imagens_ordem(@secao)
          sync_new_imagens_links(@secao)
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
          @trilhas  = Trilha.order(:nome)
          @conteudos = Conteudo.order(:titulo)
          respond_to do |format|
            format.turbo_stream do
              render turbo_stream: turbo_stream.update(
                "modal-content",
                partial: "universidade/admin/secoes/form",
                locals: { secao: @secao, trilhas: @trilhas, conteudos: @conteudos, url: admin_secao_path(@secao) }
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
        params.require(:secao).permit(:titulo, :subtitulo, :tipo, :formato_card, :layout_exibicao, :colunas_galeria, :visivel, imagens_ordem: [], imagens_links: {}, new_imagens_links: []).merge(
          user_id: current_user_id || 1,
          store_id: current_store_id || 1
        )
      end

      def sync_itens(secao)
        trilha_ids  = Array(params.dig(:secao, :trilha_ids)).map(&:to_i).reject(&:zero?)
        conteudo_ids = Array(params.dig(:secao, :conteudo_ids)).map(&:to_i).reject(&:zero?)

        secao.secao_itens.destroy_all

        ordem = 0
        trilha_ids.each do |id|
          trilha = Trilha.find_by(id: id)
          next unless trilha
          ordem += 1
          secao.secao_itens.create!(
            item: trilha,
            ordem: ordem,
            user_id: current_user_id || 1,
            store_id: current_store_id || 1
          )
        end

        conteudo_ids.each do |id|
          conteudo = Conteudo.find_by(id: id)
          next unless conteudo
          ordem += 1
          secao.secao_itens.create!(
            item: conteudo,
            ordem: ordem,
            user_id: current_user_id || 1,
            store_id: current_store_id || 1
          )
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

        # Guardar quantas imagens existiam antes
        @imagens_antes = secao.imagens.count
        secao.imagens.attach(arquivos)
      end

      def sync_new_imagens_links(secao)
        # Pegar os links fornecidos para novas imagens
        new_links = Array(params.dig(:secao, :new_imagens_links)).compact.reject(&:blank?)
        return if new_links.empty?

        # Pegar as imagens recém-anexadas (baseado na ordem de adição)
        todas_imagens = secao.imagens.to_a
        novas_imagens = todas_imagens.last(new_links.size)

        # Criar/atualizar o hash de links
        current_links = secao.imagens_links || {}
        
        novas_imagens.each_with_index do |img, index|
          link = new_links[index]
          current_links[img.blob_id.to_s] = link if link.present?
        end

        secao.update_column(:imagens_links, current_links)
      end
    end
  end
end
