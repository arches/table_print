module TablePrint
  class Config

    ATTRIBUTES = [ 
      :capitalize_headers,
      :colors,
      :fixed_width,
      :formatter,
      :formatters,
      :io,
      :klasses,
      :max_width,
      :multibyte,
      :separator,
      :time_format,
    ]

    attr_accessor *ATTRIBUTES

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

    def ==(other)
      ATTRIBUTES.all? do |attr|
        other.send(attr) == send(attr)
      end
    rescue NoMethodError
      false
    end

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

    def display(data, options={})
      data = Array(data).compact

      columns = TablePrint::ConfigResolver.new(self, data.first, options).columns

      self.formatter = MarkdownFormatter.new(self, columns)


      # copy data from original objects into the table
      fingerprinter = Fingerprinter.new(self, columns)

      table = fingerprinter.lift(data)

      # munge the tree of data we created, to condense the output
      table.collapse!

      return unless table.columns.any?

      io.puts table.format
    end

    def self.singleton(name=:global)
      @@singleton ||= {}

      @@singleton[name.to_sym] ||= Config.new({

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
