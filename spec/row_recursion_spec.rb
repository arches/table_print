require 'spec_helper'

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
    let (:child2) {Row.new}

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

describe RowRecursion do
  let(:parent) { RowGroup.new }
  let(:child) { Row.new }

  describe "tabling" do
    let(:table) { Table.new }
    let(:column) { Column.new(:name => "title", :data => [""]) }
    let(:group) { RowGroup.new }

    before {
      table.add_column(column)
      table.add_child(group)
      group.add_child(child)
    }

    describe "#columns" do
      it "gets the columns from the root node" do
        table.columns.length.should == 1
        child.columns.should == table.columns
      end
    end

    describe "#horizontal_separator" do
      it "returns hyphens equal to the table width" do
        pending "move to formatter spec"
        return

        table = Table.new
        table.columns = [
          Column.new(:name => "title", :data => %w{ aaaaa aaaaaa }),
          Column.new(:name => "description", :data => %w{ bbb bbbb }),
          Column.new(:name => "category", :data => %w{ cccccccccc ccccccccc}),
        ]

        table.header.size.should == table.horizontal_separator.size
        compare_rows(table.horizontal_separator, '-' * 6 + '-|-' + '-' * 'description'.size + '-|-' + '-' * 10)
      end

      it "matches the header width" do
        pending "move to formatter spec"
        return

        column.data = %w{foobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobarfoobar}
        table.horizontal_separator.should == '------------------------------' # 30 hyphens
      end
    end

    describe "#header" do
      it "returns the column names, padded to the proper width, separated by the | character" do
        pending "move to formatter spec"
        return

        table.columns = [
          Column.new(:name => "title", :data => ['first post']),
          Column.new(:name => "author", :data => ['chris']),
          Column.new(:name => "subtitle", :data => ['first is the worst']),
        ]

        compare_rows(table.header, "AUTHOR | SUBTITLE           | TITLE     ")
      end
    end
  end
end

