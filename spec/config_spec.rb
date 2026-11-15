require 'spec_helper'

describe TablePrint::Config do
  it "defaults max_width to 30" do
    expect(TablePrint::Config.max_width).to eq 30
  end

  it "defaults time_format to year-month-day-hour-minute-second" do
    expect(TablePrint::Config.time_format).to eq "%Y-%m-%d %H:%M:%S"
  end

  it "defaults multibyte to false" do
    expect(TablePrint::Config.multibyte).to eq false
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

      it "resets multibyte" do
        TablePrint::Config.set(:multibyte, [true])
        TablePrint::Config.clear(:multibyte)
        expect(TablePrint::Config.multibyte).to eq false
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

      it "hands out a copy, so a caller can't empty the stored config" do
        TablePrint::Config.set(Sandbox::Blog, [:title, :author])
        TablePrint::Config.for(Sandbox::Blog).clear

        expect(TablePrint::Config.for(Sandbox::Blog)).to eq [:title, :author]
      end

      it "copies the hashes inside it too, since that's what gets consumed" do
        TablePrint::Config.set(Sandbox::Blog, [{ :except => :title }])
        TablePrint::Config.for(Sandbox::Blog).first.delete(:except)

        expect(TablePrint::Config.for(Sandbox::Blog)).to eq [{ :except => :title }]
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

  describe "unreachable_value" do
    it "defaults to Method Missing" do
      expect(TablePrint::Config.unreachable_value).to eq "Method Missing"
    end

    it "takes any string, or nil to leave those cells blank" do
      TablePrint::Config.set(:unreachable_value, ["-"])
      expect(TablePrint::Config.unreachable_value).to eq "-"

      TablePrint::Config.set(:unreachable_value, [nil])
      expect(TablePrint::Config.unreachable_value).to be_nil

      TablePrint::Config.clear(:unreachable_value)
      expect(TablePrint::Config.unreachable_value).to eq "Method Missing"
    end
  end

  describe "show_headers" do
    it "defaults to true" do
      expect(TablePrint::Config.show_headers).to eq true
    end

    it "can be turned off and back on" do
      TablePrint::Config.set(:show_headers, [false])
      expect(TablePrint::Config.show_headers).to eq false

      TablePrint::Config.clear(:show_headers)
      expect(TablePrint::Config.show_headers).to eq true
    end
  end

  describe "horizontal_separator" do
    it "defaults to a hyphen" do
      expect(TablePrint::Config.horizontal_separator).to eq "-"
    end

    it "takes a single character, or nil for no line" do
      TablePrint::Config.set(:horizontal_separator, ["="])
      expect(TablePrint::Config.horizontal_separator).to eq "="

      TablePrint::Config.set(:horizontal_separator, [nil])
      expect(TablePrint::Config.horizontal_separator).to be_nil

      TablePrint::Config.clear(:horizontal_separator)
      expect(TablePrint::Config.horizontal_separator).to eq "-"
    end

    it "rejects anything longer than one character" do
      expect { TablePrint::Config.horizontal_separator = "==" }.to raise_error StandardError
      expect(TablePrint::Config.horizontal_separator).to eq "-"
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

