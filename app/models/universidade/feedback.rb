module Universidade
  class Feedback < ApplicationRecord
    self.table_name = "universidade_feedbacks"

    belongs_to :artigo, class_name: "Universidade::Artigo"

    enum sentimento: { triste: 0, neutro: 1, feliz: 2 }

    validates :lojista_id, presence: true
    validates :sentimento, presence: true
  end
end
