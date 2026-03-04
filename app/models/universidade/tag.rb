module Universidade
  class Tag < ApplicationRecord
    self.table_name = "universidade_tags"
    
    # Associations
    has_many :conteudo_tags, dependent: :destroy
    has_many :conteudos, through: :conteudo_tags

    has_many :trilha_tags, dependent: :destroy
    has_many :trilhas, through: :trilha_tags

    # Validations
    validates :nome, presence: true, uniqueness: { case_sensitive: false }
    validates :slug, presence: true, uniqueness: { case_sensitive: false }

    # Callbacks
    before_validation :gerar_slug

    # Scopes
    scope :ordem_alfabetica, -> { order(:nome) }
    scope :mais_usadas, -> { 
      left_joins(:conteudo_tags)
        .group(:id)
        .order('COUNT(universidade_conteudo_tags.id) DESC, universidade_tags.nome ASC')
    }

    # Instance methods
    def to_s
      nome
    end

    def conteudos_count
      conteudos.count
    end

    private

    def gerar_slug
      self.slug = nome.parameterize if nome.present?
    end
  end
end
