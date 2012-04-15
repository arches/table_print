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

When /^I instantiate a (.*) with (\{.*\}) and (add it|assign it) to (.*)$/ do |klass, args, assignment_method, target|
  # the thing we're instantiating
  child = Sandbox.const_get_from_string(klass).new(eval(args))

  # the place we're going to add it
  method_chain = target.split(".")
  target_method = method_chain.pop
  target_object = method_chain.inject(@objs) { |obj, method_name| obj.send(method_name) }

  # how we're going to add it
  operator = "<<" if assignment_method == "add it"
  operator = "=" if assignment_method == "assign it"

  target_object.send("#{target_method}#{operator}", child)
end

When /table_print ([\w:]*), (.*)$/ do |klass, options|
  tp(Array(@objs.send(klass.downcase)), eval(options))
end

When /table_print ([\w:]*)$/ do |klass|
  tp(Array(@objs.send(klass.downcase)))
end

Then /^the output should contain$/ do |string|
  output = []
  while line = @r.gets
    output << line
  end
  @r.close

  output.join.strip.should == string
end

def tp(data, options=nil)
  @r, w = IO.pipe
  w.puts TablePrint::Printer.new.table_print(data, options)
  w.close
end
