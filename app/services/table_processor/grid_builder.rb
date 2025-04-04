module TableProcessor
  class GridBuilder
    def build(table_structure)
      return [] if table_structure.nil? || table_structure[:headers].nil? || table_structure[:rows].nil?
      return [] if table_structure[:headers].empty? && table_structure[:rows].empty?

      # Calculate grid dimensions
      max_rows = calculate_max_rows(table_structure)
      max_cols = calculate_max_columns(table_structure)

      # Initialize empty grid
      grid = Array.new(max_rows) { Array.new(max_cols) }

      # Track filled positions
      filled_positions = Set.new

      # Fill headers
      current_row = 0
      table_structure[:headers].each do |header_row|
        current_col = 0
        header_row.each do |header|
          next if header[:content].to_s.strip.empty?  # Skip empty headers

          # Skip filled positions
          while current_col < max_cols && filled_positions.include?([ current_row, current_col ])
            current_col += 1
          end

          # Fill the cell and its spans
          fill_cell(grid, current_row, current_col, header)

          # Mark positions as filled
          (0...header[:rowspan]).each do |r|
            (0...header[:colspan]).each do |c|
              filled_positions.add([ current_row + r, current_col + c ])
            end
          end

          current_col += header[:colspan]  # Move to next column position
        end
        current_row += 1  # Move to next row
      end

      # Fill data rows
      header_rows = table_structure[:headers].size
      table_structure[:rows].each_with_index do |row, row_index|
        current_col = 0
        row.each do |cell|
          next if cell[:content].to_s.strip.empty?  # Skip empty cells

          # Skip filled positions
          while current_col < max_cols && filled_positions.include?([ header_rows + row_index, current_col ])
            current_col += 1
          end

          # Fill the cell and its spans
          fill_cell(grid, header_rows + row_index, current_col, cell)

          # Mark positions as filled
          (0...cell[:rowspan]).each do |r|
            (0...cell[:colspan]).each do |c|
              filled_positions.add([ header_rows + row_index + r, current_col + c ])
            end
          end

          current_col += cell[:colspan]  # Move to next column position
        end
      end

      # Remove empty rows and columns
      grid = remove_empty_rows_and_columns(grid)

      grid
    end

    private

    def calculate_max_rows(table_structure)
      max_rows = 0

      # Count header rows
      table_structure[:headers].each do |header_row|
        max_rows += 1  # Each header row takes one row
      end

      # Count data rows
      table_structure[:rows].each do |row|
        max_rows += 1  # Each data row takes one row
      end

      max_rows
    end

    def calculate_max_columns(table_structure)
      max_cols = 0
      current_col = 0

      # Count header columns
      table_structure[:headers].each do |header_row|
        current_col = 0
        header_row.each do |header|
          current_col += header[:colspan]
        end
        max_cols = [ max_cols, current_col ].max
      end

      # Count data columns
      table_structure[:rows].each do |row|
        current_col = 0
        row.each do |cell|
          current_col += cell[:colspan]
        end
        max_cols = [ max_cols, current_col ].max
      end

      max_cols
    end

    def fill_cell(grid, row, col, cell)
      return if row >= grid.size || col >= grid[0].size

      # Ensure content is not nil and properly stripped
      content = cell[:content].to_s.strip
      original_content = cell[:content].to_s.strip

      # Fill the main cell
      grid[row][col] = {
        content: content,
        original_content: original_content,
        type: cell[:type],
        row: row,
        col: col,
        rowspan: cell[:rowspan],
        colspan: cell[:colspan],
        spanned: false
      }

      # Fill spanned cells with references to the main cell
      (0...cell[:rowspan]).each do |r|
        (0...cell[:colspan]).each do |c|
          next if r == 0 && c == 0  # Skip main cell
          if row + r < grid.size && col + c < grid[0].size
            grid[row + r][col + c] = grid[row][col].merge(spanned: true)
          end
        end
      end
    end

    def remove_empty_rows_and_columns(grid)
      # Remove empty rows
      grid = grid.reject { |row| row.all?(&:nil?) }

      # Remove empty columns
      empty_cols = []
      (0...grid[0].size).each do |col|
        empty = true
        (0...grid.size).each do |row|
          if grid[row][col]
            empty = false
            break
          end
        end
        empty_cols << col if empty
      end

      # Remove empty columns from each row
      grid.map { |row| row.reject.with_index { |_, col| empty_cols.include?(col) } }
    end

    def determine_cell_type(cell)
      return "th" if cell.name == "th"
      return "th" if cell.classes.include?("header") || cell.classes.include?("bold")
      return "th" if cell.at_css("strong, b")
      return "th" if cell["style"]&.include?("font-weight: bold") || cell["style"]&.include?("font-weight:bold")
      return "th" if cell["align"] == "center" && cell["valign"] == "middle"
      return "th" if cell.parent&.name == "thead"
      "td"
    end

    def build_cell_data(cell, row_index, col_index)
      content = cell.text.to_s.strip
      original_content = content.dup
      type = determine_cell_type(cell)
      colspan = (cell["colspan"] || 1).to_i
      rowspan = (cell["rowspan"] || 1).to_i

      {
        content: content,
        original_content: original_content,
        type: type,
        row: row_index,
        col: col_index,
        colspan: colspan,
        rowspan: rowspan,
        spanned: false
      }
    end
  end
end
