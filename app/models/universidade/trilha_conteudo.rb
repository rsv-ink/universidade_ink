module Universidade
  class TrilhaConteudo < ApplicationRecord
    self.table_name = "universidade_trilha_conteudos"

    belongs_to :trilha, class_name: "Universidade::Trilha"
    belongs_to :conteudo, class_name: "Universidade::Conteudo"
    belongs_to :modulo, class_name: "Universidade::Modulo", optional: true

    validates :trilha_id, presence: true
    validates :conteudo_id, presence: true
    validates :posicao, presence: true, numericality: { only_integer: true }

    # Garante que um conteúdo não seja duplicado na mesma trilha
    validates :conteudo_id, uniqueness: { scope: :trilha_id, message: "já está vinculado a esta trilha" }

    default_scope { order(posicao: :asc) }

    # Método para encontrar ou criar próxima posição disponível em uma trilha
    def self.proxima_posicao(trilha_id)
      where(trilha_id: trilha_id).maximum(:posicao).to_i + 1
    end
  end
end
