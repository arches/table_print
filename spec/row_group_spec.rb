require 'spec_helper'

include TablePrint

def compare_rows(actual_rows, expected_rows)
  Array(actual_rows).length.should == Array(expected_rows).length
  Array(actual_rows).zip(Array(expected_rows)).each do |actual, expected|
    actual.split(//).sort.join.should == expected.split(//).sort.join
  end
end

describe TablePrint::RowGroup do
  let(:group1) { TablePrint::RowGroup.new }

  before do
    group1.children << TablePrint::Row.new.set_cell_values({'foo' => 'bar'})
  end

  describe "data_equal" do
    it "is true if the children are equal" do
      group2 = TablePrint::RowGroup.new
      group2.children << TablePrint::Row.new.set_cell_values({'foo' => 'bar'})

      expect(group1.data_equal(group2)).to be_true
    end

    context "with different cell values" do
      it "is false" do
        group2 = TablePrint::RowGroup.new
        group2.children << TablePrint::Row.new.set_cell_values({'foo' => 'baz'})

        expect(group1.data_equal(group2)).not_to be_true

        group2 = TablePrint::RowGroup.new
        group2.children << TablePrint::Row.new.set_cell_values({'far' => 'bar'})

        expect(group1.data_equal(group2)).not_to be_true
      end
    end

    context "with different child lengths" do
      it "is false" do
        group2 = TablePrint::RowGroup.new

        expect(group1.data_equal(group2)).not_to be_true

        group2 = TablePrint::RowGroup.new
        group2.children << TablePrint::Row.new.set_cell_values({'foo' => 'bar'})
        group2.children << TablePrint::Row.new.set_cell_values({'foo' => 'bar'})

        expect(group1.data_equal(group2)).not_to be_true
      end
    end
  end
end
