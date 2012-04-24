require 'spec_helper'
require 'ostruct'
require 'cat'
require_relative "../lib/row_group"

include TablePrint

describe RowRecursion do
  let(:parent) { RowGroup.new }
  let(:child) { Row.new }

  describe "#add_child" do
    it "adds the child to my children" do
      parent.add_child(child)
      parent.child_count.should == 1
    end

    it "sets me as my child's parent" do
      parent.add_child(child)
      child.parent.should == parent
    end
  end

  describe "#add_children" do
    let (:child2) { Row.new }

    it "adds all the children to myself" do
      parent.add_children([child, child2])
      parent.child_count.should == 2
    end

    it "sets me as their parent" do
      parent.add_children([child, child2])
      child.parent.should == parent
      child2.parent.should == parent
    end
  end
end

describe TablePrint::RowGroup do
  describe "#add_formatter" do
    it "adds the formatter to its child rows" do
      row = Row.new
      group = RowGroup.new
      group.add_child(row)

      formatter = {}

      row.should_receive(:add_formatter).with('title', formatter)
      group.add_formatter('title', formatter)
    end
  end

  describe "#raw_column_data" do
    it "returns the column data from its child rows" do
      group = RowGroup.new
      group.add_child(Row.new.set_cell_values(title: 'foo'))
      group.add_child(Row.new.set_cell_values(title: 'bar'))
      group.raw_column_data(:title).should == ['foo', 'bar']
    end
  end

  describe "#column_width" do
    it "finds the width of a column" do
      group = RowGroup.new
      group.add_child(Row.new.set_cell_values(title: 'asdf'))
      group.add_child(Row.new.set_cell_values(title: 'qwerty'))
      group.column_width(:title).should == 6
    end
  end

  describe "#set_column_widths" do
    it "applies a fixed width formatter to each column based on its data" do
      group = RowGroup.new
      [["foo", "bar"], ["one", "two"], ["asdf", "qwerty"]].each do |title, author|
        group.add_child(Row.new.set_cell_values(title: title, author: author))
      end
      group.set_column_widths([:title, :author])

      row = group.children.first
      row.formatters_for(:title).length.should == 1
      row.formatters_for(:title).first.width.should == 4

      row.formatters_for(:author).length.should == 1
      row.formatters_for(:author).first.width.should == 6
    end
  end
end

describe TablePrint::Row do
  let(:row) { Row.new.set_cell_values({'title' => "wonky", 'author' => "bob jones", 'pub_date' => "2012"}) }

  describe "#format" do
    it "joins its cell values with a separator" do
      row.format([:title, :author, :pub_date]).should == "wonky | bob jones | 2012"
    end

    context "when the row has a child group with a single row" do
      it "also formats and returns the child group" do
        group = RowGroup.new
        group.add_child(Row.new.set_cell_values('subtitle.foobar' => "super wonky", publisher: "harper"))

        row.add_child(group)

        row.format([:title, :author, :pub_date, 'subtitle.foobar', :publisher]).should == "wonky | bob jones | 2012 | super wonky | harper"
      end
    end

    context "when the row has multiple child groups with multiple rows" do
      it "formats all the rows" do
        pubs = RowGroup.new
        pubs.add_child(Row.new.set_cell_values('subtitle' => "super wonky", 'publisher' => "harper"))
        pubs.add_child(Row.new.set_cell_values('subtitle' => "never wonky", 'publisher' => "price"))

        ratings = RowGroup.new
        ratings.add_child(Row.new.set_cell_values(user: "Matt", value: 5))
        ratings.add_child(Row.new.set_cell_values(user: "Sam", value: 3))

        row.add_child(pubs)
        row.add_child(ratings)

        row.format([:title, :author, :pub_date, :subtitle, :publisher, :user, :value]).should == "wonky | bob jones | 2012 | super wonky | harper |  | \n |  |  | never wonky | price |  | \n |  |  |  |  | Matt | 5\n |  |  |  |  | Sam | 3"
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

  describe "#raw_column_data" do
    it "returns all the values for a given column" do
      row = Row.new.set_cell_values(title: 'one', author: 'two')

      group = RowGroup.new
      ['two', 'three', 'four', 'five', 'six', 'seven'].each do |title|
        group.add_child(Row.new.set_cell_values(title: title))
      end
      row.add_child(group)

      row.raw_column_data('title').should == ['one', 'two', 'three', 'four', 'five', 'six', 'seven']
    end
  end

  describe "#add_formatter" do
    it "uses the formatter to format that column" do
      Sandbox.add_class("FixedWidthFormatter")
      Sandbox.add_method("FixedWidthFormatter", "format") { |v| v }
      formatter = Sandbox::FixedWidthFormatter.new
      formatter.should_receive(:format)

      row.add_formatter(:title, formatter)
      row.format([:title])
    end

    it "passes the formatter down to child groups" do
      Sandbox.add_class("FixedWidthFormatter")
      formatter = Sandbox::FixedWidthFormatter.new

      group = RowGroup.new
      row.add_child(group)

      group.should_receive(:add_formatter).with('title', formatter)
      row.add_formatter('title', formatter)
    end
  end
end
