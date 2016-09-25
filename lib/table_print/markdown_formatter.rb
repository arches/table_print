module TablePrint

  class MarkdownFormatter

    attr_accessor :columns

    def initialize(columns)
      @columns = columns
    end

    def format_cell(column, value)
      cell_formatters = []
      cell_formatters.concat(Array(column.formatters))

      cell_formatters << TimeFormatter.new(column.time_format)
      cell_formatters << NoNewlineFormatter.new
      cell_formatters << FixedWidthFormatter.new(column.width)

      # successively apply the cell_formatters for a column
      cell_formatters.inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def format_row(cells)
      cells.join(" #{TablePrint::Config.separator} ")
    end

    def format_table(header, rows)
      [header, horizontal_separator].concat(rows).join("\n")
    end

    def format_header
      padded_names = columns.collect do |column|
        f = FixedWidthFormatter.new(column.width)
        f.format(column.name)
      end

      header_string = padded_names.join(" #{TablePrint::Config.separator} ")
      header_string.upcase! if TablePrint::Config.capitalize_headers

      header_string
    end

    def horizontal_separator
      columns.collect do |column|
        '-' * column.width
      end.join("-#{TablePrint::Config.separator}-")
    end
  end

end
