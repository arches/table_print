require_relative './formatter'

module TablePrint

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

    def add_children(children)
      @children.concat children
      children.each { |c| c.parent = self }
    end

    def child_count
      @children.length
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

    def add_formatter(column, formatter)
      @children.each { |r| r.add_formatter(column, formatter) }
    end

    def column_width(column_name)
      raw_column_data(column_name).collect(&:to_s).collect(&:length).max
    end

    def set_column_widths(columns)
      columns.map!(&:to_s)
      columns.each do |column_name|
        formatter = TablePrint::FixedWidthFormatter.new(column_width(column_name))
        add_formatter(column_name, formatter)
      end
    end
  end

  class Row
    attr_reader :cells

    include RowRecursion

    def initialize
      super
      @cells = {}
      @formatters = {}
    end

    def set_cell_values(values_hash)
      values_hash.each do |k, v|
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

    def add_formatter(column, formatter)
      @formatters[column.to_s] ||= []
      @formatters[column.to_s] << formatter

      @children.each { |g| g.add_formatter(column, formatter) }
    end

    def raw_column_data(column_name)
      output = [@cells[column_name.to_s]]
      output << @children.collect { |g| g.raw_column_data(column_name) }
      output.flatten
    end

    def apply_formatters(column, value)
      column = column.to_s
      return value unless formatters_for(column)

      # successively apply the formatters for a column
      formatters_for(column).inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def formatters_for(column)
      @formatters[column.to_s]
    end

    def absorbable_group?(group)
      return true if group.child_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end
  end
end
