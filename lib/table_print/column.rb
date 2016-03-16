module TablePrint
  class Column
    attr_reader :formatters
    attr_accessor :name, :data, :time_format, :default_width, :min_width, :fixed_width

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

    def display_method=(method)
      method = method.to_s unless method.is_a? Proc
      @display_method = method
    end

    def display_method
      @display_method ||= name
    end

    def add_formatter(formatter)
      @formatters << formatter
    end

    def data_width
      if multibyte_count
        [
          name.each_char.collect{|c| c.bytesize == 1 ? 1 : 2}.inject(0, &:+),
          Array(data).compact.collect(&:to_s).collect{|m| m.each_char.collect{|n| n.bytesize == 1 ? 1 : 2}.inject(0, &:+)}.max
        ].compact.max || 0
      else
        [
          name.length,
          Array(data).compact.collect(&:to_s).collect(&:length).max
        ].compact.max || 0
      end
    end

    def width
      return fixed_width if fixed_width

      width = [(default_width || max_width), data_width].min
      [(min_width || 0), width].max
    end

    private
    def max_width
      TablePrint::Config.max_width
    end

    def multibyte_count
      TablePrint::Config.multibyte
    end
  end
end
