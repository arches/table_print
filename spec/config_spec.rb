require 'spec_helper'

describe TablePrint::Config do
  it "defaults max_width to 30" do
    expect(TablePrint::Config.max_width).to eq 30
  end

  it "defaults time_format to year-month-day-hour-minute-second" do
    expect(TablePrint::Config.time_format).to eq "%Y-%m-%d %H:%M:%S"
  end

  describe "individual config options" do
    describe "storing and retrieving" do
      it "sets the variable" do
        TablePrint::Config.set(:max_width, [10])
        expect(TablePrint::Config.max_width).to eq 10
        TablePrint::Config.set(:max_width, [30])
      end
    end

    describe "clearing" do
      it "resets the variable to its initial value" do
        TablePrint::Config.set(:max_width, [10])
        TablePrint::Config.clear(:max_width)
        expect(TablePrint::Config.max_width).to eq 30
      end
    end
  end

  describe "class-based column config" do
    before :all do
      Sandbox.add_class("Blog")
    end

    describe "storing and retrieving" do
      it "stores the column hash" do
        TablePrint::Config.set(Sandbox::Blog, [:title, :author])
        expect(TablePrint::Config.for(Sandbox::Blog)).to eq [:title, :author]
      end
    end

    describe "clearing" do
      it "removes the class from storage" do
        TablePrint::Config.set(Sandbox::Blog, [:title, :author])
        TablePrint::Config.clear(Sandbox::Blog)
        expect(TablePrint::Config.for(Sandbox::Blog)).to be_nil
      end
    end
  end

  describe "io" do
    before :all do
      Sandbox.add_class("MyIO")
      Sandbox.add_method("MyIO", :puts) {}
    end

    it "accepts object that respond to puts" do
      myIO = Sandbox::MyIO.new
      TablePrint::Config.set(:io, [myIO])
      expect(TablePrint::Config.io).to eq myIO
    end

    it "doesn't accept objects unless they respond to puts" do
      expect {
        TablePrint::Config.set(:io, [""])
      }.to raise_error StandardError
    end

    it "defaults to STDOUT" do
      myIO = Sandbox::MyIO.new
      TablePrint::Config.set(:io, [myIO])
      TablePrint::Config.clear(:io)
      expect(TablePrint::Config.io).to eq STDOUT
    end
  end
end

