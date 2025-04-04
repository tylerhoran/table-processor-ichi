require "test_helper"

module TableProcessor
  class ValueMapperTest < ActiveSupport::TestCase
    def setup
      @parser = Parser.new(load_table_fixture("table-504.3.html"))
      @table_structure = @parser.parse
      @grid_builder = GridBuilder.new
      @grid = @grid_builder.build(@table_structure)
      @header_analyzer = HeaderAnalyzer.new
      @headers = @header_analyzer.analyze(@grid)
      @value_mapper = ValueMapper.new
    end

    def test_maps_values_to_headers
      mapped_data = @value_mapper.map(@grid, @headers)

      assert mapped_data.is_a?(Array)
      assert_not_empty mapped_data

      # Check that each row has key-value pairs
      mapped_data.each do |row_data|
        assert row_data.is_a?(Hash)
        assert_not_empty row_data
      end
    end

    def test_finds_data_rows
      data_rows = @value_mapper.send(:find_data_rows, @grid)

      assert data_rows.is_a?(Array)
      assert_not_empty data_rows

      # Check that the returned rows contain data cells
      data_rows.each do |row_index|
        assert @grid[row_index].any? { |cell| cell && cell[:type] != "th" }
      end
    end

    def test_finds_value_for_header
      # Find a header and a corresponding data cell
      header = @headers[:column_headers].first.first
      row_index = @value_mapper.send(:find_data_rows, @grid).first

      value = @value_mapper.send(:find_value_for_header, @grid, row_index, header)

      # The value should be a string or nil
      assert value.nil? || value.is_a?(String)
    end

    def test_builds_header_key
      # Create a simple header structure
      header = { content: "Test Header", col: 0, row: 1 }
      parent_headers = [
        [ { content: "Parent Header", col: 0, row: 0, type: "th" } ]
      ]

      key = @value_mapper.send(:build_header_key, header, parent_headers)

      assert key.is_a?(String)
      assert_includes key, "Parent Header"
      assert_includes key, "Test Header"
      assert_equal "Parent Header - Test Header", key
    end

    def test_is_parent_of
      parent = { col: 0, row: 0, type: :column }
      child = { col: 0, row: 1, type: :column }

      assert @value_mapper.send(:is_parent_of?, parent, child)

      # Test non-parent relationship
      non_parent = { col: 1, row: 0, type: :column }
      assert_not @value_mapper.send(:is_parent_of?, non_parent, child)
    end

    def test_handles_empty_grid
      empty_grid = []
      empty_headers = { column_headers: [], row_headers: [], relationships: [] }

      mapped_data = @value_mapper.map(empty_grid, empty_headers)

      assert mapped_data.is_a?(Array)
      assert_empty mapped_data
    end
  end
end
