class CreateUniversidadeConteudoTags < ActiveRecord::Migration[7.2]
  def change
    create_table :universidade_conteudo_tags do |t|
      t.references :conteudo, null: false, foreign_key: { to_table: :universidade_conteudos }, index: true
      t.references :tag, null: false, foreign_key: { to_table: :universidade_tags }, index: true

      t.timestamps
    end

    add_index :universidade_conteudo_tags, [:conteudo_id, :tag_id], unique: true
  end
end
