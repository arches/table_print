require 'cat'
require 'ostruct'
require_relative '../../../lib/table_print'

Given /^a class named (.*)$/ do |klass|
  Sandbox.add_class(klass)
end

Given /^(.*) has attributes (.*)$/ do |klass, attributes|
  attrs = attributes.split(",").map { |attr| attr.strip }

  Sandbox.add_attributes(klass, *attrs)
end

Given /^(.*) has a class method named (.*) with (.*)$/ do |klass, method_name, blk|
  Sandbox.add_class_method(klass, method_name, &eval(blk))
end

Given /^(.*) has a method named (\w*) with (.*)$/ do |klass, method_name, blk|
  Sandbox.add_method(klass, method_name, &eval(blk))
end

When /^I instantiate a (.*) with (\{.*\})$/ do |klass, args|
  @objs ||= OpenStruct.new
  @objs.send("#{klass.downcase}=", Sandbox.const_get_from_string(klass).new(eval(args)))
end

When /^I instantiate a (.*) with (\{.*\}) and add it to (.*)$/ do |klass, args, target|
  # the thing we're instantiating
  child = Sandbox.const_get_from_string(klass).new(eval(args))

  # the place we're going to add it
  target_array = target.split(".").inject(@objs) { |target_obj, target_part| target_obj.send(target_part) }
  target_array << child
end

When /table_print (.*)$/ do |klass|
  @r, w = IO.pipe

  w.puts TablePrint::Printer.new.table_print(Array(@objs.send(klass.downcase)))

  w.close
end

Then /^the output should contain$/ do |string|
  output = []
  while line = @r.gets
    output << line
  end
  @r.close

  output.join.strip.should == string
end
