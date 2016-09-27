module TablePrint

  class MarkdownFormatter

    attr_accessor :config, :columns

    def initialize(config, columns)
      @config = config
      @columns = columns
    end

    def format_cell(column, value)
      cell_formatters = []
      cell_formatters.concat(Array(column.formatters))

      cell_formatters << TimeFormatter.new(column.time_format || config.time_format)
      cell_formatters << NoNewlineFormatter.new
      fixed_width = FixedWidthFormatter.new(column.width)
      fixed_width.multibyte = config.multibyte
      cell_formatters << fixed_width

      # successively apply the cell_formatters for a column
      cell_formatters.inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def format_row(cells)
      cells.join(" #{config.separator} ")
    end

    def format_table(header, rows)
      [header, horizontal_separator].concat(rows).join("\n")
    end

    def format_header
      padded_names = columns.collect do |column|
        f = FixedWidthFormatter.new(column.width)
        f.format(column.name)
      end

      header_string = padded_names.join(" #{config.separator} ")
      header_string.upcase! if config.capitalize_headers

      header_string
    end

    def horizontal_separator
      columns.collect do |column|
        '-' * column.width
      end.join("-#{config.separator}-")
    end
  end
end
