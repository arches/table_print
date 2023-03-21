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
      expect(p.table_print).to eq 'No data.'
    end
  end

  describe "printing an object where there are only association columns with no data" do
    it "returns the string 'no data'" do
      Sandbox.add_class("Blog")
      Sandbox.add_attributes("Blog", :author)
      p = Printer.new(Sandbox::Blog.new, "author.name")
      expect(p.table_print).to eq 'No data.'
    end
  end

  describe "message" do
    it "defaults to the time the print took, but in string" do
      message = Printer.new([]).message
      expect(message).to be_a String
      expect(message.to_f.to_s).to eq(message)
    end

    it "shows a warning if the printed objects have config" do
      Sandbox.add_class("User")

      tp.set Sandbox::User, :id, :email
      p = Printer.new(Sandbox::User.new)
      expect(p.message).to eq "Printed with config"
    end
  end

  describe "#columns" do

    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new)
      cols = p.send(:columns)
      expect(cols.length).to eq 1
      expect(cols.first.name).to eq 'title'
    end

    it 'pull the column names off of the array of Structs' do
      struct = Struct.new(:name, :surname)
      data = [struct.new("User 1", "Familyname 1"), struct.new("User 2", "Familyname 2")]
      p = Printer.new(data)
      cols = p.send(:columns)
      expect(cols.length).to eq 2
      expect(cols.collect(&:name).sort).to eq ['name', 'surname']
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
        expect(cols.length).to eq 2
        expect(cols.collect(&:name).sort).to eq ['name', 'surname']
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
        expect(cols.length).to eq 2
        expect(cols.collect(&:name).sort).to eq ['name', 'surname']
      end
    end

    it "pulls out excepted columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      p = Printer.new(Sandbox::Post.new, :except => :title)
      cols = p.send(:columns)
      expect(cols.length).to eq 1
      expect(cols.first.name).to eq 'author'
    end

    it "adds included columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new, :include => :author)
      cols = p.send(:columns)
      expect(cols.length).to eq 2
      expect(cols.first.name).to eq 'title'
      expect(cols.last.name).to eq 'author'
    end
  end
end
