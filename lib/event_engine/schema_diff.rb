module EventEngine
  class SchemaDiff
    def initialize(expected:, actual:)
      @expected = expected
      @actual = actual
    end

    def changed?
      @expected != @actual
    end

    def to_s
      expected_lines = @expected.lines
      actual_lines = @actual.lines

      Array.new([ expected_lines.size, actual_lines.size ].max) do |index|
        line_diff(expected_lines[index], actual_lines[index])
      end.compact.join
    end

    private

    def line_diff(expected_line, actual_line)
      return " #{expected_line}" if expected_line == actual_line

      [ marked("-", expected_line), marked("+", actual_line) ].compact.join
    end

    def marked(sign, line)
      return nil if line.nil?

      "#{sign}#{line}"
    end
  end
end
