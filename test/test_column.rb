require 'helper'

class TablePrint
  class Column
    def _truncate(field_value)
      truncate(field_value)
    end
  end
end

class TestTablePrint < Test::Unit::TestCase

  # TODO: active record tests if defined?(ActiveRecord)

  # Vaguely ordered from most to least granular

  context 'Instantiating a Column' do
    context 'with a display_method' do
      setup do
        @column = TablePrint::Column.new([], "to_s")
      end
      should 'remember the display method' do
        assert_equal "to_s", @column.display_method
      end
      should 'set the name' do
        assert_equal "to s", @column.name
      end
    end

    context 'with options including' do
      context 'name' do
        setup do
          @column = TablePrint::Column.new([], "first", {:name => "test_tube"})
        end

        should 'set the name according to the options' do
          assert_equal "test_tube", @column.name
        end
      end

      context 'a field_length' do
        context 'that is valid' do
          setup do
            @column = TablePrint::Column.new(["short"], "first", {:field_length => 20})
          end

          should 'set the field length according to the options' do
            assert_equal 20, @column.field_length
          end
        end

        context 'that is less than 1' do
          setup do
            @column = TablePrint::Column.new(["short"], "first", {:field_length => 0})
          end

          should 'ignore the field_length' do
            assert_equal 5, @column.field_length
          end
        end

        context 'that is bigger than the max' do
          setup do
            @column = TablePrint::Column.new(["short"], "first", {:field_length => 20, :max_field_length => 10})
          end

          should 'respect the max_field_length' do
            assert_equal 10, @column.field_length
          end
        end
      end
    end
  end

  context 'The truncate function' do
    should 'let short strings pass through' do
      assert_equal "asdf", TablePrint::Column.new([], "")._truncate("asdf")
    end

    should 'truncate long strings with ellipses' do
      assert_equal "123456789012345678901234567...", TablePrint::Column.new([], "")._truncate("1234567890123456789012345678901234567890")
    end

    context 'when given a max length in the options' do
      should 'truncate long strings with ellipses' do
        assert_equal "1234567...", TablePrint::Column.new([], "", :max_field_length => 10)._truncate("1234567890123456789012345678901234567890")
      end
    end

    context 'when the max length is tiny' do
      should 'truncate long strings without ellipses' do
        assert_equal "1", TablePrint::Column.new([], "", :max_field_length => -10)._truncate("1234567890123456789012345678901234567890")
        assert_equal "1", TablePrint::Column.new([], "", :max_field_length => 0)._truncate("1234567890123456789012345678901234567890")
        assert_equal "1", TablePrint::Column.new([], "", :max_field_length => 1)._truncate("1234567890123456789012345678901234567890")
        assert_equal "12", TablePrint::Column.new([], "", :max_field_length => 2)._truncate("1234567890123456789012345678901234567890")
        assert_equal "123", TablePrint::Column.new([], "", :max_field_length => 3)._truncate("1234567890123456789012345678901234567890")
        assert_equal "1...", TablePrint::Column.new([], "", :max_field_length => 4)._truncate("1234567890123456789012345678901234567890")
      end
    end
  end

  context 'The field length function' do
    should 'find the maximum width of the data' do
      assert_equal 11, TablePrint::Column.new(["hello there"], "to_s").field_length
    end

    context 'when the data is longer than the max_field_length' do
      should 'equal the max field length' do
        assert_equal 5, TablePrint::Column.new(["hello there"], "to_s", :max_field_length => 5).field_length
      end
    end

    context 'when the column name is longer than the data' do
      should 'reflect the column name length' do
        assert_equal 4, TablePrint::Column.new(["he"], "to_s", :max_field_length => 5).field_length
        assert_equal 12, TablePrint::Column.new(["hello"], "to_s", :name => "foobar THIS!").field_length
      end
    end

    context 'when the column is boolean and the data is the limiting factor' do
      should 'always be 5' do
        assert_equal 5, TablePrint::Column.new([[true]], "first", :name => "dur").field_length
        assert_equal 5, TablePrint::Column.new([[false]], "first", :name => "dur").field_length
      end
    end

    context 'when the column is boolean and the data is not the limiting factor' do
      should 'be the column name length' do
        assert_equal 7, TablePrint::Column.new([[true]], "unshift").field_length
        assert_equal 8, TablePrint::Column.new([[false]], "unshift", :name => "durables").field_length
      end
    end
  end

end
