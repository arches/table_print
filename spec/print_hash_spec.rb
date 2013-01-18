require 'spec_helper'
require 'table_print'

include TablePrint

describe "printing a Hash" do
  it "can print an array of hashes" do

    data = [{:name => "User 1",
             :surname => "Familyname 1"
            },
            {:name => "User 2",
             :surname => "Familyname 2"}]

    p = Printer.new(data)
    cols = p.columns
    cols.length.should == 2
    cols.first.name.should == 'name'

    # puts p.table_print
  end
end