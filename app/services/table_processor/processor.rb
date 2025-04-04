module TableProcessor
  class Processor
    def initialize(html_content)
      @html_content = html_content || ""
      @parser = Parser.new(@html_content)
      @grid_builder = GridBuilder.new
      @header_analyzer = HeaderAnalyzer.new
      @value_mapper = ValueMapper.new
      @output_formatter = OutputFormatter.new
    end

    def process
      return "" if @html_content.strip.empty?

      # 1. Parse the HTML table structure
      table_structure = @parser.parse
      return "" if table_structure[:headers].empty? && table_structure[:rows].empty?

      # 2. Build the grid representation
      grid = @grid_builder.build(table_structure)

      # 3. Analyze headers and their relationships
      headers = @header_analyzer.analyze(grid)

      # 4. Map values to their corresponding headers
      mapped_data = @value_mapper.map(grid, headers)

      # 5. Format the output for LLM consumption
      @output_formatter.format(mapped_data)
    end
  end
end
