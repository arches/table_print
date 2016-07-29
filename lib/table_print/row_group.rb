module TablePrint

  module TableFormatMethods
    def header
      padded_names = columns.collect do |column|
        f = FixedWidthFormatter.new(column.width)
        f.format(column.name)
      end

      header_string = padded_names.join(" #{TablePrint::Config.separator} ")
      header_string.upcase! if TablePrint::Config.capitalize_headers

      header_string
    end

    def horizontal_separator
      columns.collect do |column|
        '-' * column.width
      end.join("-#{TablePrint::Config.separator}-")
    end

    def width
      return parent.width if parent
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

  end

  module RowFormatMethods
    def format
      column_names = columns.collect(&:name)

      output = [column_names.collect { |name| apply_formatters(name, @cells[name]) }.join(" #{TablePrint::Config.separator} ")]
      output.concat @children.collect { |g| g.format }

      output.join("\n")
    end

    def apply_formatters(column_name, value)
      column_name = column_name.to_s
      return value unless column_for(column_name)

      column = column_for(column_name)
      formatters = []
      formatters.concat(Array(column.formatters))

      formatters << TimeFormatter.new(column.time_format)
      formatters << NoNewlineFormatter.new
      formatters << FixedWidthFormatter.new(column_for(column_name).width)

      # successively apply the formatters for a column
      formatters.inject(value) do |value, formatter|
        formatter.format(value)
      end
    end
  end

  module RowRecursion
    attr_accessor :parent
    attr_accessor :children

    def initialize
      @children = []
      @columns = {}
    end

    def add_child(child)
      @children << child
      child.parent = self
    end

    def insert_children(i, children)
      @children.insert(i, children).flatten!
      children.each {|c| c.parent = self }
      self
    end

    def add_children(children)
      @children.concat children
      children.each { |c| c.parent = self }
      self
    end

    def child_count
      @children.length
    end

    def set_column(column)
      return parent.set_column(column) if parent
      @columns[column.name.to_s] = column
    end

    def columns
      return parent.columns if parent

      #raw_column_names.collect{|k, v| column_for(k)}
      @columns.each do |name, column|
        column.data ||= raw_column_data(column.name)
      end

      @columns.values.select { |column| column.data.compact.any? }
    end

    def column_count
      return parent.column_count if parent
      @columns.size
    end

    def column_for(name)
      return parent.column_for(name) if parent
      column = @columns[name.to_s] #||= Column.new(:name => name)

      # assign the data sets to the column before we return it
      # do this as late as possible, since new rows could be added at any time
      column.data ||= raw_column_data(column.name)
      column
    end
  end

  class Table
    include TableFormatMethods

    def initialize
      @columns = {}
    end

    def columns=(cols)
      cols.each do |column|
        @columns[column.name.to_s] = column
      end
    end

    def columns
      @columns.values.select { |column| column.data.compact.any? }
    end
  end


  class RowGroup
    include RowRecursion

    # more of a structural method than actual formatting
    def format
      rows = @children
      rows = @children[1..-1] if @skip_first_row
      rows ||= []
      rows = rows.collect { |row| row.format }.join("\n")

      return nil if rows.length == 0
      rows
    end

    def initialize
      super
      @skip_first_row = false
    end

    # TODO: save a separate set of data on the column during fingerprinting so we can avoid this tree search
    def raw_column_data(column_name)
      @children.collect { |r| r.raw_column_data(column_name) }.flatten
    end

    def raw_column_names
      return @raw_column_names if @raw_column_names
      @raw_column_names = @children.collect { |r| r.raw_column_names }.flatten.uniq
    end

    # this is a development tool, to show the structure of the row/row_group tree
    def vis(prefix="")
      if prefix == ""
        puts "columns: #{columns.inspect.to_s}"
      end

      puts "#{prefix}group"
      children.each{|c| c.vis(prefix + "  ")}
    end

    def collapse!
      @children.each(&:collapse!)
    end

    def skip_first_row!
      @skip_first_row = true
    end
  end

  class Row
    attr_reader :cells

    include RowRecursion
    include RowFormatMethods

    def initialize
      super
      @cells = {}
    end

    def set_cell_values(values_hash)
      values_hash.each do |k, v|
        @cells[k.to_s] = v
      end
      self
    end

    def raw_column_data(column_name)
      output = [@cells[column_name.to_s]]
      output << @children.collect { |g| g.raw_column_data(column_name) }
      output.flatten
    end

    def raw_column_names
      output = [@cells.keys]
      output << @children.collect { |g| g.raw_column_names }
      output.flatten.uniq
    end


    def collapse!
      children.each(&:collapse!)  # depth-first. start collapsing from the bottom and work our way up.

      to_absorb = []
      children.each do |group|
        next unless can_absorb?(group)
        to_absorb << group
      end

      to_absorb.each do |absorbable_group|
        absorbable_row = absorbable_group.children.shift

        # missing associations create groups with no rows
        children.delete(absorbable_group) and next unless absorbable_row

        @cells.merge!(absorbable_row.cells)

        i = children.index(absorbable_group)
        children.delete(absorbable_group) if absorbable_group.children.empty?
        insert_children(i, absorbable_row.children) if absorbable_row.children.any?
      end
    end

    def absorb_children(column_names, rollup)
      @children.each do |group|
        next unless can_absorb?(group)
        group.skip_first_row!

        column_names.collect do |name|
          next unless group.children and group.children.length > 0
          value = group.children.first.cells[name]
          rollup[name] = value if value
        end
      end
    end

    def can_absorb?(group)
      return true if group.child_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end

    # this is a development tool, to show the structure of the row/row_group tree
    def vis(prefix="")
      if prefix == ""
        puts "columns: #{columns.inspect.to_s}"
      end
      puts "#{prefix}row #{cells.inspect.to_s}"
      children.each{|c| c.vis(prefix + "  ")}
    end

  end
end
