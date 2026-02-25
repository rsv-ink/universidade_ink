# This migration comes from universidade (originally 20260224120004)
class CreateUniversidadeProgressos < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_progressos do |t|
      t.integer :lojista_id, null: false
      t.integer :artigo_id, null: false
      t.integer :trilha_id, null: false
      t.datetime :concluido_em

      t.timestamps
    end

    add_index :universidade_progressos, [:lojista_id, :artigo_id], unique: true
    add_index :universidade_progressos, :artigo_id
    add_index :universidade_progressos, :trilha_id
    add_index :universidade_progressos, :lojista_id
    add_foreign_key :universidade_progressos, :universidade_artigos, column: :artigo_id, on_delete: :cascade
    add_foreign_key :universidade_progressos, :universidade_trilhas, column: :trilha_id, on_delete: :cascade
  end
end
