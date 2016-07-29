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

    describe "#width" do
      it "returns the total width of the columns" do

        table = Table.new
        table.columns = [
          Column.new(:name => "title", :data => ["foobar"]),
          Column.new(:name => "subtitle", :data => ["elemental"]),
        ]

        table.width.should == 18
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

def compare_rows(actual_rows, expected_rows)
  actual_rows.split("\n").length.should == expected_rows.split("\n").length
  actual_rows.split("\n").zip(expected_rows.split("\n")).each do |actual, expected|
    actual.split(//).sort.join.should == expected.split(//).sort.join
  end
end

describe TablePrint::Row do
  let(:table) { Table.new }
  let(:group) { RowGroup.new }
  let(:row) { Row.new.set_cell_values({'title' => "wonky", 'author' => "bob jones", 'pub_date' => "2012"}) }

  before {
    table.columns = [
      Column.new(:name => "title", :data => ['wonky']),
      Column.new(:name => "author", :data => ['bob jones']),
      Column.new(:name => "pub_date", :data => ['2012']),
    ]
    table.add_child(group)
    group.add_child(row)
  }

  describe "#format" do
    it "formats the row with padding" do
      compare_rows(row.format, "wonky | bob jones | 2012    ")
    end

    it "also formats the children" do
      row.add_child(RowGroup.new.add_child(Row.new.set_cell_values(:title => "wonky2", :author => "bob jones2", :pub_date => "20122")))

      table.columns.find{|c| c.name.to_s == "title"}.data << "wonky2"
      table.columns.find{|c| c.name.to_s == "author"}.data << "bob jones2"
      table.columns.find{|c| c.name.to_s == "pub_date"}.data << "20122"

      compare_rows(row.format, "wonky  | bob jones  | 2012    \nwonky2 | bob jones2 | 20122   ")
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

      column = Column.new(:name => "title", :fixed_width => 9)
      column.formatters = [f1, f2]

      row.apply_formatters(column).should == "wonkywonk"
    end

    it "uses the config'd time_format to format times" do
      column = Column.new(:name => "title", :fixed_width => 20, :formatters => [], :time_format => "%Y %m %d")

      time_formatter = TablePrint::TimeFormatter.new
      TablePrint::TimeFormatter.should_receive(:new).with("%Y %m %d") {time_formatter}

      row.set_cell_values(title: Time.local(2012, 6, 1, 14, 20, 20))

      row.apply_formatters(column)
    end
  end

  describe "#collapse" do

    # row: foo
    #   group
    #     row: bar
    # => foo | bar
    context "for a single row in a single child group" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_child(
            RowGroup.new.add_child(
                Row.new.set_cell_values(:bar => "bar")
            )
        )
        @row.collapse!
      end

      it "pulls the cells up into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar"}
      end

      it "dereferences the now-defunct group" do
        @row.children.length.should == 0
      end
    end

    # row: foo
    #   group
    #     row: bar
    #     row: baz
    # => foo | bar
    #        | baz
    context "for two rows in a single child group" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_child(
            RowGroup.new.add_children([
                                          Row.new.set_cell_values(:bar => "bar"),
                                          Row.new.set_cell_values(:bar => "baz")
                                      ])
        )
        @row.collapse!
      end

      it "pulls the cells from the first row up into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar"}
      end

      it "deletes the absorbed row but leaves the second row in the group" do
        @row.children.length.should == 1
        @row.children.first.children.length.should == 1
        @row.children.first.children.first.cells.should == {"bar" => "baz"}
      end
    end

    # row: foo
    #   group
    #     row: bar
    #   group
    #     row: baz
    # => foo | bar | baz
    context "for two groups with a single row each" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_children([
                                                             RowGroup.new.add_child(
                                                                 Row.new.set_cell_values(:bar => "bar")
                                                             ),
                                                             RowGroup.new.add_child(
                                                                 Row.new.set_cell_values(:baz => "baz")
                                                             )
                                                         ])
        @row.collapse!
      end

      it "pulls the cells from both groups into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar", "baz" => "baz"}
      end

      it "dereferences both now-defunct groups" do
        @row.children.length.should == 0
      end
    end

    # row: foo
    #   group
    #     row: bar
    #   group
    # => foo | bar |
    context "for two groups, one of which has no rows (aka, we hit an empty association)" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_children([
                                                             RowGroup.new.add_child(
                                                                 Row.new.set_cell_values(:bar => "bar")
                                                             ),
                                                             RowGroup.new
                                                         ])
        @row.collapse!
      end

      it "pulls the cells from both groups into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar"}
      end

      it "dereferences both now-defunct groups" do
        @row.children.length.should == 0
      end
    end

    # row: foo
    #   group
    #     row: bar
    #   group
    #     row: baz
    #     row: bazaar
    # => foo | bar | baz
    #              | bazaar
    context "for two groups, one with a single row and one with two rows" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_children([
                                                             RowGroup.new.add_child(
                                                                 Row.new.set_cell_values(:bar => "bar")
                                                             ),
                                                             RowGroup.new.add_children([
                                                                                           Row.new.set_cell_values(:baz => "baz"),
                                                                                           Row.new.set_cell_values(:baz => "bazaar"),
                                                                                       ]),
                                                         ])
        @row.collapse!
      end

      it "pulls the single row and the first row from the double into itself" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar", "baz" => "baz"}
      end

      it "keeps the second row from the second group in its own group" do
        @row.children.length.should == 1
        @row.children.first.children.length.should == 1
        @row.children.first.children.first.cells.should == {"baz" => "bazaar"}
      end
    end

    # row: foo
    #   group
    #     row: bar
    #       group
    #         row: baz
    # => foo | bar | baz
    context "for two nested groups, each with one row" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_child(
            RowGroup.new.add_child(
                Row.new.set_cell_values(:bar => "bar").add_child(
                    RowGroup.new.add_child(
                        Row.new.set_cell_values(:baz => "baz")
                    )
                )
            )
        )
        @row.collapse!
      end

      it "pulls the cells from both groups into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar", "baz" => "baz"}
      end

      it "dereferences both now-defunct groups" do
        @row.children.length.should == 0
      end
    end

    # row: foo
    #   group
    #     row: bar
    #       group
    #         row: baz
    #         row: bazaar
    # => foo | bar | baz
    #              | bazaar
    context "for a child with one row, which itself has multiple rows" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_child(
            RowGroup.new.add_child(
                Row.new.set_cell_values(:bar => "bar").add_child(
                    RowGroup.new.add_children([
                                                  Row.new.set_cell_values(:baz => "baz"),
                                                  Row.new.set_cell_values(:baz => "bazaar")
                                              ])
                )
            )
        )
        @row.collapse!
      end

      it "pulls the first row from each group up into itself" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar", "baz" => "baz"}
      end

      it "deletes only the intermediary group" do
        @row.children.length.should == 1
        @row.children.first.children.length.should == 1
        @row.children.first.children.first.cells.should == {"baz" => "bazaar"}
      end
    end

    # row: foo
    #   group
    #     row: bar
    #     row: bar2
    #   group
    #     row: bazaar
    #     row: bazaar2
    # => foo | bar  |
    #        | bar2 |
    #        |      | bazaar
    #        |      | bazaar2
    context "for multiple children with multiple rows" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_children([
                                                             RowGroup.new.add_children([
                                                                                           Row.new.set_cell_values(:bar => "bar"),
                                                                                           Row.new.set_cell_values(:bar => "bar2"),
                                                                                       ]),
                                                             RowGroup.new.add_children([
                                                                                           Row.new.set_cell_values(:baz => "bazaar"),
                                                                                           Row.new.set_cell_values(:baz => "bazaar2"),
                                                                                       ])
                                                         ])
        @row.collapse!
      end

      it "pulls the first row from the first group into the parent" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar"}
      end

      it "leaves the second row in the first group" do
        @row.children.length.should == 2
        @row.children.first.children.length.should == 1
        @row.children.first.children.first.cells.should == {"bar" => "bar2"}
      end

      it "leaves the second group alone" do
        @row.children.last.children.length.should == 2
        @row.children.last.children.first.cells.should == {"baz" => "bazaar"}
        @row.children.last.children.last.cells.should == {"baz" => "bazaar2"}
      end
    end

    # row: foo
    #   group
    #     row: bar
    #       group
    #         row: bare
    #         row: bart
    #     row: baz
    #       group
    #         row: bazaar
    #         row: bizarre
    # => foo | bar  | bare
    #        |      | bart
    #        | baz  | bazaar
    #        |      | bizarre
    context "for multiple children with multiple children" do
      before(:each) do
        @row = Row.new
        @row.set_cell_values(:foo => "foo").add_child(
            RowGroup.new.add_children([
                                          Row.new.set_cell_values(:bar => "bar").add_child(
                                              RowGroup.new.add_children([
                                                                            Row.new.set_cell_values(:barry => "bare"),
                                                                            Row.new.set_cell_values(:barry => "bart")
                                                                        ])
                                          ),
                                          Row.new.set_cell_values(:bar => "baz").add_child(
                                              RowGroup.new.add_children([
                                                                            Row.new.set_cell_values(:barry => "bazaar"),
                                                                            Row.new.set_cell_values(:barry => "bizarre")
                                                                        ])
                                          )
                                      ])
        )
        @row.collapse!
      end

      it "pulls the first row from the first child into itself" do
        @row.cells.should == {"foo" => "foo", "bar" => "bar", "barry" => "bare"}
      end

      it "leaves the second row from the first child in the first group" do
        @row.children.first.children.first.cells.should == {"barry" => "bart"}
      end

      it "collapses the second group" do
        @row.children.last.children.first.cells.should == {"bar" => "baz", "barry" => "bazaar"}
        @row.children.last.children.first.children.first.children.first.cells.should == {"barry" => "bizarre"}
      end
    end
  end
end
