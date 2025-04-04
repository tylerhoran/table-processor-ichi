require "test_helper"

module TableProcessor
  class HeaderAnalyzerTest < ActiveSupport::TestCase
    def setup
      @parser = Parser.new(load_table_fixture("table-504.3.html"))
      @table_structure = @parser.parse
      @grid_builder = GridBuilder.new
      @grid = @grid_builder.build(@table_structure)
      @header_analyzer = HeaderAnalyzer.new
    end

    def test_analyzes_column_headers
      result = @header_analyzer.analyze(@grid)

      assert result[:column_headers].is_a?(Array)
      assert_not_empty result[:column_headers]

      # Check that column headers have the expected structure
      result[:column_headers].each do |row|
        assert row.is_a?(Array)
        row.each do |header|
          assert header.is_a?(Hash)
          assert_includes header.keys, :content
          assert_includes header.keys, :col
          assert_includes header.keys, :row
          assert_includes header.keys, :level
          assert_includes header.keys, :children
        end
      end
    end

    def test_analyzes_row_headers
      result = @header_analyzer.analyze(@grid)

      assert result[:row_headers].is_a?(Array)

      # Some tables might not have row headers
      if result[:row_headers].any?
        result[:row_headers].each do |col|
          assert col.is_a?(Array)
          col.each do |header|
            assert header.is_a?(Hash)
            assert_includes header.keys, :content
            assert_includes header.keys, :col
            assert_includes header.keys, :row
            assert_includes header.keys, :level
            assert_includes header.keys, :children
          end
        end
      end
    end

    def test_analyzes_header_relationships
      result = @header_analyzer.analyze(@grid)

      assert result[:relationships].is_a?(Array)

      # Check that relationships have the expected structure
      result[:relationships].each do |relationship|
        assert relationship.is_a?(Hash)
        assert_includes relationship.keys, :parent
        assert_includes relationship.keys, :child
        assert_includes relationship.keys, :type
        assert_includes relationship.keys, :level
        assert_includes [ :column, :row ], relationship[:type]
      end
    end

    def test_finds_header_rows
      header_rows = @header_analyzer.send(:find_header_rows, @grid)

      assert header_rows.is_a?(Array)
      assert_not_empty header_rows

      # Check that the returned rows contain header cells
      header_rows.each do |row_index|
        assert @grid[row_index].any? { |cell| cell && cell[:type] == "th" }
      end
    end

    def test_finds_header_columns
      header_cols = @header_analyzer.send(:find_header_columns, @grid)

      assert header_cols.is_a?(Array)

      # Some tables might not have header columns
      if header_cols.any?
        header_cols.each do |col_index|
          assert @grid.any? { |row| row[col_index] && row[col_index][:type] == "th" }
        end
      end
    end

    def test_handles_empty_grid
      empty_grid = []
      result = @header_analyzer.analyze(empty_grid)

      assert result[:column_headers].is_a?(Array)
      assert result[:row_headers].is_a?(Array)
      assert result[:relationships].is_a?(Array)

      assert_empty result[:column_headers]
      assert_empty result[:row_headers]
      assert_empty result[:relationships]
    end
  end
end
