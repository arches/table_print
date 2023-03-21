require 'spec_helper'

include TablePrint

describe Column do
  let(:c) {Column.new(:data => ["Once upon a time", "there was a dark and stormy night"], :name => :tagline)}

  it "remembers its name as a string" do
    expect(c.name).to eq "tagline"
  end

  it "exposes the array of data representing the column" do
    expect(c.data).to eq ["Once upon a time", "there was a dark and stormy night"]
  end

  describe "#add_formatter" do
    it "stores the formatter" do
      f = {}
      c.add_formatter(f)
      expect(c.formatters).to eq [f]
    end
  end

  describe "#formatter=" do
    it "adds the formatters individually" do
      expect(c).to receive(:add_formatter).twice
      c.formatters = [{}, {}]
    end
  end

  describe "#display_method" do
    it "returns the column's display method as a string" do
      c = Column.new(:display_method => :boofar)
      expect(c.display_method).to eq "boofar"
    end

    it "doesn't turn a lambda display method into a string" do
      lam = lambda{}
      c = Column.new(:display_method => lam)
      expect(c.display_method).to eq lam
    end

    it "defaults to the column name" do
      c = Column.new(:name => :boofar)
      expect(c.display_method).to eq "boofar"
    end
  end

  describe "#data_width" do
    it "reflects the width of the data set" do
      expect(c.data_width).to eq 33
    end

    it "includes the title in the calculation" do
      c.name = "a horse is a horse of course of course"
      expect(c.data_width).to eq 38
    end
  end

  describe "#width" do
    context "when default width is specified" do
      it "uses the default width" do
        c.default_width = 10
        allow(c).to receive(:data_width).and_return(15)
        allow(c).to receive(:max_width).and_return(20)
        expect(c.width).to eq 10
      end

      it "isn't limited by the config width" do
        c.default_width = 40
        allow(c).to receive(:data_width).and_return(50)
        allow(c).to receive(:max_width).and_return(20)
        expect(c.width).to eq 40
      end
    end

    context "When default width is not specified" do
      it "uses the data width" do
        c.default_width = nil
        allow(c).to receive(:data_width).and_return(10)
        allow(c).to receive(:max_width).and_return(20)
        expect(c.width).to eq 10
      end

      it "is limited by the config width" do
        c.default_width = nil
        allow(c).to receive(:data_width).and_return(30)
        allow(c).to receive(:max_width).and_return(20)
        expect(c.width).to eq 20
      end
    end
  end
end
