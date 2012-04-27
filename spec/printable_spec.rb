require 'spec_helper'
require 'printable'

describe TablePrint::Printable do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "#default_display_methods" do
    it "returns attribute getters" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")

      p = Sandbox::Hat.new
      p.extend TablePrint::Printable
      p.default_display_methods.should == %W(brand)
    end

    it "ignores dangerous methods" do
      Sandbox.add_class("Hat")
      Sandbox.add_method("Hat", "brand!") {}

      p = Sandbox::Hat.new
      p.extend TablePrint::Printable
      p.default_display_methods.should == []
    end

    it "ignores methods defined in a superclass" do
      Sandbox.add_class("Hat::Bowler")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_attributes("Hat::Bowler", "brim_width")

      p = Sandbox::Hat::Bowler.new
      p.extend TablePrint::Printable
      p.default_display_methods.should == %W(brim_width)
    end

    it "ignores methods that require arguments" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_method("Hat", "tip?") { |person| person.rapscallion? }

      p = Sandbox::Hat.new
      p.extend TablePrint::Printable
      p.default_display_methods.should == %W(brand)
    end

    it "ignores methods from an included module" do
      pending "waiting for Cat to support module manipulation"
    end

    it "uses column information when available (eg, from ActiveRecord objects)"
  end
end

