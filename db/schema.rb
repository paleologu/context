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

ActiveRecord::Schema[8.1].define(version: 2026_02_20_031710) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "actors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "name", null: false
    t.string "ref", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_actors_on_active"
    t.index ["kind"], name: "index_actors_on_kind"
    t.index ["ref", "kind"], name: "index_actors_on_ref_and_kind", unique: true
  end

  create_table "entities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id", null: false
    t.jsonb "body", default: {}, null: false
    t.float "confidence"
    t.datetime "created_at", null: false
    t.vector "embedding", limit: 1536
    t.string "kind", null: false
    t.string "scope"
    t.string "status", default: "active", null: false
    t.text "summary"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_entities_on_actor_id"
    t.index ["body"], name: "index_entities_on_body", using: :gin
    t.index ["embedding"], name: "index_entities_on_embedding", opclass: :vector_cosine_ops, using: :ivfflat
    t.index ["kind", "status"], name: "index_entities_on_kind_and_status"
    t.index ["kind"], name: "index_entities_on_kind"
    t.index ["scope"], name: "index_entities_on_scope"
    t.index ["status"], name: "index_entities_on_status"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id", null: false
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.jsonb "payload", default: {}, null: false
    t.string "scope"
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_events_on_actor_id"
    t.index ["created_at"], name: "index_events_on_created_at"
    t.index ["event_type"], name: "index_events_on_event_type"
    t.index ["payload"], name: "index_events_on_payload", using: :gin
    t.index ["scope"], name: "index_events_on_scope"
  end

  create_table "relationships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_id", null: false
    t.datetime "created_at", null: false
    t.uuid "from_id", null: false
    t.string "from_type", null: false
    t.jsonb "metadata", default: {}, null: false
    t.string "predicate", null: false
    t.uuid "to_id", null: false
    t.string "to_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_relationships_on_actor_id"
    t.index ["from_id", "from_type"], name: "index_relationships_on_from_id_and_from_type"
    t.index ["from_id", "predicate"], name: "index_relationships_on_from_id_and_predicate"
    t.index ["from_type", "to_type", "predicate"], name: "index_relationships_on_from_type_and_to_type_and_predicate"
    t.index ["predicate"], name: "index_relationships_on_predicate"
    t.index ["to_id", "to_type"], name: "index_relationships_on_to_id_and_to_type"
  end

  add_foreign_key "entities", "actors"
  add_foreign_key "events", "actors"
  add_foreign_key "relationships", "actors"
end
