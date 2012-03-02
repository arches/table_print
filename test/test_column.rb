require 'helper'

class TablePrint
  class ColumnHelper
    def _truncate(field_value)
      truncate(field_value)
    end

    def _get_current_method(method_chain)
      get_current_method(method_chain)
    end

    def _add_to_stack?(method_chain, method_hash)
      add_to_stack?(method_chain, method_hash)
    end

    def _formatted_cell_value(data_obj, method_chain)
      formatted_cell_value(data_obj, method_chain)
    end

    def _find_data_length(data, method_chain, start)
      find_data_length(data, method_chain, start)
    end

    def _add_stack_objects(stack, data_obj, method_chain, start)
      add_stack_objects(stack, data_obj, method_chain, start)
    end
  end
end

class TestTablePrint < Test::Unit::TestCase

  # TODO: active record tests if defined?(ActiveRecord)

  # Ordered to match method order in the Column class

  # attr_accessor :field_length, :max_field_length, :method, :name, :options
  context 'A column object' do
    setup do
      @column = TablePrint::ColumnHelper.new([], "to_s")
      @column.field_length = 0
      @column.max_field_length = 0
      @column.method = 0
      @column.name = 0
      @column.options = 0
    end
    should 'allow writes to and reads from its attributes' do
      assert_equal 0, @column.field_length
      assert_equal 0, @column.max_field_length
      assert_equal 0, @column.method
      assert_equal 0, @column.name
      assert_equal 0, @column.options
    end
  end

  # def initialize(data, method, options = {})
  context 'Instantiating a Column' do
    context 'with a display_method' do
      setup do
        @column = TablePrint::ColumnHelper.new([], "to_s")
      end
      should 'remember the display method' do
        assert_equal "to_s", @column.method
      end
      should 'set the name' do
        assert_equal "to s", @column.name
      end
    end

    context 'with options including' do
      context 'name' do
        setup do
          @column = TablePrint::ColumnHelper.new([], "first", {:name => "test_tube"})
        end

        should 'set the name according to the options' do
          assert_equal "test_tube", @column.name
        end

        context 'when the method name contains dots' do
          setup do
            @column = TablePrint::ColumnHelper.new(["short"], "method1.method2", {:name => "test_tube"})
          end
          should 'use the option' do
            assert_equal "TEST_TUBE", @column.formatted_header
          end
        end
      end

      context 'a field_length' do
        context 'that is valid' do
          setup do
            @column = TablePrint::ColumnHelper.new(["short"], "first", {:field_length => 20})
          end

          should 'set the field length according to the options' do
            assert_equal 20, @column.field_length
          end
        end

        context 'that is less than 1' do
          setup do
            @column = TablePrint::ColumnHelper.new(["short"], "first", {:field_length => 0})
          end

          should 'ignore the field_length' do
            assert_equal 5, @column.field_length
          end
        end

        context 'that is bigger than the max' do
          setup do
            @column = TablePrint::ColumnHelper.new(["short"], "first", {:field_length => 20, :max_field_length => 10})
          end

          should 'respect the max_field_length' do
            assert_equal 10, @column.field_length
          end
        end
      end
    end
  end

  # def formatted_header
  context 'The formatted header function' do
    context 'when the method name contains no special characters and is shorter than the max field length' do
      setup do
        @column = TablePrint::ColumnHelper.new(["short"], "first", {:field_length => 10})
      end
      should 'uppercase the method name and pad with spaces' do
        assert_equal "FIRST     ", @column.formatted_header
      end
    end

    context 'when the method name contains no special characters and is longer than the max field length' do
      setup do
        @column = TablePrint::ColumnHelper.new(["short"], "longMethodName", {:field_length => 10})
      end
      should 'uppercase and truncate the method name' do
        assert_equal "LONGMET...", @column.formatted_header
      end
    end

    context 'when the method name contains underscores' do
      setup do
        @column = TablePrint::ColumnHelper.new(["short"], "method_name")
      end
      should 'replace underscores with spaces' do
        assert_equal "METHOD NAME", @column.formatted_header
      end
    end

    context 'when the method name contains dots' do
      setup do
        @column = TablePrint::ColumnHelper.new(["short"], "method1.method2")
      end
      should 'replace dots with greater-thans' do
        assert_equal "METHOD1 > METHOD2", @column.formatted_header
      end
    end

    context 'when the user passes a name in the column options' do
      setup do
        @column = TablePrint::ColumnHelper.new(["short"], "method1.method2", {:name => "whoop"})
      end
      should 'use that name instead of the method name' do
        assert_equal "WHOOP", @column.formatted_header
      end
    end
  end

  # def formatted_cell_value(data_obj, method_chain)
  context 'The formatted_cell_value method' do
    should 'return whitespace if the method chain does not exactly match the column definition method' do
      assert_equal "               ", TablePrint::ColumnHelper.new([], "captions.text")._formatted_cell_value("test", "id")
      assert_equal "               ", TablePrint::ColumnHelper.new([], "captions.text")._formatted_cell_value("test", "captions")
    end

    should 'return whitespace if the method chain begins the ' do
      assert_equal "no, really, ...", TablePrint::ColumnHelper.new([], "captions.text")._formatted_cell_value(MyNestedClass.setup.first.captions.first, "captions")
    end
  end

  # def add_stack_objects(stack, data_obj, method_chain, method_hash)
  context 'The add_stack_objects method' do
    context 'when objects need to be added to the stack' do
      setup do
        @tp = TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.text")
        @stack = [1, 2, 3]
        @tp._add_stack_objects(@stack, MyNestedClass.setup.first, "", {})
      end
      should 'increase stack size' do
        assert_equal 4, @stack.size
      end
      should 'push the new objects on the front of the stack' do
        assert_equal MyNestedClass::Caption, @stack.first.first.class
      end
      should 'include the updated method_chain in the stack' do
        assert_equal "captions", @stack.first.last
      end
    end
  end


  # def add_to_stack?(method_chain, method_hash = {})
  context 'The add_to_stack? method' do
    should 'appropriately respond to its arguments' do

      # our first method produces an array, so yes, stack 'em up
      assert TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.text")._add_to_stack?("", {})

      # captions has already been called, so it gets popped off our method chain. text is the final method, so no, don't stack
      assert !TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.text")._add_to_stack?("captions", {})

      # the method isn't one of ours, so there's nothing for us to do
      assert !TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.text")._add_to_stack?("id", {})

      # another column has already added the captions to the stack, so there's no need for us to do it
      assert !TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.text")._add_to_stack?("", {"captions" => {}})
    end
  end

  # def wrap(object)

  # def truncate(field_value)
  context 'The truncate function' do
    should 'let short strings pass through' do
      assert_equal "asdf", TablePrint::ColumnHelper.new(["a long long long string"], "first")._truncate("asdf")
    end

    should 'truncate long strings with ellipses' do
      # have to put long data in the data set to field_length is pushed out to the default max_field_length
      assert_equal "123456789012345678901234567...", TablePrint::ColumnHelper.new([["1234567890123456789012345678901234567890"]], "first")._truncate("1234567890123456789012345678901234567890")
    end

    context 'with a non-default field length' do
      should 'truncate long strings with ellipses' do
        tp = TablePrint::ColumnHelper.new([], "")
        tp.field_length = 10
        assert_equal "1234567...", tp._truncate("1234567890123456789012345678901234567890")
      end
    end

    context 'when the max length is tiny' do
      should 'truncate long strings without ellipses' do
        assert_equal "123456789012345678901234567...", TablePrint::ColumnHelper.new([["1234567890123456789012345678901234567890"]], "first", :field_length => -10)._truncate("1234567890123456789012345678901234567890")
        assert_equal "123456789012345678901234567...", TablePrint::ColumnHelper.new([["1234567890123456789012345678901234567890"]], "first", :field_length => 0)._truncate("1234567890123456789012345678901234567890")
        assert_equal "1", TablePrint::ColumnHelper.new([], "", :field_length => 1)._truncate("1234567890123456789012345678901234567890")
        assert_equal "12", TablePrint::ColumnHelper.new([], "", :field_length => 2)._truncate("1234567890123456789012345678901234567890")
        assert_equal "123", TablePrint::ColumnHelper.new([], "", :field_length => 3)._truncate("1234567890123456789012345678901234567890")
        assert_equal "1...", TablePrint::ColumnHelper.new([], "", :field_length => 4)._truncate("1234567890123456789012345678901234567890")
      end
    end
  end

  # def initialize_field_length(data)
  context 'The field length function' do
    should 'honor the field_length options' do
      assert_equal 5, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :field_length => 5).field_length
      assert_equal 30, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :field_length => 5).max_field_length
    end

    should 'honor the max_length option' do
      assert_equal 5, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :max_field_length => 5).field_length
      assert_equal 5, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :max_field_length => 5).max_field_length
    end

    should 'honor the max_length option over the field_length option' do
      assert_equal 5, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :max_field_length => 5, :field_length => 10).field_length
      assert_equal 5, TablePrint::ColumnHelper.new(["hello there madam"], "to_s", :max_field_length => 5, :field_length => 10).max_field_length
    end

    should 'find the maximum width of the data' do
      assert_equal 11, TablePrint::ColumnHelper.new(["hello there"], "to_s").field_length
    end

    context 'when the data is longer than the max_field_length' do
      should 'equal the max field length' do
        assert_equal 5, TablePrint::ColumnHelper.new(["hello there"], "to_s", :max_field_length => 5).field_length
      end
    end

    context 'when the column name is longer than the data' do
      should 'reflect the column name length' do
        assert_equal 4, TablePrint::ColumnHelper.new(["he"], "to_s", :max_field_length => 5).field_length
        assert_equal 12, TablePrint::ColumnHelper.new(["hello"], "to_s", :name => "foobar THIS!").field_length
      end
    end

    context 'when the method is recursive' do
      should 'find the maximum width of the data' do
        assert_equal 30, TablePrint::ColumnHelper.new(MyNestedClass.setup, "captions.photo_url", :max_field_length => 50).field_length
      end
    end
  end

  # def find_data_length(data, method, start)
  context 'The find_data_length method' do
    context 'when method_chain is a top level method' do
      setup do
        @tp = TablePrint::ColumnHelper.new([], "")
        @tp._find_data_length(MyNestedClass.setup, "title", Time.now)
      end
      should 'set field_length to the longest value in the data set' do
        assert_equal 16, @tp.field_length
      end
    end

    context 'when method_chain is not a top level method' do
      setup do
        @tp = TablePrint::ColumnHelper.new([], "")
        @tp._find_data_length(MyNestedClass.setup, "captions.text", Time.now)
      end
      should 'set field_length to the longest value in the data set' do
        assert_equal 28, @tp.field_length
      end
    end

    context 'when the data value is longer than max_field_length' do
      setup do
        @tp = TablePrint::ColumnHelper.new([], "", :max_field_length => 10)
        @tp._find_data_length(MyNestedClass.setup, "captions.photo_url", Time.now)
      end
      should 'ignore max_field_length (initialize_field_length handles that - this method is just about the data)' do
        assert_equal 26, @tp.field_length
      end
    end
  end

  # def get_current_method(method_chain)
  context 'get_current_method' do
    context 'with a simple method signature' do
      context 'and no method chain' do
        should 'return the method itself' do
          assert_equal "m1", TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1")._get_current_method("")
        end
      end
      context 'and a method chain that does not match' do
        should 'return nil' do
          assert_equal nil, TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1")._get_current_method("m2")
        end
      end
      context 'and an overly long method chain' do
        should 'return nil' do
          assert_equal nil, TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1")._get_current_method("m1.m2")
        end
      end
    end

    context 'with a compound method signature' do
      context 'and no method chain' do
        should 'return the first method in the chain' do
          assert_equal "m1", TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("")
        end
      end
      context 'and a method chain that does not match' do
        should 'return nil' do
          assert_equal nil, TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("m2")
        end
      end
      context 'and a valid method chain' do
        should 'return the next method in the chain' do
          assert_equal "m2", TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("m1")
          assert_equal "m3", TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("m1.m2")
        end
      end
      context 'and an overly long method chain' do
        should 'return nil' do
          assert_equal nil, TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("m1.m2.m3.m4")
        end
      end
      context 'and a method chain matching our method signature' do
        should 'return nil' do
          assert_equal nil, TablePrint::ColumnHelper.new(MyNestedClass.setup, "m1.m2.m3")._get_current_method("m1.m2.m3")
        end
      end
    end
  end
end
