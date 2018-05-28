module TablePrint
  # This class rationalizes command-line options passed to us during display.
  # The goal of this class is straightforward: return configs for each column.
  # However, to flexibly handle a wide variety of input phrasings, the implementation
  # gets a little complicated.
  class RuntimeConfigResolver

    def initialize(base_config, example, *options)
      @base_config = base_config
      @example = example
      @options = options

      @column_hash = {}

      @included_columns = []
      @excepted_columns = []
      @only_columns = []
    end

    def columns
      # Start by generating the column set we'd use if no runtime config was given.
      # This will be overwritten by more specific configs as we progress.
      default_column_names = default_display_methods(@example)
      @default_columns = default_column_names.collect { |name| option_to_column(name) }

      # Enhance the default config with previously-stored config for this object type, if available
      process_option_set(@base_config.for(@example.class))

      # Lastly, enhance again using the runtime config
      process_option_set(@options)

      # Fine-tuning to arrive at our final column set
      usable_column_names.collect do |name|
        @column_hash[name]
      end
    end

    private

    # Examples of options
    #
    # :title
    # ["author.name"]
    # ["foo"]
    # [:foo, "bar"]
    # [:foo]
    # [[:author, :url]]
    # [[:author, {:include=>:pub_date}]]
    # [[:author]]
    # [[:id, "comments.id", "comments.username"]]
    # [[:pub_date, :length, {:except=>:length, :include=>:foobar}]]
    # [[:pub_date, :length, {:except=>:length}]]
    # [[:title, :author], [{:except=>:author}]]
    # [[:title, :author], [{:include=>:author}]]
    # [[:title, :comment], [{:include=>["comment.body", "comment.author"]}]]
    # [[:title, :foo, :bar], {:except=>[:foo, "bar"]}]
    # [[:title, :foo], {:except=>:foo}]
    # [[:title], [{:include=>:author}]]
    # [[:title], {:include=>:foo}]
    # [[:title], {:include=>[:foo, :bar]}]
    # [[:title], {:include=>{:foo=>{:fixed_width=>10}}}]
    # [[:title], {:title=>{:display_method=>:boofar}}]
    # [[:title], {:title=>{:fixed_width=>100}}]
    # [[:title], {:title=>{:formatters=>[{}, {}]}}]
    # [[:title]]
    # [[], {:title=>{:display_name=>"Ti Tle"}}]
    # [[{:include=>:size}]]
    # [[{:include=>{:two=>#<Proc:0x007ff60b1db970@(eval):1 (lambda)>}}]]
    # [[{:include=>{:two=>#<Proc:0x007ff60bb90560@(eval):1 (lambda)>}}]]
    # []
    # [{:author=>{:display_name=>"Wom Bat"}}]
    # [{:except=>:title}]
    # [{:foo=>#<Proc:0x007fd1b82cbe88@/Users/cdoyle/gems/table_print/spec/runtime_config_resolver_spec.rb:216 (lambda)>}]
    # [{:foo=>{:display_method=>#<Proc:0x007fd1b82ebb98@/Users/cdoyle/gems/table_print/spec/runtime_config_resolver_spec.rb:207 (lambda)>}}]
    # [{:include=>:author}]
    # [{:include=>["blog.author", "blog.title"]}]
    # [{:include=>{:author=>{:fixed_width=>15}}}]
    # [{:include=>{:author=>{:fixed_width=>40}}}]
    # [{:wombat=>#<Proc:0x007ff609bca230@(eval):1 (lambda)>}]
    # [{:wombat=>{:display_method=>#<Proc:0x007ff609c61658@(eval):1 (lambda)>}}]
    # [{:wombat=>{:display_method=>:author}}]
    # [{}]
    # nil
    # {:include=>{:foobar=>#<Proc:0x007ff60a1b6e78@(eval):1 (lambda)>}}
    def process_option_set(options)

      options = [options].flatten
      options.delete_if { |o| o == {} } # remove literally blank hashes from the input

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
      hash_for_key = options_array.select do |option|
        option.is_a? Hash and option.keys.include? key
      end

      return [] if hash_for_key.empty?
      hash_for_key = hash_for_key.first

      option_of_interest = hash_for_key.fetch(key)
      hash_for_key.delete(key)

      options_array.delete(hash_for_key) if hash_for_key.keys.empty?  # if we've taken all the info from this option, get rid of it

      option_of_interest
    end

    def option_to_column(option)
      column_config = TablePrint::Config.new

      column_args = {}

      if option.is_a? Hash
        name = option.keys.first
        if option[name].is_a? Proc
          column_args = {:name => name, :display_method => option[name]}
        else
          column_args = {}
          column_args[:name] = option[name][:display_name] || name
          column_args[:display_method] = option[name][:display_method] || name

          column_config = TablePrint::Config.new(option[name])
        end

      else
        column_args = {:name => option}
      end


      c = Column.new(column_args)
      c.config = @base_config.with(column_config)
      @column_hash[c.name] = c
      c
    end

    def usable_column_names
      # Start by assuming we're going to print all the default columns
      base = @default_columns

      # If runtime config gives an explicit column set, what you config is what you get
      base = @only_columns unless @only_columns.empty?
      
      # Make any additions or subtractions based on the :include and :except options
      names = (Array(base).collect(&:name) + Array(@included_columns).collect(&:name) - Array(@excepted_columns).collect(&:to_s)).uniq

      names.reject{ |name| names.any?{ |other| other.start_with? name and other != name }}
    end

    # Sniff the data class for non-standard methods to use as a baseline for display
    def default_display_methods(target)
      if target.class.respond_to? :columns
        if target.class.columns.first.respond_to? :name

          # eg ActiveRecord
          return target.class.columns.collect(&:name)
        else

          # eg Sequel
          return target.class.columns
        end
      end

      # eg mongoid
      return target.fields.keys if target.respond_to? :fields and target.fields.is_a? Hash

      return target.keys if target.is_a? Hash
      return target.members.collect(&:to_sym) if target.is_a? Struct

      methods = []
      target.methods.each do |method_name|
        method = target.method(method_name)

        if method.owner == target.class
          if method.arity == 0 # only take methods that don't require args
            methods << method_name.to_s
          end
        end
      end

      methods.delete_if { |m| m[-1].chr == "!" } # don't use dangerous methods
      methods
    end
  end
end
