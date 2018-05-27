module TablePrint
  class Config

    attr_accessor :attributes

    def initialize(attributes={})
      self.attributes = attributes
    end

    def ==(other)
      self.attributes == other.attributes
    end

    def set(attr, val)
      # if attr is a Class, val is a hash of column options
      attributes[attr] = val
    end

    def for(attr)
      attributes.fetch(attr) {}
    end

    def with(other)
      c = Config.new

      self.attributes.each do |attr, val|
        c.set(attr, val)
      end

      other.attributes.each do |attr, val|
        c.set(attr, val)
      end

      c
    end

    def clear(attr)
      attributes.delete(attr)
      if attr.to_s == "io"
        attributes[:io] = $stdout
      end
    end

    def display(data, options={})
      data = Array(data).compact

      columns = TablePrint::RuntimeConfigResolver.new(self, data.first, options).columns

      set :formatter, MarkdownFormatter.new(self, columns)

      # copy data from original objects into the table
      fingerprinter = Fingerprinter.new(self, columns)

      table = fingerprinter.lift(data)

      # munge the tree of data we created, to condense the output
      table.collapse!

      return unless table.columns.any?

      self.for(:io).puts table.format
    end

    def self.singleton
      @@singleton ||= refresh_singleton
    end

    def self.refresh_singleton
      @@singleton = Config.new({
        io: $stdout,
        max_width: 30,
        capitalize_headers: true,
        time_format: "%Y-%m-%d %H:%M:%S",
        separator: "|",
        multibyte: false
      })
    end
  end
end
