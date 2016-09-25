require 'spec_helper'

include TablePrint

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

  describe "data_equal" do
    it "is true when the cells are equal" do
      row1 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      row2 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      expect(row1.data_equal(row2)).to be_true
    end

    it "is false when the cells are not equal" do
      row1 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})

      row2 = TablePrint::Row.new.set_cell_values({'title' => "wonkier"})
      expect(row1.data_equal(row2)).not_to be_true

      row2 = TablePrint::Row.new.set_cell_values({'zitle' => "wonky"})
      expect(row1.data_equal(row2)).not_to be_true

      expect(row1.data_equal(nil)).not_to be_true
      expect(row1.data_equal("seven")).not_to be_true
    end

    it "is false when the children are not equal" do
      row1 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      group1 = TablePrint::RowGroup.new
      row1a = TablePrint::Row.new.set_cell_values({'foo' => 'bar'})
      row1.add_child(group1)
      group1.add_child(row1a)

      row2 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      expect(row1.data_equal(row2)).not_to be_true
    end

    it "is true when the children are equal" do
      row1 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      group1 = TablePrint::RowGroup.new
      row1a = TablePrint::Row.new.set_cell_values({'foo' => 'bar'})
      row1.add_child(group1)
      group1.add_child(row1a)

      row2 = TablePrint::Row.new.set_cell_values({'title' => "wonky"})
      group2 = TablePrint::RowGroup.new
      row2a = TablePrint::Row.new.set_cell_values({'foo' => 'bar'})
      row2.add_child(group2)
      group2.add_child(row2a)
      expect(row1.data_equal(row2)).to be_true
    end
  end
end

describe "collapse" do

  before(:each) do
    original.collapse!
  end

  # row: foo
  #   group
  #     row: bar
  # => foo | bar
  context "for a single row in a single child group" do
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_child(
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar")
        )
      )
    }

    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar"})
    }

    it "matches" do
      expect(original.data_equal(collapsed)).to be_true
    end
  end

  # row: foo
  #   group
  #     row: bar
  #     row: baz
  # => foo | bar
  #        | baz
  context "for two rows in a single child group" do
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_child(
        RowGroup.new.add_children([
          Row.new.set_cell_values(:bar => "bar"),
          Row.new.set_cell_values(:bar => "baz")
        ])
      )
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar"}).add_child(
        RowGroup.new.add_children(
          [
            Row.new.set_cell_values(:bar => 'baz')
          ]
        )
      )
    }

    it "matches" do
      expect(original.data_equal(collapsed)).to be_true
    end
  end

  # row: foo
  #   group
  #     row: bar
  #   group
  #     row: baz
  # => foo | bar | baz
  context "for two groups with a single row each" do
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_children([
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar")
        ),
        RowGroup.new.add_child(
          Row.new.set_cell_values(:baz => "baz")
        )
      ])
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar", "baz" => "baz"})
    }

    it "pulls the cells from both groups into the parent" do
      expect(original.data_equal(collapsed)).to be_true
    end
  end

  # row: foo
  #   group
  #     row: bar
  #   group
  # => foo | bar |
  context "for two groups, one of which has no rows (eg, we hit an empty association)" do
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_children([
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar")
        ),
        RowGroup.new
      ])
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar"})
    }

    it "pulls the cells from both groups into the parent" do
      expect(original.data_equal(collapsed)).to be_true
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
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_children([
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar")
        ),
        RowGroup.new.add_children([
          Row.new.set_cell_values(:baz => "baz"),
          Row.new.set_cell_values(:baz => "bazaar"),
        ]),
      ])
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar", "baz" => "baz"}).add_child(
        RowGroup.new.add_child(
          Row.new.set_cell_values({"baz" => "bazaar"})
        )
      )
    }

    it "pulls the single row and the first row from the double into itself" do
      expect(original.data_equal(collapsed)).to be_true
    end
  end

  # row: foo
  #   group
  #     row: bar
  #       group
  #         row: baz
  # => foo | bar | baz
  context "for two nested groups, each with one row" do
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_child(
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar").add_child(
            RowGroup.new.add_child(
              Row.new.set_cell_values(:baz => "baz")
            )
          )
        )
      )
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar", "baz" => "baz"})
    }

    it "pulls the cells from both groups into the parent" do
      expect(original.data_equal(collapsed)).to be_true
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
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_child(
        RowGroup.new.add_child(
          Row.new.set_cell_values(:bar => "bar").add_child(
            RowGroup.new.add_children([
              Row.new.set_cell_values(:baz => "baz"),
              Row.new.set_cell_values(:baz => "bazaar")
            ])
          )
        )
      )
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar", "baz" => "baz"}).add_child(
        RowGroup.new.add_child(
          Row.new.set_cell_values({"baz" => "bazaar"})
        )
      )
    }

    it "pulls the first row from each group up into itself" do
      expect(original.data_equal(collapsed)).to be_true
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
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_children([
        RowGroup.new.add_children([
          Row.new.set_cell_values(:bar => "bar"),
          Row.new.set_cell_values(:bar => "bar2"),
        ]),
        RowGroup.new.add_children([
          Row.new.set_cell_values(:baz => "bazaar"),
          Row.new.set_cell_values(:baz => "bazaar2"),
        ])
      ])
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar"}).add_children([
        RowGroup.new.add_child(
          Row.new.set_cell_values({"bar" => "bar2"})
        ),
        RowGroup.new.add_children([
          Row.new.set_cell_values({"baz" => "bazaar"}),
          Row.new.set_cell_values({"baz" => "bazaar2"})
        ])
      ])
    }

    it "pulls the first row from the first group into the parent, leaves the second row in the first group, leaves the second group alone" do
      expect(original.data_equal(collapsed)).to be_true
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
    let(:original) {
      Row.new.set_cell_values(:foo => "foo").add_child(
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
    }
    let(:collapsed) {
      Row.new.set_cell_values({"foo" => "foo", "bar" => "bar", "barry" => "bare"}).add_children([
        RowGroup.new.add_child(
          Row.new.set_cell_values({"barry" => "bart"})
        ),
        RowGroup.new.add_children([
          Row.new.set_cell_values({"bar" => "baz", "barry" => "bazaar"}).add_child(
            RowGroup.new.add_child(
              Row.new.set_cell_values({"barry" => "bizarre"})
            )
          )
        ])
      ])
    }

    it "pulls the first row from the first child into itself, leaves the second row fromthe first child in the first group, collapses the second group" do
      expect(original.data_equal(collapsed)).to be_true
    end
  end
end
