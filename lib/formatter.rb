module TablePrint
  class NoNewlineFormatter
    def format(value)
      value.to_s.gsub(/\n/, " ")
    end
  end

  class FixedWidthFormatter
    def initialize(width)
      @width = width
    end

    def format(value)
      "%-#{@width}s" % truncate(value)
    end

    def width
      [@width, TablePrint::Config.max_width].min
    end

    private
    def truncate(value)
      return "" unless value

      value = value.to_s
      return value unless value.length > @width

      "#{value[0..@width-4]}..."
    end
  end
end
