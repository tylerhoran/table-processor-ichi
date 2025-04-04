module TableProcessor
  class OutputFormatter
    def format(mapped_data)
      return "" if mapped_data.empty?

      # For simple tables with a single row, just output key-value pairs
      if mapped_data.size == 1
        row_data = mapped_data[0]
        return "" if row_data.empty?

        row_output = []

        # Sort keys to ensure consistent output
        sorted_keys = row_data.keys.sort

        sorted_keys.each do |key|
          value = row_data[key]
          row_output << "#{key}: #{value}"
        end

        return row_output.join("\n") + "\n\n---\n"  # Add separator even for single row
      end

      # For complex tables with multiple rows, use separators
      formatted_output = []

      mapped_data.each do |row_data|
        next if row_data.empty?  # Skip empty rows

        row_output = []

        # Sort keys to ensure consistent output
        sorted_keys = row_data.keys.sort

        sorted_keys.each do |key|
          value = row_data[key]
          row_output << "#{key}: #{value}"
        end

        formatted_output << row_output.join("\n")
      end

      return "" if formatted_output.empty?

      # Join rows with separator and ensure trailing separator
      formatted_output.join("\n\n---\n\n") + "\n---\n"
    end
  end
end
