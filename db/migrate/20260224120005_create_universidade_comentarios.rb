class CreateUniversidadeComentarios < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_comentarios do |t|
      t.integer :lojista_id, null: false
      t.integer :artigo_id, null: false
      t.text :corpo, null: false

      t.timestamps
    end

    add_index :universidade_comentarios, :lojista_id
    add_index :universidade_comentarios, :artigo_id
    add_index :universidade_comentarios, [:artigo_id, :created_at]
    add_foreign_key :universidade_comentarios, :universidade_artigos, column: :artigo_id, on_delete: :cascade
  end
end
