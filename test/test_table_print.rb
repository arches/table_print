require 'helper'

class MyClass
  attr_accessor :title, :name, :summary

  def initialize(title, name, summary)
    self.title = title
    self.name = name
    self.summary = summary
  end

  def self.setup
    [["how to", "bert", "bertto"],
     ["enemies", "ernie", "ernieenemies"],
     ["a walk to forget", "big bird", "bigbirdforget"],
     ["cookies", "cookie monster", "cookiemonstercookies"],
     ["your mom", "the count", "thecountmom"],
     ["fire!", "elmo", "elmofire!"],
     ["eat your veggies", "michelle obama", "michelleobamaveggies"],
     ["wakka wakka", "ellen degeneres", "ellendegenereswakka"],
     ["peas and carrots", "the hulk", "thehulkcarrots"],
     ["juan valdez", "camaro", "camaravaldez"],
     ["fish fish fish", "alaska", "alaskafish"],
     ["tracks", "sir toppem hat", "sirtoppemhattracks"],
     ["smoking stacked", "thomas", "thomasstacked"],
     ["cannes", "alpo", "alpocannes"],
    ].collect { |a| MyClass.new(a[0], a[1], a[2]) }
  end
end

class MyNestedClass
  attr_accessor :title, :name, :summary, :captions

  def initialize(title, name, summary, captions)
    self.title = title
    self.name = name
    self.summary = summary
    self.captions = captions.collect{|c| Caption.new(c[:text], c[:photo_url])}
  end

  class Caption
    attr_accessor :text, :photo_url

    def initialize(text, photo_url)
      self.text = text
      self.photo_url = photo_url
    end
  end

  def self.setup
    [["how to", "bert", "bertto", [{:text => "no, really, how to", :photo_url => "http://www.123.com/456.jpg"}]],
     ["enemies", "ernie", "ernieenemies", [{:text => "no, really, enemies", :photo_url => "http://www.234.com/567.jpg"}]],
     ["a walk to forget", "big bird", "bigbirdforget", [{:text => "no, really, a walk to forget", :photo_url => "http://www.345.com/678.jpg"}]],
     ["cookies", "cookie monster", "cookiemonstercookies", [{:text => "no, really, cookies", :photo_url => "http://www.456.com/789.jpg"}]],
     ["your mom", "the count", "thecountmom", [{:text => "no, really, your mom", :photo_url => "http://www.789.com/1011.jpg"}]],
     ["fire!", "elmo", "elmofire!", [{:text => "no, really, fire!", :photo_url => "http://www.8910.com/1112.jpg"}]],
     ["eat your veggies", "michelle obama", "michelleobamaveggies", [{:text => "no, really, eat your veggies", :photo_url => "http://www.91011.com/1213.jpg"}]],
     ["wakka wakka", "ellen degeneres", "ellendegenereswakka", [{:text => "no, really, wakka wakka", :photo_url => "http://www.101112.com/1314.jpg"}]],
     ["peas and carrots", "the hulk", "thehulkcarrots", [{:text => "no, really, peas and carrots", :photo_url => "http://www.abc.com/def.jpg"}]],
     ["juan valdez", "camaro", "camaravaldez", [{:text => "no, really, juan valdez", :photo_url => "http://www.bcd.com/efg.jpg"}]],
     ["fish fish fish", "alaska", "alaskafish", [{:text => "no, really, fish fish fish", :photo_url => "http://www.cde.com/fgh.jpg"}]],
     ["tracks", "sir toppem hat", "sirtoppemhattracks", [{:text => "no, really, tracks", :photo_url => "http://www.def.com/ghi.jpg"}]],
     ["smoking stacked", "thomas", "thomasstacked", [{:text => "no, really, smoking stacked", :photo_url => "http://www.efg.com/hij.jpg"}]],
     ["cannes", "alpo", "alpocannes", [{:text => "no, really, cannes", :photo_url => "http://www.fgh.com/ijk.jpg"}]],
    ].collect { |a| MyNestedClass.new(a[0], a[1], a[2], a[3]) }
  end
end

class TablePrint
  def _get_display_methods(data_obj, options)
    get_display_methods(data_obj, options)
  end

  def _get_default_display_methods(data_obj)
    get_default_display_methods(data_obj)
  end

  def _sort_display_methods(display_methods)
    sort_display_methods(display_methods)
  end
end

