require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "shows update history" do
    get updates_path

    assert_response :success
    assert_select "h1", text: "更新情報"
    assert_select "time[datetime='2026-08-18']", count: 2
    assert_select "h2", text: "使い方チュートリアルを追加しました"
    assert_select "h2", text: "既存のリストを活用できるようになりました"
    assert_select "time[datetime='2026-08-17']"
    assert_select "a", text: "巡回リストを作成する", count: 0
  end

  test "shows update history link in navigation" do
    get root_path

    assert_response :success
    assert_select "nav a[href='#{updates_path}']", text: "更新情報"
  end
end
