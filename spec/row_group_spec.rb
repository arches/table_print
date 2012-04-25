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

    it "pulls column information from the new child" do
      pending
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

  describe "#add_column" do
    it "adds the column on the root node" do
      parent.add_child(child)
      child.add_column(:title)

      parent.column_count.should == 1
    end
  end

  describe "#columns" do
    it "returns columns populated with names and data" do
      parent.add_child(child)
      child.set_cell_values(title: 'foobar')

      parent.columns.length.should == 1
      parent.columns.first.name.should == 'title'
      parent.columns.first.data.should == ['foobar']
    end

    it "gets the columns from the root node" do
      parent.add_child(child)
      child.set_cell_values(title: 'foobar')

      child.columns.should == parent.columns
    end
  end

  describe "#column_for" do
    it "returns the column object for a given column name" do
      parent.add_column(:title)
      column = parent.columns.first
      parent.column_for(:title).should == column
    end
  end

  describe "#add_formatter" do
    it "adds the formatter to the column object" do
      parent.add_column(:title)
      column = parent.columns.first
      parent.add_formatter(:title, {})

      column.formatters.should == [{}]
    end
  end

  describe "#width" do
    it "returns the total width of the columns" do
      parent.add_child(r1 = Row.new)
      parent.add_child(r2 = Row.new)

      r1.set_cell_values(title: 'foobar')
      r2.set_cell_values(subtitle: 'elemental')

      parent.width.should == 18
    end
  end

  describe "#horizontal_separator" do
    it "returns hyphens equal to the table width" do
      child.set_cell_values(title: 'foobar')
      child.horizontal_separator.should == '------'
    end
  end

  describe "#header" do
    it "returns the column names, padded to the proper width, separated by the | character" do
      child.set_cell_values(title: 'first post', author: 'chris', subtitle: 'first is the worst')
      child.header.should == 'TITLE      | AUTHOR | SUBTITLE          '
    end
  end
end

describe TablePrint::RowGroup do
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
end

describe TablePrint::Row do
  let(:row) { Row.new.set_cell_values({'title' => "wonky", 'author' => "bob jones", 'pub_date' => "2012"}) }

  describe "#format" do
    it "joins its cell values with a separator" do
      row.format.should == "wonky | bob jones | 2012"
    end

    context "when the row has a child group with a single row" do
      it "also formats and returns the child group" do
        group = RowGroup.new
        row.add_child(group)

        r2 = Row.new
        group.add_child(r2)
        r2.set_cell_values('subtitle.foobar' => "super wonky", publisher: "harper")

        row.format.should == "wonky | bob jones | 2012 | super wonky | harper"
      end
    end

    context "when the row has multiple child groups with multiple rows" do
      it "formats all the rows" do
        pubs = RowGroup.new
        row.add_child(pubs)
        pr1 = Row.new
        pr2 = Row.new
        pubs.add_children([pr1, pr2])

        pr1.set_cell_values('subtitle' => "super wonky", 'publisher' => "harper")
        pr2.set_cell_values('subtitle' => "never wonky", 'publisher' => "price")

        ratings = RowGroup.new
        row.add_child(ratings)
        rr1 = Row.new
        rr2 = Row.new
        ratings.add_children([rr1, rr2])

        rr1.set_cell_values(user: "Matt", value: 5)
        rr2.set_cell_values(user: "Sam", value: 3)

        row.format.should == "wonky | bob jones | 2012 | super wonky | harper |  | \n |  |  | never wonky | price |  | \n |  |  |  |  | Matt | 5\n |  |  |  |  | Sam | 3"
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
end
