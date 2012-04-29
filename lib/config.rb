require 'column'

module TablePrint
  class Config
    def initialize(default_column_names, *options)
      @default_column_names = default_column_names
      @options = options

      set_included_columns
      set_excepted_columns
    end

    def set_included_columns
      include, @options = @options.partition do |o|
        o.is_a? Hash and o.keys.include? :include
      end

      @included_columns = (include.first || {}).fetch(:include) {[]}
    end

    def set_excepted_columns
      except, @options = @options.partition do |o|
        o.is_a? Hash and o.keys.include? :except
      end

      @excepted_columns = (except.first || {}).fetch(:except) {[]}
    end

    def usable_columns
      return @options if @options and @options.length > 0
      Array(@default_column_names).collect(&:to_s) + Array(@included_columns).collect(&:to_s) - Array(@excepted_columns).collect(&:to_s)
    end

    def columns
      usable_columns.collect do |o|
        if o.is_a? Hash
          name = o.keys.first
          o = o[name].merge(:name => name)
        else
          o = {:name => o}
        end
        Column.new(o)
      end
    end
  end
end
