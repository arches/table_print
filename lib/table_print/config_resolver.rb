module TablePrint
  class ConfigResolver
    def initialize(klass, default_column_names, *options)
      @column_hash = {}

      @default_columns = default_column_names.collect { |name| option_to_column(name) }

      @included_columns = []
      @excepted_columns = []
      @only_columns = []

      process_option_set(TablePrint::Config.for(klass))
      process_option_set(options)
    end

    def process_option_set(options)

      options = [options].flatten
      options.delete_if { |o| o == {} }

      # process special symbols

      @included_columns.concat [get_and_remove(options, :include)].flatten
      @included_columns.map! do |option|
        if option.is_a? Column
          option
        else
          option_to_column(option)
        end
      end

      @included_columns.each do |c|
        @column_hash[c.name] = c
      end

      # excepted columns don't need column objects since we're just going to throw them out anyway
      @excepted_columns.concat [get_and_remove(options, :except)].flatten

      # anything that isn't recognized as a special option is assumed to be a column name
      options.compact!
      @only_columns = options.collect { |name| option_to_column(name) } unless options.empty?
    end

    def get_and_remove(options_array, key)
      except = options_array.select do |option|
        option.is_a? Hash and option.keys.include? key
      end

      return [] if except.empty?
      except = except.first

      option_of_interest = except.fetch(key)
      except.delete(key)

      options_array.delete(except) if except.keys.empty?  # if we've taken all the info from this option, get rid of it

      option_of_interest
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

      if option.has_key? :width
        option[:default_width] = option.delete(:width)
      end

      if option.has_key? :display_name
        option[:display_method] = option[:name]
        option[:name] = option.delete(:display_name)
      end

      c = Column.new(option)
      @column_hash[c.name] = c
      c
    end

    def usable_column_names
      base = @default_columns
      base = @only_columns unless @only_columns.empty?
      Array(base).collect(&:name) + Array(@included_columns).collect(&:name) - Array(@excepted_columns).collect(&:to_s)
    end

    def columns
      usable_column_names.collect do |name|
        @column_hash[name]
      end
    end
  end
end
