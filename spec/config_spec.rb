require 'spec_helper'
require 'config'

describe TablePrint::Config do
  it "defaults max_width to 30" do
    TablePrint::Config.max_width.should == 30
  end

  it "defaults date_format to year-month-day-hour-minute-second" do
    TablePrint::Config.date_format.should == "%Y-%m-%d %H:%M:%S"
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
end

