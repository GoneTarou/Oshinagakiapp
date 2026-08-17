require "application_system_test_case"

class ListDraftsTest < ApplicationSystemTestCase
  setup do
    visit root_path
    page.execute_script("window.sessionStorage.clear()")
    click_link "＋ 新しい巡回リストを作る"
  end

  test "restores the draft after returning from a created list" do
    select events(:one).name, from: "list_event_id"
    fill_in "list_list_items_attributes_0_space_number", with: "作者名"

    click_button "巡回リストを作成"

    assert_text events(:one).name

    page.execute_script("window.history.back()")

    assert_field "list_event_id", with: events(:one).id.to_s
    assert_field "list_list_items_attributes_0_space_number", with: "作者名"
  end

  test "clears the draft when starting a new list intentionally" do
    select events(:one).name, from: "list_event_id"
    fill_in "list_list_items_attributes_0_space_number", with: "作者名"

    visit root_path
    click_link "＋ 新しい巡回リストを作る"

    assert_field "list_event_id", with: ""
    assert_field "list_list_items_attributes_0_space_number", with: ""
  end
end
