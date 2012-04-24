require_relative './row_group'
require_relative './hash_extensions'

module TablePrint
  class Fingerprinter
    def lift(columns, object)
      column_hash = column_names_to_nested_hash(columns)

      hash_to_rows("", column_hash, object)
    end

    def hash_to_rows(prefix, hash, objects)
      rows = []

      # convert each object into its own row
      Array(objects).each do |target|
        row = populate_row(prefix, hash, target)
        rows << row

        # make a group and recurse for the columns we don't handle
        groups = create_child_group(prefix, hash, target)
        row.add_children(groups)
      end

      rows
    end

    def populate_row(prefix, hash, target)
      row = TablePrint::Row.new()

      # populate a row with the columns we handle
      cells = {}
      handleable_columns(hash).each do |method|
        cells["#{prefix}#{'.' unless prefix == ''}#{method}"] = target.send(method)
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
      # get the keys where the value is an empty hash
      hash.select { |k, v| v == {} }.collect { |k, v| k }
    end

    def passable_columns(hash)
      # get the keys where the value is not an empty hash
      hash.select { |k, v| v != {} }.collect { |k, v| k }
    end

    def column_names_to_nested_hash(columns)
      extended_hash = {}.extend TablePrint::HashExtensions::ConstructiveMerge

      # turn each column chain into a nested hash and add it to the output
      columns.inject(extended_hash) do |hash, column_name|
        hash.constructive_merge!(column_to_nested_hash(column_name))
      end
    end

    def column_to_nested_hash(column_name)
      hash = {}
      column_name.split(".").inject(hash) do |hash_level, method|
        hash_level[method] ||= {}
      end
      hash
    end
  end
end
