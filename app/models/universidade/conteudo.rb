module Universidade
  class Conteudo < ApplicationRecord
    self.table_name = "universidade_conteudos"

    # Relação muitos-para-muitos com trilhas através de trilha_conteudos
    has_many :trilha_conteudos, class_name: "Universidade::TrilhaConteudo", foreign_key: :conteudo_id, dependent: :destroy
    has_many :trilhas, through: :trilha_conteudos, class_name: "Universidade::Trilha"

    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :conteudo_id, dependent: :destroy
    has_many :feedbacks, class_name: "Universidade::Feedback", foreign_key: :conteudo_id, dependent: :destroy

    # Taxonomia: categoria e tags
    belongs_to :categoria, class_name: "Universidade::Categoria", optional: true
    has_many :conteudo_tags, class_name: "Universidade::ConteudoTag", foreign_key: :conteudo_id, dependent: :destroy
    has_many :tags, through: :conteudo_tags, class_name: "Universidade::Tag"

    attribute :rascunho, :boolean, default: false

    validates :titulo, presence: true
    scope :por_categoria, ->(categoria_id) { where(categoria_id: categoria_id) if categoria_id.present? }
    scope :com_tag, ->(tag_id) { joins(:conteudo_tags).where(universidade_conteudo_tags: { tag_id: tag_id }) if tag_id.present? }
    scope :com_tags, ->(tag_ids) { joins(:conteudo_tags).where(universidade_conteudo_tags: { tag_id: tag_ids }).distinct if tag_ids.present? }
    validates :user_id, presence: true
    validates :store_id, presence: true

    scope :visivel, -> { where(visivel: true) }
    scope :buscar, ->(q) {
      left_joins(:tags)
        .where(
          "lower(universidade_conteudos.titulo) LIKE lower(:q) OR lower(COALESCE(universidade_tags.nome,'')) LIKE lower(:q)",
          q: "%#{q}%"
        )
        .distinct
    }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Slug humanizado para URLs amigáveis (ex: "1-introducao-ao-activerecord").
    def to_param
      "#{id}-#{titulo.parameterize}"
    end

    # Verifica se este conteúdo foi concluído pelo usuário
    def concluido?(user_id, store_id)
      return false unless user_id && store_id
      progressos.where(user_id: user_id, store_id: store_id).where.not(concluido_em: nil).exists?
    end

    # Retorna true se o conteúdo não está vinculado a nenhuma trilha
    def orfao?
      trilha_conteudos.empty?
    end

    # Retorna a trilha contexto (primeira trilha associada)
    def trilha_contexto
      trilhas.first
    end

    # Retorna a contagem de trilhas vinculadas
    def trilhas_count
      trilha_conteudos.count
    end

    # Retorna o módulo ao qual este conteúdo pertence em uma trilha específica
    def modulo_em_trilha(trilha)
      return nil unless trilha
      trilha_conteudos.find_by(trilha_id: trilha.id)&.modulo
    end

    # Retorna conteúdos relacionados baseados em categoria e tags compartilhadas
    def conteudos_relacionados(limit = 3)
      return self.class.none unless persisted?

      # Busca conteúdos com mesma categoria ou tags compartilhadas
      relacionados = self.class.where.not(id: id)
                               .where(visivel: true, rascunho: false)

      tag_ids = tags.pluck(:id).map(&:to_i)

      # Prioriza conteúdos com mesma categoria ou tags em comum
      if categoria_id.present? || tag_ids.any?
        relacionados = relacionados
          .left_joins(:conteudo_tags)
          .where(
            "universidade_conteudos.categoria_id = :categoria_id OR universidade_conteudo_tags.tag_id IN (:tag_ids)",
            categoria_id: categoria_id,
            tag_ids: tag_ids.presence || [-1]
          )
          .group("universidade_conteudos.id")
          .order(Arel.sql("COUNT(universidade_conteudo_tags.tag_id) DESC, universidade_conteudos.created_at DESC"))
      else
        relacionados = relacionados.order(created_at: :desc)
      end

      relacionados.limit(limit)
    end

    # Extrai texto completo do conteúdo (título + corpo parseado)
    def texto_completo
      texto = [titulo]
      
      if corpo.present?
        begin
          corpo_json = corpo.is_a?(String) ? JSON.parse(corpo) : corpo
          blocos = corpo_json.dig("blocks") || []
          
          blocos.each do |bloco|
            case bloco["type"]
            when "paragraph", "header"
              texto << bloco.dig("data", "text")
            when "list"
              items = bloco.dig("data", "items") || []
              texto.concat(items)
            end
          end
        rescue JSON::ParserError
          # Se não for JSON válido, ignora o corpo
        end
      end
      
      texto.compact.join(" ")
    end
  end
end
