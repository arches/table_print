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

end
