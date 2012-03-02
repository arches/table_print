# future work:
#
#   allow other output venues besides 'puts'
#   allow fine-grained formatting
#   on-the-fly column definitions (pass a proc as an include, eg 'tp User.all, :include => {:column_name => "Zodiac", :display_method => lambda {|u| find_zodiac_sign(u.birthday)}}')
#   allow user to pass ActiveRelation instead of a data array? That could open up so many options!
#   a :short_booleans method could save a little space (replace true/false with T/F or 1/0)
#   we could do some really smart stuff with polymorphic relationships, eg reusing photo column for blogs AND books!
#
# bugs
#
#   handle multibyte (see https://skitch.com/arches/r3cbg/multibyte-bug)

class TablePrint

  attr_accessor :columns, :display_methods, :separator

  def initialize(options = {})
    # TODO: make options for things like column order
  end

  def tp(data, options = {})
    # TODO: show documentation if invoked with no arguments
    # TODO: use *args instead of options

    self.separator = options[:separator] || " | "

    stack = Array(data).compact

    if stack.empty?
      return "No data."
    end

    self.display_methods = get_display_methods(data.first, options) # these are all strings now
    unless self.display_methods.length > 0
      return stack.inspect.to_s
    end

    # make columns for all the display methods
    self.columns = {}
    self.display_methods.each do |m|
      self.columns[m] = ColumnHelper.new(data, m, options[m] || options[m.to_sym])
    end

    output = [] # a list of rows.  we'll join this with newlines when we're done

    # column headers
    row = []
    self.display_methods.each do |m|
      row << self.columns[m].formatted_header
    end
    output << row.join(self.separator)

    # a row of hyphens to separate the headers from the data
    output << ("-" * output.first.length)

    while stack.length > 0
      format_row(stack, output)
    end

    output.join("\n")
  end

  private

  def format_row(stack, output)

    # method_chain is a dot-delimited list of methods, eg "user.blogs.url". It represents the path from the top-level
    # objects to the data_obj.
    data_obj, method_chain = stack.shift

    # top level objects don't have a method_chain, give them one so we don't have to null-check everywhere
    method_chain ||= ""

    # represent method_chain strings we've seen for this row as a tree of hash keys.
    # eg, if we have columns for "user.blogs.url" and "user.blogs.title", we only want to add one set of user.blogs to the stack
    method_hash = {}

    # if no columns in this row produce any data, we don't want to append it to the output. eg, if our only columns are
    # ["id", "blogs.title"] we don't want to print a blank row for every blog we iterate over. We want to entirely skip
    # printing a row for that level of the hierarchy.
    found_data = false

    # dive right in!
    row = []
    self.display_methods.each do |m|
      column = self.columns[m]

      # If this column happens to begin a recursion, get those objects on the stack. Pass in the stack-tracking info
      # we've saved: method_chain and method_hash.
      column.add_stack_objects(stack, data_obj, method_chain, method_hash)

      # all rows show all cells. Even if there's no data we still have to generate an empty cell of the proper width
      row << column.formatted_cell_value(data_obj, method_chain)
      found_data = true unless row[-1].strip.empty?
    end

    output << row.join(self.separator) if found_data
  end

  # Sort out the user options into a set of display methods we're going to show. This always returns strings.
  def get_display_methods(data_obj, options)
    # determine what methods we're going to use

    # using options:
    # TODO: maybe rename these a little? cascade/include are somewhat mixed with respect to rails lexicon
    #   :except - use the default set of methods but NOT the ones passed here
    #   :include - use the default set of methods AND the ones passed here
    #   :only - discard the default set of methods in favor of this list
    #   :cascade - show all methods in child objects

    if options.has_key? :only
      display_methods = Array(options[:only]).map { |m| m.to_s }
      return display_methods if display_methods.length > 0
    else
      display_methods = get_default_display_methods(data_obj) # start with what we can deduce
      display_methods.concat(Array(options[:include])).map! { |m| m.to_s } # add the includes
      display_methods = (display_methods - Array(options[:except]).map! { |m| m.to_s }) # remove the excepts
    end

    display_methods.uniq.compact
  end

  # Sniff the data class for non-standard methods to use as a baseline for display
  def get_default_display_methods(data_obj)
    # ActiveRecord
    return data_obj.class.columns.collect { |c| c.name } if defined?(ActiveRecord) and data_obj.is_a? ActiveRecord::Base

    methods = []
    data_obj.methods.each do |method_name|
      method = data_obj.method(method_name)

      if method.owner == data_obj.class
        if method.arity == 0 #
          methods << method_name.to_s
        end
      end
    end

    methods.delete_if { |m| m[-1].chr == "=" } # don't use assignment methods
    methods.delete_if { |m| m[-1].chr == "!" } # don't use dangerous methods
    methods.map! { |m| m.to_s } # make any symbols into strings
    methods
  end

  class ColumnHelper
    attr_accessor :field_length, :max_field_length, :method, :name, :options

    def initialize(data, method, options = {})
      self.method = method
      self.options = options || {} # could have been passed an explicit nil

      self.name = self.options[:name] || method.gsub("_", " ").gsub(".", " > ")

      self.max_field_length = self.options[:max_field_length] || 30
      self.max_field_length = [self.max_field_length, 1].max # numbers less than one are meaningless

      initialize_field_length(data)
    end

    def formatted_header
      "%-#{self.field_length}s" % truncate(self.name.upcase)
    end

    def formatted_cell_value(data_obj, method_chain)
      cell_value = ""

      # top-level objects don't have method chain. Need to check explicitly whether our method is top-level, otherwise
      # if the last method in our chain matches a top-level method we could accidentally print its data in our column.
      #
      # The method chain is what we've been building up as we were "recursing" through previous objects. You could think of
      # it as a prefix for this row.  Eg, we could be looping through the columns with a method_chain of "locker.assets",
      # indicating that we've recursed down from user to locker and are now interested in printing assets. So
      #
      unless method_chain == "" and self.method.include? "."
        our_method_chain = self.method.split(".")
        our_method = our_method_chain.pop

        # check whether the method_chain fully qualifies the path to this particular object. If this is the bottom level
        # of object in the tree, and the method_chain matches all the way down, then it's finally time to print this cell.
        if method_chain == our_method_chain.join(".")
          if data_obj.respond_to? our_method
            cell_value = data_obj.send(our_method).to_s.gsub("\n", " ")
          end
        end
      end
      "%-#{self.field_length}s" % truncate(cell_value.to_s)
    end

    # Determine if we need to add some stuff to the stack. If so, put it on top and update the tracking objects.
    def add_stack_objects(stack, data_obj, method_chain, method_hash)

      return unless self.add_to_stack?(method_chain, method_hash)

      # TODO: probably a less awkward string method to do this
      # current_method is the method we're going to call on our data_obj. Say our column is "locker.assets.url" and
      # our chain is "locker", current_method would be "assets"
      current_method = get_current_method(method_chain)

      new_stack_objects = []
      if current_method != "" and data_obj.respond_to? current_method
        new_stack_objects = data_obj.send(current_method)
      end

      # Now that we've seen "locker.assets", no need to add it to the stack again for this row! Save it off in method_hash
      # so when we hit "locker.assets.caption" we won't add the same assets again.
      new_method_chain = method_chain == "" ? current_method : "#{method_chain}.#{current_method}"
      method_hash[new_method_chain] = {}

      # TODO: probably a cool array method to do this
      # finally - update the stack with the object(s) we found
      Array(new_stack_objects).reverse_each do |stack_obj|
        stack.unshift [stack_obj, new_method_chain]
      end
    end

    def add_to_stack?(method_chain, method_hash = {})

      # Check whether we're involved in this row. method_chain lets us know the path we took to find the current set of
      # data objects. If our method doesn't act upon those objects, bail.
      # eg, if these objects are the result of calling "locker.assets" on top-level user objects, but our method is "blogs.title",
      # all we're going to be doing on this row is pushing out empty cells.
      return unless self.method.start_with? method_chain

      # check whether another column has already added our objects. if we hit "locker.assets.url" already and we're
      # "locker.assets.caption", the assets are already on the stack. Don't want to add them again.
      new_method_chain = method_chain == "" ? get_current_method(method_chain) : "#{method_chain}.#{get_current_method(method_chain)}"
      return if method_hash.has_key? new_method_chain

      # OK! this column relates to the data object and hasn't been beaten to the punch. But do we have more levels to recurse, or
      # is this object on the bottom rung and just needs formatting?

      # if this is the top level, all we need to do is check for a dot, indicating a chain of methods
      if method_chain == ""
        return method.include? "."
      end

      # if this isn't the top level, subtract out the part of the chain we've already called before we check for further chaining
      test_method = String.new(method[method_chain.length, method.length])
      test_method = test_method[1, test_method.length] if test_method.start_with? "."

      test_method.include? "."
    end

    private

    # cut off field_value based on our previously determined width
    def truncate(field_value)
      copy = String.new(field_value)
      if copy.length > self.field_length
        copy = copy[0..self.field_length-1]
        copy[-3..-1] = "..." unless self.field_length <= 3 # don't use ellipses when the string is tiny
      end
      copy
    end

    # determine how wide this column is going to be
    def initialize_field_length(data)
      # skip all this nonsense if we've been explicitly told what to do
      if self.options[:field_length] and self.options[:field_length] > 0
        self.field_length = self.options[:field_length]
      else
        self.field_length = self.name.length # it has to at least be long enough for the column header!

        find_data_length(data, self.method, Time.now)
      end

      self.field_length = [self.field_length, self.max_field_length].min # never bigger than the max
    end

    # recurse through the data set using the method chain to find the longest field (or until time's up)
    def find_data_length(data, method, start)
      return if (Time.now - start) > 2
      return if method.nil?
      return if data.nil?
      return if self.field_length >= self.max_field_length

      Array(data).each do |data_obj|
        next_method = method.split(".").first

        return unless data_obj.respond_to? next_method

        if next_method == method  # done!
          self.field_length = [self.field_length, data_obj.send(next_method).to_s.length].max
        else  # keep going
          find_data_length(data_obj.send(next_method), method[(next_method.length + 1)..-1], start)
        end
      end
    end

    # add the next level to the method_chain
    def get_current_method(method_chain)
      if self.method.start_with? method_chain
        current_method = String.new(self.method)
        current_method = current_method[method_chain.length, current_method.length]
        current_method.split(".").detect { |m| m != "" }
      end
    end
  end

