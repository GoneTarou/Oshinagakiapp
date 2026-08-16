require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = List.new(event: events(:one))
    @list.list_items.build(space_number: "東A-12b")
    @list.save!

    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rails.cache.clear
    Rails.cache = @original_cache
  end

  test "serves cached OGP image" do
    cache_key = [ "ogp-image", OgpImageGenerator::CACHE_VERSION, @list.id ]
    Rails.cache.write(cache_key, "cached-png-image-data".b)

    get list_ogp_image_path(token: @list.token)

    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal "cached-png-image-data".b, response.body
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes response.headers["Cache-Control"], "immutable"
  end

  test "adds OGP cache version to image URL" do
    get list_path(token: @list.token)

    assert_response :success
    assert_select 'meta[property="og:image"]' do |elements|
      assert_includes elements.first["content"], "v=#{OgpImageGenerator::CACHE_VERSION}"
    end
  end
end
