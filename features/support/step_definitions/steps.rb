require 'cat'
require 'ostruct'
require 'table_print'

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

Given /^a variable named (.*) with$/ do |variable, table|
  @objs ||= OpenStruct.new
  @objs.send("#{variable.downcase}=", table.hashes)
end

Given /^an array of structs named (.*) with$/ do |variable, table|
  @objs ||= OpenStruct.new
  struct = Struct.new(*(table.column_names.collect(&:to_sym)))
  data = table.hashes.collect do |hsh|
    obj = struct.new
    hsh.each {|k,v| obj.send "#{k}=", v}
    obj
  end
  @objs.send("#{variable.downcase}=", data)
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
  if assignment_method == "assign it"
    target_object.send("#{target_method}=", child)
  else
    target_object.send("#{target_method}") << child
  end
end

When /^I configure multibyte with (.*)$/ do |value|
  TablePrint::Config.set(:multibyte, [value == "true"])
end

When /^I configure capitalize_headers with (.*)$/ do |value|
  TablePrint::Config.set(:capitalize_headers, [value == "true"])
end

When /^I configure separator with '(.*)'$/ do |value|
  TablePrint::Config.set(:separator, [value])
end

When /^configure (.*) with (.*)$/ do |klass, config|
  klass = Sandbox.const_get_from_string(klass)
  TablePrint::Config.set(klass, eval(config))
end

When /table_print ([\w:]*), (.*)$/ do |klass, options|
  tp(@objs.send(klass.downcase), eval(options))
end

When /table_print ([\w\.:]*)$/ do |klass|
  obj = @objs.send(klass.split(".").first.downcase)
  obj = obj.send(klass.split(".").last) if klass.include? "."  # hack - we're assuming only two levels. use inject to find the target.

  tp(obj)
end

Then /^the output should contain$/ do |string|
  output = @r.lines.to_a

  output.zip(string.split("\n")).each do |actual, expected|
    actual.gsub(/\s/m, "").split(//).sort.join.should == expected.gsub(" ", "").split(//).sort.join
  end
end

def tp(data, options={})
  @r, w = IO.pipe
  w.puts TablePrint::Printer.table_print(data, options)
  w.close
end
