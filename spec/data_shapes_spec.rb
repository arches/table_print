require 'spec_helper'

# One example per kind of input, each showing the data and the table it prints.
#
# The rest of the suite covers behaviour thoroughly and input types only in passing.
#
# The last group pins types that print badly today, so that fixing one fails
# here loudly instead of changing behaviour nobody notices.
describe "printing" do
  # Every cell is padded, and trailing spaces are invisible in a heredoc, so
  # compare the tables without them.
  def printed(data, *options)
    TablePrint::Printer.new(data, options).table_print.to_s.lines.collect { |line| line.rstrip + "\n" }.join
  end

  # The first row is taken as representative of the whole set, whatever the data
  # is. Every other group below inherits this rule.
  describe "choosing columns" do
    it "takes them from the first row" do
      expect(printed([{ a: 1 }, { b: 2 }])).to eq <<~TABLE
        A
        --------------
        1
        Method Missing
      TABLE
    end

    it "shows nothing for cells past the first row's width" do
      expect(printed([%w[a b], %w[c], %w[d e f]])).to eq <<~TABLE
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

      expect(printed(data)).to eq <<~TABLE
        VALUE
        -----
        hello
        world
      TABLE

      expect(data).to eq %w[hello world] # tp used to call String#clear on these
    end

    it "treats symbols and numbers the same way" do
      expect(printed([:sym, 42, 3.14])).to eq <<~TABLE
        VALUE
        -----
        sym
        42
        3.14
      TABLE
    end

    it "treats booleans the same way" do
      expect(printed([true, false])).to eq <<~TABLE
        VALUE
        -----
        true
        false
      TABLE
    end
  end

  describe "hashes" do
    it "prints one bare hash as a single row" do
      expect(printed("host" => "db.internal", "user" => "app")).to eq <<~TABLE
        HOST        | USER
        ------------|-----
        db.internal | app
      TABLE
    end

    it "uses the keys as columns, blank for a nil" do
      expect(printed([{ a: 1, b: "two" }, { a: 3, b: nil }])).to eq <<~TABLE
        A | B
        --|----
        1 | two
        3 |
      TABLE
    end

    it "finds values behind keys that are neither strings nor symbols" do
      expect(printed([{ 1 => "one", 2 => "two" }])).to eq <<~TABLE
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
      expect(printed([row], include: { two: ->(r) { r[:author] * 2 } })).to eq <<~TABLE
        AUTHOR | TWO
        -------|---------
        ryan   | ryanryan
      TABLE
    end
  end

  describe "arrays of arrays" do
    it "prints a grid, with each position as a column" do
      expect(printed([[1, "alice"], [2, "bob"]])).to eq <<~TABLE
        0 | 1
        --|------
        1 | alice
        2 | bob
      TABLE
    end

    it "lets you address a column by its index" do
      expect(printed([[1, "alice"], [2, "bob"]], "1")).to eq <<~TABLE
        1
        -----
        alice
        bob
      TABLE
    end
  end

  describe "structs, Data and OpenStruct" do
    it "uses a struct's members as columns" do
      expect(printed([Struct.new(:title, :author).new("First", "ryan")])).to eq <<~TABLE
        TITLE | AUTHOR
        ------|-------
        First | ryan
      TABLE
    end

    it "uses a Data object's members" do
      point = Data.define(:x, :y)

      # columns given explicitly: the default order comes from #methods, which
      # isn't the same on every ruby
      expect(printed([point.new(x: 1, y: 2)], "x", "y")).to eq <<~TABLE
        X | Y
        --|--
        1 | 2
      TABLE
    end

    it "uses an OpenStruct's attributes rather than its methods" do
      expect(printed([OpenStruct.new(name: "alice", age: 30)])).to eq <<~TABLE
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

      expect(printed([post.new])).to eq <<~TABLE
        HEADLINE
        ----------------
        once upon a time
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

      expect(printed(authors, "name", "books.title", "books.reviews.stars")).to eq <<~TABLE
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

      expect(printed([post.new])).to eq <<~TABLE
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

      expect(printed([post.new])).to eq <<~TABLE
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

      expect(printed([post.new])).to eq <<~TABLE
        ID | TITLE
        ---|-------------
        3  | from #fields
      TABLE
    end
  end

  # Everything below prints badly. The output is pinned so that a fix shows up
  # here as a failure, rather than quietly changing what users see.
  describe "types that don't work yet" do
    it "ignores attributes inherited from a superclass" do
      base = Class.new do
        attr_accessor :title

        def initialize(title)
          @title = title
        end
      end

      expect(printed([Class.new(base).new("First")])).to eq "No data.\n"
    end

    it "ignores attributes mixed in from a module" do
      titled = Module.new { attr_accessor :title }
      post = Class.new do
        include titled

        def initialize(title)
          @title = title
        end
      end

      expect(printed([post.new("First")])).to eq "No data.\n"
    end

    it "can't follow a dotted path into a hash" do
      expect { printed([{ a: 1, b: { c: 2 } }], "a", "b.c") }.to raise_error NoMethodError
    end

    it "drops a column entirely when the association is nil" do
      author = Struct.new(:name, :books)

      expect(printed([author.new("alice", nil)], "name", "books.title")).to eq <<~TABLE
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

      expect(printed(collection.new("mine", [1, 2]))).to eq <<~TABLE
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
      expect(printed([stateful.new(items)], "items", "clear", "size")).to eq <<~TABLE
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
