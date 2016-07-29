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
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

    # more of a structural method than actual formatting
    def format
      rows = @children
      rows = @children[1..-1] if @skip_first_row
      rows ||= []
      rows = rows.collect { |row| row.format }.join("\n")

      return nil if rows.length == 0
      rows
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
    end

    def add_child(child)
      @children << child
      child.parent = self
    end

    def insert_children(i, children)
      @children.insert(i, children).flatten!
      children.each { |c| c.parent = self }
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

    def columns
      parent.columns
    end

    def column_for(name)
      parent.column_for(name)
    end
  end

  class Table
    include TableFormatMethods
    include RowRecursion

    def initialize
      super

      @columns = {}
    end

    def collapse!
      @children.each(&:collapse!)
    end

    def columns=(cols)
      cols.each { |column| add_column(column) }
    end

    def add_column(column)
      @columns[column.name.to_s] = column
    end

    def columns
      @columns.values.select { |column| column.data.compact.any? }
    end

    def column_for(name)
      @columns[name.to_s]
    end
  end


  class RowGroup
    include RowRecursion

    def initialize
      super
      @skip_first_row = false
    end

    def collapse!
      @children.each(&:collapse!)
    end

    def skip_first_row!
      @skip_first_row = true
    end

    # more of a structural method than actual formatting
    def format
      rows = @children
      rows = @children[1..-1] if @skip_first_row
      rows ||= []
      rows = rows.collect { |row| row.format }.join("\n")

      return nil if rows.length == 0
      rows
    end

    # this is a development tool, to show the structure of the row/row_group tree
    def vis(prefix="")
      if prefix == ""
        puts "columns: #{columns.inspect.to_s}"
      end

      puts "#{prefix}group"
      children.each{|c| c.vis(prefix + "  ")}
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
