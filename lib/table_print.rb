# future work:
#
#   handle multi-level includes like 'tp User.all, :include => "blogs.title"' and ActiveRecord associations
#   allow other output venues besides 'puts'
#   allow fine-grained formatting
#   on-the-fly column definitions (pass a proc as an include, eg 'tp User.all, :include => {:column_name => "Zodiac", :display_method => lambda {|u| find_zodiac_sign(u.birthday)}}')
#   allow user to pass ActiveRelation instead of a data array? That could open up so many options!
#   a :short_booleans method could save a little space (replace true/false with T/F or 1/0)
#
# bugs
#
#   handle multibyte (see https://skitch.com/arches/r3cbg/multibyte-bug)


# start with a list of objects
#stack = []
#
#data_obj = stack.first
#
#methods = ["title", "name", "blogs.title", "blogs.name", "lockers.assets.url", "lockers.assets.caption"]
##method_hierarchy = "title", "name", "blogs" => ["title", "name"], "lockers" => {"assets" => ["url", "caption"]}
#
#
#stack = [
#      ["", User1],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#data_obj.send("title")  # add to row
#data_obj.send("name") # add to row
#
#data_obj.send("blogs")  # add to stack        # ["blogs", blog entry]
#data_obj.send("lockers")  # add to stack      # ["lockers", locker entry]
#
#stack = [
#      ["lockers", Locker1],
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
## prints USER TITLE, USER NAME
#####
#
## top stack object is now a locker
#  data_obj.send("assets") # add to stack      # ["lockers.assets", asset entry]
#
#stack = [
#      ["lockers.assets", Asset1],
#      ["lockers.assets", Asset2],
#      ["lockers.assets", Asset3],
#      ["lockers.assets", Asset4],
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
## prints NOTHING
#####
#
## top stack object is now an asset
#    data_obj.send("url") # add to row
#    data_obj.send("caption") # add to row
#
#stack = [
#      ["lockers.assets", Asset2],
#      ["lockers.assets", Asset3],
#      ["lockers.assets", Asset4],
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#stack = [
#      ["lockers.assets", Asset3],
#      ["lockers.assets", Asset4],
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#stack = [
#      ["lockers.assets", Asset4],
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#stack = [
#      ["lockers", Locker2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#stack = [
#      ["lockers.assets", Asset1],
#      ["lockers.assets", Asset2],
#      ["blogs", Blog1],
#      ["blogs", Blog2],
#      ["blogs", Blog3],
#      ["", User2],
#      ["", User3],
#      ["", User4],
#]
#
#
## prints LOCKERS.ASSETS.URL, LOCKERS.ASSETS.CAPTION
#####
#
## top stack object is now an asset
#    data_obj.send("url") # add to row
#    data_obj.send("caption") # add to row
#
## prints LOCKERS.ASSETS.URL, LOCKERS.ASSETS.CAPTION
#####
#
## top stack object is now a blog
#  data_obj.send("title") # add to stack
#  data_obj.send("name") # add to stack
#
## prints BLOGS.TITLE, BLOGS.NAME
#####
#
## top stack object is now a blog
#  data_obj.send("title") # add to stack
#  data_obj.send("name") # add to stack
#
## prints BLOGS.TITLE, BLOGS.NAME
#####
#
## top stack object is now a user again
#
## so we can either add to stack or add to the output
#
#output = []
#stack = []
#stack = [
#      [Asset1, "lockers.assets"],
#      [Asset2, "lockers.assets"],
#      [Blog1, "blogs"],
#      [Blog2, "blogs"],
#      [Blog3, "blogs"],
#      User2,
#      User3,
#      User4,
#]

def wrap(object)
  if object.nil?
    []
  elsif object.respond_to?(:to_ary)
    object.to_ary
  else
    [object]
  end
end

class TestClass
  attr_accessor :title, :name, :blogs, :locker

  def initialize(title, name, blogs, locker)
    self.title = title
    self.name = name
    self.blogs = blogs
    self.locker = locker
  end
end

class Blog
  attr_accessor :title, :summary

  def initialize(title, summary)
    self.title = title
    self.summary = summary
  end
end

