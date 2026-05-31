require "test_helper"

module EventEngine
  class SubscriberTest < ActiveSupport::TestCase
    teardown do
      SubscriberRegistry.clear!
    end

    test "subscribes_to registers the subclass for the event" do
      subscriber = Class.new(Subscriber) do
        subscribes_to :cow_fed
      end

      assert_includes SubscriberRegistry.subscribers_for(:cow_fed), subscriber
    end
  end
end
