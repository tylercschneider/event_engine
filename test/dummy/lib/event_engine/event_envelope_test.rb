require "test_helper"

module EventEngine
  class EventEnvelopeTest < ActiveSupport::TestCase
    test "returns outbox attributes" do
      envelope = EventEnvelope.new(
        event_name: "cow.fed",
        event_type: "domain",
        payload: { cow_id: 123 }
      )

      assert_equal(
        {
          event_name: "cow.fed",
          event_type: "domain",
          payload: { cow_id: 123 }
        },
        envelope.to_outbox_attributes
      )
    end
  end
end
