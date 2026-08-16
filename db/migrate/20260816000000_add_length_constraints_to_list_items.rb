class AddLengthConstraintsToListItems < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :list_items,
                         "length(space_number) <= 100",
                         name: "check_list_items_space_number_length"
    add_check_constraint :list_items,
                         "length(source_url) <= 2048",
                         name: "check_list_items_source_url_length"
  end
end
