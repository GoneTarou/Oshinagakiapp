require "test_helper"

class OgpImageGeneratorTest < ActiveSupport::TestCase
  test "uses a compact event point size for long event context" do
    event = Event.new(name: "あ" * 16)
    list = List.new(event: event)

    generator = OgpImageGenerator.new(list)

    assert_equal 40, generator.send(:event_context_pointsize)
  end

  test "uses the earliest registered general circle info when no item is featured" do
    list = List.new(event: events(:one))

    list.list_items.build(
      space_number: "東A-12b",
      created_at: Time.zone.parse("2026-08-14 10:00:00")
    )
    list.list_items.build(
      space_number: "西れ-05a",
      is_adult_content: true,
      created_at: Time.zone.parse("2026-08-14 08:00:00")
    )
    list.list_items.build(
      space_number: "南1-01a",
      created_at: Time.zone.parse("2026-08-14 09:00:00")
    )

    generator = OgpImageGenerator.new(list)

    assert_equal "イチ推し 南1-01a", generator.send(:featured_space_text)
  end

  test "uses featured circle info before the earliest registered circle info" do
    list = List.new(event: events(:one))

    list.list_items.build(
      space_number: "東A-12b",
      created_at: Time.zone.parse("2026-08-14 08:00:00")
    )
    list.list_items.build(
      space_number: "西れ-05a",
      is_featured: true,
      created_at: Time.zone.parse("2026-08-14 09:00:00")
    )

    generator = OgpImageGenerator.new(list)

    assert_equal "イチ推し 西れ-05a", generator.send(:featured_space_text)
  end

  test "does not add circle info when all general items have no circle info" do
    list = List.new(event: events(:one))
    list.list_items.build(created_at: Time.zone.parse("2026-08-14 08:00:00"))

    generator = OgpImageGenerator.new(list)

    assert_nil generator.send(:featured_space_text)
  end

  test "uses the artwork asset for OGP generation" do
    list = List.new(event: events(:one))

    artwork_path = OgpImageGenerator.new(list).send(:artwork_path)

    assert File.file?(artwork_path), "OGP artwork asset is missing: #{artwork_path}"
  end
end
