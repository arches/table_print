# column_helpers.rb
#
#  OBJ.from(SRC)      -- set :display_method => SRC
#  OBJ.as(LABEL)      -- set :display_name   => LABEL
#  OBJ.width(W)       -- set :width => W
#  OBJ.formatter(FMT) -- set :formatters => [ FMT ]
#  OBJ.left(W)        -- set :align=>:left, :width=>W
#  OBJ.right(W)       -- set :align=>:right, :width=>W
#  OBJ.center(W)      -- set :align=>:center, :width=>W
#  OBJ.as_num(W)      -- set :width => W, :formatter => [TP_NumFormat]
#  OBJ.as_money(W)    -- set :width => W, :formatter => [TP_MoneyFormat]
#
#  OBJ.as(LABEL).width(w).as_num
#
# where OBJ can be a Symbol, String, or HASH (chained helpers)

module TablePrint::ColumnHelpers

  # tp Object, :building_id.as('Id')
  # tp Object, 'building_id'.as('Id')
  # tp Object, :building_id.width(4).as('Id')

  refine Symbol do ; def as l ; { self => { :display_name => l }}                   ; end ; end
  refine String do ; def as l ; self.intern.as(l)                                   ; end ; end
  refine Hash   do ; def as l ; self.merge_column_attributes! self.keys.first.as(l) ; end ; end

  # tp Object, :name.from(src)
  # tp Object, 'name'.from(src)
  # tp Object, :name.width(30).from(src)

  refine Symbol do ; def from src ; { self => { :display_method => src } }                  ; end ; end
  refine String do ; def from src ; self.intern.from(src)                                   ; end ; end
  refine Hash   do ; def from src ; self.merge_column_attributes! self.keys.first.from(src) ; end ; end

  # tp Object, :name.width(30)
  # tp Object, 'name'.width(30)
  # tp Object, :name.as('Building Name').width(30)

  refine Symbol do ; def width w ; { self => { :width => w } }                            ; end ; end
  refine String do ; def width w ; self.intern.width(w)                                   ; end ; end
  refine Hash   do ; def width w ; self.merge_column_attributes! self.keys.first.width(w) ; end ; end

  # tp Object, :name.left(5)
  # tp Object, 'name'.right(10)
  # tp Object, 'name'.center(20)
  #
  # tp Object, :name.align(:left)
  # tp Object, :name.align(:left, 10)

  refine Symbol do

    def left   w=nil  ; self.align :left,   w ; end
    def right  w=nil  ; self.align :right,  w ; end
    def center w=nil  ; self.align :center, w ; end

    def align how=:left, width=nil
      if width.nil?
        { self => { :align => how } }
      else
        { self => { :align => how, :width => width }}
      end
    end
  end

  refine String do
    def left   w=nil ; self.align :left,   w ; end
    def right  w=nil ; self.align :right,  w ; end
    def center w=nil ; self.align :center, w ; end

    def align how=:left, width=nil
      self.intern.align how, width
    end
  end

  refine Hash do
    def left   w=nil ; self.align :left,   w ; end
    def right  w=nil ; self.align :right,  w ; end
    def center w=nil ; self.align :center, w ; end

    def align how=:left, width=nil
      self.merge_column_attributes! self.keys.first.align(how, width)
    end
  end

  # tp Object, :name.formatter(FMT)
  # tp Object, 'name'.formatter(FMT)
  # tp Object, :name.as('MyName').formatter(FMT)

  refine Symbol do ; def formatter fmt ; { self => { :formatters => Array(fmt) } }                    ; end ; end
  refine String do ; def formatter fmt ; self.intern.formatter fmt                                    ; end ; end
  refine Hash   do ; def formatter fmt ; self.merge_column_attributes! self.keys.first.formatter(fmt) ; end ; end

  # tp Object, :name.as_num(width=nil)
  # tp Object, 'name'.as_num(width=nil)
  # tp Object, :name.as('MyName').as_num(width=nil)

  refine Symbol do ; def as_num w=nil ; self.formatter(TablePrint::NumFormatter.new(w)).width(w) ; end ; end
  refine String do ; def as_num w=nil ; self.intern.as_num w                                     ; end ; end
  refine Hash   do ; def as_num w=nil ; self.merge_column_attributes! self.keys.first.as_num(w)  ; end ; end

  # tp Object, :name.as_money(w=nil)
  # tp Object, 'name'.as_money(w=nil)
  # tp Object, :name.width(20).as_money(w=nil)

  refine Symbol do ; def as_money w=nil ; self.formatter(TablePrint::MoneyFormatter.new(w)).width(w) ; end ; end
  refine String do ; def as_money w=nil ; self.intern.as_money w                                     ; end ; end
  refine Hash   do ; def as_money w=nil ; self.merge_column_attributes! self.keys.first.as_money(w)  ; end ; end

  # merge_column_attributes -- merge a new HASH with the existing attributes
  # hash.

  refine Hash do
    def merge_column_attributes! more
      { self.keys.first => self.values.first.merge(more.values.first) }
    end
  end

end # TablePrint::ColumnHelpers

module TablePrint

  class NumFormatter
    attr_accessor :width
    def initialize width=nil
      @width = width
    end
    def format v
      sprintf "%*d", @width || 4, v.to_i
    end
  end

  class MoneyFormatter
    attr_accessor :width
    def initialize width=nil
      @width = width
    end
    def format v
      sprintf "$%*.2f", @width.nil? ? 0 : @width - 1, v.to_f
    end
  end

end # module TablePrint

# end column_helpers.rb
