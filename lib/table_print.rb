# future work:
#
#   handle multi-level includes like 'tp User.all, :include => "blogs.title"' and ActiveRecord associations
#   allow other output venues besides 'puts'
#   allow fine-grained formatting
#
# bugs
#
#   handle multibyte (see https://skitch.com/arches/r3cbg/multibyte-bug)

class TablePrint

  MAX_FIELD_LENGTH = 30

  # TODO: make options for things like MAX_FIELD_LENGTH
  # TODO: make options for things like separator
  # TODO: make options for things like column order
  def initialize(options = {})
  end

  # TODO: show documentation if invoked with no arguments
  # TODO: use *args instead of options
  def tp(data, options = {})
    data = wrap(data).compact

    # nothing to see here
    if data.empty?
      return "No data."
    end

    separator = "  | "

    display_methods = get_display_methods(data.first, options)
    unless display_methods.length > 0
      return data.inspect.to_s
    end

    # we're going to load all the data into memory so we can calculate field lengths.
    # TODO: there has to be a better way than loading everything into memory
    # TODO: stop checking field length once we hit the max
    # TODO: don't check field length on fixed-width columns

    field_lengths = {}

    # column headers
    display_methods.each do |m|
      field_lengths[m] = m.to_s.length
    end

    data.each do |obj|
      display_methods.each do |m|
        field_value = truncate(obj.send(m).to_s)
        field_lengths[m] = [field_lengths[m], field_value.length].max
      end
    end

    output = []

    row = []
    display_methods.each do |m|
      field_value = truncate(m.to_s)
      field_length = field_lengths[m]
      row << ("%-#{field_length}s" % field_value.upcase)
    end
    output << row.join(separator)
    output << ("-" * row.join(separator).length)

    data.each do |obj|
      row = []
      display_methods.each do |m|
        field_value = truncate(obj.send(m).to_s)
        field_length = field_lengths[m]
        row << ("%-#{field_length}s" % field_value)
      end
      output << row.join(separator)
    end

    output.join("\n")
  end

  private

  def truncate(field_value)
    if field_value.length > MAX_FIELD_LENGTH
      field_value = field_value[0..MAX_FIELD_LENGTH-1]
      field_value[-3..-1] = "..."
    end
    field_value
  end

  def get_display_methods(data_obj, options)
    # determine what methods we're going to use

    # using options:
    # TODO: maybe rename these a little? cascade/include are somewhat mixed with respect to rails lexicon
    #   :except - use the default set of methods but NOT the ones passed here
    #   :include - use the default set of methods AND the ones passed here
    #   :only - discard the default set of methods in favor of this list
    #   :cascade -
    #
    # eg
    #
    # tp User.limit(30) # default to using AR columns
    # tp User.limit(30) :except => :display_name
    # tp User.limit(30) :except => [:display_name, :created_at]
    # tp User.limit(30) :except => [:display_name, :timestamps] # a rails convention - but this could just be a type-based filter instead of method-based?
    # tp User.limit(30) :include => :status     # not an AR column
    # tp User.limit(30) :except => :display_name
    # tp User.limit(30) :except => :display_name
    # tp User.limit(30) :except => :display_name
    # tp User.limit(30) :except => :display_name
    #
    # tp User.include(:blogs).limit(30) :cascade => :blog
    # tp User.limit(30) :include => "blog.title"  # use dot notation to traverse children
    # TODO: how to handle multiple children? eg, a user has fifteen blogs
    #
    # tp [myClassInstance1, ...]  # default to using non-base methods
    # tp [myClassInstance1, ...] :except => :blah
    # tp [myClassInstance1, ...] :except => [:blah, :blow]
    # tp [myClassInstance1, ...] :include => :blah
    # tp [myClassInstance1, ...] :include => [:blah, :blow]
    # tp [myClassInstance1, ...] :include => :blah, :except => :blow
    # tp [myClassInstance1, ...] :only => [:one, :two, :three]

    if options.has_key? :only or options.has_key? "only"
      display_methods = clean_display_methods(data_obj, wrap(options[:only]))
      return display_methods if display_methods.length > 0
    end

    # make all the options into arrays
    methods_to_include = clean_display_methods(data_obj, wrap(options[:include]))
    methods_to_except = clean_display_methods(data_obj, wrap(options[:except]))

    # add/remove the includes/excludes from the defaults
    display_methods = get_default_display_methods(data_obj)
    display_methods.concat(methods_to_include).uniq!
    display_methods - methods_to_except
  end

  def get_default_display_methods(data_obj)
    # ActiveRecord
    return data_obj.class.columns.collect { |c| c.name } if defined?(ActiveRecord) and data_obj.is_a? ActiveRecord::Base

    # base types
    # TODO: fill out this list. any way to get this programatically? do we actually want to filter out all base ruby types? important question for custom classes inheriting from base types
    return [] if [Float, Fixnum, String, Numeric, Array, Hash].include? data_obj.class

    # custom class
    methods = data_obj.class.instance_methods - Object.instance_methods
    methods.delete_if { |m| m[-1].chr == "=" } # don't use assignment methods
    methods.map! { |m| m.to_s } # make any symbols into strings
    methods
  end

  def clean_display_methods(data_obj, display_methods)
    clean_methods = []
    display_methods.each do |m|
      next if m.nil?
      next if m == ""
      next unless data_obj.respond_to? m
      clean_methods << m.to_s
    end
    clean_methods.uniq
  end

  # borrowed from rails
  def wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary
    else
      [object]
    end
  end
end

module Kernel
  def tp(data, options = {})
    start = Time.now
    table_print = TablePrint.new
    puts table_print.tp(data, options)
    return Time.now - start
  end

  module_function :tp
end
