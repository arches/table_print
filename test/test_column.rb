require 'helper'

class TablePrint
  class ColumnHelper
    def _truncate(field_value)
      truncate(field_value)
    end
    def _get_current_method(method_chain)
      get_current_method(method_chain)
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
  end

  # def formatted_cell_value(data_obj, method_chain)
  # def add_stack_objects(stack, data_obj, method_chain, method_hash)
  # def add_to_stack?(method_chain, method_hash = {})
  # def wrap(object)

  # def truncate(field_value)
#  context 'The truncate function' do
#    should 'let short strings pass through' do
#      assert_equal "asdf", TablePrint::ColumnHelper.new([], "")._truncate("asdf")
#    end
#
#    should 'truncate long strings with ellipses' do
#      assert_equal "123456789012345678901234567...", TablePrint::ColumnHelper.new([], "")._truncate("1234567890123456789012345678901234567890")
#    end
#
#    context 'when given a max length in the options' do
#      should 'truncate long strings with ellipses' do
#        assert_equal "1234567...", TablePrint::ColumnHelper.new([], "", :max_field_length => 10)._truncate("1234567890123456789012345678901234567890")
#      end
#    end
#
#    context 'when the max length is tiny' do
#      should 'truncate long strings without ellipses' do
#        assert_equal "1", TablePrint::ColumnHelper.new([], "", :max_field_length => -10)._truncate("1234567890123456789012345678901234567890")
#        assert_equal "1", TablePrint::ColumnHelper.new([], "", :max_field_length => 0)._truncate("1234567890123456789012345678901234567890")
#        assert_equal "1", TablePrint::ColumnHelper.new([], "", :max_field_length => 1)._truncate("1234567890123456789012345678901234567890")
#        assert_equal "12", TablePrint::ColumnHelper.new([], "", :max_field_length => 2)._truncate("1234567890123456789012345678901234567890")
#        assert_equal "123", TablePrint::ColumnHelper.new([], "", :max_field_length => 3)._truncate("1234567890123456789012345678901234567890")
#        assert_equal "1...", TablePrint::ColumnHelper.new([], "", :max_field_length => 4)._truncate("1234567890123456789012345678901234567890")
#      end
#    end
#  end

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
  context '' do

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
