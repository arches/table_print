require 'table_print/column'
require 'table_print/config_resolver'
require 'table_print/config'
require 'table_print/fingerprinter'
require 'table_print/formatter'
require 'table_print/hash_extensions'
require 'table_print/markdown_formatter'
require 'table_print/row_recursion'
require 'table_print/table'
require 'table_print/row_group'
require 'table_print/row'
require 'table_print/returnable'


def tp(data=Class, *options)
  TablePrint::Config.singleton.display(data, options) unless data.is_a? Class
  TablePrint::Returnable.new("printed!") # we have to return *something*, might as well be execution time.
end
