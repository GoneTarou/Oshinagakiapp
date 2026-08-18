class UpdateListItemsMemoConstraints < ActiveRecord::Migration[8.1]
  def up
    remove_index :list_items, name: "index_list_items_on_list_id_and_space_number"
    remove_check_constraint :list_items, name: "check_list_items_space_number_length"
    add_check_constraint :list_items,
                         "length(space_number) <= 30",
                         name: "check_list_items_space_number_length",
                         validate: false
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "重複したメモが保存されるため、一意制約は安全に復元できません"
  end
end
