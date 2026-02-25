class CreateUniversidadeCursos < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_cursos do |t|
      t.string :nome, null: false
      t.text :descricao
      t.text :tags  # Serialized array - SQLite3 compatible
      t.integer :ordem
      t.boolean :visivel, default: true, null: false

      t.timestamps
    end

    add_index :universidade_cursos, :ordem
    add_index :universidade_cursos, :visivel
  end
end
