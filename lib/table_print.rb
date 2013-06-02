require 'table_print/cattr'
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

    # Convenience method to call table_print() method (which is an instance method) on the class
    def self.table_print(data, options={})
      p = new(data, options)
      p.table_print
    end

    def initialize(data, options={})
      @data = [data].flatten.compact
      @options = options
      @columns = nil
    end

    # Constructs string output in a tabular form which can be printed
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

    # Returns the columns for the stored data
    def columns
      return @columns if @columns
      default_columns = TablePrint::Printable.default_display_methods(@data.first)
      c = TablePrint::ConfigResolver.new(@data.first.class, default_columns, @options)
      @columns = c.columns
    end

  end
end


def tp(data=Class, *options)
  start = Time.now
  printer = TablePrint::Printer.new(data, options)

  puts "\n"
  puts printer.table_print unless data.is_a? Class
  puts "\n"
  TablePrint::Returnable.new(Time.now - start) # we have to return *something*, might as well be execution time.
end
