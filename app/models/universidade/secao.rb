module Universidade
  class Secao < ApplicationRecord
    self.table_name = "universidade_secoes"

    has_many :secao_itens, -> { order(:ordem) },
             dependent: :destroy,
             class_name: "Universidade::SecaoItem",
             foreign_key: :secao_id

    has_many_attached :imagens

    attribute :subtitulo, :string
    attribute :layout_exibicao, :string, default: "galeria"
    attribute :colunas_galeria, :integer, default: 3
    attribute :imagens_ordem, default: []
    attribute :imagens_links, default: {}

    serialize :imagens_ordem, type: Array, coder: JSON

    serialize :imagens_links, type: Hash, coder: JSON

    validates :tipo,         inclusion: { in: %w[imagem conteudo] }
    validates :formato_card, inclusion: { in: %w[quadrado] }
    validates :layout_exibicao, inclusion: { in: %w[carrossel galeria] }
    validates :colunas_galeria, inclusion: { in: [1, 2, 3, 4] }
    validates :user_id, presence: true
    validates :store_id, presence: true

    def imagens_ordenadas
      return imagens unless imagens_ordem.present?

      ordem = Array(imagens_ordem).map(&:to_s)
      imagens.sort_by { |img| ordem.index(img.blob_id.to_s) || ordem.length }
    end

    scope :visivel, -> { where(visivel: true) }

    def conteudo? = tipo == "conteudo"
    def imagem_tipo? = tipo == "imagem"
  end
end
