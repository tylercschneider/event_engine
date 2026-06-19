require "test_helper"

class DummySchemaTest < ActiveSupport::TestCase
  test "dummy database does not carry the vestigial outbox table" do
    refute_includes ActiveRecord::Base.connection.tables, "event_engine_outbox_events"
  end
end
