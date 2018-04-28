require 'spec_helper'

describe TablePrint::Config do
  class TestIO
    def puts(content)
      @content = content
    end

    def read
      @content
    end

    def clear
      @content = nil
    end
  end

  let(:config) { TablePrint::Config.new }
  let(:io) { TestIO.new }

  before(:each) do
    config.io = io
  end

  after(:each) do
    io.clear
  end

  context "display" do
    it "writes formatted data to the io" do
      config.display(OpenStruct.new(foo: "bar"), 'foo')

      expect(io.read).to eq(<<OUTPUT)
FOO
---
bar
OUTPUT
    end

    context "empty data set" do
      it "writes nothing" do
        config.display([], 'foo')

        expect(io.read).to be_nil
      end
    end

    context "only association columns, no data" do
      it "writes nothing" do
        Sandbox.add_class("Blog")
        Sandbox.add_attributes("Blog", :author)

        config.display(Sandbox::Blog.new, 'author.name')

        expect(io.read).to be_nil
      end
    end
  end

#  context "top-level singleton" do
#    it "defaults max_width to 30" do
#      TablePrint::Config.singleton.max_width.should == 30
#    end
#
#    it "defaults time_format to year-month-day-hour-minute-second" do
#      TablePrint::Config.singleton.time_format.should == "%Y-%m-%d %H:%M:%S"
#    end
#
#    describe "individual config options" do
#      describe "storing and retrieving" do
#        it "sets the variable" do
#          TablePrint::Config.singleton.set(:max_width, [10])
#          TablePrint::Config.singleton.max_width.should == 10
#          TablePrint::Config.singleton.set(:max_width, [30])
#        end
#      end
#
#      describe "clearing" do
#        it "resets the variable to its initial value" do
#          TablePrint::Config.singleton.set(:max_width, [10])
#          TablePrint::Config.singleton.clear(:max_width)
#          TablePrint::Config.singleton.max_width.should == 30
#        end
#      end
#    end

  describe "class-based column config" do
    before :all do
      Sandbox.add_class("Blog")
    end

    describe "storing and retrieving" do
      it "stores the column hash" do
        config.set(Sandbox::Blog, [:title, :author])
        config.for(Sandbox::Blog).should == [:title, :author]
      end
    end

    describe "clearing" do
      it "removes the class from storage" do
        config.set(Sandbox::Blog, [:title, :author])
        config.clear(Sandbox::Blog)
        config.for(Sandbox::Blog).should be_nil
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
      config.set(:io, [myIO])
      config.io.should == myIO
    end

    it "doesn't accept objects unless they respond to puts" do
      lambda {
        config.set(:io, [""])
      }.should raise_error StandardError
    end

    it "defaults to STDOUT" do
      myIO = Sandbox::MyIO.new

      config.set(:io, [myIO])
      config.clear(:io)
      config.io.should == STDOUT
    end
  end

  describe "duping" do
    it "creates a new equal config" do
      c1 = TablePrint::Config.new
      c2 = c1.dup
      expect(c1.object_id).not_to eq(c2.object_id)
      expect(c1).to eq(c2)
    end
  end
end

