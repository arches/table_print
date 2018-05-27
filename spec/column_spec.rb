require 'spec_helper'

include TablePrint

describe Column do
  let(:config) { TablePrint::Config.new }

  let(:column) {
    Column.new(
      :config => config,
      :name => :tagline,
      :data => ["Once upon a time", "there was a dark and stormy night"]
    )
  }

  it "remembers its name as a string" do
    column.name.should == "tagline"
  end

  it "exposes the array of data representing the column" do
    column.data.should == ["Once upon a time", "there was a dark and stormy night"]
  end

  describe "#display_method" do
    it "returns the column's display method as a string" do
      column = Column.new(:display_method => :boofar)
      column.display_method.should == "boofar"
    end

    it "doesn't turn a lambda display method into a string" do
      lam = lambda{}
      column = Column.new(:display_method => lam)
      column.display_method.should == lam
    end

    it "defaults to the column name" do
      column = Column.new(:name => :boofar)
      column.display_method.should == "boofar"
    end
  end

  describe "#data_width" do
    it "reflects the width of the data set" do
      column.data_width.should == 33
    end

    it "includes the title in the calculation" do
      column.name = "a horse is a horse of course of course"
      column.data_width.should == 38
    end
  end

  describe "#width" do
    context "when fixed width is specified" do
      it "uses the fixed width" do
        config.set(:fixed_width, 10)

        column.stub(:data_width => 15)
        column.stub(:max_width => 20)
        column.width.should == 10

        column.stub(:data_width => 5)
        column.stub(:max_width => 2)
        column.width.should == 10
      end
    end

    context "When fixed width is not specified" do
      it "uses the data width" do
        config.set(:fixed_width, nil)

        column.stub(:data_width => 10)
        column.stub(:max_width => 20)
        column.width.should == 10
      end

      it "is limited by the config width" do
        config.set(:fixed_width, nil)

        column.stub(:data_width => 30)
        column.stub(:max_width => 20)
        column.width.should == 20
      end
    end
  end
end
