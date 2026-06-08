require "test_helper"

module EventEngine
  class ProcessTypeTest < ActiveSupport::TestCase
    test "all lists the known process types" do
      assert_equal %i[inline background durable broker telemetry sourced], ProcessType.all
    end

    test "processor_for maps each process type to its owning processor" do
      expected = {
        inline: :subscribers,
        background: :subscribers,
        durable: :delivery,
        broker: :delivery,
        telemetry: :telemetry,
        sourced: :sourcing
      }

      assert_equal expected, ProcessType.all.to_h { |type| [type, ProcessType.processor_for(type)] }
    end

    test "known? reports whether a symbol is a known process type" do
      assert ProcessType.known?(:broker)
      refute ProcessType.known?(:bogus)
    end

    test "from_event_level maps legacy integer levels to process types" do
      assert_equal %i[inline background durable broker sourced],
                   [1, 2, 3, 4, 5].map { |level| ProcessType.from_event_level(level) }
    end
  end
end
