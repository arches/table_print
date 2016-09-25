require 'table_print/column'
require 'table_print/config_resolver'
require 'table_print/config'
require 'table_print/fingerprinter'
require 'table_print/formatter'
require 'table_print/hash_extensions'
require 'table_print/printable'
require 'table_print/markdown_formatter'
require 'table_print/row_recursion'
require 'table_print/table'
require 'table_print/row_group'
require 'table_print/row'
require 'table_print/returnable'

module TablePrint
  class Printer

    def self.table_print(data, options={})
      p = new(data, options)
      p.table_print
    end

    def initialize(data, options={})
      @data = Array(data).compact
      @options = options
      @columns = nil
      @start_time = Time.now
    end

    def table_print
      return "No data." if @data.empty?

      table = TablePrint::Table.new
      table.columns = columns

      # copy data from original objects into the group
      fingerprinter = Fingerprinter.new(columns)
      group_data = (@data.first.is_a?(Hash) || @data.first.is_a?(Struct)) ? [@data] : @data
      group_data.each do |data|
        table.add_children(fingerprinter.lift(data))
      end

      # munge the tree of data we created, to condense the output
      table.collapse!
      return "No data." if table.columns.empty?

      # turn everything into a string for output
      table.format
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
  TablePrint::Config.io.puts printer.table_print unless data.is_a? Class
  TablePrint::Returnable.new(printer.message) # we have to return *something*, might as well be execution time.
end
