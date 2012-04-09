module TablePrint
  class Cell
    attr_accessor :row, :column, :wrapped_object

    # could be empty (if the column's method doesn't apply to this object type)
  end
end
