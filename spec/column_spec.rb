require 'spec_helper'
require 'column'

include TablePrint

describe Column do
  let(:c) {Column.new(:data => ["Once upon a time", "there was a dark and stormy night"], :name => :tagline)}

  it "remembers its name as a string" do
    c.name.should == "tagline"
  end

  it "exposes the array of data representing the column" do
    c.data.should == ["Once upon a time", "there was a dark and stormy night"]
  end

  describe "#add_formatter" do
    it "stores the formatter" do
      f = {}
      c.add_formatter(f)
      c.formatters.should == [f]
    end
  end

  describe "#formatter=" do
    it "adds the formatters individually" do
      c.should_receive(:add_formatter).twice
      c.formatters = [{}, {}]
    end
  end

  describe "#display_method" do
    it "stores the column's display method as a string" do
      c = Column.new(:display_method => :boofar)
      c.display_method.should == "boofar"
    end

    it "doesn't turn a lambda display method into a string" do
      lam = lambda{}
      c = Column.new(:display_method => lam)
      c.display_method.should == lam
    end

    it "defaults to the column name" do
      c = Column.new(:name => :boofar)
      c.display_method.should == "boofar"
    end
  end

  describe "#data_width" do
    it "reflects the width of the data set" do
      c.data_width.should == 33
    end

    it "includes the title in the calculation" do
      c.name = "a horse is a horse of course of course"
      c.data_width.should == 38
    end
  end

  describe "#width" do
    it "returns the specified width" do
      c.width = 14
      c.width.should == 14
    end

    it "uses the data_width if no width has been set" do
      c.width.should == 33
    end
  end
end
