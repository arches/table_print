require_relative './formatter'
require_relative './column'

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

    def add_column(name)
      return parent.add_column(name) if parent
      return if @columns[name.to_s]

      @columns[name.to_s] = Column.new(name: name.to_s)
    end

    def columns
      return parent.columns if parent

      @columns.collect{|k, v| column_for(k)}
    end

    def column_count
      @columns.size
    end

    def column_for(name)
      column = @columns[name.to_s]
      return unless column

      # assign the data sets to the column before we return it
      # do this as late as possible, since new rows could be added at any time
      column.data = raw_column_data(column.name)
      column
    end

    def width
      columns.collect(&:width).inject(&:+) + (columns.length - 1) * 3 # add (n-1)*3 for the 3-character separator
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

    def format(column_names)
      column_names = column_names.collect(&:to_s)
      rows = @children
      rows = @children[1..-1] if @skip_first_row
      rows = rows.collect { |row| row.format(column_names) }.join("\n")

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
        add_column(k)
        @cells[k.to_s] = v
      end
      self
    end

    def format(column_names)
      column_names.map!(&:to_s)

      @already_absorbed_a_multigroup = false

      rollup = {}
      column_names.each do |name|
        rollup[name] = @cells[name]
      end

      # try to get cell values from groups we can roll up
      absorb_children(column_names, rollup)

      output = [column_names.collect { |name| apply_formatters(name, rollup[name]) }.join(" | ")]
      output.concat @children.collect { |g| g.format(column_names) }
      output.compact!

      output.join("\n")
    end

    def absorb_children(column_names, rollup)
      @children.each do |group|
        next unless absorbable_group?(group)
        group.skip_first_row!

        column_names.collect do |name|
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
