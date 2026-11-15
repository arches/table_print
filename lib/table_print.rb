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
      # a single hash is one row, not a list of [key, value] pairs
      @data = data.is_a?(Hash) ? [data] : Array(data).compact

      # Convert array of arrays into hashes
      @data = @data.collect { |row| Array(row).each_with_index.to_h { |cell, i| [i.to_s, cell] } } if @data.first.is_a?(Array)

      # Columns are looked up by name, so a key that isn't already a string or a
      # symbol can never be found
      @data = @data.collect { |row| stringify_exotic_keys(row) } if @data.first.is_a?(Hash)

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
      group_data = (@data.first.is_a?(Hash) || @data.first.is_a?(Struct) || @data.first.is_a?(Range)) ? [@data] : @data
      group_data.each do |data|
        group.add_children(Fingerprinter.new.lift(columns, data))
      end

      # munge the tree of data we created, to condense the output
      group.collapse!
      return "No data." if group.columns.empty?

      # turn everything into a string for output
      # the line under the header has nothing to be under when headers are off
      lines = [group.format]
      lines.unshift(group.header, group.horizontal_separator) if TablePrint::Config.show_headers
      lines.compact.join("\n")
    end

    def message
      return "Printed with config" if configged?
      (Time.now - @start_time).to_s
      # the message is used to initiate Returnable
      # whose argument is regarded in ruby 2.7.1 as string
      # (ruby 2.7.1 calls ".includes?" method on this argument)
    end

    private
    def stringify_exotic_keys(row)
      # Skip rows that aren't affected because transform_keys returns a plain Hash,
      # which would strip a subclass like HashWithIndifferentAccess of the lookup a
      # lambda column may rely on
      return row if row.keys.all? { |key| key.is_a?(String) || key.is_a?(Symbol) }
      row.transform_keys { |key| key.is_a?(String) || key.is_a?(Symbol) ? key : key.to_s }
    end

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
