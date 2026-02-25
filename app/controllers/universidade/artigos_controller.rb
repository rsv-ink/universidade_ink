module Universidade
  class ArtigosController < ApplicationController
    before_action :set_artigo
    before_action :set_trilha_context

    def show
      @comentarios = @artigo.comentarios.order(created_at: :asc)
      @progresso   = progresso_atual
    end

    # POST /artigos/:id/concluir
    # Registra ou atualiza o Progresso do lojista para este artigo.
    def concluir
      unless current_lojista_id && @trilha
        redirect_to artigo_path(@artigo) and return
      end

      @progresso = Progresso.find_or_initialize_by(
        artigo_id:  @artigo.id,
        lojista_id: current_lojista_id
      )
      @progresso.trilha_id   = @trilha.id
      @progresso.concluido_em = Time.current
      @progresso.save!

      # Se houver um parâmetro redirect_to, redirecionar para lá
      redirect_url = params[:redirect_to].presence || artigo_path(@artigo)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirect_url }
      end
    end

    # POST /artigos/:id/comentar
    # Cria um novo comentário no artigo.
    def comentar
      unless current_lojista_id
        redirect_to artigo_path(@artigo), alert: "É necessário estar logado para comentar." and return
      end

      @comentario = Comentario.new(
        artigo:     @artigo,
        lojista_id: current_lojista_id,
        corpo:      params.dig(:comentario, :corpo).to_s.strip
      )

      if @comentario.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to artigo_path(@artigo) }
        end
      else
        redirect_to artigo_path(@artigo), alert: "O comentário não pode ser vazio."
      end
    end

    private

    def set_artigo
      @artigo = Artigo.visivel.find(params[:id])
    end

    def set_trilha_context
      @trilha = @artigo.trilha&.visivel? ? @artigo.trilha : nil

      if @trilha
        @trilha_artigos  = @trilha.artigos.visivel.order(Arel.sql("COALESCE(ordem, id)")).to_a
        @concluidos_ids  = concluidos_ids_for(@trilha_artigos)
        artigo_idx       = @trilha_artigos.find_index { |a| a.id == @artigo.id }
        @artigo_anterior = artigo_idx&.positive? ? @trilha_artigos[artigo_idx - 1] : nil
        @proximo_artigo  = artigo_idx ? @trilha_artigos[artigo_idx + 1] : nil
      end
    end

    def progresso_atual
      return nil unless current_lojista_id
      Progresso.find_by(artigo_id: @artigo.id, lojista_id: current_lojista_id)
    end

    def concluidos_ids_for(artigos)
      return Set.new unless current_lojista_id

      Progresso.where(
        artigo_id:  artigos.map(&:id),
        lojista_id: current_lojista_id
      ).where.not(concluido_em: nil).pluck(:artigo_id).to_set
    end
  end
end
