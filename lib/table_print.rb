require 'fingerprinter'
require 'printable'

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

      group.add_children(Fingerprinter.new.lift(columns, @data))

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      @data.extend Printable
      @data.default_display_methods
    end
  end
end
