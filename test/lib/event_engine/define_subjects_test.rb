require "test_helper"

class DefineSubjectsTest < ActiveSupport::TestCase
  def teardown
    EventEngine.reset_subjects!
  end

  test "define_subjects declares subjects on the global registry" do
    EventEngine.define_subjects do
      subject :feeding, area: :farm
    end

    assert EventEngine.subject_registry.registered?(:feeding)
  end
end
