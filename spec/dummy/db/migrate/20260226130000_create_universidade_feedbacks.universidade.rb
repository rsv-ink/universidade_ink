class CreateUniversidadeFeedbacks < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_feedbacks do |t|
      t.integer :artigo_id, null: false
      t.integer :lojista_id, null: false
      t.integer :sentimento, null: false

      t.timestamps
    end

    add_index :universidade_feedbacks, [:artigo_id, :lojista_id], unique: true
    add_index :universidade_feedbacks, :artigo_id
  end
end
