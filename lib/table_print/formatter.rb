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
      padding = width - length(escape_strip(value).to_s)
      truncate(value) + (padding < 0 ? '' : " " * padding)
    end

    private
    def truncate(value)
      return "" unless value

      value = value.to_s

      value_stripped, stripped_stuff = escape_strip(value, true)

      return value unless value_stripped.length > width

      "#{value[0..(width + stripped_stuff.length)-4]}..."
    end

    def length(str)
      if TablePrint::Config.multibyte
        str.each_char.collect{|c| c.bytesize == 1 ? 1 : 2}.inject(0, &:+)
      else
        str.length
      end
    end

    def escape_strip(string, return_stripped_stuff = false)
      return string unless string.class == String
      stripped_stuff = ''
      string_stripped = string.gsub(/\e\[([0-9]{1,2};){0,2}[0-9]{1,2}m/) do |s|
        stripped_stuff << s
        s = ''
      end
      return string_stripped, stripped_stuff if return_stripped_stuff == true
      return string_stripped
    end
  end
end
