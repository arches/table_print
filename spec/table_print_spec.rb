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

  describe "message" do
    it "defaults to the time the print took" do
      Printer.new([]).message.should be_a Numeric
    end

    it "shows a warning if the printed objects have config" do
      Sandbox.add_class("User")

      tp.set Sandbox::User, :id, :email
      p = Printer.new(Sandbox::User.new)
      p.message.should == "Printed with config"
    end
  end

  describe "#columns" do

    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new)
      cols = p.send(:columns)
      cols.length.should == 1
      cols.first.name.should == 'title'
    end

    it 'pull the column names off of the array of Structs' do
      struct = Struct.new(:name, :surname)
      data = [struct.new("User 1", "Familyname 1"), struct.new("User 2", "Familyname 2")]
      p = Printer.new(data)
      cols = p.send(:columns)
      cols.length.should == 2
      cols.collect(&:name).sort.should == ['name', 'surname']
    end
    
    context 'when keys are symbols' do
      it "pulls the column names off the array of hashes" do
        data = [{:name => "User 1",
                  :surname => "Familyname 1"
                },
                {:name => "User 2",
                  :surname => "Familyname 2"}]

        p = Printer.new(data)
        cols = p.send(:columns)
        cols.length.should == 2
        cols.collect(&:name).sort.should == ['name', 'surname']
      end
    end

    context 'when keys are strings' do
      it "pulls the column names off the array of hashes" do
        data = [{'name' => "User 1",
                  'surname' => "Familyname 1"
                },
                {'name' => "User 2",
                  'surname' => "Familyname 2"}]

        p = Printer.new(data)
        cols = p.send(:columns)
        cols.length.should == 2
        cols.collect(&:name).sort.should == ['name', 'surname']
      end
    end

    it "pulls out excepted columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      p = Printer.new(Sandbox::Post.new, :except => :title)
      cols = p.send(:columns)
      cols.length.should == 1
      cols.first.name.should == 'author'
    end

    it "adds included columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new, :include => :author)
      cols = p.send(:columns)
      cols.length.should == 2
      cols.first.name.should == 'title'
      cols.last.name.should == 'author'
    end
  end
end
