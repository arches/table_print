module TablePrint
  class Config

    ATTRIBUTES = [ 
      :capitalize_headers,
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

    # todo: move these down into the formatters
    DEFAULT_MAX_WIDTH = 30
    DEFAULT_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"
    DEFAULT_IO = $stdout
    DEFAULT_CAPITALIZE_HEADERS = true
    DEFAULT_SEPARATOR = "|"

    def initialize(opts={})
      self.io = DEFAULT_IO
      self.max_width = DEFAULT_MAX_WIDTH
      self.capitalize_headers = true

      self.klasses = {}

      opts.each do |k,v|
        send("#{k}=", v)
      end

      self
    end

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

    def display(data, options={})
      data = Array(data).compact

      columns = TablePrint::RuntimeConfigResolver.new(self, data.first, options).columns

      self.formatter = MarkdownFormatter.new(self, columns)


      # copy data from original objects into the table
      fingerprinter = Fingerprinter.new(self, columns)

      table = fingerprinter.lift(data)

      # munge the tree of data we created, to condense the output
      table.collapse!

      return unless table.columns.any?

      io.puts table.format
    end

    def self.singleton
      @@singleton ||= Config.new
    end
  end
end
