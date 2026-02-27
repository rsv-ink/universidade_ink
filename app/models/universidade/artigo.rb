module Universidade
  class Artigo < ApplicationRecord
    self.table_name = "universidade_artigos"

    belongs_to :trilha, class_name: "Universidade::Trilha", optional: true

    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :artigo_id, dependent: :destroy
    has_many :feedbacks, class_name: "Universidade::Feedback", foreign_key: :artigo_id, dependent: :destroy

    attribute :rascunho, :boolean, default: false

    validates :titulo, presence: true
    validates :user_id, presence: true
    validates :store_id, presence: true

    scope :visivel, -> { where(visivel: true) }
    scope :buscar, ->(q) { where("lower(titulo) LIKE lower(?)", "%#{q}%") }

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

    # Retorna a fração de artigos concluídos na trilha deste artigo (0.0 a 1.0).
    # Retorna 0.0 se o artigo não pertencer a nenhuma trilha.
    def progresso_trilha(user_id, store_id)
      return 0.0 unless trilha_id.present?
      return 0.0 unless user_id && store_id

      total = trilha.artigos.visivel.count
      return 0.0 if total.zero?

      concluidos = trilha.artigos.visivel
                         .joins(:progressos)
                         .where(universidade_progressos: { user_id: user_id, store_id: store_id })
                         .where.not(universidade_progressos: { concluido_em: nil })
                         .count

      concluidos.to_f / total
    end
  end
end
