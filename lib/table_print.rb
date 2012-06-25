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
      @columns = nil
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
      return "No data." if group.columns.empty?

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      return @columns if @columns
      defaults = TablePrint::Printable.default_display_methods(@data.first)
      c = TablePrint::ConfigResolver.new(@data.first.class, defaults, @options)
      @columns = c.columns
    end
  end
end
