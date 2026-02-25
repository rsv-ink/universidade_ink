class CreateUniversidadeTrilhas < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_trilhas do |t|
      t.integer :modulo_id, null: true
      t.string :nome, null: false
      t.integer :ordem
      t.integer :tempo_estimado_minutos
      t.boolean :visivel, default: true, null: false

      t.timestamps
    end

    add_index :universidade_trilhas, :modulo_id
    add_index :universidade_trilhas, :ordem
    add_index :universidade_trilhas, :visivel
    add_foreign_key :universidade_trilhas, :universidade_modulos, column: :modulo_id, on_delete: :nullify
  end
end