class Locker
  attr_accessor :assets

  def initialize(assets)
    self.assets = assets
  end
end

class Asset
  attr_accessor :url, :caption

  def initialize(url, caption)
    self.url = url
    self.caption = caption
  end
end

stack = [

      TestClass.new("one title", "one name", [
            Blog.new("one blog title1", "one blog sum1"),
            Blog.new("one blog title2", "one blog sum2"),
            Blog.new("one blog title3", "one blog sum3"),
      ],
                    Locker.new([
                                     Asset.new("one asset url1", "one asset cap1"),
                                     Asset.new("one asset url2", "one asset cap2"),
                                     Asset.new("one asset url3", "one asset cap3"),
                               ])
      ),
      TestClass.new("two title", "two name", [
            Blog.new("two blog title1", "two blog sum1"),
            Blog.new("two blog title2", "two blog sum2"),
            Blog.new("two blog title3", "two blog sum3"),
      ],
                    Locker.new([
                                     Asset.new("two asset url1", "two asset cap1"),
                                     Asset.new("two asset url2", "two asset cap2"),
                                     Asset.new("two asset url3", "two asset cap3"),
                               ])
      ),
      TestClass.new("three title", "three name", [
            Blog.new("three blog title1", "three blog sum1"),
            Blog.new("three blog title2", "three blog sum2"),
            Blog.new("three blog title3", "three blog sum3"),
      ],
                    Locker.new([
                                     Asset.new("three asset url1", "three asset cap1"),
                                     Asset.new("three asset url2", "three asset cap2"),
                                     Asset.new("three asset url3", "three asset cap3"),
                               ])
      ),
      TestClass.new("four title", "four name", [
            Blog.new("four blog title1", "four blog sum1"),
            Blog.new("four blog title2", "four blog sum2"),
            Blog.new("four blog title3", "four blog sum3"),
      ],
                    Locker.new([
                                     Asset.new("four asset url1", "four asset cap1"),
                                     Asset.new("four asset url2", "four asset cap2"),
                                     Asset.new("four asset url3", "four asset cap3"),
                               ])
      ),
]


def do_row(stack, columns, output)

  # method_chain is a dot-delimited list of methods, eg "user.blogs.url". It represents the path from the top-level
  # objects to the data_obj.
  #
  # data_obj is a particular 
  data_obj, method_chain = stack.shift
  method_chain ||= "" # top level objects don't have a method_chain, give them one so we don't have to null-check everywhere

  # represent method_chain strings we've seen for this row as a tree of hash keys.
  # eg, if we have columns for "user.blogs.url" and "user.blogs.title", we only want to add one set of user.blogs to the stack
  method_hash = {}

  # dive right in!
  row = []
  columns.each do |column|

    # If this column happens to begin a recursion, get those objects on the stack. Pass in the stack-tracking info
    # we've saved: method_chain and method_hash.
    column.add_stack_objects(stack, data_obj, method_chain, method_hash)

    # all rows show all cells. Even if there's no data we still have to generate an empty cell of the proper width
    row << column.formatted_cell_value(data_obj, method_chain)
  end

  output << row.join(" | ")
end

class Column
  attr_accessor :method

  def initialize(method)
    self.method = method
  end


  def formatted_cell_value(data_obj, method_chain)
    if method.start_with? method_chain
      current_method = self.method.split(".").last
      if data_obj.respond_to? current_method
        data_obj.send(current_method)
      end
    end
  end

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
    wrap(new_stack_objects).reverse_each do |stack_obj|
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
    return test_method.include? "."
  end

  private
  # add the next level to the method_chain
  def get_current_method(method_chain)
    if self.method.start_with? method_chain
      current_method = String.new(self.method)
      current_method = current_method[method_chain.length, current_method.length]
      current_method.split(".").detect { |m| m != "" }
    end
  end
end

columns = [
      Column.new("title"),
      Column.new("name"),
      Column.new("blogs.title"),
      Column.new("blogs.summary"),
      Column.new("locker.assets.url"),
      Column.new("locker.assets.caption")
]

output = []
while stack.length > 0
  do_row(stack, columns, output)
end
puts output.join("\n")


