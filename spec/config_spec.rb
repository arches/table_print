require 'spec_helper'

describe TablePrint::Config do

  before :all do
    Sandbox.add_class("Blog")
    Sandbox.add_class("Book")
  end

  let(:config) { TablePrint::Config.new }
  
  describe "storing options" do
    it "allows any options" do
      config.set :foo, "bar"
      expect(config.for(:foo)).to eq("bar")
    end
  end

  describe "class-based column config" do
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

  describe "combining configs" do
    it "respects the lastmost option" do
      c1 = TablePrint::Config.new
      c2 = TablePrint::Config.new

      c1.set :opt1, "foo"
      c1.set :opt2, "bar"
      c1.set Sandbox::Blog, [:title, :author]
      c1.set Sandbox::Book, [:title, :imprint]

      c2.set :opt1, "baz"
      c2.set :opt3, "boozle"
      c2.set Sandbox::Blog, [:author, :published_on]

      combined = c1.with(c2)

      expect(combined.for(:opt1)).to eq("baz")
      expect(combined.for(:opt2)).to eq("bar")
      expect(combined.for(:opt3)).to eq("boozle")

      expect(combined.for(Sandbox::Blog)).to eq([:author, :published_on])
      expect(combined.for(Sandbox::Book)).to eq([:title, :imprint])
    end

    context "with klass options" do
      it "respects the lastmost option" do
        c1 = TablePrint::Config.new
        c2 = TablePrint::Config.new

        c1.set :opt2, "bar"

        c2.set :opt1, "baz"
        c2.set :opt3, "boozle"

        combined = c1.with(c2)

        expect(combined.for(:opt1)).to eq("baz")
        expect(combined.for(:opt2)).to eq("bar")
        expect(combined.for(:opt3)).to eq("boozle")
      end
    end
  end


  context "display" do
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

    let(:io) { TestIO.new }

    before(:each) do
      config.set(:io, io)
    end

    after(:each) do
      io.clear
    end

    it "writes formatted data to the io" do
      config.display(OpenStruct.new(foo: "bar"), 'foo')

      expect(io.read).to eq(<<OUTPUT)
foo
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

  context "top-level singleton" do
    it "defaults max_width to 30" do
      TablePrint::Config.singleton.for(:max_width).should == 30
    end

    it "defaults time_format to year-month-day-hour-minute-second" do
      TablePrint::Config.singleton.for(:time_format).should == "%Y-%m-%d %H:%M:%S"
    end

    describe "individual config options" do
      describe "storing and retrieving" do
        it "sets the variable" do
          TablePrint::Config.singleton.set(:max_width, 10)
          TablePrint::Config.singleton.for(:max_width).should == 10
          TablePrint::Config.singleton.set(:max_width, 30)
        end
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
      config.set(:io, myIO)
      config.for(:io).should == myIO
    end

    it "defaults to STDOUT" do
      myIO = Sandbox::MyIO.new

      config.set(:io, myIO)
      config.clear(:io)
      config.for(:io).should == $stdout
    end
  end

  describe "duping" do
    it "creates a new equal config" do
      c1 = TablePrint::Config.new
      c2 = c1.dup
      expect(c1.object_id).not_to eq(c2.object_id)
      expect(c1 == c2).to be_true
    end
  end
end

