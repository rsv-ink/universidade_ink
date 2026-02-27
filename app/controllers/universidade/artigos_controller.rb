module Universidade
  class ArtigosController < ApplicationController
    before_action :set_artigo
    before_action :set_trilha_context

    def show
        @progresso = progresso_atual
        @feedback  = (current_user_id && current_store_id) ? Feedback.find_by(artigo_id: @artigo.id, user_id: current_user_id, store_id: current_store_id) : nil
    end

    # POST /artigos/:id/concluir
    # Registra ou atualiza o Progresso do lojista para este artigo.
    def concluir
      unless current_user_id && current_store_id && @trilha
        redirect_to artigo_path(@artigo) and return
      end

      @progresso = Progresso.find_or_initialize_by(
        artigo_id: @artigo.id,
        user_id: current_user_id,
        store_id: current_store_id
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

    # POST /artigos/:id/feedback
    # Registra ou atualiza o feedback do lojista para este artigo.
    def feedback
      unless current_user_id && current_store_id
        redirect_to artigo_path(@artigo), alert: "É necessário estar logado para votar." and return
      end

      sentimento = params.dig(:feedback, :sentimento).to_s
      @feedback = Feedback.find_or_initialize_by(
        artigo_id: @artigo.id,
        user_id: current_user_id,
        store_id: current_store_id
      )
      @feedback.sentimento = sentimento

      if @feedback.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to artigo_path(@artigo) }
        end
      else
        redirect_to artigo_path(@artigo), alert: "Feedback inválido."
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
      return nil unless current_user_id && current_store_id
      Progresso.find_by(artigo_id: @artigo.id, user_id: current_user_id, store_id: current_store_id)
    end

    def concluidos_ids_for(artigos)
      return Set.new unless current_user_id && current_store_id

      Progresso.where(
        artigo_id: artigos.map(&:id),
        user_id: current_user_id,
        store_id: current_store_id
      ).where.not(concluido_em: nil).pluck(:artigo_id).to_set
    end
  end
end
