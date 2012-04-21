require 'spec_helper'
require 'ostruct'
require 'cat'
require_relative "../lib/row_group"

include TablePrint

describe TablePrint::RowGroup do
  describe "#add_row" do
    it "adds the given row to the count" do
      rg = RowGroup.new
      rg.add_row(OpenStruct.new)
      rg.row_count.should == 1
    end
  end
end

describe TablePrint::Row do
  let (:row) {Row.new.set_cell_values({title: "wonky", author: "bob jones", pub_date: "2012"})}

  describe "#format" do
    it "joins its cell values with a separator" do
      row.format(:title, :author, :pub_date).should == "wonky | bob jones | 2012"
    end

    context "when the row has a child group with a single row" do
      it "also formats and returns the child group" do
        group = RowGroup.new
        group.add_row(Row.new.set_cell_values('subtitle.foobar' => "super wonky", publisher: "harper"))

        row.add_group(group)

        row.format(:title, :author, :pub_date, 'subtitle.foobar', :publisher).should == "wonky | bob jones | 2012 | super wonky | harper"
      end
    end

    context "when the row has multiple child groups with multiple rows" do
      it "formats all the rows" do
        pubs = RowGroup.new
        pubs.add_row(Row.new.set_cell_values(subtitle: "super wonky", publisher: "harper"))
        pubs.add_row(Row.new.set_cell_values(subtitle: "never wonky", publisher: "price"))

        ratings = RowGroup.new
        ratings.add_row(Row.new.set_cell_values(user: "Matt", value: 5))
        ratings.add_row(Row.new.set_cell_values(user: "Sam", value: 3))

        row.add_group(pubs)
        row.add_group(ratings)


        row.format(:title, :author, :pub_date, :subtitle, :publisher, :user, :value).should == "wonky | bob jones | 2012 | super wonky | harper |  | \n |  |  | never wonky | price |  | \n |  |  |  |  | Matt | 5\n |  |  |  |  | Sam | 3"
      end
    end
  end

  describe "#apply_formatters" do
    it "calls the format method on each formatter for that column" do
      Sandbox.add_class("DoubleFormatter")
      Sandbox.add_method("DoubleFormatter", :format) { |value| value * 2 }

      Sandbox.add_class("ChopFormatter")
      Sandbox.add_method("ChopFormatter", :format) { |value| value[0..-2] }

      f1 = Sandbox::DoubleFormatter.new
      f2 = Sandbox::ChopFormatter.new
      row.add_formatter(:title, f1)
      row.add_formatter(:title, f2)

      row.apply_formatters(:title, "foobar").should == "foobarfooba"
    end
  end

  describe "#add_formatter" do
    it "uses the formatter to format that column" do
      Sandbox.add_class("FixedWidthFormatter")
      Sandbox.add_method("FixedWidthFormatter", "format") { |v| v }
      formatter = Sandbox::FixedWidthFormatter.new
      formatter.should_receive(:format)

      row.add_formatter(:title, formatter)
      row.format(:title)
    end
  end
end
