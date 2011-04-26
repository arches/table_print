require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'table_print'

class Test::Unit::TestCase
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
