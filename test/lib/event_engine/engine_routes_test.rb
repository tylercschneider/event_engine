require "test_helper"

module EventEngine
  class EngineRoutesTest < ActiveSupport::TestCase
    test "the engine defines no dashboard routes" do
      paths = EventEngine::Engine.routes.routes.map { |route| route.path.spec.to_s }

      assert_empty paths.select { |path| path.include?("dashboard") }
    end
  end
end
