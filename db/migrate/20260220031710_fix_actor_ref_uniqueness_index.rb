class FixActorRefUniquenessIndex < ActiveRecord::Migration[8.1]
  def change
    remove_index :actors, :ref
    add_index :actors, [:ref, :kind], unique: true
  end
end