class TablePrint

  OBJECT_CLASSES = [String, Bignum, Regexp, ThreadError, Numeric, SystemStackError, IndexError,
                    SecurityError, SizedQueue, IO, Range, Object, Exception, NoMethodError, TypeError, Integer, Dir,
                    ZeroDivisionError, Kernel, RegexpError, SystemExit, NotImplementedError, Hash,
                    Interrupt, SyntaxError, Enumerable, Struct, Class, Continuation, IOError, Proc,
                    RangeError, Data, Thread, Array, NoMemoryError, Time, MatchData,
                    ConditionVariable, Method, Mutex, StopIteration, Comparable, ArgumentError, Float,
                    FloatDomainError, UnboundMethod, ThreadGroup, Precision, RuntimeError, FalseClass, Fixnum, Queue,
                    StandardError, EOFError, LoadError, NameError, NilClass, TrueClass, MatchingData,
                    LocalJumpError, Binding, SignalException, SystemCallError, File, ScriptError, Module, Symbol]

  attr_accessor :column_helpers, :display_methods, :separator

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

    self.separator = options[:separator] || " | "

    self.display_methods = get_display_methods(data.first, options) # these are all strings now
    unless display_methods.length > 0
      return data.inspect.to_s
    end

    # make columns for all the display methods
    self.column_helpers = {}
    display_methods.each do |m|
      self.column_helpers[m] = ColumnHelper.new(data, m, options[m] || options[m.to_sym])
    end

    # arrange a hierarchy of display methods by object
    # eg, if we're showing users, with "blogs.title" and "blogs.url" it'd be something like
    # ["user", "blogs" => ["title", "url"]]
    #
    # then sort it so that hashes are at the end.

    sorted_display_methods = sort_display_methods(display_methods)

    output = [] # a list of rows.  we'll join this with newlines when we're done

    # column headers
    row = []
    self.display_methods.each do |m|
      row << self.column_helpers[m].formatted_header
    end
    output << row.join(self.separator)

    # a row of hyphens to separate the headers from the data
    output << ("-" * row.join(self.separator).length)

    self.show_rows(output, sorted_display_methods, data)

#    # the data!
#    data.each do |data_obj|
#      row = []
#      columns.each do |column|
#        row << column.formatted_field_value(data_obj)
#      end
#      output << row.join(self.separator)
#    end

    output.join("\n")
  end

  def show_rows(output, method_tree, data)
  end

  private

  def sort_display_methods(display_methods)

    method_hash = {}
    display_methods.each do |method|
      hash = method_hash
      method.split(".").each do |m|
        hash[m] ||= {}
        hash = hash[m]
      end
    end
    return method_hash

