require 'fingerprinter'
require 'printable'

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

      group.add_children(Fingerprinter.new.lift(columns.collect(&:name), @data))

      [group.header, group.horizontal_separator, group.format].join("\n")
    end

    def columns
      @data.extend Printable
      (@data.default_display_methods + included_columns - excepted_columns).sort.collect{|c| Column.new(:name => c)}
    end

    def excepted_columns
      Array(@options[:except]).collect(&:to_s)
    end

    def included_columns
      Array(@options[:include]).collect(&:to_s)
    end
  end
end
