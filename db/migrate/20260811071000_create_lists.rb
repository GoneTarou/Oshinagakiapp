class CreateLists < ActiveRecord::Migration[8.1]
  def change
    create_table :lists do |t|
      t.references :event, null: false, foreign_key: true
      t.references :event_occurrence, null: true, foreign_key: true
      t.string :token, null: false

      t.timestamps
    end

    add_index :lists, :token, unique: true
  end
end
