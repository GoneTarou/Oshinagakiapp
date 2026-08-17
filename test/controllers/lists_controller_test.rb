require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @list = List.new(event: events(:one))
    @list.list_items.build(space_number: "東A-12b")
    @list.save!

    @original_cache = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ListsController.cache_store.clear
  end

  teardown do
    Rails.cache.clear
    Rails.cache = @original_cache
    ListsController.cache_store.clear
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

  test "limits list creation to three requests per minute from the same IP" do
    3.times do |index|
      post lists_path, params: valid_list_params("Circle #{index}")

      assert_response :redirect
    end

    post lists_path, params: valid_list_params("Circle 4")

    assert_response :see_other
    assert_redirected_to new_list_path

    follow_redirect!

    assert_response :success
    assert_select "section:first-of-type [role='alert']", text: /短時間に作成できる回数を超えました。/
    assert_select "section:first-of-type [role='alert']", text: /少し待ってから、もう一度お試しください。/
  end

  private

  def valid_list_params(space_number)
    {
      list: {
        event_id: events(:one).id,
        list_items_attributes: {
          "0" => {
            space_number: space_number,
            source_url: "",
            is_featured: "0",
            is_adult_content: "0"
          }
        }
      }
    }
  end
end
