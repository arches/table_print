require 'column'
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
      @data = [data].flatten
      @options = options
    end

    def table_print
      group = TablePrint::RowGroup.new
      columns.each do |c|
        group.set_column(c.name, c)
      end

      @data.each do |data|
        group.add_children(Fingerprinter.new.lift(columns.collect(&:name), data))
      end

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      defaults = TablePrint::Printable.default_display_methods(@data.first)
      c = TablePrint::Config.new(defaults, @options)
      c.columns
    end
  end
end
