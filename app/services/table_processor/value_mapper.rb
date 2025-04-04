module TableProcessor
  class ValueMapper
    def map(grid, headers)
      map_values(grid, headers)
    end

    def map_values(grid, headers)
      return [] if grid.nil? || grid.empty? || headers.nil? || headers.empty?

      data_rows = find_data_rows(grid)
      return [] if data_rows.empty?

      mapped_data = []
      data_rows.each do |row_index|
        row_data = {}

        # Map column headers to values
        headers[:column_headers].each_with_index do |header_row, level|
          header_row.each do |header|
            value = find_value_for_header(grid, row_index, header)
            if value
              key = build_header_key(header, headers[:column_headers][0...level])
              row_data[key] = value
            end
          end
        end

        # Map row headers to values
        headers[:row_headers].each_with_index do |header_col, level|
          header_col.each do |header|
            value = find_value_for_header(grid, row_index, header)
            if value
              key = build_header_key(header, headers[:row_headers][0...level])
              row_data[key] = value
            end
          end
        end

        mapped_data << row_data if row_data.any?
      end

      mapped_data
    end

    private

    def find_data_rows(grid)
      return [] if grid.nil? || grid.empty?

      data_rows = []
      header_rows = Set.new  # Keep track of known header rows

      # First pass: identify header rows
      grid.each_with_index do |row, row_index|
        next unless row
        if row.any? { |cell| cell && cell[:type] == "th" && !cell[:spanned] }
          header_rows.add(row_index)
        end
      end

      # Second pass: find data rows
      grid.each_with_index do |row, row_index|
        next unless row
        next if header_rows.include?(row_index)

        # A row is a data row if it has any non-spanned cells with content
        if row.any? { |cell| cell && !cell[:spanned] && cell[:content].to_s.strip.length > 0 }
          data_rows << row_index
        end
      end

      # If no data rows found, try again with less strict criteria
      if data_rows.empty?
        grid.each_with_index do |row, row_index|
          next unless row
          next if header_rows.include?(row_index)

          # Consider any row with content as a data row
          if row.any? { |cell| cell && cell[:content].to_s.strip.length > 0 }
            data_rows << row_index
          end
        end
      end

      data_rows
    end

    def find_value_for_header(grid, row_index, header)
      return nil if grid.nil? || grid.empty? || row_index.nil? || header.nil?
      return nil if row_index >= grid.size || header[:col].nil?
      return nil if grid[row_index].nil? || header[:col] >= grid[row_index].size

      col = header[:col]
      cell = grid[row_index][col]

      if cell && !cell[:spanned] && cell[:type] != "th"
        content = cell[:original_content].to_s.strip
        content.empty? ? nil : content
      end
    end

    def build_header_key(header, parent_headers = nil)
      return header[:content] if parent_headers.nil? || parent_headers.empty?

      key_parts = []

      # Add parent headers
      parent_headers.each do |parent_row|
        parent_row.each do |parent|
          if is_parent_of?(parent, header)
            key_parts << parent[:content]
          end
        end
      end

      # Add current header
      key_parts << header[:content]

      # Join with spaces for hierarchical headers
      key_parts.join(" - ")
    end

    def is_parent_of?(parent, child)
      return false if parent.nil? || child.nil?

      if parent[:type] == :column || parent[:type] == "th"
        # For column headers, check if they share the same column and the parent is above
        parent[:col] == child[:col] && parent[:row] < child[:row]
      else
        # For row headers, check if they share the same row and the parent is to the left
        parent[:row] == child[:row] && parent[:col] < child[:col]
      end
    end
  end
end
