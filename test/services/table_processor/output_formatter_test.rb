require "test_helper"

module TableProcessor
  class OutputFormatterTest < ActiveSupport::TestCase
    def setup
      @output_formatter = OutputFormatter.new
    end

    def test_formats_mapped_data
      mapped_data = [
        { "Header1" => "Value1", "Header2" => "Value2" },
        { "Header1" => "Value3", "Header2" => "Value4" }
      ]

      result = @output_formatter.format(mapped_data)

      assert result.is_a?(String)
      assert_includes result, "Header1: Value1"
      assert_includes result, "Header2: Value2"
      assert_includes result, "Header1: Value3"
      assert_includes result, "Header2: Value4"
      assert_includes result, "---"
    end

    def test_sorts_keys
      mapped_data = [
        { "B" => "Value1", "A" => "Value2", "C" => "Value3" }
      ]

      result = @output_formatter.format(mapped_data)

      # Check that keys are sorted alphabetically
      assert result.index("A: Value2") < result.index("B: Value1")
      assert result.index("B: Value1") < result.index("C: Value3")
    end

    def test_handles_empty_mapped_data
      mapped_data = []

      result = @output_formatter.format(mapped_data)

      assert result.is_a?(String)
      assert_empty result
    end

    def test_handles_empty_row_data
      mapped_data = [ {} ]

      result = @output_formatter.format(mapped_data)

      assert result.is_a?(String)
      assert_empty result
    end

    def test_formats_complex_data
      mapped_data = [
        { "Header1, Subheader1" => "Value1", "Header2" => "Value2" },
        { "Header1, Subheader1" => "Value3", "Header2" => "Value4" }
      ]

      result = @output_formatter.format(mapped_data)

      assert result.is_a?(String)
      assert_includes result, "Header1, Subheader1: Value1"
      assert_includes result, "Header2: Value2"
      assert_includes result, "Header1, Subheader1: Value3"
      assert_includes result, "Header2: Value4"
      assert_includes result, "---"
    end
  end
end
