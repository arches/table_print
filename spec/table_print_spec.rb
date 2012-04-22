require 'spec_helper'
require_relative '../lib/table_print'

include TablePrint

describe TablePrint::Printer do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "#column_names" do
    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new(title: "first post"))
      p.columns.should == ['title']
    end
  end

  describe "#header_row" do
    it "sets cells values to uppercased column names" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      p = Printer.new(Sandbox::Post.new(title: "first post", author: "bobby"))
      p.header.cells.should == {'title' => 'TITLE', 'author' => 'AUTHOR'}
    end
  end
end
