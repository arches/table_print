require 'column'

module TablePrint
  class Config
    def initialize(default_column_names, *options)
      @column_hash = {}

      @default_columns = default_column_names.collect{|name| option_to_column(name)}

      @options = [options].flatten
      @options.delete_if {|o| o == {}}

      # process special symbols
      set_included_columns
      set_excepted_columns

      # anything that isn't recognized as a special option is assumed to be a column name
      @only_columns = @options.collect{|name| option_to_column(name)}
    end

    def option_to_column(option)
      if option.is_a? Hash
        name = option.keys.first
        if option[name].is_a? Proc
          option = {:name => name, :display_method => option[name]}
        else
          option = option[name].merge(:name => name)
        end
      else
        option = {:name => option}
      end
      c = Column.new(option)
      @column_hash[c.name] = c
      c
    end
    
    def set_included_columns
      include, @options = @options.partition do |o|
        o.is_a? Hash and o.keys.include? :include
      end

      @included_columns = [(include.first || {}).fetch(:include) {[]}].flatten
      @included_columns.map!{|option| option_to_column(option)}
      
      @included_columns.each do |c|
        @column_hash[c.name] = c
      end
    end

    def set_excepted_columns
      except, @options = @options.partition do |o|
        o.is_a? Hash and o.keys.include? :except
      end

      @excepted_columns = (except.first || {}).fetch(:except) {[]}
    end

    def usable_column_names
      return @only_columns.collect(&:name) if @only_columns.length > 0
      Array(@default_columns).collect(&:name) + Array(@included_columns).collect(&:name) - Array(@excepted_columns).collect(&:to_s)
    end

    def columns
      usable_column_names.collect do |name|
        @column_hash[name]
      end
    end
  end
end
