module TablePrint
  class Config

    attr_accessor :capitalize_headers,
      :io,
      :klasses,
      :max_width,
      :multibyte,
      :separator,
      :time_format

    DEFAULT_MAX_WIDTH = 30
    DEFAULT_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
    DEFAULT_IO = $stdout
    DEFAULT_CAPITALIZE_HEADERS = true
    DEFAULT_SEPARATOR = "|"

    @@max_width = DEFAULT_MAX_WIDTH
    @@time_format = DEFAULT_TIME_FORMAT
    @@multibyte = false
    @@io = DEFAULT_IO
    @@capitalize_headers = true
    @@separator = DEFAULT_SEPARATOR

    @@klasses = {}

    @@singleton = nil

    def self.set(klass, val)
      if klass.is_a? Class
        singleton.klasses[klass] = val  # val is a hash of column options
      else
        TablePrint::Config.send("#{klass}=", val.first)
      end
    end

    def self.for(klass)
      singleton.klasses.fetch(klass) {}
    end

    def self.clear(klass)
      if klass.is_a? Class
        singleton.klasses.delete(klass)
      else
        original_value = TablePrint::Config.const_get("DEFAULT_#{klass.to_s.upcase}")
        TablePrint::Config.send("#{klass}=", original_value)
      end
    end

    def self.max_width
      singleton.max_width
    end

    def self.max_width=(width)
      singleton.max_width = width
    end

    def self.multibyte
      singleton.multibyte
    end

    def self.multibyte=(width)
      singleton.multibyte = width
    end

    def self.time_format
      singleton.time_format
    end

    def self.time_format=(format)
      singleton.time_format = format
    end

    def self.capitalize_headers
      singleton.capitalize_headers
    end

    def self.capitalize_headers=(caps)
      singleton.capitalize_headers = caps
    end

    def self.separator
      singleton.separator
    end

    def self.separator=(separator)
      singleton.separator = separator
    end

    def self.io
      singleton.io
    end

    def self.io=(io)
      raise StandardError.new("IO object must respond to :puts") unless io.respond_to? :puts
      singleton.io = io
    end

    def initialize(opts={})
      self.klasses = {}

      opts.each do |k,v|
        send("#{k}=", v)
      end

      self
    end

    private
    def self.singleton
      @@singleton ||= Config.new({
        capitalize_headers: true,
        io: DEFAULT_IO,
        max_width: DEFAULT_MAX_WIDTH,
        multibyte: false,
        separator: DEFAULT_SEPARATOR,
        time_format: DEFAULT_TIME_FORMAT,
      })
    end
  end
end
