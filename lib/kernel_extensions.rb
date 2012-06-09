require 'returnable'

module Kernel
  def tp(data=[], *options)
    start = Time.now
    printer = TablePrint::Printer.new(data, options)
    puts printer.table_print unless data.is_a? Class
    TablePrint::Returnable.new(Time.now - start) # we have to return *something*, might as well be execution time.
  end

  module_function :tp
end
