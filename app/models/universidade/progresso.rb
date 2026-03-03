module Universidade
  class Progresso < ApplicationRecord
    self.table_name = "universidade_progressos"

    belongs_to :conteudo, class_name: "Universidade::Conteudo"
    belongs_to :trilha, class_name: "Universidade::Trilha", optional: true
    
    validates :user_id, presence: true
    validates :store_id, presence: true
    validates :conteudo_id, presence: true
    validates :user_id, uniqueness: { scope: [:conteudo_id, :store_id] }

    scope :concluidos, -> { where.not(concluido_em: nil) }
    scope :pendentes,  -> { where(concluido_em: nil) }

    def concluido?
      concluido_em.present?
    end
  end
end
