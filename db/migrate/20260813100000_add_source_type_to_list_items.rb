class AddSourceTypeToListItems < ActiveRecord::Migration[8.1]
  def change
    add_column :list_items, :source_type, :string
  end
end
