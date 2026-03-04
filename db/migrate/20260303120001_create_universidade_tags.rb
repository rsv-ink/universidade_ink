class CreateUniversidadeTags < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_tags do |t|
      t.string :nome, null: false
      t.string :slug, null: false

      t.timestamps
    end

    add_index :universidade_tags, :slug, unique: true
    add_index :universidade_tags, :nome, unique: true
  end
end
