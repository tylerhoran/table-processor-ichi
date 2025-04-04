require "test_helper"

module TableProcessor
  class ParserTest < ActiveSupport::TestCase
    def setup
      @simple_table_html = load_table_fixture("table-1208.4.1.html")
      @complex_table_html = load_table_fixture("table-504.3.html")
      @window_schedule_html = load_table_fixture("table-window-schedule.html")
    end

    def test_parses_simple_table
      parser = Parser.new(@simple_table_html)
      result = parser.parse

      assert result[:headers].is_a?(Array)
      assert result[:rows].is_a?(Array)
      assert result[:metadata].is_a?(Hash)

      # Check that headers were extracted
      assert_not_empty result[:headers]

      # Check that rows were extracted
      assert_not_empty result[:rows]

      # Check that metadata was extracted
      assert_includes result[:metadata].keys, :class
    end

    def test_parses_complex_table
      parser = Parser.new(@complex_table_html)
      result = parser.parse

      assert result[:headers].is_a?(Array)
      assert result[:rows].is_a?(Array)
      assert result[:metadata].is_a?(Hash)

      # Check that headers were extracted
      assert_not_empty result[:headers]

      # Check that rows were extracted
      assert_not_empty result[:rows]

      # Check for merged cells
      has_merged_cells = false
      result[:headers].each do |row|
        row.each do |cell|
          if cell[:colspan] > 1 || cell[:rowspan] > 1
            has_merged_cells = true
            break
          end
        end
        break if has_merged_cells
      end

      assert has_merged_cells, "No merged cells found in complex table"
    end

    def test_parses_window_schedule
      parser = Parser.new(@window_schedule_html)
      result = parser.parse

      assert result[:headers].is_a?(Array)
      assert result[:rows].is_a?(Array)
      assert result[:metadata].is_a?(Hash)

      # Check that headers were extracted
      assert_not_empty result[:headers]

      # Check that rows were extracted
      assert_not_empty result[:rows]

      # Check for specific content in window schedule
      header_content = result[:headers].flatten.map { |h| h[:content] }
      assert header_content.any? { |content| content.include?("SYMBOL") || content.include?("LOCATION") }
    end

    def test_handles_empty_table
      parser = Parser.new("<table></table>")
      result = parser.parse

      assert result[:headers].is_a?(Array)
      assert result[:rows].is_a?(Array)
      assert result[:metadata].is_a?(Hash)

      assert_empty result[:headers]
      assert_empty result[:rows]
    end

    def test_handles_malformed_html
      parser = Parser.new("<div>Not a table</div>")
      result = parser.parse

      assert result[:headers].is_a?(Array)
      assert result[:rows].is_a?(Array)
      assert result[:metadata].is_a?(Hash)

      assert_empty result[:headers]
      assert_empty result[:rows]
    end
  end
end
