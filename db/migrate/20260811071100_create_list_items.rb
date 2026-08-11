class CreateListItems < ActiveRecord::Migration[8.1]
  def change
    create_table :list_items do |t|
      t.references :list, null: false, foreign_key: true
      t.string :space_number, null: false
      t.string :source_url
      t.boolean :is_featured, null: false, default: false
      t.boolean :is_adult_content, null: false, default: false

      t.timestamps
    end

    add_index :list_items, [:list_id, :space_number], unique: true
  end
end
