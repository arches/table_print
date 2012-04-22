require_relative './fingerprinter'

module TablePrint

  class Printer
    def table_print(data, options=nil)
      @data = Array(data)
      data_obj = @data.first.extend TablePrint::Printable
      display_methods = data_obj.default_display_methods
      #columns = display_methods.collect { |m| Column.new(@data, m) }

      #columns. options_to_columns(options)
    end

    private

    # Translate strings and hashes into Column initialization args
    class ColumnConstructor
      def initialize(input)
        @input = input
      end

      def display_method
        return @input unless @input.respond_to? :keys
        @input.keys.first.to_s
      end

      def column_options
        return {} unless @input.respond_to? :values
        @input.values.first
      end
    end

    # Turns command-line input into Column objects
    def options_to_columns(options)
      return [] if options.nil?
      return [] if options == []
      return [] if options == {}
      options = [options] unless options.is_a? Array

      columns = []
      options.each do |option|
        cc = ColumnConstructor.new(option)
        columns << cc.display_method
        #columns << Column.new(@data, cc.display_method, cc.column_options)
      end

      columns
    end
  end

  module Printable
    # Sniff the data class for non-standard methods to use as a baseline for display
    def default_display_methods
      methods = []
      self.methods.each do |method_name|
        method = self.method(method_name)

        if method.owner == self.class
          if method.arity == 0 #
            methods << method_name.to_s
          end
        end
      end

      methods.delete_if { |m| m[-1].chr == "!" } # don't use dangerous methods
      methods
    end
  end
end

module Kernel
  def tp(data, options = {})
    start = Time.now
    puts "PENDING PENDING PENDING"
    #table_print = TablePrint::TablePrint.new
    #puts table_print.tp(Array(data), options)

    config = TablePrintConfig.new
    config.timer = Time.now - start # we have to return *something*, might as well be execution time.
    config
  end

  module_function :tp
end

#tp stack, :include => ["blogs.title", "blogs.summary", "locker.assets.url", "locker.assets.caption"]

# This is so we can write:
#
#   > tp MyObject.new
#    => TablePrintConfig.new.to_s
#   > tp.set MyObject, :include => :foo
#    => TablePrintConfig.set(MyObject, :include => :foo)
#
#class TablePrintConfig
#
#  attr_accessor :timer
#
#  def set(options)
#    TablePrint::Configuration.set options
#  end
#
#  def to_s
#    self.timer
#  end
#end
#
