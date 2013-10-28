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

    def initialize(width)
      self.width = width
    end

    def format(value)
      padding = width - strip_escape(value.to_s).each_char.collect{|c| c.bytesize == 1 ? 1 : 2}.inject(0, &:+)
      truncate(value) + (padding < 0 ? '' : " " * padding)
    end

    private
    def truncate(value)
      return "" unless value

      value = value.to_s
      return value unless strip_escape(value).length > width

      "#{value[0..width-4]}..."
    end

    def strip_escape(value)
      value.gsub(%r{\e[^m]*m}, '')
    end
  end
end
