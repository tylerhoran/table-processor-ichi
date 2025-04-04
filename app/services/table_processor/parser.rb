require "nokogiri"

module TableProcessor
  class Parser
    def initialize(html_content)
      @html_content = html_content
    end

    def parse
      doc = Nokogiri::HTML(@html_content)
      table = doc.at_css("table")

      return { headers: [], rows: [], metadata: {} } unless table

      {
        headers: extract_headers(table),
        rows: extract_rows(table),
        metadata: extract_metadata(table)
      }
    end

    private

    def extract_headers(table)
      return [] unless table

      headers = []

      # Extract thead if present
      if thead = table.at_css("thead")
        thead.css("tr").each_with_index do |tr, row_index|
          row_headers = []
          tr.css("th, td").each_with_index do |cell, col_index|
            row_headers << {
              content: extract_cell_content(cell),
              colspan: normalize_span_value(cell["colspan"]),
              rowspan: normalize_span_value(cell["rowspan"]),
              type: "th",  # Always treat thead cells as headers
              row: row_index,
              col: col_index
            }
          end
          headers << row_headers unless row_headers.empty?
        end
        return headers  # Return early if we found headers in thead
      end

      # Extract header cells from tbody if no thead
      if headers.empty? && tbody = table.at_css("tbody")
        header_rows = []
        tbody.css("tr").each_with_index do |tr, row_index|
          # Check if this row contains any header-like cells
          has_header_cells = tr.css("th").any?

          if has_header_cells || row_index == 0  # Consider first row as header if no headers found yet
            row_headers = []
            tr.css("th, td").each_with_index do |cell, col_index|
              row_headers << {
                content: extract_cell_content(cell),
                colspan: normalize_span_value(cell["colspan"]),
                rowspan: normalize_span_value(cell["rowspan"]),
                type: "th",  # Treat all cells in header rows as headers
                row: header_rows.size,  # Use the current header row count
                col: col_index
              }
            end
            header_rows << row_headers unless row_headers.empty?
          else
            # If we've found any header rows and this is not a header row, stop looking
            break
          end
        end
        headers = header_rows
      end

      # Handle tables without thead/tbody
      if headers.empty?
        # First row with th elements is considered header
        table.css("tr").each_with_index do |tr, row_index|
          if tr.at_css("th")
            row_headers = []
            tr.css("th").each_with_index do |cell, col_index|
              row_headers << {
                content: extract_cell_content(cell),
                colspan: normalize_span_value(cell["colspan"]),
                rowspan: normalize_span_value(cell["rowspan"]),
                type: "th",
                row: row_index,
                col: col_index
              }
            end
            headers << row_headers unless row_headers.empty?
            break  # Stop after first row with th elements
          end
        end

        # If still no headers, use first row as header
        if headers.empty?
          first_row = table.at_css("tr")
          if first_row
            row_headers = []
            first_row.css("td").each_with_index do |cell, col_index|
              row_headers << {
                content: extract_cell_content(cell),
                colspan: normalize_span_value(cell["colspan"]),
                rowspan: normalize_span_value(cell["rowspan"]),
                type: "th",  # Treat as header
                row: 0,
                col: col_index
              }
            end
            headers << row_headers unless row_headers.empty?
          end
        end
      end

      headers
    end

    def extract_rows(table)
      rows = []
      header_rows = 0

      # First try to extract from tbody
      if tbody = table.at_css("tbody")
        tbody.css("tr").each_with_index do |tr, row_index|
          # Skip if this is a header row (contains th elements)
          next if tr.css("th").any?

          row = []
          tr.css("td").each_with_index do |td, col_index|
            row << {
              content: extract_cell_content(td),
              colspan: normalize_span_value(td["colspan"]),
              rowspan: normalize_span_value(td["rowspan"]),
              type: "td",  # Treat as data cell
              row: row_index,
              col: col_index
            }
          end
          rows << row unless row.empty?
        end
      else
        # Handle tables without tbody
        # Skip the first row if it contains headers
        rows_to_process = table.css("tr")
        if rows_to_process.any? && rows_to_process.first.at_css("th")
          header_rows = 1
          rows_to_process = rows_to_process[1..-1]
        end

        rows_to_process.each_with_index do |tr, row_index|
          row = []
          tr.css("td").each_with_index do |td, col_index|
            row << {
              content: extract_cell_content(td),
              colspan: normalize_span_value(td["colspan"]),
              rowspan: normalize_span_value(td["rowspan"]),
              type: "td",  # Treat as data cell
              row: header_rows + row_index,
              col: col_index
            }
          end
          rows << row unless row.empty?
        end
      end

      rows
    end

    def extract_metadata(table)
      {
        class: table["class"],
        id: table["id"],
        style: table["style"]
      }
    end

    def extract_cell_content(cell)
      return "" unless cell

      # Get text content and normalize whitespace
      content = cell.text.to_s.strip
      content.gsub(/\s+/, " ")
    end

    def normalize_span_value(value)
      value.to_i > 1 ? value.to_i : 1
    end

    def determine_cell_type(cell)
      return "th" if cell.name == "th"
      return "td" if cell.name == "td"
      "td"  # Default to td if unknown
    end
  end
end
