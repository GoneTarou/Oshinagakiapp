class AllowNullSpaceNumberOnListItems < ActiveRecord::Migration[8.1]
  def change
    change_column_null :list_items, :space_number, true
  end
end
