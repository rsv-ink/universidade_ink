# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_02_27_190001) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "universidade_artigos", force: :cascade do |t|
    t.integer "trilha_id"
    t.string "titulo", null: false
    t.text "corpo"
    t.integer "ordem"
    t.integer "tempo_estimado_minutos"
    t.boolean "visivel", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rascunho", default: false, null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["ordem"], name: "index_universidade_artigos_on_ordem"
    t.index ["rascunho"], name: "index_universidade_artigos_on_rascunho"
    t.index ["store_id"], name: "index_universidade_artigos_on_store_id"
    t.index ["trilha_id"], name: "index_universidade_artigos_on_trilha_id"
    t.index ["user_id"], name: "index_universidade_artigos_on_user_id"
    t.index ["visivel"], name: "index_universidade_artigos_on_visivel"
  end

  create_table "universidade_cursos", force: :cascade do |t|
    t.string "nome", null: false
    t.text "descricao"
    t.text "tags"
    t.integer "ordem"
    t.boolean "visivel", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rascunho", default: false, null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["ordem"], name: "index_universidade_cursos_on_ordem"
    t.index ["rascunho"], name: "index_universidade_cursos_on_rascunho"
    t.index ["store_id"], name: "index_universidade_cursos_on_store_id"
    t.index ["user_id"], name: "index_universidade_cursos_on_user_id"
    t.index ["visivel"], name: "index_universidade_cursos_on_visivel"
  end

  create_table "universidade_feedbacks", force: :cascade do |t|
    t.integer "artigo_id", null: false
    t.integer "sentimento", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["artigo_id", "user_id", "store_id"], name: "index_universidade_feedbacks_on_artigo_user_store", unique: true
    t.index ["artigo_id"], name: "index_universidade_feedbacks_on_artigo_id"
    t.index ["store_id"], name: "index_universidade_feedbacks_on_store_id"
    t.index ["user_id"], name: "index_universidade_feedbacks_on_user_id"
  end

  create_table "universidade_modulos", force: :cascade do |t|
    t.integer "curso_id"
    t.string "nome", null: false
    t.text "descricao"
    t.integer "ordem"
    t.boolean "visivel", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rascunho", default: false, null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["curso_id"], name: "index_universidade_modulos_on_curso_id"
    t.index ["ordem"], name: "index_universidade_modulos_on_ordem"
    t.index ["rascunho"], name: "index_universidade_modulos_on_rascunho"
    t.index ["store_id"], name: "index_universidade_modulos_on_store_id"
    t.index ["user_id"], name: "index_universidade_modulos_on_user_id"
    t.index ["visivel"], name: "index_universidade_modulos_on_visivel"
  end

  create_table "universidade_progressos", force: :cascade do |t|
    t.integer "artigo_id", null: false
    t.integer "trilha_id", null: false
    t.datetime "concluido_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["artigo_id"], name: "index_universidade_progressos_on_artigo_id"
    t.index ["store_id"], name: "index_universidade_progressos_on_store_id"
    t.index ["trilha_id"], name: "index_universidade_progressos_on_trilha_id"
    t.index ["user_id", "artigo_id", "store_id"], name: "index_universidade_progressos_on_user_artigo_store", unique: true
    t.index ["user_id"], name: "index_universidade_progressos_on_user_id"
  end

  create_table "universidade_secao_itens", force: :cascade do |t|
    t.integer "secao_id", null: false
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.integer "ordem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["item_type", "item_id"], name: "index_universidade_secao_itens_on_item_type_and_item_id"
    t.index ["secao_id"], name: "index_universidade_secao_itens_on_secao_id"
    t.index ["store_id"], name: "index_universidade_secao_itens_on_store_id"
    t.index ["user_id"], name: "index_universidade_secao_itens_on_user_id"
  end

  create_table "universidade_secoes", force: :cascade do |t|
    t.string "titulo", default: "", null: false
    t.string "tipo", default: "conteudo", null: false
    t.string "formato_card", default: "quadrado", null: false
    t.integer "ordem"
    t.boolean "visivel", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subtitulo"
    t.string "layout_exibicao", default: "galeria", null: false
    t.integer "colunas_galeria", default: 3, null: false
    t.text "imagens_ordem"
    t.text "imagens_links", default: "{}"
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["store_id"], name: "index_universidade_secoes_on_store_id"
    t.index ["user_id"], name: "index_universidade_secoes_on_user_id"
  end

  create_table "universidade_trilhas", force: :cascade do |t|
    t.integer "modulo_id"
    t.string "nome", null: false
    t.integer "ordem"
    t.integer "tempo_estimado_minutos"
    t.boolean "visivel", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rascunho", default: false, null: false
    t.integer "user_id", null: false
    t.integer "store_id", null: false
    t.index ["modulo_id"], name: "index_universidade_trilhas_on_modulo_id"
    t.index ["ordem"], name: "index_universidade_trilhas_on_ordem"
    t.index ["rascunho"], name: "index_universidade_trilhas_on_rascunho"
    t.index ["store_id"], name: "index_universidade_trilhas_on_store_id"
    t.index ["user_id"], name: "index_universidade_trilhas_on_user_id"
    t.index ["visivel"], name: "index_universidade_trilhas_on_visivel"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "universidade_artigos", "universidade_trilhas", column: "trilha_id", on_delete: :nullify
  add_foreign_key "universidade_modulos", "universidade_cursos", column: "curso_id", on_delete: :nullify
  add_foreign_key "universidade_progressos", "universidade_artigos", column: "artigo_id", on_delete: :cascade
  add_foreign_key "universidade_progressos", "universidade_trilhas", column: "trilha_id", on_delete: :cascade
  add_foreign_key "universidade_secao_itens", "universidade_secoes", column: "secao_id"
  add_foreign_key "universidade_trilhas", "universidade_modulos", column: "modulo_id", on_delete: :nullify
end
