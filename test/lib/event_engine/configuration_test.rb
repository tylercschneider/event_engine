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
  end
end
