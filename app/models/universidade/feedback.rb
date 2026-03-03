module Universidade
  class Feedback < ApplicationRecord
    self.table_name = "universidade_feedbacks"

    belongs_to :conteudo, class_name: "Universidade::Conteudo"

    enum sentimento: { triste: 0, neutro: 1, feliz: 2 }

    validates :user_id, presence: true
    validates :store_id, presence: true
    validates :sentimento, presence: true
    validates :user_id, uniqueness: { scope: [:conteudo_id, :store_id] }
  end
end
