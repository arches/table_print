require 'spec_helper'
require 'ostruct'
require_relative "../lib/table_print"

describe TablePrint do
  before(:each) do
    Sandbox.cleanup!
  end

  describe TablePrint::Printer::ColumnConstructor do
    it "returns the input string as the display method" do
      cc = TablePrint::Printer::ColumnConstructor.new("title")
      cc.display_method.should == "title"
    end

    it "returns an empty hash as the column options for a string" do
      cc = TablePrint::Printer::ColumnConstructor.new("title")
      cc.column_options.should == {}
    end

    it "returns the input hash key as the display method" do
      cc = TablePrint::Printer::ColumnConstructor.new(author: {name: "Written By"})
      cc.display_method.should == "author"
    end

    it "returns the input hash value as the column options" do
      cc = TablePrint::Printer::ColumnConstructor.new(author: {name: "Written By"})
      cc.column_options.should == {name: "Written By"}
    end
  end

  describe TablePrint::Printer do
    it "prints a table" do
      tp = TablePrint::Printer.new

      Sandbox.add_class("Movie")
      Sandbox.add_attributes("Movie", :title, :lead)
      tp.table_print(Sandbox::Movie.new(title: "House Bunny", lead: "Anna Faris")).should == "TITLE       | LEAD      \n------------------------\nHouse Bunny | Anna Faris"
    end

    describe "#options_to_columns" do
      it "returns an empty array if nothing is passed" do
        tp = TablePrint::Printer.new
        columns = tp.send(:options_to_columns, nil)
        columns.should == []

        columns = tp.send(:options_to_columns, {})
        columns.should == []

        columns = tp.send(:options_to_columns, [])
        columns.should == []
      end

      it "passes the data to be printed into the column constructor" do
        tp = TablePrint::Printer.new

        data = OpenStruct.new
        tp.instance_variable_set("@data", data)

        columns = tp.send(:options_to_columns, "title")
        columns.length.should == 1

        columns.first.data.should == data
        columns.first.display_method.should == "title"
        columns.first.name.should == "title"
      end

      it "turns two methods into two columns" do
        tp = TablePrint::Printer.new
        data = OpenStruct.new(title: "Amelie", lead: "Audrey Tautou")
        tp.instance_variable_set("@data", data)

        columns = tp.send(:options_to_columns, ["title", "lead"])
        columns.length.should == 2

        columns.first.name.should == "title"
        columns.last.name.should == "lead"
      end

      it "turns a hash into a column" do
        tp = TablePrint::Printer.new
        columns = tp.send(:options_to_columns, "title" => {name: "calling"})
        columns.length.should == 1

        column = columns.first
        column.display_method.should == "title"
        column.name.should == "calling"
      end

      it "turns an array of a hash and a string into two columns" do
        tp = TablePrint::Printer.new
        data = OpenStruct.new(title: "Amelie", lead: "Audrey Tautou")
        tp.instance_variable_set("@data", data)

        columns = tp.send(:options_to_columns, ["title", lead: {name: "Headlining Actress"}])
        columns.length.should == 2

        columns.first.name.should == "title"
        columns.last.name.should == "Headlining Actress"

        columns.first.display_method.should == "title"
        columns.last.display_method.should == "lead"
      end
    end
  end

  describe TablePrint::Column do
    it "knows its name and display method" do
      c = TablePrint::Column.new(OpenStruct.new, "foo", {name: "Foobar"})
      c.name.should == "Foobar"
      c.display_method.should == "foo"
    end

    describe "#width" do
      it "returns the max width of the display_method's values" do
        data = [OpenStruct.new(foo: "bar"), OpenStruct.new(foo: "babar")]
        c = TablePrint::Column.new(data, "foo")
        c.width.should == 5
      end

      context "for a nested display_method" do
        it "returns the max width of the display_method's values'" do
          values = %W(abc def ghij)
          bottom_level_objects = values.map { |val| OpenStruct.new(bar: val) }
          top_level_objects = bottom_level_objects.map { |obj| OpenStruct.new(foo: obj) }

          c = TablePrint::Column.new(top_level_objects, "foo.bar")
          c.width.should == 7
        end
      end

      context "for a singular nested display method" do
        it "returns the max width of the display_method's values'" do
          Sandbox.add_class("Foo::Blog")
          Sandbox.add_attributes("Foo", "blog")
          Sandbox.add_attributes("Foo::Blog", "title")

          blog = Sandbox::Foo::Blog.new(title: "pop pop pop pop")
          foo = Sandbox::Foo.new(blog: blog)

          c = TablePrint::Column.new(foo, "blog.title")
          c.width.should == 15
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
