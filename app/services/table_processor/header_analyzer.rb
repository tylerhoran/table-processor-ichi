module TableProcessor
  class HeaderAnalyzer
    def analyze(grid)
      return { column_headers: [], row_headers: [], relationships: [] } if grid.nil? || grid.empty?

      {
        column_headers: analyze_column_headers(grid),
        row_headers: analyze_row_headers(grid),
        relationships: analyze_header_relationships(grid)
      }
    end

    private

    def analyze_column_headers(grid)
      return [] if grid.nil? || grid.empty?

      headers = []
      header_rows = find_header_rows(grid)

      header_rows.each do |row_index|
        row_headers = []
        col = 0

        while col < grid[row_index].size
          cell = grid[row_index][col]
          if cell && cell[:type] == "th" && !cell[:spanned]
            # Include only main cells, not spanned cells
            header = {
              content: cell[:original_content] || cell[:content],
              col: col,  # Use current column position
              row: row_index,  # Use current row position
              level: row_index,
              children: find_child_headers(grid, row_index, col)
            }
            row_headers << header unless row_headers.any? { |h| h[:col] == header[:col] && h[:row] == header[:row] }
          end
          col += 1
        end

        headers << row_headers unless row_headers.empty?
      end

      headers
    end

    def analyze_row_headers(grid)
      return [] if grid.nil? || grid.empty?

      headers = []
      header_cols = find_header_columns(grid)

      header_cols.each do |col_index|
        col_headers = []
        row = 0

        while row < grid.size
          cell = grid[row] && grid[row][col_index]
          if cell && cell[:type] == "th" && !cell[:spanned]
            # Include only main cells, not spanned cells
            header = {
              content: cell[:original_content] || cell[:content],
              col: col_index,  # Use current column position
              row: row,  # Use current row position
              level: col_index,
              children: find_child_headers(grid, row, col_index, :row)
            }
            col_headers << header unless col_headers.any? { |h| h[:col] == header[:col] && h[:row] == header[:row] }
          end
          row += 1
        end

        headers << col_headers unless col_headers.empty?
      end

      headers
    end

    def analyze_header_relationships(grid)
      return [] if grid.nil? || grid.empty?

      relationships = []

      # Analyze relationships between column headers
      column_headers = analyze_column_headers(grid)
      column_headers.each_with_index do |row, row_index|
        row.each do |header|
          if header[:children].any?
            header[:children].each do |child|
              relationships << {
                parent: header[:content],
                child: child[:content],
                type: :column,
                level: row_index
              }
            end
          end
        end
      end

      # Analyze relationships between row headers
      row_headers = analyze_row_headers(grid)
      row_headers.each_with_index do |col, col_index|
        col.each do |header|
          if header[:children].any?
            header[:children].each do |child|
              relationships << {
                parent: header[:content],
                child: child[:content],
                type: :row,
                level: col_index
              }
            end
          end
        end
      end

      relationships
    end

    def find_header_rows(grid)
      return [] if grid.nil? || grid.empty?

      header_rows = []
      row = 0

      while row < grid.size
        if grid[row] && grid[row].any? { |cell| cell && cell[:type] == "th" && !cell[:spanned] }
          header_rows << row
        end
        row += 1
      end

      header_rows
    end

    def find_header_columns(grid)
      return [] if grid.nil? || grid.empty? || grid[0].nil?

      header_cols = []
      col = 0

      while col < grid[0].size
        if grid.any? { |row| row && row[col] && row[col][:type] == "th" && !row[col][:spanned] }
          header_cols << col
        end
        col += 1
      end

      header_cols
    end

    def find_child_headers(grid, row, col, direction = :column)
      return [] if grid.nil? || grid.empty? || row >= grid.size || col >= grid[0].size

      children = []

      if direction == :column
        # Look for child headers in the next row
        next_row = row + 1
        while next_row < grid.size
          cell = grid[next_row] && grid[next_row][col]
          if cell && cell[:type] == "th" && !cell[:spanned]
            child = {
              content: cell[:original_content] || cell[:content],
              col: col,  # Use current column position
              row: next_row  # Use current row position
            }
            children << child unless children.any? { |c| c[:col] == child[:col] && c[:row] == child[:row] }
          end
          next_row += 1
        end
      else
        # Look for child headers in the next column
        next_col = col + 1
        while next_col < grid[row].size
          cell = grid[row] && grid[row][next_col]
          if cell && cell[:type] == "th" && !cell[:spanned]
            child = {
              content: cell[:original_content] || cell[:content],
              col: next_col,  # Use current column position
              row: row  # Use current row position
            }
            children << child unless children.any? { |c| c[:col] == child[:col] && c[:row] == child[:row] }
          end
          next_col += 1
        end
      end

      children
    end
  end
end
