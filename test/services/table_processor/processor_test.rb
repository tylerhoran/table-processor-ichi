require "test_helper"

module TableProcessor
  class ProcessorTest < ActiveSupport::TestCase
    def setup
      @simple_table_html = load_table_fixture("table-1208.4.1.html")
      @complex_table_html = load_table_fixture("table-504.3.html")
      @window_schedule_html = load_table_fixture("table-window-schedule.html")
    end

    def test_processes_simple_table
      processor = Processor.new(@simple_table_html)
      result = processor.process

      assert result.is_a?(String)
      assert_not_empty result
      assert_includes result, "---"
    end

    def test_processes_complex_table
      processor = Processor.new(@complex_table_html)
      result = processor.process

      assert result.is_a?(String)
      assert_not_empty result
      assert_includes result, "---"
    end

    def test_processes_window_schedule
      processor = Processor.new(@window_schedule_html)
      result = processor.process

      assert result.is_a?(String)
      assert_not_empty result
      assert_includes result, "---"

      # Check for specific content in window schedule
      assert_includes result, "SYMBOL:"
      assert_includes result, "LOCATION:"
    end

    def test_handles_empty_html
      processor = Processor.new("")
      result = processor.process

      assert result.is_a?(String)
      assert_empty result
    end

    def test_handles_malformed_html
      processor = Processor.new("<div>Not a table</div>")
      result = processor.process

      assert result.is_a?(String)
      assert_empty result
    end

    def test_end_to_end_processing
      # Test with a simple table
      processor = Processor.new(@simple_table_html)
      result = processor.process

      # Check that the result has the expected format
      assert result.is_a?(String)
      assert_not_empty result

      # Check that the result contains key-value pairs
      lines = result.split("\n")
      assert lines.any? { |line| line.include?(": ") }

      # Check that rows are separated by '---'
      assert result.include?("---")
    end
  end
end
