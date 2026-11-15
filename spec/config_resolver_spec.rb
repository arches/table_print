require 'spec_helper'

describe TablePrint::ConfigResolver do

  #it "starts with the specified config" do
  #  Sandbox.add_class("Configged")
  #  TablePrint::Config.set(Sandbox::Configged, [:title, :author])
  #  c = TablePrint::ConfigResolver.new(Object, Object, [:name])
  #  expect(c.columns.length).to eq 2
  #  expect(c.columns.first.name).to eq 'title'
  #  expect(c.columns.last.name).to eq 'author'
  #end

  describe "#get_and_remove" do
    it "deletes and returns the :except key from an array" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, :author, {:except => [:title]}]
      expect(c.get_and_remove(options, :except)).to eq [:title]
      expect(options).to eq [:title, :author]
    end

    it "deletes and returns the :except key from an array with an :include key" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title]}, {:include => [:author]}]
      expect(c.get_and_remove(options, :except)).to eq [:title]
      expect(options).to eq [:title, {:include => [:author]}]
    end

    it "deletes and returns the :except key from a hash with an :include key" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title], :include => [:author]}]
      expect(c.get_and_remove(options, :except)).to eq [:title]
      expect(options).to eq [:title, {:include => [:author]}]
    end

    it "deletes and returns both the :include and :except keys" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title]}, {:include => [:author]}]
      expect(c.get_and_remove(options, :include)).to eq [:author]
      expect(c.get_and_remove(options, :except)).to eq [:title]
      expect(options).to eq [:title]
    end

    it "works even if the array doesn't have an exception hash" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, :author]
      expect(c.get_and_remove(options, :except)).to eq []
      expect(options).to eq [:title, :author]
    end
  end

  describe ":only" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo)
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [:title], 'foo')
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'foo'
      end
    end
    context "with an array of symbols and strings" do
      it "returns columns named foo and bar" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo, 'bar')
        expect(c.columns.length).to eq 2
        expect(c.columns.first.name).to eq 'foo'
        expect(c.columns.last.name).to eq 'bar'
      end
    end
  end

  describe ":include" do
    context "with a symbol" do
      it "adds foo to the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => :foo)
        expect(c.columns.length).to eq 2
        expect(c.columns.first.name).to eq 'title'
        expect(c.columns.last.name).to eq 'foo'
      end
    end

    context "with an array" do
      it "adds foo and bar to the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => [:foo, :bar])
        expect(c.columns.length).to eq 3
        expect(c.columns.first.name).to eq 'title'
        expect(c.columns.last.name).to eq 'bar'
      end
    end

    context "with options" do
      it "adds foo to the list of methods and remembers its options" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => {:foo => {:width => 10}})
        expect(c.columns.length).to eq 2
        expect(c.columns.first.name).to eq 'title'

        expect(c.columns.last.name).to eq 'foo'
        expect(c.columns.last.default_width).to eq 10
      end
    end
  end

  describe ":except" do
    context "with a symbol" do
      it "removes foo from the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title, :foo], :except => :foo)
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'title'
      end
    end
    context "with an array" do
      it "removes foo and bar from the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title, :foo, :bar], :except => [:foo, 'bar'])
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'title'
      end
    end
  end

  describe "lambdas" do
    it "uses the key as the name and the lambda as the display method" do
      lam = lambda {}
      c = TablePrint::ConfigResolver.new(Object, [:title], :foo => {:display_method => lam})
      expect(c.columns.length).to eq 1
      expect(c.columns.first.name).to eq 'foo'
      expect(c.columns.first.display_method).to eq lam
    end

    context "without the display_method keyword" do
      it "uses the key as the name and the lambda as the display method" do
        lam = lambda {}
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo => lam)
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'foo'
        expect(c.columns.first.display_method).to eq lam
      end
    end
  end

  describe "several columns in one hash" do
    let(:first) { lambda { |row| "one" } }
    let(:second) { lambda { |row| "two" } }

    it "makes a column out of every key" do
      c = TablePrint::ConfigResolver.new(Object, [], :title => { :max_width => 3 }, :author => { :max_width => 5 })

      expect(c.columns.collect(&:name)).to eq %w[title author]
      expect(c.columns.collect(&:default_width)).to eq [3, 5]
    end

    it "handles more than two" do
      c = TablePrint::ConfigResolver.new(Object, [], :a => {}, :b => {}, :c => {})

      expect(c.columns.collect(&:name)).to eq %w[a b c]
    end

    it "keeps them in the order they were written" do
      c = TablePrint::ConfigResolver.new(Object, [], :zebra => {}, :aardvark => {})

      expect(c.columns.collect(&:name)).to eq %w[zebra aardvark]
    end

    it "takes a lambda for each one" do
      c = TablePrint::ConfigResolver.new(Object, [], :a => first, :b => second)

      expect(c.columns.collect(&:name)).to eq %w[a b]
      expect(c.columns.collect(&:display_method)).to eq [first, second]
    end

    it "mixes lambdas and option hashes in the same hash" do
      c = TablePrint::ConfigResolver.new(Object, [], :a => first, :title => { :max_width => 3 })

      expect(c.columns.collect(&:name)).to eq %w[a title]
      expect(c.columns.first.display_method).to eq first
      expect(c.columns.last.default_width).to eq 3
    end

    it "works for columns added with :include" do
      c = TablePrint::ConfigResolver.new(Object, [:title], :include => { :a => first, :b => second })

      expect(c.columns.collect(&:name)).to eq %w[title a b]
      expect(c.columns.last.display_method).to eq second
    end

    it "works alongside :except in the same hash" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], :except => :author, :include => { :a => first, :b => second })

      expect(c.columns.collect(&:name)).to eq %w[title a b]
    end

    it "carries display_name and display_method through for each one" do
      c = TablePrint::ConfigResolver.new(Object, [],
                                         :one => { :display_name => "First One", :display_method => first },
                                         :two => { :display_name => "Second One", :display_method => second })

      expect(c.columns.collect(&:name)).to eq ["First One", "Second One"]
      expect(c.columns.collect(&:display_method)).to eq [first, second]
    end

    it "still accepts a column per hash, with braces" do
      c = TablePrint::ConfigResolver.new(Object, [], [{ :title => { :max_width => 3 } }, { :author => { :max_width => 5 } }])

      expect(c.columns.collect(&:name)).to eq %w[title author]
      expect(c.columns.collect(&:default_width)).to eq [3, 5]
    end

    it "still accepts a single-key hash" do
      c = TablePrint::ConfigResolver.new(Object, [], :title => { :max_width => 3 })

      expect(c.columns.collect(&:name)).to eq %w[title]
      expect(c.columns.first.default_width).to eq 3
    end

    it "still accepts a Column object passed to :include" do
      column = TablePrint::Column.new(:name => "handmade")
      c = TablePrint::ConfigResolver.new(Object, [:title], :include => column)

      expect(c.columns.collect(&:name)).to eq %w[title handmade]
    end
  end

  describe "#usable_column_names" do
    it "returns default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title])
      expect(c.usable_column_names).to eq ['title']
    end

    it "returns specified columns instead of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:author])
      expect(c.usable_column_names).to eq ['author']
    end

    it "applies includes on top of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:include => :author])
      expect(c.usable_column_names).to eq ['title', 'author']
    end

    it "applies includes on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:author, {:include => :pub_date}])
      expect(c.usable_column_names).to eq ['author', 'pub_date']
    end

    it "applies excepts on top of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:except => :author])
      expect(c.usable_column_names).to eq ['title']
    end

    it "applies excepts on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:pub_date, :length, {:except => :length}])
      expect(c.usable_column_names).to eq ['pub_date']
    end

    it "applies both includes and excepts on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:pub_date, :length, {:except => :length, :include => :foobar}])
      expect(c.usable_column_names).to eq ['pub_date', 'foobar']
    end
  end

  describe "column options" do
    context "display_method" do
      it "sets the display method on the column" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:display_method => :boofar})
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'title'
        expect(c.columns.first.display_method).to eq "boofar"
      end
    end
    context "width" do
      it "sets the default width" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:width => 100})
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'title'
        expect(c.columns.first.default_width).to eq 100
      end

      it "accepts max_width, the current spelling of the same option" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:max_width => 100})
        expect(c.columns.first.default_width).to eq 100
      end

      it "prefers max_width when both spellings are given" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:width => 10, :max_width => 100})
        expect(c.columns.first.default_width).to eq 100
      end
    end
    context "formatters" do
      it "adds the formatters to the column" do
        f1 = {}
        f2 = {}
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:formatters => [f1, f2]})
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'title'
        expect(c.columns.first.formatters).to eq [f1, f2]
      end
    end
    context "display_name" do
      it "sets the display name on the column" do
        c = TablePrint::ConfigResolver.new(Object, [], :title => {:display_name => "Ti Tle"})
        expect(c.columns.length).to eq 1
        expect(c.columns.first.name).to eq 'Ti Tle'
        expect(c.columns.first.display_method).to eq "title"
      end

      it "keeps a display_method the caller specified" do
        lam = lambda { |row| row }
        c = TablePrint::ConfigResolver.new(Object, [], :whatever => {:display_name => "Ti Tle", :display_method => lam})

        expect(c.columns.first.name).to eq "Ti Tle"
        expect(c.columns.first.display_method).to eq lam
      end

      it "keeps a display_method given as a symbol, too" do
        c = TablePrint::ConfigResolver.new(Object, [], :whatever => {:display_name => "Ti Tle", :display_method => :title})

        expect(c.columns.first.name).to eq "Ti Tle"
        expect(c.columns.first.display_method).to eq "title"
      end
    end
  end

  describe "#option_to_column" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column(:foo)
        expect(column.name).to eq 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column('foo')
        expect(column.name).to eq 'foo'
      end
    end
    context "with a hash" do
      it "returns a column named foo and the specified options" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column({:foo => {:default_width => 10}})
        expect(column.name).to eq 'foo'
        expect(column.default_width).to eq 10
      end
    end
  end
end
