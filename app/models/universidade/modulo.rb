module Universidade
  class Modulo < ApplicationRecord
    self.table_name = "universidade_modulos"

    belongs_to :curso, class_name: "Universidade::Curso", optional: true

    has_many :trilhas, class_name: "Universidade::Trilha", foreign_key: :modulo_id, dependent: :nullify

    validates :nome, presence: true

    attribute :rascunho, :boolean, default: false

    scope :visivel, -> { where(visivel: true, rascunho: false) }
    scope :buscar, ->(q) { where("lower(nome) LIKE lower(:q) OR lower(COALESCE(descricao,'')) LIKE lower(:q)", q: "%#{q}%") }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Retorna a fração de trilhas concluídas pelo lojista (0.0 a 1.0).
    # Uma trilha é considerada concluída quando todos os seus artigos visíveis foram concluídos.
    def progresso(lojista_id)
      return 0.0 unless lojista_id
      
      trilhas_visiveis = trilhas.visivel
      total = trilhas_visiveis.count
      return 0.0 if total.zero?

      concluidas = trilhas_visiveis.count { |trilha| trilha.concluida?(lojista_id) }
      concluidas.to_f / total
    end
  end
end
