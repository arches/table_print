require 'column'
require 'config_resolver'
require 'config'
require 'fingerprinter'
require 'formatter'
require 'hash_extensions'
require 'kernel_extensions'
require 'printable'
require 'row_group'

module TablePrint
  class Printer

    def self.table_print(data, options={})
      p = new(data, options)
      p.table_print
    end

    def initialize(data, options={})
      @data = [data].flatten.compact
      @options = options
    end

    def table_print
      return "No data." if @data.empty?
      group = TablePrint::RowGroup.new
      columns.each do |c|
        group.set_column(c.name, c)
      end

      @data.each do |data|
        group.add_children(Fingerprinter.new.lift(columns, data))
      end

      group.collapse!

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      defaults = TablePrint::Printable.default_display_methods(@data.first)
      c = TablePrint::ConfigResolver.new(@data.first.class, defaults, @options)
      c.columns
    end
  end
end
