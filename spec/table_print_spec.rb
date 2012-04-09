require 'spec_helper'
require 'ostruct'
require_relative "../lib/table_print"

describe TablePrint do
  before(:each) do
    Sandbox.cleanup!
  end

  describe TablePrint::Printer do
    it "prints a table" do
      tp = TablePrint::Printer.new

      Sandbox.add_class("Movie")
      Sandbox.add_attributes("Movie", :title, :lead)
      tp.table_print(Sandbox::Movie.new(title: "House Bunny", lead: "Anna Faris")).should == "TITLE       | LEAD      \n------------------------\nHouse Bunny | Anna Faris"
    end
  end

  describe TablePrint::Column do
    it "knows its name and display method" do
      c = TablePrint::Column.new(name: "Foo", display_method: "foo")
      c.name.should == "Foo"
      c.display_method.should == "foo"
    end

    describe "#width" do
      it "returns the max width of the display_method's values" do
        data = [OpenStruct.new(foo: "bar"), OpenStruct.new(foo: "babar")]
        c = TablePrint::Column.new(data: data, display_method: "foo")
        c.width.should == 5
      end

      context "for a nested display_method" do
        it "returns the max width of the display_method's values'" do
          values = %W(abc def ghij)
          bottom_level_objects = values.map { |val| OpenStruct.new(bar: val) }
          top_level_objects = bottom_level_objects.map { |obj| OpenStruct.new(foo: obj) }

          c = TablePrint::Column.new(data: top_level_objects, display_method: "foo.bar")
          c.width.should == 7
        end
      end
    end
  end

  describe TablePrint::Printable do
    describe "#truncate" do
      it "truncates strings" do
        s = "A very long string"
        s.extend TablePrint::Printable
        s.truncate(8).should == "A ver..."
      end
    end

    describe "#default_display_methods" do
      it "returns attribute getters" do
        Sandbox.add_class("Hat")
        Sandbox.add_attributes("Hat", "brand")

        p = Sandbox::Hat.new
        p.extend TablePrint::Printable
        p.default_display_methods.should == %W(brand)
      end

      it "ignores dangerous methods" do
        Sandbox.add_class("Hat")
        Sandbox.add_method("Hat", "brand!") {}

        p = Sandbox::Hat.new
        p.extend TablePrint::Printable
        p.default_display_methods.should == []
      end

      it "ignores methods defined in a superclass" do
        Sandbox.add_class("Hat::Bowler")
        Sandbox.add_attributes("Hat", "brand")
        Sandbox.add_attributes("Hat::Bowler", "brim_width")

        p = Sandbox::Hat::Bowler.new
        p.extend TablePrint::Printable
        p.default_display_methods.should == %W(brim_width)
      end

      it "ignores methods that require arguments" do
        Sandbox.add_class("Hat")
        Sandbox.add_attributes("Hat", "brand")
        Sandbox.add_method("Hat", "tip?") { |person| person.rapscallion? }

        p = Sandbox::Hat.new
        p.extend TablePrint::Printable
        p.default_display_methods.should == %W(brand)
      end

      it "ignores methods from an included module" do
        pending "waiting for Cat to support module manipulation"
      end

      it "uses column information when available (eg, from ActiveRecord objects)"
    end
  end
end
