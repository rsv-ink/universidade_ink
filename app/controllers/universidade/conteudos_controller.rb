module Universidade
  class ConteudosController < ApplicationController
    before_action :set_conteudo
    before_action :set_trilha_context

    def show
      @progresso = progresso_atual
      @feedback  = Feedback.find_by(conteudo_id: @conteudo.id, user_id: universidade_current_user.id, store_id: universidade_current_user.store_id)

      # Conteúdos relacionados (excluindo os já concluídos pelo usuário)
      ids_concluidos = Progresso.where(user_id: universidade_current_user.id, store_id: universidade_current_user.store_id)
                                .where.not(concluido_em: nil)
                                .pluck(:conteudo_id)
      
      @conteudos_relacionados = @conteudo.conteudos_relacionados(3)
                                         .where.not(id: ids_concluidos)
      
      # SEO meta tags
      description = extract_description_from_content(@conteudo)
      set_meta_tags(
        title: @conteudo.titulo,
        description: description,
        image: extract_first_image_from_content(@conteudo),
        type: "article"
      )
    end

    # POST /conteudos/:id/concluir
    # Registra ou atualiza o Progresso do lojista para este conteúdo.
    def concluir
      unless @trilha
        redirect_to conteudo_path(@conteudo) and return
      end

      @progresso = Progresso.find_or_initialize_by(
        conteudo_id: @conteudo.id,
        user_id: universidade_current_user.id,
        store_id: universidade_current_user.store_id
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
      sentimento = params.dig(:feedback, :sentimento).to_s
      @feedback = Feedback.find_or_initialize_by(
        conteudo_id: @conteudo.id,
        user_id: universidade_current_user.id,
        store_id: universidade_current_user.store_id
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
        # Descobre o módulo do conteúdo atual (se houver)
        modulo_atual = @conteudo.modulo_em_trilha(@trilha)
        
        # Lista flat ordenada dos conteúdos relevantes
        if modulo_atual
          # Se está em um módulo, mostra apenas conteúdos do mesmo módulo
          @trilha_conteudos = @trilha.trilha_conteudos
                                     .joins(:conteudo)
                                     .where(modulo_id: modulo_atual.id)
                                     .where(universidade_conteudos: { visivel: true })
                                     .order(:posicao)
                                     .includes(:conteudo)
                                     .map(&:conteudo)
        else
          # Se não está em módulo, mostra apenas conteúdos sem módulo da mesma trilha
          @trilha_conteudos = @trilha.trilha_conteudos
                                     .joins(:conteudo)
                                     .where(modulo_id: nil)
                                     .where(universidade_conteudos: { visivel: true })
                                     .order(:posicao)
                                     .includes(:conteudo)
                                     .map(&:conteudo)
        end
        
        @concluidos_ids   = concluidos_ids_for(@trilha_conteudos)
        conteudo_idx      = @trilha_conteudos.find_index { |c| c.id == @conteudo.id }
        @conteudo_anterior = conteudo_idx&.positive? ? @trilha_conteudos[conteudo_idx - 1] : nil
        @proximo_conteudo  = conteudo_idx ? @trilha_conteudos[conteudo_idx + 1] : nil
      end
    end

    def progresso_atual
      Progresso.find_by(conteudo_id: @conteudo.id, user_id: universidade_current_user.id, store_id: universidade_current_user.store_id)
    end

    def concluidos_ids_for(conteudos)
      Progresso.where(
        conteudo_id: conteudos.map(&:id),
        user_id: universidade_current_user.id,
        store_id: universidade_current_user.store_id
      ).where.not(concluido_em: nil).pluck(:conteudo_id).to_set
    end

    def extract_description_from_content(conteudo)
      return "" if conteudo.corpo.blank?

      blocks = begin
        parsed = JSON.parse(conteudo.corpo)
        parsed.is_a?(Array) ? parsed : []
      rescue JSON::ParserError
        []
      end

      # Busca pelo primeiro bloco de texto
      text_block = blocks.find { |b| b["type"] == "texto" }
      if text_block && text_block["data"] && text_block["data"]["html"]
        return text_block["data"]["html"].gsub(/<[^>]*>/, "").strip
      end

      # Fallback para qualquer bloco com texto
      any_text = blocks.find { |b| b["data"] && b["data"]["text"] }
      any_text&.dig("data", "text") || ""
    end

    def extract_first_image_from_content(conteudo)
      return nil if conteudo.corpo.blank?

      blocks = begin
        parsed = JSON.parse(conteudo.corpo)
        parsed.is_a?(Array) ? parsed : []
      rescue JSON::ParserError
        []
      end

      image_block = blocks.find { |b| b["type"] == "imagem" }
      image_block&.dig("data", "url")
    end
  end
end
