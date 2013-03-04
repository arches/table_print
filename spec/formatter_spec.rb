require 'spec_helper'

include TablePrint

describe TablePrint::TimeFormatter do
  describe "#format" do
    it "only operates on Time objects" do
      f = TablePrint::TimeFormatter.new
      f.format(12).should == 12
    end

    it "uses the config'd time_format" do
      f = TablePrint::TimeFormatter.new
      time = Time.local(2012, 01, 11, 1, 23, 45)
      f.format(time).should == "2012-01-11 01:23:45" # default time format is set in config.rb
    end

    it "overrides the config'd time format with one it was passed" do
      f = TablePrint::TimeFormatter.new("%Y")
      time = Time.local(2012, 01, 11, 1, 23, 45)
      f.format(time).should == "2012" # default time format is set in config.rb
    end
  end
end

describe TablePrint::NoNewlineFormatter do
  before(:each) do
    @f = TablePrint::NoNewlineFormatter.new
  end

  describe "#format" do
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
end
