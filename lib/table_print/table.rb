module TablePrint
  class Table
    include RowRecursion

    attr_accessor :config, :columns

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

    #### format ####
    
    def format
      formatter.format_table(formatter.format_header, children.collect(&:format))
    end

    private

    def formatter
      config.formatter
    end
  end
end
