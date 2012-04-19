module TablePrint

  class FixedWidthFormatter
    def initialize(width)
      @width = width
    end

    def format(value)

    end
  end

  class RowGroup
    attr_reader :rows

    def initialize
      @rows = []
      @skip_first_row
    end

    def add_row(row)
      @rows << row
    end

    def format(*column_names)
      rows = @rows
      rows = @rows[1..-1] if @skip_first_row
      rows = rows.collect { |row| row.format(*column_names) }.join("\n")

      return nil if rows.length == 0
      rows
    end

    def skip_first_row!
      @skip_first_row = true
    end

    def row_count
      @rows.length
    end
  end

  class Row
    attr_reader :cells

    def initialize
      @cells = {}
      @groups = []
      @formatters = {}
    end

    def set_cell_values(values_hash)
      values_hash.each do |k, v|
        @cells[k.to_sym] = v
      end
      self
    end

    def format(*column_names)
      column_names = *column_names.collect(&:to_sym)

      @already_absorbed_a_multigroup = false

      rollup = {}
      column_names.each do |name|
        rollup[name] = @cells[name]
      end

      # try to get cell values from groups we can roll up
      @groups.each do |group|
        next unless absorbable_group?(group)
        group.skip_first_row!

        column_names.collect do |name|
          value = group.rows.first.cells[name]
          rollup[name] = value if value
        end
      end

      output = [column_names.collect { |name| apply_formatters(name, rollup[name]) }.join(" | ")]
      output.concat @groups.collect { |g| g.format(*column_names) }
      output.compact!

      output.join("\n")
    end

    def apply_formatters(column, value)
      return value unless @formatters[column]

      @formatters[column.to_sym].inject(value) do |value, formatter|
        formatter.format(value)
      end
    end

    def add_formatter(column, formatter)
      @formatters[column.to_sym] ||= []
      @formatters[column.to_sym] << formatter
    end

    def add_group(group)
      @groups << group
    end

    def absorbable_group?(group)
      return true if group.row_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end
  end
end
