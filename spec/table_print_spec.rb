require 'spec_helper'
require 'table_print'

include TablePrint

describe TablePrint::Printer do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "printing an empty array" do
    it "returns the string 'no data'" do
      p = Printer.new([])
      p.table_print.should == 'No data.'
    end
  end

  describe "printing an object where there are only association columns with no data" do
    it "returns the string 'no data'" do
      Sandbox.add_class("Blog")
      Sandbox.add_attributes("Blog", :author)
      p = Printer.new(Sandbox::Blog.new, "author.name")
      p.table_print.should == 'No data.'
    end
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

    it "pulls the column names off the array of hashes" do
      data = [{:name => "User 1",
               :surname => "Familyname 1"
              },
              {:name => "User 2",
               :surname => "Familyname 2"}]

      p = Printer.new(data)
      cols = p.columns
      cols.length.should == 2
      cols.collect(&:name).sort.should == ['name', 'surname']
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
