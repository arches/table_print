module TablePrint
  class Config

    DEFAULT_MAX_WIDTH = 30
    DEFAULT_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
    DEFAULT_IO = $stdout
    DEFAULT_CAPITALIZE_HEADERS = true
    DEFAULT_SHOW_HEADERS = true
    DEFAULT_SEPARATOR = "|"
    DEFAULT_HORIZONTAL_SEPARATOR = "-"
    DEFAULT_MULTIBYTE = false

    @@max_width = DEFAULT_MAX_WIDTH
    @@time_format = DEFAULT_TIME_FORMAT
    @@multibyte = DEFAULT_MULTIBYTE
    @@io = DEFAULT_IO
    @@capitalize_headers = DEFAULT_CAPITALIZE_HEADERS
    @@show_headers = DEFAULT_SHOW_HEADERS
    @@separator = DEFAULT_SEPARATOR
    @@horizontal_separator = DEFAULT_HORIZONTAL_SEPARATOR

    @@klasses = {}

    def self.set(klass, val)
      if klass.is_a? Class
        @@klasses[klass] = val  # val is a hash of column options
      else
        TablePrint::Config.send("#{klass}=", val.first)
      end
    end

    # A copy, because resolving options consumes them: ConfigResolver reads an
    # :include or :except out of the hash it's given with Hash#delete, which
    # would empty the stored config after a single print. The copy is shallow on
    # purpose - nested option hashes are never mutated, and a deep copy would
    # break a config holding a lambda column.
    def self.for(klass)
      config = @@klasses.fetch(klass) {}
      return config.dup if config.is_a?(Hash)
      return config unless config.is_a?(Array)

      config.collect { |option| option.is_a?(Hash) ? option.dup : option }
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

    def self.capitalize_headers
      @@capitalize_headers
    end

    def self.capitalize_headers=(caps)
      @@capitalize_headers = caps
    end

    def self.show_headers
      @@show_headers
    end

    def self.show_headers=(show)
      @@show_headers = show
    end

    def self.separator
      @@separator
    end

    def self.separator=(separator)
      @@separator = separator
    end

    def self.horizontal_separator
      @@horizontal_separator
    end

    # the character under the header, or nil for no line at all
    def self.horizontal_separator=(separator)
      unless separator.nil? or separator.to_s.length == 1
        raise StandardError.new("horizontal_separator must be a single character, or nil for no line, got #{separator.inspect}")
      end
      @@horizontal_separator = separator
    end

    def self.io
      @@io
    end

    def self.io=(io)
      raise StandardError.new("IO object must respond to :puts") unless io.respond_to? :puts
      @@io = io
    end
  end
end
