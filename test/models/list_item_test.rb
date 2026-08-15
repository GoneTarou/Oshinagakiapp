require "test_helper"

class ListItemTest < ActiveSupport::TestCase
  setup do
    @list = List.new(event: events(:one))
  end

  test "allows an x.com URL" do
    item = @list.list_items.build(source_url: "https://x.com/example/status/1")

    assert item.valid?
  end

  test "rejects an x.com URL that is not a post" do
    item = @list.list_items.build(source_url: "https://x.com/example")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "はXの投稿URLを入力してください"
  end

  test "allows pixiv.net and www.pixiv.net URLs" do
    [ "https://pixiv.net/users/1", "https://www.pixiv.net/users/1" ].each do |url|
      item = @list.list_items.build(source_url: url)

      assert item.valid?, url
    end
  end

  test "rejects twitter.com URLs" do
    item = @list.list_items.build(source_url: "https://twitter.com/example/status/1")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "はXまたはpixivのURLを入力してください"
  end

  test "rejects URLs from unsupported sites" do
    item = @list.list_items.build(source_url: "https://example.com/post/1")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "はXまたはpixivのURLを入力してください"
  end

  test "rejects non-http protocols" do
    item = @list.list_items.build(source_url: "javascript:alert(1)")

    assert_not item.valid?
    assert_includes item.errors[:source_url], "はhttpまたはhttpsのURLを入力してください"
  end

  test "allows an empty source URL" do
    item = @list.list_items.build(source_url: "")

    assert item.valid?
    assert_nil item.source_url
  end
end
