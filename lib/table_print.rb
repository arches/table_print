require 'fingerprinter'
require 'printable'
require 'config'

module TablePrint
  class Printer

    def self.table_print(data, options={})
      p = new(data, options)
      p.table_print
    end

    def initialize(data, options={})
      @data = data
      @options = options
    end

    def table_print
      group = TablePrint::RowGroup.new
      columns.each do |c|
        group.set_column(c.name, c)
      end

      group.add_children(Fingerprinter.new.lift(columns.collect(&:name), @data))

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      @data.extend Printable
      c = TablePrint::Config.new(@data.default_display_methods, @options)
      c.columns
    end
  end
end
