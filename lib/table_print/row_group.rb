module TablePrint


  class MarkdownFormatter

    attr_accessor :columns

    def initialize(columns)
      @columns = columns
    end

    def format_cell(column, value)
      cell_formatters = []
      cell_formatters.concat(Array(column.formatters))

      cell_formatters << TimeFormatter.new(column.time_format)
      cell_formatters << NoNewlineFormatter.new
      cell_formatters << FixedWidthFormatter.new(column.width)

      # successively apply the cell_formatters for a column
      cell_formatters.inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def format_row(cells)
      cells.join(" #{TablePrint::Config.separator} ")
    end

    def format_table(header, rows)
      [header, horizontal_separator].concat(rows).join("\n")
    end

    def format_header
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

    def formatter
      parent.formatter
    end
  end

  class Table
    include RowRecursion

    attr_accessor :formatter

    def initialize
      super

      @columns = []

    end

    def collapse!
      @children.each(&:collapse!)
    end

    def columns=(cols)
      @columns = cols
    end

    def add_column(column)
      @columns << column
    end

    def columns
      @columns.select { |column| column.data.compact.any? }
    end

    def width
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

    def format
      formatter.format_table(formatter.format_header, children.collect(&:format))
    end

    def formatter
      @formatter ||= MarkdownFormatter.new(@columns)
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
      rows = rows.collect { |row| row.format }

      return nil if rows.length == 0
      rows
    end

    def data_equal(other)
      return false unless children.length == other.children.length

      children.zip(other.children).all? { |row1, row2| row1.data_equal(row2) }
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

    def format
      output = [
        formatter.format_row(columns.collect { |column|
          apply_formatters(column)
        })
      ]
      output.concat @children.collect { |group| group.format }

      output.flatten
    end

    def apply_formatters(column)
      formatter.format_cell(column, @cells[column.name])
    end

    def data_equal(other)
      cells == other.cells
    rescue NoMethodError
      false
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