class OneMethod
  def title
  end
end

class OneAttrAccessor
  attr_accessor :title
end

class ManyMethods
  def title
  end
  def author
  end
  def summary
  end
end

class StringInheritor < String
  attr_accessor :title
end

class ArrayInheritor < Array
  attr_accessor :title
end

class HashInheritor < Hash
  attr_accessor :title
end

class TestTablePrint < Test::Unit::TestCase

  # TODO: active record tests if defined?(ActiveRecord)

  # Vaguely ordered from most to least granular

  context '' do
    setup do
      @tp = TablePrint.new
      tp MyNestedClass.setup, :only => [:name, :title, "captions.text"]
    end

    context 'Sorting display methods' do
      should 'work properly' do
        assert_equal ["username", {"blogs" => ["title", "summary"]}], @tp._sort_display_methods(["username", "blogs.title", "blogs.summary"])
        assert_equal ["title", "name", "summary", "id"], @tp._sort_display_methods(["title", "name", "summary", "id"])
      end
    end

    context 'The default display methods for ruby base types' do
      should 'be empty' do
        assert_equal [], @tp._get_default_display_methods([])
        assert_equal [], @tp._get_default_display_methods("")
        assert_equal [], @tp._get_default_display_methods({})
        assert_equal [], @tp._get_default_display_methods(10)
        assert_equal [], @tp._get_default_display_methods(1.0)
      end
    end

    context 'The default display methods for a custom class with one method' do
      should 'be that method' do
        assert_equal ["title"], @tp._get_default_display_methods(OneMethod.new)
      end
    end

    context 'The default display methods for a custom class with one attr_accessor' do
      should 'only be the attr setter' do
        assert_equal ["title"], @tp._get_default_display_methods(OneAttrAccessor.new)
      end
      
      context 'that subclasses Hash' do
        should 'only be the attr setter' do
          assert_equal ["title"], @tp._get_default_display_methods(HashInheritor.new)
        end
      end
      context 'that subclasses Array' do
        should 'only be the attr setter' do
          assert_equal ["title"], @tp._get_default_display_methods(ArrayInheritor.new)
        end
      end
      context 'that subclasses String' do
        should 'only be the attr setter' do
          assert_equal ["title"], @tp._get_default_display_methods(StringInheritor.new)
        end
      end
    end

    context 'The display methods for a custom class using the :only option' do
      should 'be an array containing the methods specified in the :only option' do
        assert_equal ["title"], @tp._get_display_methods(ManyMethods.new, {:only => :title})
        assert_equal ["title"], @tp._get_display_methods(ManyMethods.new, {:only => "title"})
        assert_equal ["title"], @tp._get_display_methods(ManyMethods.new, {:only => [:title]})
        assert_equal ["title"], @tp._get_display_methods(ManyMethods.new, {:only => ["title"]})
      end
    end

    # The :include option is more for ActiveRecord. It will only affect custom classes once multi-level methods are implemented.
    context 'The display methods for a custom class using the :include option' do
      should "be the same as if it weren't used" do
        assert_equal ["author", "summary", "title"], @tp._get_display_methods(ManyMethods.new, {:include => :title}).sort
        assert_equal ["author", "summary", "title"], @tp._get_display_methods(ManyMethods.new, {:include => "title"}).sort
        assert_equal ["author", "summary", "title"], @tp._get_display_methods(ManyMethods.new, {:include => [:title]}).sort
        assert_equal ["author", "summary", "title"], @tp._get_display_methods(ManyMethods.new, {:include => ["title"]}).sort
      end
    end

    context 'The display methods for a custom class using the :except option' do
      should "not include any specified methods" do
        assert_equal ["author", "summary"], @tp._get_display_methods(ManyMethods.new, {:except => :title}).sort
        assert_equal ["author", "summary"], @tp._get_display_methods(ManyMethods.new, {:except => "title"}).sort
        assert_equal ["author", "summary"], @tp._get_display_methods(ManyMethods.new, {:except => [:title]}).sort
        assert_equal ["summary"], @tp._get_display_methods(ManyMethods.new, {:except => ["title", :author]}).sort
      end
    end

    context 'An empty input' do
      should 'say as much in the output' do
        assert_equal "No data.", @tp.tp(nil)
        assert_equal "No data.", @tp.tp([])
        assert_equal "No data.", @tp.tp([nil])
      end
    end
  end
end

