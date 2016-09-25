module TablePrint
  module RowRecursion
    attr_accessor :parent
    attr_accessor :children

    def initialize
      @children = []
    end

    def add_child(child)
      @children << child
      child.parent = self
    end

    def insert_children(i, children)
      @children.insert(i, children).flatten!
      children.each { |c| c.parent = self }
      self
    end

    def add_children(children)
      @children.concat children
      children.each { |c| c.parent = self }
      self
    end

    def child_count
      @children.length
    end

    def columns
      parent.columns if parent
    end

    # suspect
    def formatter
      parent.formatter
    end
  end
end
