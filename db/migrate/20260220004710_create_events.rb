class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events, id: :uuid do |t|
      t.references :actor,      null: false, foreign_key: true, type: :uuid
      t.string     :event_type, null: false   # e.g. "entity.created" | "entity.linked" | "entity.deprecated"
      t.jsonb      :payload,    null: false, default: {}
      t.jsonb      :metadata,   null: false, default: {}
      t.string     :scope                     # optional: project / workspace identifier
      t.timestamps null: false
    end

    add_index :events, :event_type
    add_index :events, :scope
    add_index :events, :created_at
    add_index :events, :payload,  using: :gin
  end
end