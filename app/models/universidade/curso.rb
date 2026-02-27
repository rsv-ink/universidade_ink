module Universidade
  class Curso < ApplicationRecord
    self.table_name = "universidade_cursos"

    has_one_attached :imagem
    has_many :modulos, class_name: "Universidade::Modulo", foreign_key: :curso_id, dependent: :nullify

    validates :nome, presence: true

    attribute :rascunho, :boolean, default: false

    # Serialização do campo tags para compatibilidade com SQLite3
    serialize :tags, coder: JSON

    scope :visivel, -> { where(visivel: true, rascunho: false) }
    scope :buscar, ->(q) { where("lower(nome) LIKE lower(:q) OR lower(COALESCE(descricao,'')) LIKE lower(:q)", q: "%#{q}%") }

    def publicado?
      !rascunho? && visivel?
    end

    def despublicado?
      !rascunho? && !visivel?
    end

    # Atributo virtual para o formulário: tags como texto separado por vírgula.
    def tags_text
      (tags || []).join(", ")
    end

    # Slug humanizado para URLs amigáveis (ex: "1-ruby-on-rails").
    # Rails extrai o ID automaticamente via to_i no finder.
    def to_param
      "#{id}-#{nome.parameterize}"
    end

    # Retorna a fração de artigos visíveis concluídos pelo lojista em todo o curso (0.0 a 1.0).
    # Considera apenas artigos de trilhas e módulos visíveis pertencentes ao curso.
    # Progresso do curso = artigos_concluidos / total_artigos_do_curso
    def progresso_lojista(lojista_id)
      return 0.0 unless lojista_id

      total = Artigo
        .joins(trilha: :modulo)
        .where(
          universidade_artigos: { visivel: true },
          universidade_trilhas: { visivel: true },
          universidade_modulos: { curso_id: id, visivel: true }
        ).count

      return 0.0 if total.zero?

      concluidos = Artigo
        .joins(:progressos, trilha: :modulo)
        .where(
          universidade_artigos: { visivel: true },
          universidade_trilhas: { visivel: true },
          universidade_modulos: { curso_id: id, visivel: true },
          universidade_progressos: { lojista_id: lojista_id }
        )
        .where.not(universidade_progressos: { concluido_em: nil })
        .count

      concluidos.to_f / total
    end
  end
end
