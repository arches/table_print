require 'table_print/column'
require 'table_print/config_resolver'
require 'table_print/config'
require 'table_print/fingerprinter'
require 'table_print/formatter'
require 'table_print/hash_extensions'
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
      @start_time = Time.now
    end

    def table_print
      return "No data." if @data.empty?

      config = Config.singleton
      columns = TablePrint::ConfigResolver.new(config, @data.first, @options).columns

      config.formatter = MarkdownFormatter.new(config, columns)

      # copy data from original objects into the table
      fingerprinter = Fingerprinter.new(config, columns)

      table = fingerprinter.lift(@data)

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
      !!Config.singleton.for(@data.first.class)
    end
  end
end

def tp(data=Class, *options)
  printer = TablePrint::Printer.new(data, options)
  TablePrint::Config.singleton.io.puts printer.table_print unless data.is_a? Class
  TablePrint::Returnable.new(printer.message) # we have to return *something*, might as well be execution time.
end
