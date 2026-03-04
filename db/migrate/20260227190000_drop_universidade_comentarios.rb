class DropUniversidadeComentarios < ActiveRecord::Migration[7.2]
  def change
    drop_table :universidade_comentarios do |t|
      t.integer :lojista_id, null: false
      t.integer :artigo_id, null: false
      t.text :corpo, null: false
      t.timestamps
    end
  end
end
