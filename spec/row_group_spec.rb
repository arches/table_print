require 'spec_helper'

include TablePrint

def compare_rows(actual_rows, expected_rows)
  Array(actual_rows).length.should == Array(expected_rows).length
  Array(actual_rows).zip(Array(expected_rows)).each do |actual, expected|
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

#  describe "#format" do
#    it "formats the row with padding" do
#      compare_rows(row.format, "wonky | bob jones | 2012    ")
#    end
#
#    it "also formats the children" do
#      row.add_child(RowGroup.new.add_child(Row.new.set_cell_values(:title => "wonky2", :author => "bob jones2", :pub_date => "20122")))
#
#      table.columns.find{|c| c.name.to_s == "title"}.data << "wonky2"
#      table.columns.find{|c| c.name.to_s == "author"}.data << "bob jones2"
#      table.columns.find{|c| c.name.to_s == "pub_date"}.data << "20122"
#
#      compare_rows(row.format, ["wonky  | bob jones  | 2012    ", "wonky2 | bob jones2 | 20122   "])
#    end
#  end

#  describe "#apply_formatters" do
#    it "calls the format method on each formatter for that column" do
#      Sandbox.add_class("DoubleFormatter")
#      Sandbox.add_method("DoubleFormatter", :format) { |value| value * 2 }
#
#      Sandbox.add_class("ChopFormatter")
#      Sandbox.add_method("ChopFormatter", :format) { |value| value[0..-2] }
#
#      f1 = Sandbox::DoubleFormatter.new
#      f2 = Sandbox::ChopFormatter.new
#
#      column = Column.new(:name => "title", :fixed_width => 9)
#      column.formatters = [f1, f2]
#
#      row.apply_formatters(column).should == "wonkywonk"
#    end
#
#    it "uses the config'd time_format to format times" do
#      column = Column.new(:name => "title", :fixed_width => 20, :formatters => [], :time_format => "%Y %m %d")
#
#      time_formatter = TablePrint::TimeFormatter.new
#      TablePrint::TimeFormatter.should_receive(:new).with("%Y %m %d") {time_formatter}
#
#      row.set_cell_values(:title => Time.local(2012, 6, 1, 14, 20, 20))
#
#      row.apply_formatters(column)
#    end
#  end
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
