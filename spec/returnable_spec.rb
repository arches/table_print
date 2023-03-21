require 'spec_helper'

describe TablePrint::Returnable do
  it "returns its initialized value from its to_s method" do
    r = TablePrint::Returnable.new("foobar")
    expect(r.to_s).to eq "foobar"
  end

  it "returns its initialized value from its inspect method" do
    # 1.8.7 calls inspect on return values
    r = TablePrint::Returnable.new("foobar")
    expect(r.inspect).to eq "foobar"
  end

  it "passes #set through to TablePrint::Config" do
    expect(TablePrint::Config).to receive(:set).with(Object, [:foo])
    r = TablePrint::Returnable.new
    r.set(Object, :foo)
  end

  it "passes #clear through to TablePrint::Config" do
    expect(TablePrint::Config).to receive(:clear).with(Object)
    r = TablePrint::Returnable.new
    r.clear(Object)
  end

  it "passes #config_for through to TablePrint::Config.for" do
    expect(TablePrint::Config).to receive(:for).with(Object)
    r = TablePrint::Returnable.new
    r.config_for(Object)
  end
end

