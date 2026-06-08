require "test_helper"

module EventEngine
  class ProcessTypeTest < ActiveSupport::TestCase
    test "all lists the known process types" do
      assert_equal %i[inline background durable broker telemetry sourced], ProcessType.all
    end
  end
end
