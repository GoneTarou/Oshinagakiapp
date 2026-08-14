require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "allows a name with 20 characters" do
    event = Event.new(name: "あ" * 20)

    assert event.valid?
  end

  test "rejects a name with more than 20 characters" do
    event = Event.new(name: "あ" * 21)

    assert_not event.valid?
    assert_equal [ { error: :too_long, count: 20 } ], event.errors.details[:name]
  end
end
