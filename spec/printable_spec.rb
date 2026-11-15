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
      expect(TablePrint::Printable.default_display_methods(p)).to eq %W(brand)
    end

    it "uses an OpenStruct's attributes rather than its methods" do
      expect(TablePrint::Printable.default_display_methods(OpenStruct.new(:name => "alice", :age => 30))).to eq [:name, :age]
    end

    it "shows booleans in a single value column" do
      methods = TablePrint::Printable.default_display_methods(true)
      expect(methods.length).to eq 1
      expect(methods.first.keys).to eq ["value"]
    end

    it "ignores dangerous methods" do
      Sandbox.add_class("Hat")
      Sandbox.add_method("Hat", "brand!") {}

      p = Sandbox::Hat.new
      expect(TablePrint::Printable.default_display_methods(p)).to eq []
    end

    it "ignores methods defined in a superclass" do
      Sandbox.add_class("Hat::Bowler")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_attributes("Hat::Bowler", "brim_width")

      p = Sandbox::Hat::Bowler.new
      expect(TablePrint::Printable.default_display_methods(p)).to eq %W(brim_width)
    end

    it "ignores methods that require arguments" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_method("Hat", "tip?") { |person| person.rapscallion? }

      p = Sandbox::Hat.new
      expect(TablePrint::Printable.default_display_methods(p)).to eq %W(brand)
    end

    it "ignores methods from an included module" do
      skip "waiting for Cat to support module manipulation"
    end

    it "uses column information when available (eg, from ActiveRecord objects)"
    
    it "uses the members method when passed a Struct" do
      test_struct = Struct.new(:foo, :bar)
      obj = test_struct.new
      obj.foo = 1
      obj.bar = 2
      expect(TablePrint::Printable.default_display_methods(obj)).to eq [:foo, :bar]
    end
      
      
  end

end

