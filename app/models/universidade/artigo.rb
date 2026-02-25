module Universidade
  class Artigo < ApplicationRecord
    self.table_name = "universidade_artigos"

    belongs_to :trilha, class_name: "Universidade::Trilha", optional: true

    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :artigo_id, dependent: :destroy
    has_many :comentarios, class_name: "Universidade::Comentario", foreign_key: :artigo_id, dependent: :destroy

    validates :titulo, presence: true

    scope :visivel, -> { where(visivel: true) }

    # Slug humanizado para URLs amigáveis (ex: "1-introducao-ao-activerecord").
    def to_param
      "#{id}-#{titulo.parameterize}"
    end

    # Retorna a fração de artigos concluídos na trilha deste artigo (0.0 a 1.0).
    # Retorna 0.0 se o artigo não pertencer a nenhuma trilha.
    def progresso_trilha(lojista_id)
      return 0.0 unless trilha_id.present?

      total = trilha.artigos.visivel.count
      return 0.0 if total.zero?

      concluidos = trilha.artigos.visivel
                         .joins(:progressos)
                         .where(universidade_progressos: { lojista_id: lojista_id })
                         .where.not(universidade_progressos: { concluido_em: nil })
                         .count

      concluidos.to_f / total
    end
  end
end
