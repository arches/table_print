require 'spec_helper'

# One example per kind of input, each showing the data and the table it prints.
#
# The rest of the suite covers behaviour thoroughly and input types only in passing.
#
# The last group pins types that print badly today, so that fixing one fails
# here loudly instead of changing behaviour nobody notices.
describe "printing" do
  def printed(data, *options)
    TablePrint::Printer.new(data, options).table_print.to_s
  end

  # Cells are padded, so a table's lines carry trailing spaces - invisible in a
  # heredoc, stripped by most editors on save, and present if you paste real
  # output. Compare line by line without them, on both sides.
  RSpec::Matchers.define :print_as do |expected|
    def lines(table)
      table.to_s.lines.collect(&:rstrip)
    end

    match { |actual| lines(actual) == lines(expected) }

    failure_message do |actual|
      "expected:\n#{expected}\n     got:\n#{actual}"
    end
  end

  # The first row is taken as representative of the whole set, whatever the data
  # is. Every other group below inherits this rule.
  describe "choosing columns" do
    it "takes them from the first row" do
      expect(printed([{ a: 1 }, { b: 2 }])).to print_as <<~TABLE
        A
        --------------
        1
        Method Missing
      TABLE
    end

    it "shows nothing for cells past the first row's width" do
      expect(printed([%w[a b], %w[c], %w[d e f]])).to print_as <<~TABLE
        0 | 1
        --|---------------
        a | b
        c | Method Missing
        d | e
      TABLE
    end
  end

  describe "scalars" do
    it "puts strings in a single VALUE column, untouched" do
      data = ["hello".dup, "world".dup]

      expect(printed(data)).to print_as <<~TABLE
        VALUE
        -----
        hello
        world
      TABLE

      expect(data).to eq %w[hello world] # tp used to call String#clear on these
    end

    it "treats symbols and numbers the same way" do
      expect(printed([:sym, 42, 3.14])).to print_as <<~TABLE
        VALUE
        -----
        sym
        42
        3.14
      TABLE
    end

    it "treats a range as one value, not as the list it could expand into" do
      expect(printed([(1..3), (4..6)])).to print_as <<~TABLE
        VALUE
        -----
        1..3
        4..6
      TABLE
    end

    it "still expands a range handed over as the whole data set" do
      # a collection at the top level is rows; a range inside one is a value
      expect(printed(1..3)).to print_as <<~TABLE
        VALUE
        -----
        1
        2
        3
      TABLE
    end

    it "treats booleans the same way" do
      expect(printed([true, false])).to print_as <<~TABLE
        VALUE
        -----
        true
        false
      TABLE
    end
  end

  describe "hashes" do
    it "prints one bare hash as a single row" do
      expect(printed("host" => "db.internal", "user" => "app")).to print_as <<~TABLE
        HOST        | USER
        ------------|-----
        db.internal | app
      TABLE
    end

    it "uses the keys as columns, blank for a nil" do
      expect(printed([{ a: 1, b: "two" }, { a: 3, b: nil }])).to print_as <<~TABLE
        A | B
        --|----
        1 | two
        3 |
      TABLE
    end

    it "prints a range in a cell as itself" do
      expect(printed([{ "name" => "alice", "span" => (1..5) }])).to print_as <<~TABLE
        NAME  | SPAN
        ------|-----
        alice | 1..5
      TABLE
    end

    it "finds values behind keys that are neither strings nor symbols" do
      expect(printed([{ 1 => "one", 2 => "two" }])).to print_as <<~TABLE
        1   | 2
        ----|----
        one | two
      TABLE
    end

    it "hands a lambda column the row it was given, subclass and all" do
      indifferent = Class.new(Hash) do
        def [](key)
          super(key.to_s)
        end
      end
      row = indifferent.new
      row["author"] = "ryan"

      # the row keeps its own lookup, so :author finds the "author" key
      expect(printed([row], include: { two: ->(r) { r[:author] * 2 } })).to print_as <<~TABLE
        AUTHOR | TWO
        -------|---------
        ryan   | ryanryan
      TABLE
    end
  end

  describe "arrays of arrays" do
    it "prints a grid, with each position as a column" do
      expect(printed([[1, "alice"], [2, "bob"]])).to print_as <<~TABLE
        0 | 1
        --|------
        1 | alice
        2 | bob
      TABLE
    end

    it "lets you address a column by its index" do
      expect(printed([[1, "alice"], [2, "bob"]], "1")).to print_as <<~TABLE
        1
        -----
        alice
        bob
      TABLE
    end
  end

  describe "structs, Data and OpenStruct" do
    it "uses a struct's members as columns" do
      expect(printed([Struct.new(:title, :author).new("First", "ryan")])).to print_as <<~TABLE
        TITLE | AUTHOR
        ------|-------
        First | ryan
      TABLE
    end

    it "uses a Data object's members" do
      point = Data.define(:x, :y)

      # columns given explicitly: the default order comes from #methods, which
      # isn't the same on every ruby
      expect(printed([point.new(x: 1, y: 2)], "x", "y")).to print_as <<~TABLE
        X | Y
        --|--
        1 | 2
      TABLE
    end

    it "uses an OpenStruct's attributes rather than its methods" do
      expect(printed([OpenStruct.new(name: "alice", age: 30)])).to print_as <<~TABLE
        NAME  | AGE
        ------|----
        alice | 30
      TABLE
    end
  end

  describe "objects" do
    it "finds the methods defined on the object's own class" do
      post = Class.new do
        def headline
          "once upon a time"
        end
      end

      expect(printed([post.new])).to print_as <<~TABLE
        HEADLINE
        ----------------
        once upon a time
      TABLE
    end

    # Only the object's own class counts, no methods from a superclass or a mixin
    it "leaves out attributes inherited from a superclass" do
      base = Class.new { attr_accessor :title }
      post = Class.new(base) { attr_accessor :subtitle }.new
      post.title = "First"
      post.subtitle = "the worst"

      expect(printed([post])).to print_as <<~TABLE
        SUBTITLE
        ---------
        the worst
      TABLE

      expect(printed([post], include: :title)).to print_as <<~TABLE
        SUBTITLE  | TITLE 
        ----------|------
        the worst | First 
      TABLE

      # an object whose attributes are all inherited has nothing left to show
      expect(printed([Class.new(base).new])).to print_as "No data."
    end

    it "leaves out attributes mixed in from a module" do
      titled = Module.new { attr_accessor :title }
      post = Class.new do
        include titled
        attr_accessor :subtitle
      end.new
      post.title = "First"
      post.subtitle = "the worst"

      expect(printed([post])).to print_as <<~TABLE
        SUBTITLE
        ---------
        the worst
      TABLE
    end

    it "follows a dotted path, printing each parent once" do
      review = Struct.new(:stars)
      book = Struct.new(:title, :reviews)
      author = Struct.new(:name, :books)
      authors = [
        author.new("alice", [book.new("Book A", [review.new(5), review.new(3)]), book.new("Book B", [])]),
        author.new("bob", [book.new("Book C", [review.new(1)])]),
        author.new("carol", [])
      ]

      expect(printed(authors, "name", "books.title", "books.reviews.stars")).to print_as <<~TABLE
        NAME  | BOOKS.TITLE | BOOKS.REVIEWS.STARS
        ------|-------------|--------------------
        alice | Book A      | 5
              |             | 3
              | Book B      |
        bob   | Book C      | 1
        carol |             |
      TABLE
    end
  end

  describe "ORM-shaped objects" do
    it "reads column names from an ActiveRecord-style class.columns" do
      post = Class.new do
        def self.columns
          [Struct.new(:name).new("id"), Struct.new(:name).new("title")]
        end

        def id
          1
        end

        def title
          "from .columns"
        end

        def not_a_column
          "hidden"
        end
      end

      expect(printed([post.new])).to print_as <<~TABLE
        ID | TITLE
        ---|--------------
        1  | from .columns
      TABLE
    end

    it "reads a Sequel-style class.columns of symbols" do
      post = Class.new do
        def self.columns
          [:id, :title]
        end

        def id
          2
        end

        def title
          "from .columns"
        end
      end

      expect(printed([post.new])).to print_as <<~TABLE
        ID | TITLE
        ---|--------------
        2  | from .columns
      TABLE
    end

    it "reads a Mongoid-style #fields hash" do
      post = Class.new do
        def fields
          { "id" => nil, "title" => nil }
        end

        def id
          3
        end

        def title
          "from #fields"
        end
      end

      expect(printed([post.new])).to print_as <<~TABLE
        ID | TITLE
        ---|-------------
        3  | from #fields
      TABLE
    end
  end

  # Everything below prints badly. The output is pinned so that a fix shows up
  # here as a failure, rather than quietly changing what users see.
  describe "types that don't work yet" do
    it "can't follow a dotted path into a hash" do
      expect { printed([{ a: 1, b: { c: 2 } }], "a", "b.c") }.to raise_error NoMethodError
    end

    it "drops a column entirely when the association is nil" do
      author = Struct.new(:name, :books)

      expect(printed([author.new("alice", nil)], "name", "books.title")).to print_as <<~TABLE
        NAME
        -----
        alice
      TABLE
    end

    it "unwraps an object that defines to_a, losing its attributes" do
      collection = Class.new do
        include Enumerable
        attr_accessor :name

        def initialize(name, items)
          @name, @items = name, items
        end

        def each(&block)
          @items.each(&block)
        end
      end

      expect(printed(collection.new("mine", [1, 2]))).to print_as <<~TABLE
        VALUE
        -----
        1
        2
      TABLE
    end

    it "calls every zero-argument method, destructive ones included" do
      stateful = Class.new do
        def initialize(items)
          @items = items
        end

        def items
          @items
        end

        def size
          @items.size
        end

        def clear # no bang, so tp has no reason to avoid it
          @items.clear
        end
      end
      items = %w[a b]

      # items reads as [] even though it's measured before clear runs: the cell
      # holds the same array that clear empties
      expect(printed([stateful.new(items)], "items", "clear", "size")).to print_as <<~TABLE
        ITEMS | CLEAR | SIZE
        ------|-------|-----
        []    | []    | 0
      TABLE

      expect(items).to eq []
    end

    it "lets a single raising reader take down the whole print" do
      exploder = Class.new do
        def title
          "ok"
        end

        def boom
          raise ArgumentError, "do not call me"
        end
      end

      expect { printed([exploder.new], "title", "boom") }.to raise_error ArgumentError
    end

    it "chokes on an object whose respond_to_missing? says yes to everything" do
      proxy = Class.new do
        def respond_to_missing?(*)
          true
        end

        def method_missing(name, *)
          "delegated #{name}"
        end
      end

      # Array(data) asks for to_ary, gets a String, and gives up
      expect { printed([proxy.new]) }.to raise_error TypeError
    end
  end
end
