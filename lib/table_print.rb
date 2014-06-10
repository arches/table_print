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
      @data = Array(data).compact
      @options = options
      @columns = nil
      @start_time = Time.now
    end

    def table_print
      return "No data." if @data.empty?

      # it's groups all the way down
      # make a top-level group to hold everything we're about to do
      group = TablePrint::RowGroup.new

      # parse the config and attach it to the group
      columns.each do |c|
        group.set_column(c)
      end

      # copy data from original objects into the group
      group_data = (@data.first.is_a?(Hash) || @data.first.is_a?(Struct)) ? [@data] : @data
      group_data.each do |data|
        group.add_children(Fingerprinter.new.lift(columns, data))
      end

      # munge the tree of data we created, to condense the output
      group.collapse!
      return "No data." if group.columns.empty?

      # turn everything into a string for output
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
  TablePrint::Config.io.puts printer.table_print unless data.is_a? Class
  TablePrint::Returnable.new(printer.message) # we have to return *something*, might as well be execution time.
end
