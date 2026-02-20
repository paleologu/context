class CreateEntities < ActiveRecord::Migration[8.1]
  def change
    create_table :entities, id: :uuid do |t|
      t.uuid     :actor_id,   null: false
      t.string   :kind,       null: false
      t.string   :title,      null: false
      t.text     :summary
      t.jsonb    :body,       null: false, default: {}
      t.string   :status,     null: false, default: "active"
      t.float    :confidence
      t.string   :scope
      t.vector   :embedding,  limit: 1536
      t.timestamps null: false
    end

    add_foreign_key :entities, :actors
    add_index :entities, :actor_id
    add_index :entities, :kind
    add_index :entities, :status
    add_index :entities, :scope
    add_index :entities, [:kind, :status]
    add_index :entities, :body,      using: :gin
    add_index :entities, :embedding, using: :ivfflat, opclass: :vector_cosine_ops
  end
end
