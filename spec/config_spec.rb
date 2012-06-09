require 'spec_helper'
require 'config'

describe TablePrint::Config do

  describe ":only" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::Config.new([:title], :foo)
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::Config.new([:title], 'foo')
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
      end
    end
    context "with an array of symbols and strings" do
      it "returns columns named foo and bar" do
        c = TablePrint::Config.new([:title], :foo, 'bar')
        c.columns.length.should == 2
        c.columns.first.name.should == 'foo'
        c.columns.last.name.should == 'bar'
      end
    end
  end

  describe ":include" do
    context "with a symbol" do
      it "adds foo to the list of methods" do
        c = TablePrint::Config.new([:title], :include => :foo)
        c.columns.length.should == 2
        c.columns.first.name.should == 'title'
        c.columns.last.name.should == 'foo'
      end
    end

    context "with an array" do
      it "adds foo and bar to the list of methods" do
        c = TablePrint::Config.new([:title], :include => [:foo, :bar])
        c.columns.length.should == 3
        c.columns.first.name.should == 'title'
        c.columns.last.name.should == 'bar'
      end
    end

    context "with options" do
      it "adds foo to the list of methods and remembers its options" do
        c = TablePrint::Config.new([:title], :include => {:foo => {:width => 10}})
        c.columns.length.should == 2
        c.columns.first.name.should == 'title'

        c.columns.last.name.should == 'foo'
        c.columns.last.width.should == 10
      end
    end
  end

  describe ":except" do
    context "with a symbol" do
      it "removes foo from the list of methods" do
        c = TablePrint::Config.new([:title, :foo], :except => :foo)
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
      end
    end
    context "with an array" do
      it "removes foo and bar from the list of methods" do
        c = TablePrint::Config.new([:title, :foo, :bar], :except => [:foo, 'bar'])
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
      end
    end
  end

  describe "lambdas" do
    it "uses the key as the name and the lambda as the display method" do
      lam = lambda {}
      c = TablePrint::Config.new([:title], :foo => {:display_method => lam})
      c.columns.length.should == 1
      c.columns.first.name.should == 'foo'
      c.columns.first.display_method.should == lam
    end

    context "without the display_method keyword" do
      it "uses the key as the name and the lambda as the display method" do
        lam = lambda {}
        c = TablePrint::Config.new([:title], :foo => lam)
        c.columns.length.should == 1
        c.columns.first.name.should == 'foo'
        c.columns.first.display_method.should == lam
      end
    end
  end

  describe "column options" do
    context "display_method" do
      it "sets the display method on the column" do
        c = TablePrint::Config.new([:title], :title => {:display_method => :boofar})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.display_method.should == "boofar"
      end
    end
    context "width" do
      it "sets the width" do
        c = TablePrint::Config.new([:title], :title => {:width => 100})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.width.should == 100
      end
    end
    context "formatters" do
      it "adds the formatters to the column" do
        f1 = {}
        f2 = {}
        c = TablePrint::Config.new([:title], :title => {:formatters => [f1, f2]})
        c.columns.length.should == 1
        c.columns.first.name.should == 'title'
        c.columns.first.formatters.should == [f1, f2]
      end
    end
  end

  describe "#option_to_column" do
    context "with a symbol" do
      it "returns a column named foo" do
        c = TablePrint::Config.new([])
        column = c.option_to_column(:foo)
        column.name.should == 'foo'
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        c = TablePrint::Config.new([])
        column = c.option_to_column('foo')
        column.name.should == 'foo'
      end
    end
    context "with a hash" do
      it "returns a column named foo and the specified options" do
        c = TablePrint::Config.new([])
        column = c.option_to_column({:foo => {:width => 10}})
        column.name.should == 'foo'
        column.width.should == 10
      end
    end
  end
end
