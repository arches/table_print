module TablePrint
  class RowGroup
    attr_reader :rows

    def initialize
      @rows = []
      @skip_first_row
    end

    def add_row(row)
      @rows << row
    end

    def add_rows(rows)
      @rows.concat(rows)
    end

    def format(column_names)
      column_names = column_names.collect(&:to_s)
      rows = @rows
      rows = @rows[1..-1] if @skip_first_row
      rows = rows.collect { |row| row.format(column_names) }.join("\n")

      return nil if rows.length == 0
      rows
    end

    def skip_first_row!
      @skip_first_row = true
    end

    def row_count
      @rows.length
    end

    def add_formatter(column, formatter)
      @rows.each {|r| r.add_formatter(column, formatter)}
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
      output.concat @groups.collect { |g| g.format(column_names) }
      output.compact!

      output.join("\n")
    end

    def absorb_children(column_names, rollup)
      @groups.each do |group|
        next unless absorbable_group?(group)
        group.skip_first_row!

        column_names.collect do |name|
          value = group.rows.first.cells[name]
          rollup[name] = value if value
        end
      end
    end

    def add_formatter(column, formatter)
      @formatters[column.to_s] ||= []
      @formatters[column.to_s] << formatter

      @groups.each {|g| g.add_formatter(column, formatter)}
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

    def add_group(group)
      @groups << group
    end

    def add_groups(groups)
      @groups.concat groups
    end

    def absorbable_group?(group)
      return true if group.row_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end
  end
end
