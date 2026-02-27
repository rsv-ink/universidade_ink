class AddImagensOrdemToUniversidadeSecoes < ActiveRecord::Migration[7.0]
  def up
    add_column :universidade_secoes, :imagens_ordem, :text

    return unless ActiveRecord::Base.connection.table_exists?(:active_storage_attachments)

    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET name = 'imagens'
      WHERE name = 'imagem'
        AND record_type = 'Universidade::Secao'
    SQL
  end

  def down
    remove_column :universidade_secoes, :imagens_ordem

    return unless ActiveRecord::Base.connection.table_exists?(:active_storage_attachments)

    execute <<~SQL.squish
      UPDATE active_storage_attachments
      SET name = 'imagem'
      WHERE name = 'imagens'
        AND record_type = 'Universidade::Secao'
    SQL
  end
end
