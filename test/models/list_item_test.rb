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

  test "limits author or circle information to 100 characters" do
    item = @list.list_items.build(space_number: "あ" * 100)

    assert item.valid?

    item.space_number = "あ" * 101

    assert_not item.valid?
    assert_includes item.errors.details[:space_number], { error: :too_long, count: 100 }
  end

  test "limits source URLs to 2,048 characters" do
    prefix = "https://x.com/example/status/"
    source_url = "#{prefix}#{"1" * (2048 - prefix.length)}"
    item = @list.list_items.build(source_url: source_url)

    assert_equal 2048, source_url.length
    assert item.valid?

    item.source_url = "#{source_url}1"

    assert_not item.valid?
    assert_includes item.errors.details[:source_url], { error: :too_long, count: 2048 }
  end
end