#    sorted_display_methods = []
#
#    # For each display method...
#    display_methods.each do |long_method|
#
#      puts
#      puts sorted_display_methods.inspect
#      puts long_method
#
#      # loop through its constituent parts.
#      list = sorted_display_methods
#      method_list = long_method.split(".")
#      method_list.each do |m|
#
#        puts method_list.index(m)
#        level = 1
#        # If this item already exists...
#        list.each do |list_item|
#          if list_item.is_a? Hash and list_item.has_key? m
#            puts "\t"*level + "Descending from #{list.inspect} to #{list_item.inspect} via #{m}"
#            # add our method to it
#            list = list_item[m]
#            level += 1
#            next
#          end
#        end
#
#        # But if it doesn't, create it.
#        if m == method_list[-1]
#          # If this is the last method in the chain, add it to the array
#          puts "\t"*level +"Adding #{m} to #{list.inspect}"
#          list << m
#        else
#          puts "This method was number #{method_list.index(m)}"
#          # If this isn't the last method, create a new level
#          new_list = []
#          list << {m => new_list}
#          list = new_list
#        end
#      end
#    end
#    sorted_display_methods
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

    if options.has_key? :only or options.has_key? "only"
      display_methods = wrap(options[:only]).map { |m| m.to_s }
      return display_methods if display_methods.length > 0
    else
      display_methods = get_default_display_methods(data_obj) # start with what we can deduce
      display_methods.concat(wrap(options[:include])).map! { |m| m.to_s } # add the includes
      (display_methods - wrap(options[:except]).map! { |m| m.to_s }) # remove the excepts
    end

    display_methods.uniq.compact
  end

  def get_default_display_methods(data_obj)
    # ActiveRecord
    return data_obj.class.columns.collect { |c| c.name } if defined?(ActiveRecord) and data_obj.is_a? ActiveRecord::Base

    # base types
    # TODO: fill out this list. any way to get this programatically? do we actually want to filter out all base ruby types? important question for custom classes inheriting from base types
    return [] if [Float, Fixnum, String, Numeric, Array, Hash].include? data_obj.class

    # custom class
    methods = data_obj.class.instance_methods
    OBJECT_CLASSES.each do |oclass|
      if data_obj.is_a? oclass
        methods = methods - oclass.instance_methods # we're only interested in custom methods, not ruby core methods
      end
    end

    methods.delete_if { |m| m[-1].chr == "=" } # don't use assignment methods
    methods.map! { |m| m.to_s } # make any symbols into strings
    methods
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

  class ColumnHelper
    attr_accessor :name, :display_chain, :options, :data, :field_length, :max_field_length

    def initialize(data, display_method, options = {})
      self.options = options || {} # could have been passed an explicit nil
      self.display_chain = display_method.to_s.split(".")
      self.name = self.options[:name] || display_method.gsub("_", " ").gsub(".", ">")
      self.max_field_length = self.options[:max_field_length] || 30
      self.max_field_length = [self.max_field_length, 1].max # numbers less than one are meaningless

      # initialization
      self.initialize_field_length(data)
    end

    def formatted_header
      "%-#{self.field_length}s" % truncate(self.name.upcase)
    end

    def formatted_field_value(data_obj)
      "%-#{self.field_length}s" % truncate(cell_value(data_obj).to_s)
    end

    def initialize_field_length(data)
      # skip all this nonsense if we've been explicitly told what to do
      if self.options[:field_length] and self.options[:field_length] > 0
        length = self.options[:field_length]
      else
        length = self.name.length # it has to at least be long enough for the column header!

        start = Time.now
        data.each do |data_obj|
          next if data_obj.nil?

          # TODO: are there other fixed-width data types?
          # fixed-width fields don't require the full loop
          cell_value = cell_value(data_obj)
          case cell_value
            when Time
              length = cell_value.to_s.length # TODO: this needs to be tested against max_field_length
              break # TODO: this is breaking the data_obj loop, right?
            when TrueClass, FalseClass
              length = [5, length].max
              break
          end

          length = [length, cell_value.to_s.length].max
          break if length >= self.max_field_length # we're never going to longer than the global max, so why keep going
          break if (Time.now - start) > 2 # assume if we loop for more than 2s that we've made it through a representative sample, and bail
        end
      end

      self.field_length = [length, self.max_field_length].min # never bigger than the max
    end

    private

    # Apply the method chain to the data object to obtain the value for this particular table cell
    def cell_value(data_obj)
      self.display_chain.inject(data_obj) { |obj, m| obj.send(m) unless obj.nil? or not obj.respond_to? m }
    end

    def truncate(field_value)
      copy = String.new(field_value)
      if copy.length > self.max_field_length
        copy = copy[0..self.max_field_length-1]
        copy[-3..-1] = "..." unless self.max_field_length <= 3 # don't use ellipses when the string is tiny
      end
      copy
    end
  end
end

module Kernel
  def tp(data, options = {})
    start = Time.now
    table_print = TablePrint.new
    puts table_print.tp(data, options)
    Time.now - start
  end

  module_function :tp
end


