module Universidade
  class Trilha < ApplicationRecord
    self.table_name = "universidade_trilhas"

    belongs_to :modulo, class_name: "Universidade::Modulo", optional: true

    has_many :artigos, class_name: "Universidade::Artigo", foreign_key: :trilha_id, dependent: :nullify
    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :trilha_id, dependent: :destroy

    validates :nome, presence: true

    attribute :rascunho, :boolean, default: false

    scope :visivel, -> { where(visivel: true, rascunho: false) }
    scope :buscar, ->(q) { where("lower(nome) LIKE lower(?)", "%#{q}%") }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Slug humanizado para URLs amigáveis (ex: "1-introducao-ao-ruby").
    def to_param
      "#{id}-#{nome.parameterize}"
    end

    # Retorna a fração de artigos visíveis concluídos pelo lojista nesta trilha (0.0 a 1.0).
    def progresso_lojista(lojista_id)
      return 0.0 unless lojista_id

      total = artigos.visivel.count
      return 0.0 if total.zero?

      concluidos = artigos.visivel
                          .joins(:progressos)
                          .where(universidade_progressos: { lojista_id: lojista_id })
                          .where.not(universidade_progressos: { concluido_em: nil })
                          .count

      concluidos.to_f / total
    end

    # Retorna true se todos os artigos visíveis da trilha foram concluídos pelo lojista.
    def concluida?(lojista_id)
      total = artigos.visivel.count
      return false if total.zero?

      concluidos = artigos.visivel
                          .joins(:progressos)
                          .where(universidade_progressos: { lojista_id: lojista_id })
                          .where.not(universidade_progressos: { concluido_em: nil })
                          .count

      concluidos == total
    end
  end
end
