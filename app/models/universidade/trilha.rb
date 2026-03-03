module Universidade
  class Trilha < ApplicationRecord
    include ImageProcessor
    
    self.table_name = "universidade_trilhas"

    has_one_attached :imagem
    has_many :modulos, class_name: "Universidade::Modulo", foreign_key: :trilha_id, dependent: :nullify
    
    # Relação muitos-para-muitos com conteúdos através de trilha_conteudos
    has_many :trilha_conteudos, class_name: "Universidade::TrilhaConteudo", foreign_key: :trilha_id, dependent: :destroy
    has_many :conteudos, through: :trilha_conteudos, class_name: "Universidade::Conteudo"
    
    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :trilha_id, dependent: :destroy

    validates :nome, presence: true
    validates :user_id, presence: true
    validates :store_id, presence: true

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

    # Retorna a fração de conteúdos visíveis concluídos pelo usuário em toda a trilha (0.0 a 1.0).
    # Considera conteúdos vinculados à trilha através da tabela de junção.
    def progresso_lojista(user_id, store_id)
      return 0.0 unless user_id && store_id

      # Todos os conteúdos visíveis vinculados a esta trilha
      conteudo_ids = trilha_conteudos.joins(:conteudo).where(universidade_conteudos: { visivel: true }).pluck(:conteudo_id).uniq
      total = conteudo_ids.size
      return 0.0 if total.zero?

      concluidos = Progresso
        .where(conteudo_id: conteudo_ids, user_id: user_id, store_id: store_id)
        .where.not(concluido_em: nil)
        .count

      concluidos.to_f / total
    end

    # Retorna true se todos os conteúdos visíveis da trilha foram concluídos pelo usuário.
    def concluida?(user_id, store_id)
      progresso_lojista(user_id, store_id) == 1.0
    end

    # Retorna lista flat ordenada de todos os conteúdos visíveis da trilha
    # Os conteúdos podem estar agrupados por módulos ou não
    def conteudos_ordenados
      trilha_conteudos
        .joins(:conteudo)
        .where(universidade_conteudos: { visivel: true })
        .order(:posicao)
        .includes(:conteudo)
        .map(&:conteudo)
    end
  end
end
