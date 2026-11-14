require 'spec_helper'

describe "#constructive_merge" do
  it "merges hashes without clobbering" do
    x = {'reviews' => {'user' => {}}}
    y = {'reviews' => {'ratings' => {}}}
    x.extend TablePrint::HashExtensions::ConstructiveMerge
    expect(x.constructive_merge(y)).to eq({'reviews' => {'user' => {}, 'ratings' => {}}})
  end
end

describe "#constructive_merge!" do
  it "merges hashes in place without clobbering" do
    x = {'reviews' => {'user' => {}}}
    y = {'reviews' => {'ratings' => {}}}
    x.extend TablePrint::HashExtensions::ConstructiveMerge
    x.constructive_merge!(y)
    expect(x).to eq({'reviews' => {'user' => {}, 'ratings' => {}}})
  end
end
