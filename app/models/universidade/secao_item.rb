module Universidade
  class SecaoItem < ApplicationRecord
    self.table_name = "universidade_secao_itens"

    belongs_to :secao, class_name: "Universidade::Secao", foreign_key: :secao_id
    belongs_to :item,  polymorphic: true

    validates :item, presence: true
  end
end
