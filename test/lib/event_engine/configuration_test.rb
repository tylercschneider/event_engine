require "test_helper"

module EventEngine
  class ConfigurationTest < ActiveSupport::TestCase
    setup do
      @config = Configuration.new
    end

    test "retention_period defaults to nil" do
      assert_nil @config.retention_period
    end

    test "retention_period can be set to a duration" do
      @config.retention_period = 30.days

      assert_equal 30.days, @config.retention_period
    end

    test "dashboard_auth defaults to nil" do
      assert_nil @config.dashboard_auth
    end

    test "dashboard_auth can be set to a callable" do
      auth_check = ->(controller) { controller.current_user&.admin? }
      @config.dashboard_auth = auth_check

      assert_equal auth_check, @config.dashboard_auth
    end

    test "validate! is called during boot_from_schema!" do
      EventEngine.configure do |c|
        c.delivery_adapter = :active_job
        c.transport = nil
      end

      schema_file = Tempfile.new("event_schema.rb")
      schema_file.write("EventEngine::EventSchema.define {}\n")
      schema_file.rewind

      assert_raises(Configuration::InvalidConfigurationError) do
        EventEngine.boot_from_schema!(
          schema_path: schema_file.path,
          registry: EventEngine::SchemaRegistry.new
        )
      end
    ensure
      schema_file&.unlink
      EventEngine.configure do |c|
        c.delivery_adapter = :inline
        c.transport = nil
      end
    end
  end
end
