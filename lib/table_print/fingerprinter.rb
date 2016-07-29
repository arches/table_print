module TablePrint
  class Fingerprinter

    attr_reader :columns

    def initialize(columns=nil)
      if columns
        @columns ||= {}
        columns.each do |column|
          @columns[column.display_method] = column
          column.data = []
        end

        display_methods_to_nested_hash(columns.collect(&:display_method))
      end
    end

    def lift(object)
      hash_to_rows("", @column_hash, object)
    end

    def hash_to_rows(prefix, hash, objects)
      rows = []

      # convert each object into its own row
      Array(objects).each do |target|
        row = populate_row(prefix, hash, target)
        rows << row

        # make a group and recurse for the columns we don't handle
        groups = create_child_group(prefix, hash, target)
        row.add_children(groups) unless groups.all? {|g| g.children.empty?}
      end

      rows
    end

    def populate_row(prefix, hash, target)
      row = TablePrint::Row.new()

      # populate a row with the columns we handle
      cells = {}
      handleable_columns(hash).each do |method|
        display_method = (prefix == "" ? method : "#{prefix}.#{method}")
        if method.is_a? Proc
          cell_value = method.call(target)
        elsif target.is_a? Hash and target.keys.include? method.to_sym
          cell_value = target[method.to_sym]
        elsif target.is_a? Hash and target.keys.include? method
          cell_value = target[method]
        elsif target.respond_to? method
          cell_value ||= target.send(method)
        else
          cell_value = "Method Missing"
        end
        column = @columns[display_method]
        cells[column.name] = cell_value
        column.data << cell_value
      end

      row.set_cell_values(cells)
    end

    def create_child_group(prefix, hash, target)
      passable_columns(hash).collect do |name|
        recursing_prefix = "#{prefix}#{'.' unless prefix == ''}#{name}"
        group = RowGroup.new
        group.add_children hash_to_rows(recursing_prefix, hash[name], target.send(name))
        group
      end
    end

    def handleable_columns(hash)
      # if the value is an empty hash, we're at the end of the method chain
      hash.select { |k, v| v == {} }.collect { |k, v| k }
    end

    def passable_columns(hash)
      # get the keys where the value is not an empty hash
      hash.select { |k, v| v != {} }.collect { |k, v| k }
    end

    def display_methods_to_nested_hash(display_methods)
      @column_hash = {}.extend TablePrint::HashExtensions::ConstructiveMerge

      # turn each column chain into a nested hash and add it to the output
      display_methods.inject(@column_hash) do |hash, display_method|
        hash.constructive_merge!(display_method_to_nested_hash(display_method))
      end
    end

    def display_method_to_nested_hash(display_method)
      hash = {}

      return {display_method => {}} if display_method.is_a? Proc

      display_method.split(".").inject(hash) do |hash_level, method|
        hash_level[method] ||= {}
      end
      hash
    end
  end
end
