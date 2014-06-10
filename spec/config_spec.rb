require 'spec_helper'

describe TablePrint::Config do
  it "defaults max_width to 30" do
    TablePrint::Config.max_width.should == 30
  end

  it "defaults time_format to year-month-day-hour-minute-second" do
    TablePrint::Config.time_format.should == "%Y-%m-%d %H:%M:%S"
  end

  describe "individual config options" do
    describe "storing and retrieving" do
      it "sets the variable" do
        TablePrint::Config.set(:max_width, [10])
        TablePrint::Config.max_width.should == 10
        TablePrint::Config.set(:max_width, [30])
      end
    end

    describe "clearing" do
      it "resets the variable to its initial value" do
        TablePrint::Config.set(:max_width, [10])
        TablePrint::Config.clear(:max_width)
        TablePrint::Config.max_width.should == 30
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
        TablePrint::Config.for(Sandbox::Blog).should == [:title, :author]
      end
    end

    describe "clearing" do
      it "removes the class from storage" do
        TablePrint::Config.set(Sandbox::Blog, [:title, :author])
        TablePrint::Config.clear(Sandbox::Blog)
        TablePrint::Config.for(Sandbox::Blog).should be_nil
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
      TablePrint::Config.io.should == myIO
    end

    it "doesn't accept objects unless they respond to puts" do
      lambda {
        TablePrint::Config.set(:io, [""])
      }.should raise_error StandardError
    end

    it "defaults to STDOUT" do
      myIO = Sandbox::MyIO.new
      TablePrint::Config.set(:io, [myIO])
      TablePrint::Config.clear(:io)
      TablePrint::Config.io.should == STDOUT
    end
  end
end

