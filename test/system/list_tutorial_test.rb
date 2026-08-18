require "application_system_test_case"

class ListTutorialTest < ApplicationSystemTestCase
  setup do
    visit new_list_path
    page.execute_script(
      "window.localStorage.removeItem('oshinagaki:list-tutorial:v1')"
    )
  end

  test "shows the tutorial on the first visit and can reopen it" do
    visit new_list_path

    assert_selector "dialog[open]", text: "1 / 4"
    assert_selector "img[alt='イベントを選択する画面']", visible: true

    click_button "次へ"

    assert_selector "dialog[open]", text: "2 / 4"
    assert_selector "img[alt='巡回先を登録する画面']", visible: true
    assert_button "戻る", visible: true

    click_button "戻る"

    assert_selector "dialog[open]", text: "1 / 4"
    assert_no_button "戻る", visible: true

    click_button "次へ"

    click_button "次へ"

    click_button "次へ"

    assert_selector "dialog[open]", text: "4 / 4"
    assert_selector "img[alt='既存のリストを活用して新しくリストを作成する画面']", visible: true
    assert_button "はじめる", visible: true

    click_button "はじめる"

    assert_no_selector "dialog[open]"

    visit new_list_path

    assert_no_selector "dialog[open]"

    click_button "使い方を見る"

    assert_selector "dialog[open]", text: "1 / 4"
  end
end
