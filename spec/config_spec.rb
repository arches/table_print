require 'spec_helper'

include TablePrint

describe TablePrint::Config do

  context "top-level singleton" do
    it "defaults max_width to 30" do
      Config.singleton.max_width.should == 30
    end

    it "defaults time_format to year-month-day-hour-minute-second" do
      Config.singleton.time_format.should == "%Y-%m-%d %H:%M:%S"
    end

    describe "individual config options" do
      describe "storing and retrieving" do
        it "sets the variable" do
          Config.singleton.set(:max_width, [10])
          Config.singleton.max_width.should == 10
          Config.singleton.set(:max_width, [30])
        end
      end

      describe "clearing" do
        it "resets the variable to its initial value" do
          Config.singleton.set(:max_width, [10])
          Config.singleton.clear(:max_width)
          Config.singleton.max_width.should == 30
        end
      end
    end

    describe "class-based column config" do
      before :all do
        Sandbox.add_class("Blog")
      end

      describe "storing and retrieving" do
        it "stores the column hash" do
          Config.singleton.set(Sandbox::Blog, [:title, :author])
          Config.singleton.for(Sandbox::Blog).should == [:title, :author]
        end
      end

      describe "clearing" do
        it "removes the class from storage" do
          Config.singleton.set(Sandbox::Blog, [:title, :author])
          Config.singleton.clear(Sandbox::Blog)
          Config.singleton.for(Sandbox::Blog).should be_nil
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
        Config.singleton.set(:io, [myIO])
        Config.singleton.io.should == myIO
      end

      it "doesn't accept objects unless they respond to puts" do
        lambda {
          Config.singleton.set(:io, [""])
        }.should raise_error StandardError
      end

      it "defaults to STDOUT" do
        myIO = Sandbox::MyIO.new
        Config.singleton.set(:io, [myIO])
        Config.singleton.clear(:io)
        Config.singleton.io.should == STDOUT
      end
    end
  end

  describe "a named singleton" do
    it "is a different object than the top-level singleton" do
      expect(Config.singleton).not_to eq(Config.singleton(:csv))
    end

    it "is tolerant of name types" do
      expect(Config.singleton(:csv)).to eq(Config.singleton('csv'))
    end

    it "setting values doesn't affet other singletons" do
      csv = Config.singleton(:csv)
      global = Config.singleton

      csv.set :time_format, ["asdf"]

      expect(global.time_format).not_to eq(csv.time_format)
      expect(Config.singleton(:html)).not_to eq(csv.time_format)
    end
  end
end

