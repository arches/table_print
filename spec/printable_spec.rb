require 'spec_helper'

describe TablePrint::Printable do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "#default_display_methods" do
    it "returns attribute getters" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")

      p = Sandbox::Hat.new
      TablePrint::Printable.default_display_methods(p).should == %W(brand)
    end

    it "ignores dangerous methods" do
      Sandbox.add_class("Hat")
      Sandbox.add_method("Hat", "brand!") {}

      p = Sandbox::Hat.new
      TablePrint::Printable.default_display_methods(p).should == []
    end

    it "ignores methods defined in a superclass" do
      Sandbox.add_class("Hat::Bowler")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_attributes("Hat::Bowler", "brim_width")

      p = Sandbox::Hat::Bowler.new
      TablePrint::Printable.default_display_methods(p).should == %W(brim_width)
    end

    it "ignores methods that require arguments" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_method("Hat", "tip?") { |person| person.rapscallion? }

      p = Sandbox::Hat.new
      TablePrint::Printable.default_display_methods(p).should == %W(brand)
    end

    it "ignores methods from an included module" do
      pending "waiting for Cat to support module manipulation"
    end

    it "uses column information when available (eg, from ActiveRecord objects)"
    
    it "uses the members method when passed a Struct" do
      test_struct = Struct.new(:foo, :bar)
      obj = test_struct.new
      obj.foo = 1
      obj.bar = 2
      TablePrint::Printable.default_display_methods(obj).should == [:foo, :bar]
    end
      
      
  end

end

