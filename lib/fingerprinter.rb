require_relative './row_group'
require_relative './hash_extensions'

module TablePrint
  class Fingerprinter
    def lift(columns, object)
      column_hash = columns_to_nested_hash(columns)

      hash_to_rows("", column_hash, object)
    end

    def hash_to_rows(prefix, hash, objects)
      rows = []

      # convert each object into its own row
      objects.each do |target|
        row = TablePrint::Row.new()

        # populate a row with the columns we handle
        cells = {}
        columns_to_handle(hash).each do |method|
          cells["#{prefix}#{'.' unless prefix == ''}#{method}"] = target.send(method)
        end

        row.set_cell_values(cells)
        rows << row

        # make a group and recurse for the columns we don't handle
        columns_to_pass(hash).each do |name|
          recursing_prefix = "#{prefix}#{'.' unless prefix == ''}#{name}"
          group = RowGroup.new
          group.add_rows hash_to_rows(recursing_prefix, hash[name], target.send(name))
          row.add_group(group)
        end
      end

      rows
    end

    def columns_to_handle(hash)
      # get the keys where the value is an empty hash
      hash.select { |k, v| v == {} }.collect { |k, v| k }
    end

    def columns_to_pass(hash)
      # get the keys where the value is not an empty hash
      hash.select { |k, v| v != {} }.collect { |k, v| k }
    end

    def columns_to_nested_hash(columns)
      extended_hash = {}.extend TablePrint::HashExtensions::ConstructiveMerge

      # turn each column chain into a nested hash and add it to the output
      columns.inject(extended_hash) do |hash, name|
        hash.constructive_merge!(chain_to_nested_hash(name))
      end
    end

    def chain_to_nested_hash(chain)
      hash = {}
      chain.split(".").inject(hash) do |hash_level, method|
        hash_level[method] ||= {}
      end
      hash
    end

    def method_chains(columns)
      columns.collect { |name| split_into_chain_and_method(name)[0] }.uniq
    end

    def split_into_chain_and_method(column_name)
      parts = column_name.split(".")

      # have to pop the method_name before we do the join, but need to return the chain first
      [parts.pop, parts.join(".")].reverse
    end
  end
end
