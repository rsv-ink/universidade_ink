class CreateUniversidadeSecoes < ActiveRecord::Migration[7.0]
  def change
    create_table :universidade_secoes do |t|
      t.string  :titulo,       null: false, default: ""
      t.string  :tipo,         null: false, default: "conteudo"   # "imagem" | "conteudo"
      t.string  :formato_card, null: false, default: "quadrado"   # "quadrado" | "horizontal"
      t.integer :ordem
      t.boolean :visivel,      null: false, default: true

      t.timestamps
    end
  end
end
