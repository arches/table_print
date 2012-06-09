require 'spec_helper'
require "formatter"

include TablePrint

describe TablePrint::NoNewlineFormatter do
  before(:each) do
    @f = TablePrint::NoNewlineFormatter.new
  end

  describe "#formater" do
    it "replaces carriage returns with spaces" do
      @f.format("foo\r\nbar").should == "foo bar"
    end

    it "replaces newlines with spaces" do
      @f.format("foo\nbar").should == "foo bar"
    end
  end
end

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

    it "uses an empty string in place of nils" do
      @f.format(nil).should == "          "
    end

    it "turns objects into strings before trying to format them" do
      @f.format(123).should == "123       "
    end
  end

  describe "#width" do
    it "returns the width" do
      @f.width.should == 10
    end

    it "respects the config'd max_width" do
      max = TablePrint::Config.max_width
      TablePrint::Config.max_width = 5
      @f.width.should == 5
      TablePrint::Config.max_width = max
    end
  end
end
