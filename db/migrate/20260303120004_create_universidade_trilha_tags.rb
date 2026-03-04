class CreateUniversidadeTrilhaTags < ActiveRecord::Migration[7.2]
  def up
    return if table_exists?(:universidade_trilha_tags)

    create_table :universidade_trilha_tags do |t|
      t.integer :trilha_id, null: false
      t.integer :tag_id, null: false
      t.timestamps
    end

    add_index :universidade_trilha_tags, :trilha_id
    add_index :universidade_trilha_tags, :tag_id
    add_index :universidade_trilha_tags, [:trilha_id, :tag_id],
              unique: true, name: "index_universidade_trilha_tags_on_trilha_and_tag"

    add_foreign_key :universidade_trilha_tags, :universidade_trilhas,
                    column: :trilha_id, on_delete: :cascade
    add_foreign_key :universidade_trilha_tags, :universidade_tags,
                    column: :tag_id, on_delete: :cascade
  end

  def down
    drop_table :universidade_trilha_tags, if_exists: true
  end
end
