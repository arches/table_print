require 'spec_helper'

describe "#constructive_merge" do
  it "merges hashes without clobbering" do
    x = {'reviews' => {'user' => {}}}
    y = {'reviews' => {'ratings' => {}}}
    x.extend TablePrint::HashExtensions::ConstructiveMerge
    x.constructive_merge(y).should == {'reviews' => {'user' => {}, 'ratings' => {}}}
  end
end

describe "#constructive_merge!" do
  it "merges hashes in place without clobbering" do
    x = {'reviews' => {'user' => {}}}
    y = {'reviews' => {'ratings' => {}}}
    x.extend TablePrint::HashExtensions::ConstructiveMerge
    x.constructive_merge!(y)
    x.should == {'reviews' => {'user' => {}, 'ratings' => {}}}
  end
end
