module TablePrint
  class Column
    attr_reader :formatters
    attr_writer :width, :display_method
    attr_accessor :name, :data

    def initialize(attr_hash={})
      @formatters = []
      attr_hash.each do |k, v|
        self.send("#{k}=", v)
      end
    end

    def name=(n)
      @name = n.to_s
    end

    def formatters=(formatter_list)
      formatter_list.each do |f|
        add_formatter(f)
      end
    end

    def display_method=(method_name)
      @display_method = method_name.to_s
    end

    def display_method
      @display_method ||= name
    end

    def add_formatter(formatter)
      @formatters << formatter
    end

    def data_width
      [name.length].concat(data.compact.collect(&:to_s).collect(&:length)).max
    end

    def width
      @width ||= data_width
    end
  end
end
