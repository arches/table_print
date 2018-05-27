module TablePrint
  class Row
    include RowRecursion

    attr_reader :cells

    def initialize
      super
      @cells = {}
    end

    #### structural ####
    
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

    #### format ####

    def format
      output = [
        formatter.format_row(columns.collect { |column|
          formatter.format_cell(column, @cells[column.name])
        })
      ]
      output.concat @children.collect { |group| group.format }

      output.flatten
    end

    #### helper ####

    def data_equal(other)

      return false unless children.length == other.children.length

      children.zip(other.children).all? { |row1, row2| row1.data_equal(row2) } and cells == other.cells

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


    private

    def formatter
      config.for(:formatter)
    end

    def can_absorb?(group)
      return true if group.child_count == 1

      return false if @already_absorbed_a_multigroup
      @already_absorbed_a_multigroup = true # only call this method once
    end
  end
end
