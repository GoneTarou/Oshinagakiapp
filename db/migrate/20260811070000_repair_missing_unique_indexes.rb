class RepairMissingUniqueIndexes < ActiveRecord::Migration[8.1]
  def change
    add_index :events, :name, unique: true
    add_index :event_occurrences, [:event_id, :number], unique: true
  end
end
