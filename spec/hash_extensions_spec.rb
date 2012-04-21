require 'spec_helper'
require_relative '../lib/hash_extensions'

describe "#constructive_merge" do
  it "merges hashes without clobbering" do
    x = {'reviews' => {'user' => {}}}
    y = {'reviews' => {'ratings' => {}}}
    x.extend TablePrint::HashExtensions::ConstructiveMerge
    x.constructive_merge(y).should == {'reviews' => {'user' => {}, 'ratings' => {}}}
  end
end
