module TablePrint
  class Config

    DEFAULT_MAX_WIDTH = 30
    DEFAULT_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

    @@max_width = DEFAULT_MAX_WIDTH
    @@time_format = DEFAULT_TIME_FORMAT
    @@multibyte = false

    @@klasses = {}

    def self.set(klass, val)
      if klass.is_a? Class
        @@klasses[klass] = val  # val is a hash of column options
      else
        TablePrint::Config.send("#{klass}=", val.first)
      end
    end

    def self.for(klass)
      @@klasses.fetch(klass) {}
    end

    def self.clear(klass)
      if klass.is_a? Class
        @@klasses.delete(klass)
      else
        original_value = TablePrint::Config.const_get("DEFAULT_#{klass.to_s.upcase}")
        TablePrint::Config.send("#{klass}=", original_value)
      end
    end

    def self.max_width
      @@max_width
    end

    def self.max_width=(width)
      @@max_width = width
    end

    def self.multibyte
      @@multibyte
    end

    def self.multibyte=(width)
      @@multibyte = width
    end

    def self.time_format
      @@time_format
    end

    def self.time_format=(format)
      @@time_format = format
    end
  end
end
