module TablePrint
  class TimeFormatter
    def initialize(time_format=nil)
      @format = time_format
      @format ||= TablePrint::Config.time_format
    end

    def format(value)
      return value unless value.is_a? Time
      value.strftime @format
    end
  end

  class NoNewlineFormatter
    def format(value)
      value.to_s.gsub(/\r\n/, "\n").gsub(/\n/, " ")
    end
  end

  class FixedWidthFormatter
    attr_accessor :width
    attr_accessor :align

    def initialize(width, align=:left)
      self.width = width
      self.align = align
    end

    def format(value)
      case align
      when :left, 'left', 'l'
        truncate(value).ljust(width)
      when :right, 'right', 'r'
        truncate(value).rjust(width)
      when :center, 'center', 'c'
        truncate(value).center(width)
      else
        truncate(value).ljust(width)
      end
    end

    private
    def truncate(value)
      return "" unless value

      value = value.to_s
      return value unless value.length > width

      "#{value[0..width-4]}..."
    end

    def length(str)
      if TablePrint::Config.multibyte
        str.each_char.collect{|c| c.bytesize == 1 ? 1 : 2}.inject(0, &:+)
      else
        str.length
      end
    end
  end
end
