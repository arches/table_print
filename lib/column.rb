module TablePrint
  class Column
    attr_reader :data, :formatters
    attr_writer :width
    attr_accessor :name

    def initialize(attr_hash)
      attr_hash.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
      @formatters ||= []
    end

    def add_formatter(formatter)
      @formatters << formatter
    end

    def data_width
      data.inject(0) {|sum, datum| sum + datum.length}
    end

    def width
      @width ||= data_width
    end
  end
end
