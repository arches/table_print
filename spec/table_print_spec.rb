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
      cols.first.name.should == 'title'
      cols.last.name.should == 'author'
    end
  end
end
