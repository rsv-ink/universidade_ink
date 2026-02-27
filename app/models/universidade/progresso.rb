module Universidade
  class Progresso < ApplicationRecord
    self.table_name = "universidade_progressos"

    belongs_to :artigo, class_name: "Universidade::Artigo"
    belongs_to :trilha, class_name: "Universidade::Trilha"
    
    validates :user_id, presence: true
    validates :store_id, presence: true
    validates :artigo_id, presence: true
    validates :trilha_id, presence: true
    validates :user_id, uniqueness: { scope: [:artigo_id, :store_id] }

    scope :concluidos, -> { where.not(concluido_em: nil) }
    scope :pendentes,  -> { where(concluido_em: nil) }

    def concluido?
      concluido_em.present?
    end
  end
end
