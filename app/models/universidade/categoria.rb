module Universidade
  class Categoria < ApplicationRecord
    self.table_name = "universidade_categorias"
    
    # Associations
    has_many :conteudos, dependent: :nullify

    # Validations
    validates :nome, presence: true, uniqueness: { case_sensitive: false }
    validates :slug, presence: true, uniqueness: { case_sensitive: false }

    # Callbacks
    before_validation :gerar_slug

    # Scopes
    scope :ordem_alfabetica, -> { order(:nome) }

    # Instance methods
    def conteudos_count
      conteudos.count
    end

    private

    def gerar_slug
      self.slug = nome.parameterize if nome.present?
    end
  end
end
