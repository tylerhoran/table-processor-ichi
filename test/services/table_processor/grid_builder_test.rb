require "test_helper"

module TableProcessor
  class GridBuilderTest < ActiveSupport::TestCase
    def setup
      @parser = Parser.new(load_table_fixture("table-504.3.html"))
      @table_structure = @parser.parse
      @grid_builder = GridBuilder.new
    end

    def test_builds_grid_from_table_structure
      grid = @grid_builder.build(@table_structure)

      assert grid.is_a?(Array)
      assert_not_empty grid
      assert grid[0].is_a?(Array)
      assert_not_empty grid[0]
    end

    def test_grid_dimensions_match_table_structure
      grid = @grid_builder.build(@table_structure)

      # Calculate expected dimensions
      max_cols = 0
      @table_structure[:headers].each do |row|
        cols = row.sum { |cell| cell[:colspan] }
        max_cols = [ max_cols, cols ].max
      end

      @table_structure[:rows].each do |row|
        cols = row.sum { |cell| cell[:colspan] }
        max_cols = [ max_cols, cols ].max
      end

      max_rows = @table_structure[:headers].size + @table_structure[:rows].size

      # Check grid dimensions
      assert_equal max_rows, grid.size
      assert_equal max_cols, grid[0].size
    end

    def test_handles_merged_cells
      grid = @grid_builder.build(@table_structure)

      # Find a merged cell
      merged_cell = nil
      grid.each do |row|
        row.each do |cell|
          if cell && cell[:spanned]
            merged_cell = cell
            break
          end
        end
        break if merged_cell
      end

      assert_not_nil merged_cell, "No merged cells found in grid"
      assert merged_cell[:spanned]
      assert_not_nil merged_cell[:content]
    end

    def test_cell_content_preserved
      grid = @grid_builder.build(@table_structure)

      # Check that cell content is preserved
      header_content = grid.flatten.compact.select { |cell| cell[:type] == "th" }.map { |cell| cell[:content] }
      grid_content = grid.flatten.compact.map { |cell| cell[:content] }

      # All header content should be in the grid
      header_content.each do |content|
        assert grid_content.include?(content), "Header content '#{content}' not found in grid"
      end
    end

    def test_handles_empty_table_structure
      empty_structure = { headers: [], rows: [], metadata: {} }
      grid = @grid_builder.build(empty_structure)

      assert grid.is_a?(Array)
      assert_empty grid
    end
  end
end
