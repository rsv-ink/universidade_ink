module Universidade
  class SidebarItem < ApplicationRecord
    self.table_name = "universidade_sidebar_items"
    
    # Constants
    TIPOS = %w[link divider].freeze

    # Callbacks
    before_save :sanitize_icon_classes

    # Validations
    validates :nome, presence: true
    validates :tipo, presence: true, inclusion: { in: TIPOS }
    validates :url, presence: true, if: -> { tipo == 'link' }
    validates :icone, presence: true, if: -> { tipo == 'link' }

    # Scopes
    scope :visivel, -> { where(visivel: true) }
    scope :ordenado, -> { order(Arel.sql("COALESCE(ordem, id)")) }

    # Instance methods
    def link?
      tipo == 'link'
    end

    def divider?
      tipo == 'divider'
    end

    private

    def sanitize_icon_classes
      return unless icone.present?
      
      # Remove classes de cor específicas para permitir que o ícone herde a cor do contexto
      self.icone = icone
        .gsub(/text-gray-\d+/, '')
        .gsub(/text-white/, '')
        .gsub(/text-black/, '')
        .gsub(/dark:text-\w+/, '')
        .gsub(/text-blue-\d+/, '')
        .gsub(/text-pink-\d+/, '')
        .gsub(/text-red-\d+/, '')
        .gsub(/text-green-\d+/, '')
        .gsub(/text-yellow-\d+/, '')
        .gsub(/text-purple-\d+/, '')
        .gsub(/text-indigo-\d+/, '')
        .gsub(/class="([^"]*)\s+"/, 'class="\1"')  # Remove espaços extras
        .gsub(/\s+/, ' ')  # Normaliza espaços
        .strip
    end
  end
end
