class RemoveSourceTypeFromListItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :list_items, :source_type, :string
  end
end
