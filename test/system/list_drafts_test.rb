require "application_system_test_case"

class ListDraftsTest < ApplicationSystemTestCase
  setup do
    visit root_path
    page.execute_script(
      "window.localStorage.setItem('oshinagaki:list-tutorial:v1', 'true')"
    )
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

  test "copies an existing list into the new list form" do
    source_list = List.create!(
      event: events(:one),
      list_items_attributes: [
        {
          space_number: "作者・サークルA",
          source_url: "https://x.com/example/status/1234567890",
          is_featured: true,
          is_adult_content: true
        },
        {
          space_number: "作者・サークルB"
        },
        {
          space_number: "作者・サークルC"
        },
        {
          space_number: "作者・サークルD"
        },
        {
          space_number: "作者・サークルE"
        },
        {
          space_number: "作者・サークルF"
        }
      ]
    )

    fill_in "list_list_items_attributes_0_space_number", with: "上書き前の下書き"
    visit list_path(token: source_list.token)

    click_button "このリスト内容を使って新しくリストを作る"

    assert_current_path new_list_path
    assert_field "list_event_id", with: events(:one).id.to_s
    assert_field "list_list_items_attributes_0_space_number", with: "作者・サークルA"
    assert_field "list_list_items_attributes_0_source_url",
                 with: "https://x.com/example/status/1234567890"
    assert_checked_field "list_list_items_attributes_0_is_featured"
    assert_checked_field "list_list_items_attributes_0_is_adult_content"
    assert_field "list_list_items_attributes_1_space_number", with: "作者・サークルB"
    assert_field "list_list_items_attributes_5_space_number", with: "作者・サークルF", visible: true
  end
end
