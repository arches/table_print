module TablePrint
  class FixedWidthFormatter
    def initialize(width)
      @width = width
    end

    def format(value)
      "%-#{@width}s" % truncate(value)
    end

    private
    def truncate(value)
      return value unless value.length > @width

      "#{value[0..@width-4]}..."
    end
  end
end
