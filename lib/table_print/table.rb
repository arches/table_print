module TablePrint
  class Table
    include RowRecursion

    attr_accessor :formatter

    def initialize
      super
      @columns = []
    end

    #### structural ####

    def collapse!
      @children.each(&:collapse!)
    end

    def columns=(cols)
      @columns = cols
    end

    def add_column(column)
      @columns << column
    end

    #### format? ####
    
    # suspect
    def columns
      @columns.select { |column| column.data.compact.any? }
    end

    # suspect
    def width
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

    # suspect
    def format
      formatter.format_table(formatter.format_header, children.collect(&:format))
    end

    def formatter
      @formatter ||= MarkdownFormatter.new(@columns)
    end
  end
end
