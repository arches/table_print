require 'spec_helper'

describe TablePrint::ConfigResolver do

  #it "starts with the specified config" do
  #  Sandbox.add_class("Configged")
  #  TablePrint::Config.set(Sandbox::Configged, [:title, :author])
  #  c = TablePrint::ConfigResolver.new(Object, Object, [:name])
  #  c.columns.length.should == 2
  #  c.columns.first.name.should == 'title'
  #  c.columns.last.name.should == 'author'
  #end

  describe "#get_and_remove" do
    it "deletes and returns the :except key from an array" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, :author, {:except => [:title]}]
      c.get_and_remove(options, :except).should == [:title]
      options.should == [:title, :author]
    end

    it "deletes and returns the :except key from an array with an :include key" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title]}, {:include => [:author]}]
      c.get_and_remove(options, :except).should == [:title]
      options.should == [:title, {:include => [:author]}]
    end

    it "deletes and returns the :except key from a hash with an :include key" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title], :include => [:author]}]
      c.get_and_remove(options, :except).should == [:title]
      options.should == [:title, {:include => [:author]}]
    end

    it "deletes and returns both the :include and :except keys" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, {:except => [:title]}, {:include => [:author]}]
      c.get_and_remove(options, :include).should == [:author]
      c.get_and_remove(options, :except).should == [:title]
      options.should == [:title]
    end

    it "works even if the array doesn't have an exception hash" do
      c = TablePrint::ConfigResolver.new(Object, [])
      options = [:title, :author]
      c.get_and_remove(options, :except).should == []
      options.should == [:title, :author]
    end
  end

  describe ":only" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo)
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [:title], 'foo')
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
      end
    end
    context "with an array of symbols and strings" do
      it "returns columns named foo and bar" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo, 'bar')
        c.columns.length.should == 2
        c.columns.first.name.should == 'foo'
        c.columns.last.name.should == 'bar'
      end
    end
  end

  describe ":include" do
    context "with a symbol" do
      it "adds foo to the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => :foo)
        c.columns.length.should == 2
        c.columns.first.name.should == 'title'
        c.columns.last.name.should == 'foo'
      end
    end

    context "with an array" do
      it "adds foo and bar to the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => [:foo, :bar])
        c.columns.length.should == 3
        c.columns.first.name.should == 'title'
        c.columns.last.name.should == 'bar'
      end
    end

    context "with options" do
      it "adds foo to the list of methods and remembers its options" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :include => {:foo => {:width => 10}})
        c.columns.length.should == 2
        c.columns.first.name.should == 'title'

        c.columns.last.name.should == 'foo'
        c.columns.last.default_width.should == 10
      end
    end
  end

  describe ":except" do
    context "with a symbol" do
      it "removes foo from the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title, :foo], :except => :foo)
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
      end
    end
    context "with an array" do
      it "removes foo and bar from the list of methods" do
        c = TablePrint::ConfigResolver.new(Object, [:title, :foo, :bar], :except => [:foo, 'bar'])
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
      end
    end
  end

  describe "lambdas" do
    it "uses the key as the name and the lambda as the display method" do
      lam = lambda {}
      c = TablePrint::ConfigResolver.new(Object, [:title], :foo => {:display_method => lam})
      c.columns.length.should == 1
      c.columns.first.name.should == 'foo'
      c.columns.first.display_method.should == lam
    end

    context "without the display_method keyword" do
      it "uses the key as the name and the lambda as the display method" do
        lam = lambda {}
        c = TablePrint::ConfigResolver.new(Object, [:title], :foo => lam)
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
        c.columns.first.display_method.should == lam
      end
    end
  end

  describe "#usable_column_names" do
    it "returns default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title])
      c.usable_column_names.should == ['title']
    end

    it "returns specified columns instead of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:author])
      c.usable_column_names.should == ['author']
    end

    it "applies includes on top of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:include => :author])
      c.usable_column_names.should == ['title', 'author']
    end

    it "applies includes on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title], [:author, {:include => :pub_date}])
      c.usable_column_names.should == ['author', 'pub_date']
    end

    it "applies excepts on top of default columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:except => :author])
      c.usable_column_names.should == ['title']
    end

    it "applies excepts on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:pub_date, :length, {:except => :length}])
      c.usable_column_names.should == ['pub_date']
    end

    it "applies both includes and excepts on top of specified columns" do
      c = TablePrint::ConfigResolver.new(Object, [:title, :author], [:pub_date, :length, {:except => :length, :include => :foobar}])
      c.usable_column_names.should == ['pub_date', 'foobar']
    end
  end

  describe "column options" do
    context "display_method" do
      it "sets the display method on the column" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:display_method => :boofar})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.display_method.should == "boofar"
      end
    end
    context "width" do
      it "sets the default width" do
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:width => 100})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.default_width.should == 100
      end
    end
    context "formatters" do
      it "adds the formatters to the column" do
        f1 = {}
        f2 = {}
        c = TablePrint::ConfigResolver.new(Object, [:title], :title => {:formatters => [f1, f2]})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.formatters.should == [f1, f2]
      end
    end
    context "display_name" do
      it "sets the display name on the column" do
        c = TablePrint::ConfigResolver.new(Object, [], :title => {:display_name => "Ti Tle"})
        c.columns.length.should == 1
        c.columns.first.name.should == 'Ti Tle'
        c.columns.first.display_method.should == "title"
      end
    end
  end

  describe "#option_to_column" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column(:foo)
        column.name.should == 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column('foo')
        column.name.should == 'foo'
      end
    end
    context "with a hash" do
      it "returns a column named foo and the specified options" do
        c = TablePrint::ConfigResolver.new(Object, [])
        column = c.option_to_column({:foo => {:default_width => 10}})
        column.name.should == 'foo'
        column.default_width.should == 10
      end
    end
  end
end
