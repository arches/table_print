module TablePrint
  class Table
    include RowRecursion

    attr_accessor :formatter, :columns
    attr_writer :config

    def initialize
      super
      @columns = []
    end

    #### structural ####

    def collapse!
      @children.each(&:collapse!)
      @columns = @columns.select { |column| column.data.compact.any? }
    end

    def columns=(cols)
      @columns = cols
      cols.each { |c| c.table = self }
      cols
    end

    def add_column(column)
      @columns << column
      column.table = self
      column
    end

    def config
      @config ||= TablePrint::Config.singleton
    end

    #### format? ####
    
    # suspect
    def width
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

    # suspect
    def format
      formatter.format_table(formatter.format_header, children.collect(&:format))
    end

    def formatter
      @formatter ||= MarkdownFormatter.new(config, columns)
    end
  end
end
