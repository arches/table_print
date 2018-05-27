module TablePrint
  class Column

    attr_accessor :table, :config, :name, :data

    def initialize(attr_hash={})
      @data = []
      attr_hash.each do |k, v|
        self.send("#{k}=", v)
      end
    end

    def name=(n)
      @name = n.to_s
    end

    def display_method=(method)
      method = method.to_s unless method.is_a? Proc
      @display_method = method
    end

    def display_method
      @display_method ||= name
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

      [max_width, data_width].compact.min
    end

    private
    def max_width
      config.for(:max_width)
    end

    def fixed_width
      config.for(:fixed_width)
    end

    def multibyte_count
      config.for(:multibyte)
    rescue
      false
    end
  end
end
