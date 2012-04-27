require 'spec_helper'
require "formatter"

include TablePrint

describe TablePrint::FixedWidthFormatter do
  before(:each) do
    @f = TablePrint::FixedWidthFormatter.new(10)
  end

  describe "#format" do
    it "pads a short field to the specified width" do
      @f.format("asdf").should == "asdf      "
    end

    it "truncates long fields with periods" do
      @f.format("1234567890123456").should == "1234567..."
    end
  end

  describe "#width" do
    it "returns the width" do
      @f.width.should == 10
    end
  end
end
