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

    def set(klass, val)
      if klass.is_a? Class
        klasses[klass] = val  # val is a hash of column options
      else
        send("#{klass}=", val.first)
      end
    end

    def for(klass)
      klasses.fetch(klass) {}
    end

    def clear(klass)
      if klass.is_a? Class
        klasses.delete(klass)
      else
        send("#{klass}=", Config.const_get("DEFAULT_#{klass.to_s.upcase}"))
      end
    end

    def io=(io)
      raise StandardError.new("IO object must respond to :puts") unless io.respond_to? :puts
      @io = io
    end

    def initialize(opts={})
      self.klasses = {}

      opts.each do |k,v|
        send("#{k}=", v)
      end

      self
    end

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
