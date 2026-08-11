class CreateEventOccurrences < ActiveRecord::Migration[8.1]
  def change
    create_table :event_occurrences do |t|
      t.references :event, null: false, foreign_key: true
      t.integer :number

      t.timestamps
    end
  end
end
