require 'formatter'
require 'column'

module TablePrint

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

    def add_children(children)
      @children.concat children
      children.each { |c| c.parent = self }
    end

    def child_count
      @children.length
    end

    def set_column(name, column)
      return parent.set_column(name, column) if parent
      @columns[name.to_s] = column
    end

    def columns
      return parent.columns if parent

      raw_column_names.collect{|k, v| column_for(k)}
    end

    def column_count
      return parent.column_count if parent
      @columns.size
    end

    def column_for(name)
      return parent.column_for(name) if parent
      column = @columns[name.to_s] ||= Column.new(:name => name)

      # assign the data sets to the column before we return it
      # do this as late as possible, since new rows could be added at any time
      column.data ||= raw_column_data(column.name)
      column
    end

    def width
      return parent.width if parent
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
    end

    def horizontal_separator
      '-' * width
    end

    def header
      padded_names = columns.collect do |column|
        f = FixedWidthFormatter.new(column.width)
        f.format(column.name)
      end

      padded_names.join(" | ").upcase
    end

    def add_formatter(name, formatter)
      return unless column_for(name)
      column_for(name).add_formatter(formatter)
    end
  end

  class RowGroup
    include RowRecursion

    def initialize
      super
      @skip_first_row = false
    end

    def raw_column_data(column_name)
      @children.collect { |r| r.raw_column_data(column_name) }.flatten
    end

    def raw_column_names
      return @raw_column_names if @raw_column_names
      @raw_column_names = @children.collect { |r| r.raw_column_names }.flatten.uniq
    end

    def format
      rows = @children
      rows = @children[1..-1] if @skip_first_row
      rows ||= []
      rows = rows.collect { |row| row.format }.join("\n")

      return nil if rows.length == 0
      rows
    end

    def skip_first_row!
      @skip_first_row = true
    end

    def column_width(column_name)
      raw_column_data(column_name).collect(&:to_s).collect(&:length).max
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

    def format
      column_names = columns.collect(&:name)

      @already_absorbed_a_multigroup = false

      rollup = {}
      column_names.each do |name|
        rollup[name] = @cells[name]
      end

      # try to get cell values from groups we can roll up
      absorb_children(column_names, rollup)

      output = [column_names.collect { |name| padded(name, apply_formatters(name, rollup[name])) }.join(" | ")]
      output.concat @children.collect { |g| g.format }
      output.compact!

      output.join("\n")
    end

    def padded(name, value)
      f = FixedWidthFormatter.new(column_for(name).width)
      #puts "#{name}\t#{value}\t#{column_for(name).width}\t#{f.format(value)}\t#{column_for(name)}"
      f.format(value)
    end

    def absorb_children(column_names, rollup)
      @children.each do |group|
        next unless absorbable_group?(group)
        group.skip_first_row!

        column_names.collect do |name|
          next unless group.children and group.children.length > 0
          value = group.children.first.cells[name]
          rollup[name] = value if value
        end
      end
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

    def apply_formatters(column_name, value)
      column_name = column_name.to_s
      return value unless column_for(column_name)

      # successively apply the formatters for a column
      column_for(column_name).formatters.inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def absorbable_group?(group)
      return true if group.child_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end
  end
end
