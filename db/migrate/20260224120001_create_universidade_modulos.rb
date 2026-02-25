class CreateUniversidadeModulos < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_modulos do |t|
      t.integer :curso_id, null: true
      t.string :nome, null: false
      t.text :descricao
      t.integer :ordem
      t.boolean :visivel, default: true, null: false

      t.timestamps
    end

    add_index :universidade_modulos, :curso_id
    add_index :universidade_modulos, :ordem
    add_index :universidade_modulos, :visivel
    add_foreign_key :universidade_modulos, :universidade_cursos, column: :curso_id, on_delete: :nullify
  end
end
