require 'spec_helper'

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
    it "returns the column's display method as a string" do
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
    context "when default width is specified" do
      it "uses the default width" do
        c.default_width = 10
        c.stub(:data_width => 15)
        c.stub(:max_width => 20)
        c.width.should == 10
      end

      it "isn't limited by the config width" do
        c.default_width = 40
        c.stub(:data_width => 50)
        c.stub(:max_width => 20)
        c.width.should == 40
      end
    end

    context "When default width is not specified" do
      it "uses the data width" do
        c.default_width = nil
        c.stub(:data_width => 10)
        c.stub(:max_width => 20)
        c.width.should == 10
      end

      it "is limited by the config width" do
        c.default_width = nil
        c.stub(:data_width => 30)
        c.stub(:max_width => 20)
        c.width.should == 20
      end
    end
  end
end