# When the return type of a field is enumerable, we want to show it in its own rows unless we received the :inline_enumerables option
#
# Eg, say we're looking at the photos of a user's blog posts
#
# tp User.includes(:blogs => :photos).all, :include => ["blogs.title", "blogs.photos.url"]
#
# The output should look like this:
#
# ID  | NAME  | BLOG TITLE   | BLOG PHOTO URL
# 1   | Sam   | wheat grass  | http://www.abc.com/def.jpg
#     |       |              | http://www.abc.com/ghi.jpg
#     |       |              | http://www.abc.com/jkl.jpg
#     |       |              | http://www.abc.com/mno.jpg
#     |       |              | http://www.abc.com/pqr.jpg
#     |       | potpourri    | http://www.abc.com/stu.jpg
#     |       |              | http://www.abc.com/vwx.jpg
#     |       |              | http://www.abc.com/yz.jpg
# 2   | Joe   | lawnmowers   | http://www.123.com/456.jpg
#     |       |              | http://www.123.com/789.jpg
#
#
# So we collect up objects at various levels of hierarchy. Top level is what we're passed in, the User objects. We were
# requested to provide blog.title and blog.photos, so for each user we're going to be looping over blog objects and showing
# those properties.  Then we have blog.photos.url, so for each blog object we're going to be looping over photos. Basically
# we're building a tree of objects, based on the tree of methods we were passed.
#
# So what we need is a way for each level to handle itself, but be aware of the level above it because we need to leave enough
# space (eg, most of the rows showing the photo URL don't show anything about the user, but the photo URLs still need to be aligned).
#
# We need a data structure that can handle both the nesting of layers AND the flat list of columns.
#
# Let's make it so that the columns know they don't always need to print something. So we can pass blog objects to user columns
# and they know to print out a blank cell.  That way we can loop over every column for every row, but only print the relevant data.
#
# Will that work?
#
# [
#   { :id => 1,                                     # This is easy enough. But what about two separate arrays, blogs and books?
#     :name => "Sam",
#     :blogs => [
#       { :title => "wheat grass"
#         :photos => [
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."}
#         ]
#       },
#       { :title => "potpourri"
#         :photos => [
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."}
#         ]
#       }
#     ]
#   },
#   {...},
#   {...},
#   {...}
# ]
#
#
# (oooh, tricky.... we could do some really smart stuff with polymorphic relationships, eg reusing photo column for blogs AND books!)
#
# tp User.includes(:blogs => :photos, :books => :photos)
# [
#   { :id => 1,
#     :name => "Sam",
#     :blogs => [
#       { :title => "wheat grass"
#         :photos => [
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."}
#         ]
#       },
#       { :title => "potpourri"
#         :photos => [
#           {:url => "..."},
#           {:url => "..."},
#           {:url => "..."}
#         ]
#       }
#     ],
#     :books => [
#       { :title => "Cookin meat"
#         :photos => [
#           {:caption => "..."},
#           {:caption => "..."},
#           {:caption => "..."},
#           {:caption => "..."},
#           {:caption => "..."}
#         ]
#       }
#     ]
#   },
#   {...},
#   {...},
#   {...}
# ]
#
#
#
# ID  | NAME  | BLOG TITLE   | BLOG PHOTO URL              | BOOK TITLE    | BOOK PHOTO CAPTION
# 1   | Sam   | wheat grass  | http://www.abc.com/def.jpg  |               |
#     |       |              | http://www.abc.com/ghi.jpg  |               |
#     |       |              | http://www.abc.com/jkl.jpg  |               |
#     |       |              | http://www.abc.com/mno.jpg  |               |
#     |       |              | http://www.abc.com/pqr.jpg  |               |
#     |       | potpourri    | http://www.abc.com/stu.jpg  |               |
#     |       |              | http://www.abc.com/vwx.jpg  |               |
#     |       |              | http://www.abc.com/yz.jpg   |               |
#     |       |              |                             | Cooking meat  | When killing a bison...
#     |       |              |                             |               | Rabbits are sneaky
#     |       |              |                             |               | Not again!
#     |       |              |                             |               | Leave Rome to the Romans
# 2   | Joe   | lawnmowers   | http://www.123.com/456.jpg  |               |
#     |       |              | http://www.123.com/789.jpg  |               |
#
#
#
# So we end up with a tree of methods
#
# [
#   id:integer
#   name:string
#   blogs:array
#     photos:array
#       url:string
#   books:array
#     photos:array
#       caption:string
# ]
#
# For each object, we have two sets of methods: internal and external. All the internal methods are collapsed into
# one row. All the external methods have their own rows (because they're each handed control at one point or another).
#
# This would sort of argue for some kind of inspection before printing. The column should be able to say whether it's
# internal or external to a given object (or unrelated, ie, whitespace).
#


















