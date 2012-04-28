require 'spec_helper'
require 'table_print'

include TablePrint

describe TablePrint::Printer do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "#columns" do
    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new)
      cols = p.columns
      cols.length.should == 1
      cols.first.name.should == 'title'
    end

    it "pulls out excepted columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      p = Printer.new(Sandbox::Post.new, :except => :title)
      cols = p.columns
      cols.length.should == 1
      cols.first.name.should == 'author'
    end

    it "adds included columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new, :include => :author)
      cols = p.columns
      cols.length.should == 2
      cols.first.name.should == 'author'
      cols.last.name.should == 'title'
    end
  end

  describe "#hash_to_columns" do
    it "turns a hash into a list of column objects" do
      Printer.new({}, :foo).hash_to_columns.first.should be_a Column
    end

    context "with a single column name" do
      it "returns a single column with that name" do
        cols = Printer.new({}, :foo).hash_to_columns
        cols.length.should == 1
        cols.first.name.should == 'foo'
      end
    end

    context "with two column names" do
      it "returns two columns, one with each name" do
        cols = Printer.new({}, [:foo, :bar]).hash_to_columns
        cols.length.should == 2
        cols.first.name.should == 'foo'
        cols.last.name.should == 'bar'
      end
    end

    context "with a width" do
      it "returns a column with the specified width" do
        cols = Printer.new({}, {:name => :foo, :width => 10}).hash_to_columns
        cols.length.should == 1
        cols.first.name.should == 'foo'
        cols.first.width.should == 10
      end
    end
  end
end
