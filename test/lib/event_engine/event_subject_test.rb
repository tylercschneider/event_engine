require "test_helper"

class EventSubjectTest < ActiveSupport::TestCase
  test "event retains its subject" do
    event = EventEngine::Event.new(event_name: :cow_fed, subject: :feeding)

    assert_equal :feeding, event.subject
  end
end
