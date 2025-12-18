require "test_helper"

module EventEngine
  class EventDefinitionExtractionRulesTest < ActiveSupport::TestCase
    test "required field can declare extraction rule" do
      definition_class = Class.new(EventDefinition) do
        input :cow
        required :cow_id, from: [:cow, :id]
      end

      fields = definition_class.fields

      assert_equal [:cow, :id], fields[:cow_id][:from]
      assert_equal true, fields[:cow_id][:required]
    end

    test "optional field can declare extraction rule" do
      definition_class = Class.new(EventDefinition) do
        optional :weight_gain, from: [:cow, :weight_gain]
      end

      fields = definition_class.fields

      assert_equal [:cow, :weight_gain], fields[:weight_gain][:from]
      assert_equal false, fields[:weight_gain][:required]
    end
  end
end
