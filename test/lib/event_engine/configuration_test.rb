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
  end
end
