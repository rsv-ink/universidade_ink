module Universidade
  class ConteudosController < ApplicationController
    before_action :set_conteudo
    before_action :set_trilha_context

    def show
      @progresso = progresso_atual
      @feedback  = (current_user_id && current_store_id) ? Feedback.find_by(conteudo_id: @conteudo.id, user_id: current_user_id, store_id: current_store_id) : nil
    end

    # POST /conteudos/:id/concluir
    # Registra ou atualiza o Progresso do lojista para este conteúdo.
    def concluir
      unless current_user_id && current_store_id && @trilha
        redirect_to conteudo_path(@conteudo) and return
      end

      @progresso = Progresso.find_or_initialize_by(
        conteudo_id: @conteudo.id,
        user_id: current_user_id,
        store_id: current_store_id
      )
      @progresso.trilha_id   = @trilha.id
      @progresso.concluido_em = Time.current
      @progresso.save!

      # Se houver um parâmetro redirect_to, redirecionar para lá
      redirect_url = params[:redirect_to].presence || conteudo_path(@conteudo)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to redirect_url }
      end
    end

    # POST /conteudos/:id/feedback
    # Registra ou atualiza o feedback do lojista para este conteúdo.
    def feedback
      unless current_user_id && current_store_id
        redirect_to conteudo_path(@conteudo), alert: "É necessário estar logado para votar." and return
      end

      sentimento = params.dig(:feedback, :sentimento).to_s
      @feedback = Feedback.find_or_initialize_by(
        conteudo_id: @conteudo.id,
        user_id: current_user_id,
        store_id: current_store_id
      )
      @feedback.sentimento = sentimento

      if @feedback.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to conteudo_path(@conteudo) }
        end
      else
        redirect_to conteudo_path(@conteudo), alert: "Feedback inválido."
      end
    end

    private

    def set_conteudo
      @conteudo = Conteudo.visivel.find(params[:id])
    end

    def set_trilha_context
      # Encontra a trilha-mãe (via módulo ou direta)
      @trilha = @conteudo.trilha_contexto
      @trilha = nil unless @trilha&.visivel?

      if @trilha
        # Lista flat ordenada de todos os conteúdos da trilha
        @trilha_conteudos = @trilha.conteudos_ordenados
        @concluidos_ids   = concluidos_ids_for(@trilha_conteudos)
        conteudo_idx      = @trilha_conteudos.find_index { |c| c.id == @conteudo.id }
        @conteudo_anterior = conteudo_idx&.positive? ? @trilha_conteudos[conteudo_idx - 1] : nil
        @proximo_conteudo  = conteudo_idx ? @trilha_conteudos[conteudo_idx + 1] : nil
      end
    end

    def progresso_atual
      return nil unless current_user_id && current_store_id
      Progresso.find_by(conteudo_id: @conteudo.id, user_id: current_user_id, store_id: current_store_id)
    end

    def concluidos_ids_for(conteudos)
      return Set.new unless current_user_id && current_store_id

      Progresso.where(
        conteudo_id: conteudos.map(&:id),
        user_id: current_user_id,
        store_id: current_store_id
      ).where.not(concluido_em: nil).pluck(:conteudo_id).to_set
    end
  end
end
