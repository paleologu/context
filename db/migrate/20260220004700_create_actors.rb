class CreateActors < ActiveRecord::Migration[8.1]
  def change
    create_table :actors, id: :uuid do |t|
      t.string   :kind,        null: false           # "human" | "agent"
      t.string   :name,        null: false
      t.string   :ref,         null: false           # unique identifier: email, agent slug
      t.boolean  :active,      null: false, default: true
      t.jsonb    :metadata,    null: false, default: {}
      t.timestamps null: false
    end

    add_index :actors, :ref, unique: true
    add_index :actors, :kind
    add_index :actors, :active
  end
end