require 'table_print/column'
require 'table_print/config_resolver'
require 'table_print/config'
require 'table_print/fingerprinter'
require 'table_print/formatter'
require 'table_print/hash_extensions'
require 'table_print/printable'
require 'table_print/row_group'
require 'table_print/returnable'

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
      @start_time = Time.now
    end

    def table_print
      return "No data." if @data.empty?
      group = TablePrint::RowGroup.new
      columns.each do |c|
        group.set_column(c.name, c)
      end

      group_data = (@data.first.is_a? Hash) ? [@data] : @data
      group_data.each do |data|
        group.add_children(Fingerprinter.new.lift(columns, data))
      end

      group.collapse!
      return "No data." if group.columns.empty?

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def message
      return "Printed with config" if configged?
      Time.now - @start_time
    end

    private
    def configged?
      !!Config.for(@data.first.class)
    end

    def columns
      return @columns if @columns
      defaults = TablePrint::Printable.default_display_methods(@data.first)
      c = TablePrint::ConfigResolver.new(@data.first.class, defaults, @options)
      @columns = c.columns
    end
  end
end

def tp(data=Class, *options)
  printer = TablePrint::Printer.new(data, options)
  puts printer.table_print unless data.is_a? Class
  TablePrint::Returnable.new(printer.message) # we have to return *something*, might as well be execution time.
end