end

module Kernel
  def tp(data, options = {})
    start = Time.now
    table_print = TablePrint.new
    puts table_print.tp(Array(data), options)
    Time.now - start # we have to return *something*, might as well be execution time.
  end

  module_function :tp
end

## Some nested classes to make development easier! Make sure you don't commit these uncommented.
#
#class TestClass
#  attr_accessor :title, :name, :blogs, :locker
#
#  def initialize(title, name, blogs, locker)
#    self.title = title
#    self.name = name
#    self.blogs = blogs
#    self.locker = locker
#  end
#end
#
#class Blog
#  attr_accessor :title, :summary
#
#  def initialize(title, summary)
#    self.title = title
#    self.summary = summary
#  end
#end
#
#class Locker
#  attr_accessor :assets
#
#  def initialize(assets)
#    self.assets = assets
#  end
#end
#
#class Asset
#  attr_accessor :url, :caption
#
#  def initialize(url, caption)
#    self.url = url
#    self.caption = caption
#  end
#end
#
#stack = [
#
#      TestClass.new("one title", "one name", [
#            Blog.new("one blog title1", "one blog sum1"),
#            Blog.new("one blog title2", "one blog sum2"),
#            Blog.new("one blog title3", "one blog sum3"),
#      ],
#                    Locker.new([
#                                     Asset.new("one asset url1", "one asset cap1"),
#                                     Asset.new("one asset url2", "one asset cap2"),
#                                     Asset.new("one asset url3", "one asset cap3"),
#                               ])
#      ),
#      TestClass.new("two title", "two name", [
#            Blog.new("two blog title1", "two blog sum1"),
#            Blog.new("two blog title2", "two blog sum2"),
#            Blog.new("two blog title3", "two blog sum3"),
#      ],
#                    Locker.new([
#                                     Asset.new("two asset url1", "two asset cap1"),
#                                     Asset.new("two asset url2", "two asset cap2"),
#                                     Asset.new("two asset url3", "two asset cap3"),
#                               ])
#      ),
#      TestClass.new("three title", "three name", [
#            Blog.new("three blog title1", "three blog sum1"),
#            Blog.new("three blog title2", "three blog sum2"),
#            Blog.new("three blog title3", "three blog sum3"),
#      ],
#                    Locker.new([
#                                     Asset.new("three asset url1", "three asset cap1"),
#                                     Asset.new("three asset url2", "three asset cap2"),
#                                     Asset.new("three asset url3", "three asset cap3"),
#                               ])
#      ),
#      TestClass.new("four title", "four name", [
#            Blog.new("four blog title1", "four blog sum1"),
#            Blog.new("four blog title2", "four blog sum2"),
#            Blog.new("four blog title3", "four blog sum3"),
#      ],
#                    Locker.new([
#                                     Asset.new("four asset url1", "four asset cap1"),
#                                     Asset.new("four asset url2", "four asset cap2"),
#                                     Asset.new("four asset url3", "four asset cap3"),
#                               ])
#      ),
#]

#tp stack, :include => ["blogs.title", "blogs.summary", "locker.assets.url", "locker.assets.caption"]




