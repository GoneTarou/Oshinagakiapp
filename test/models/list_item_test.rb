require "test_helper"

class ListItemTest < ActiveSupport::TestCase
  setup do
    @list = List.new(event: events(:one), event_occurrence: event_occurrences(:one))
  end

  test "allows an x.com URL with x source type" do
    item = @list.list_items.build(source_type: "x", source_url: "https://x.com/example/status/1")

    assert item.valid?
  end

  test "allows pixiv.net and www.pixiv.net URLs with pixiv source type" do
    ["https://pixiv.net/users/1", "https://www.pixiv.net/users/1"].each do |url|
      item = @list.list_items.build(source_type: "pixiv", source_url: url)

      assert item.valid?, url
    end
  end

  test "rejects twitter.com URLs" do
    item = @list.list_items.build(source_type: "x", source_url: "https://twitter.com/example/status/1")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "は選択したサイトのURLを入力してください"
  end

  test "rejects URLs from unsupported sites" do
    item = @list.list_items.build(source_type: "x", source_url: "https://example.com/post/1")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "は選択したサイトのURLを入力してください"
  end

  test "rejects non-http protocols" do
    item = @list.list_items.build(source_type: "x", source_url: "javascript:alert(1)")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "はhttpまたはhttpsのURLを入力してください"
  end

  test "allows an empty source URL and clears its source type" do
    item = @list.list_items.build(source_type: "x", source_url: "")

    assert item.valid?
    assert_nil item.source_url
    assert_nil item.source_type
  end
end
