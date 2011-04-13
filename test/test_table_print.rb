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

class TablePrint
  def _get_display_methods(data_obj, options)
    get_display_methods(data_obj, options)
  end

  def _get_default_display_methods(data_obj)
    get_default_display_methods(data_obj)
  end

  def _clean_display_methods(data_obj, display_methods)
    clean_display_methods(data_obj, display_methods)
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

class TestTablePrint < Test::Unit::TestCase

  # TODO: active record tests if defined?(ActiveRecord)

  # Vaguely ordered from most to least granular

  context '' do
    setup do
      @tp = TablePrint.new
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

    context 'The clean_display_methods function' do
      should 'only give back valid methods' do
        assert_equal [], @tp._clean_display_methods(ManyMethods.new, [""])
        assert_equal [], @tp._clean_display_methods(ManyMethods.new, [nil])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, ["title"])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, [:title])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, ["title", "title"])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, ["title", :title])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, [:title, :title])
        assert_equal ["title"], @tp._clean_display_methods(ManyMethods.new, ["title", "january1985"])
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
