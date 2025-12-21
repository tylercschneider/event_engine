require "test_helper"

class DeliveryAdapterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "inline adapter publishes immediately" do
    called = false

    EventEngine.configure do |config|
      config.delivery_adapter = :inline
    end

    EventEngine::Delivery.enqueue do
      called = true
    end

    assert called
  end

  test "active_job adapter enqueues PublishOutboxEventsJob" do
    EventEngine.configure do |config|
      config.delivery_adapter = :active_job
    end

    assert_enqueued_with(job: EventEngine::PublishOutboxEventsJob) do
      EventEngine::Delivery.enqueue
    end
  end
end
