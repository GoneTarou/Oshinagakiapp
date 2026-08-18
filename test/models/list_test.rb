require "test_helper"

class ListTest < ActiveSupport::TestCase
  test "is valid with an event and one list item" do
    list = List.new(event: events(:one))
    list.list_items.build(space_number: "東A-12b")

    assert list.valid?
  end

  test "allows duplicate memos in a list" do
    list = List.new(event: events(:one))
    list.list_items.build(space_number: "8/18")
    list.list_items.build(space_number: "8/18")

    assert list.valid?
  end
end
