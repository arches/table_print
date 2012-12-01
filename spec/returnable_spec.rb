require 'spec_helper'

describe TablePrint::Returnable do
  it "returns its initialized value from its to_s method" do
    r = TablePrint::Returnable.new("foobar")
    r.to_s.should == "foobar"
  end

  it "returns its initialized value from its inspect method" do
    # 1.8.7 calls inspect on return values
    r = TablePrint::Returnable.new("foobar")
    r.inspect.should == "foobar"
  end

  it "passes #set through to TablePrint::Config" do
    TablePrint::Config.should_receive(:set).with(Object, [:foo])
    r = TablePrint::Returnable.new
    r.set(Object, :foo)
  end

  it "passes #clear through to TablePrint::Config" do
    TablePrint::Config.should_receive(:clear).with(Object)
    r = TablePrint::Returnable.new
    r.clear(Object)
  end

  it "passes #config_for through to TablePrint::Config.for" do
    TablePrint::Config.should_receive(:for).with(Object)
    r = TablePrint::Returnable.new
    r.config_for(Object)
  end
end

