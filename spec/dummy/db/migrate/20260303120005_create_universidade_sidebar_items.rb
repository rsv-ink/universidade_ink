class CreateUniversidadeSidebarItems < ActiveRecord::Migration[7.2]
  def change
    create_table :universidade_sidebar_items do |t|
      t.string  :nome,    null: false
      t.text    :icone    # SVG completo do ícone (apenas para tipo 'link')
      t.string  :url      # URL interna ou externa (apenas para tipo 'link')
      t.string  :tipo,    null: false, default: "link"  # "link" ou "divider"
      t.integer :ordem
      t.boolean :visivel, null: false, default: true

      t.timestamps
    end

    add_index :universidade_sidebar_items, :ordem
    add_index :universidade_sidebar_items, :visivel
  end
end
