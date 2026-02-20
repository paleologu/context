class CreateRelationships < ActiveRecord::Migration[8.1]
  def change
    create_table :relationships, id: :uuid do |t|
      t.references :actor,      null: false, foreign_key: true, type: :uuid
      t.uuid       :from_id,    null: false
      t.string     :from_type,  null: false   # "Entity" | "Event"
      t.uuid       :to_id,      null: false
      t.string     :to_type,    null: false   # "Entity" | "Event" | "Actor"
      t.string     :predicate,  null: false   # "emerged_from" | "made_by" | "about" | "informed_by" | "supersedes" | "contradicts" | "validates" | "depends_on"
      t.jsonb      :metadata,   null: false, default: {}
      t.timestamps null: false
    end

    add_index :relationships, [:from_id, :from_type]
    add_index :relationships, [:to_id, :to_type]
    add_index :relationships, :predicate
    add_index :relationships, [:from_id, :predicate]
    add_index :relationships, [:from_type, :to_type, :predicate]
  end
end