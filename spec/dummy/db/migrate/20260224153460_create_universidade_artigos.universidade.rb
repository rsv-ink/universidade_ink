# This migration comes from universidade (originally 20260224120003)
class CreateUniversidadeArtigos < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_artigos do |t|
      t.integer :trilha_id, null: true
      t.string :titulo, null: false
      t.text :corpo  # Serialized JSON - SQLite3 compatible
      t.integer :ordem
      t.integer :tempo_estimado_minutos
      t.boolean :visivel, default: true, null: false

      t.timestamps
    end

    add_index :universidade_artigos, :trilha_id
    add_index :universidade_artigos, :ordem
    add_index :universidade_artigos, :visivel
    add_foreign_key :universidade_artigos, :universidade_trilhas, column: :trilha_id, on_delete: :nullify
  end
end
