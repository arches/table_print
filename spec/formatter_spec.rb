require 'spec_helper'
require_relative "../lib/formatter"

include TablePrint

describe TablePrint::FixedWidthFormatter do
  describe "#format" do
    before(:each) do
      @f = TablePrint::FixedWidthFormatter.new(10)
    end
    it "pads a short field to the specified width" do
      @f.format("asdf").should == "asdf      "
    end

    it "truncates long fields with periods" do
      @f.format("1234567890123456").should == "1234567..."
    end
  end
end
