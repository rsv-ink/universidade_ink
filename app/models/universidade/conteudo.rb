module Universidade
  class Conteudo < ApplicationRecord
    self.table_name = "universidade_conteudos"

    # Relação muitos-para-muitos com trilhas através de trilha_conteudos
    has_many :trilha_conteudos, class_name: "Universidade::TrilhaConteudo", foreign_key: :conteudo_id, dependent: :destroy
    has_many :trilhas, through: :trilha_conteudos, class_name: "Universidade::Trilha"

    has_many :progressos, class_name: "Universidade::Progresso", foreign_key: :conteudo_id, dependent: :destroy
    has_many :feedbacks, class_name: "Universidade::Feedback", foreign_key: :conteudo_id, dependent: :destroy

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

    # Verifica se este conteúdo foi concluído pelo usuário
    def concluido?(user_id, store_id)
      return false unless user_id && store_id
      progressos.where(user_id: user_id, store_id: store_id).where.not(concluido_em: nil).exists?
    end

    # Retorna true se o conteúdo não está vinculado a nenhuma trilha
    def orfao?
      trilha_conteudos.empty?
    end

    # Retorna a contagem de trilhas vinculadas
    def trilhas_count
      trilha_conteudos.count
    end
  end
end
