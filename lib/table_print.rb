require_relative './fingerprinter'
require_relative './printable'

module TablePrint
  class Printer

    def self.table_print(data)
      p = new(data)
      p.table_print
    end

    def initialize(data)
      @data = data
    end

    def table_print
      group = TablePrint::RowGroup.new
      group.add_row(header)

      group.add_rows(Fingerprinter.new.lift(columns, @data))

      group.set_column_widths(columns)

      group.format(columns)
    end

    def header
      row = TablePrint::Row.new

      cell_hash = {}
      columns.each { |name| cell_hash[name] = name.upcase }

      row.set_cell_values(cell_hash)
    end

    def columns
      @data.extend Printable
      @data.default_display_methods
    end
  end
end
