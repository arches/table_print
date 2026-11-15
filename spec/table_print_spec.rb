require 'spec_helper'
require 'table_print'

include TablePrint

describe TablePrint::Printer do
  before(:each) do
    Sandbox.cleanup!
  end

  describe "printing an empty array" do
    it "returns the string 'no data'" do
      p = Printer.new([])
      expect(p.table_print).to eq 'No data.'
    end
  end

  describe "printing strings" do
    it "prints the strings without modifying them" do
      data = ["hello".dup, "world".dup]
      expect(Printer.new(data).table_print).to eq "VALUE\n-----\nhello\nworld"
      expect(data).to eq ["hello", "world"]
    end

    it "prints strings nested in arrays without modifying them" do
      data = [["hello".dup, "world".dup]]
      expect(Printer.new(data).table_print).to eq "0     | 1    \n------|------\nhello | world"
      expect(data).to eq [["hello", "world"]]
    end
  end

  describe "printing a hash with keys that aren't strings or symbols" do
    it "finds the values anyway" do
      expect(Printer.new([{1 => "one", 2 => "two"}]).table_print).to eq "1   | 2  \n----|----\none | two"
    end

    it "leaves string and symbol keyed rows untouched, subclass and all" do
      # A hash subclass gets clobbered by the transform_keys, which we would prefer to avoid when we can
      indifferent = Class.new(Hash) do
        def [](key)
          super(key.to_s)
        end
      end
      row = indifferent.new
      row["author"] = "ryan"

      # a lambda column gets the row as it was handed to us, so its own lookup still works
      expect(Printer.new([row], [{:include => {:two => lambda { |r| r[:author] * 2 }}}]).table_print).to eq(
        "AUTHOR | TWO     \n-------|---------\nryan   | ryanryan"
      )
    end
  end

  describe "several columns named in one options hash" do
    it "applies each one to hash data" do
      rows = [{ :title => "First post!", :author => "Ryan" }]

      expect(Printer.new(rows, [{ :title => { :max_width => 6 }, :author => { :min_width => 8 } }]).table_print).to eq(
        "TITLE  | AUTHOR  \n-------|---------\nFir... | Ryan    "
      )
    end

    it "picks and sizes grid columns by index" do
      rows = [[1, "alice", true], [2, "bob", false]]

      expect(Printer.new(rows, [{ "0" => {}, "2" => {} }]).table_print).to eq(
        "0 | 2    \n--|------\n1 | true \n2 | false"
      )
    end
  end

  describe "printing an array of arrays" do
    it "prints one row per inner array, with the positions as columns" do
      expect(Printer.new([[1, "alice"], [2, "bob"]]).table_print).to eq "0 | 1    \n--|------\n1 | alice\n2 | bob  "
    end

    it "takes its columns from the first row" do
      # the short row has no cell for column 1; the long row's third cell is not shown
      expect(Printer.new([["a", "b"], ["c"], ["d", "e", "f"]]).table_print).to eq(
        "0 | 1             \n--|---------------\na | b             \nc | Method Missing\nd | e             "
      )
    end

    it "lets you address the columns by index" do
      expect(Printer.new([[1, "alice"], [2, "bob"]], ["1"]).table_print).to eq "1    \n-----\nalice\nbob  "
      expect(Printer.new([[1, "alice"], [2, "bob"]], [{:except => "0"}]).table_print).to eq "1    \n-----\nalice\nbob  "
    end
  end

  describe "printing a hash" do
    it "prints the hash as one row with its keys as columns" do
      data = {"host" => "db.internal", "user" => "app"}
      expect(Printer.new(data).table_print).to eq "HOST        | USER\n------------|-----\ndb.internal | app "
    end
  end

  describe "printing an object where there are only association columns with no data" do
    it "returns the string 'no data'" do
      Sandbox.add_class("Blog")
      Sandbox.add_attributes("Blog", :author)
      p = Printer.new(Sandbox::Blog.new, "author.name")
      expect(p.table_print).to eq 'No data.'
    end
  end

  describe "unreachable cells" do
    it "shows the configured value" do
      TablePrint::Config.set(:unreachable_value, ["n/a"])

      expect(Printer.new([{ :a => 1 }, { :b => 2 }]).table_print).to eq "A  \n---\n1  \nn/a"
    ensure
      TablePrint::Config.clear(:unreachable_value)
    end

    it "leaves the cell blank when the value is nil, keeping the column" do
      TablePrint::Config.set(:unreachable_value, [nil])

      # one trailing space: the column is still there, the cell is just empty
      expect(Printer.new([{ :a => 1 }, { :b => 2 }]).table_print).to eq "A\n-\n1\n "
    ensure
      TablePrint::Config.clear(:unreachable_value)
    end
  end

  describe "a class-level config" do
    it "survives being printed more than once" do
      Sandbox.add_class("Blog")
      Sandbox.add_attributes("Blog", :title, :author)
      blogs = [Sandbox::Blog.new(:title => "First post!", :author => "Ryan")]

      tp.set Sandbox::Blog, :except => :title

      # resolving the options used to consume them, so the second print ignored the config
      expect(Printer.new(blogs).table_print).to eq "AUTHOR\n------\nRyan  "
      expect(Printer.new(blogs).table_print).to eq "AUTHOR\n------\nRyan  "
    ensure
      tp.clear Sandbox::Blog
    end
  end

  describe "message" do
    it "defaults to the time the print took, but in string" do
      message = Printer.new([]).message
      expect(message).to be_a String
      expect(message.to_f.to_s).to eq(message)
    end

    it "shows a warning if the printed objects have config" do
      Sandbox.add_class("User")

      tp.set Sandbox::User, :id, :email
      p = Printer.new(Sandbox::User.new)
      expect(p.message).to eq "Printed with config"
    end
  end

  describe "#columns" do

    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new)
      cols = p.send(:columns)
      expect(cols.length).to eq 1
      expect(cols.first.name).to eq 'title'
    end

    it 'pull the column names off of the array of Structs' do
      struct = Struct.new(:name, :surname)
      data = [struct.new("User 1", "Familyname 1"), struct.new("User 2", "Familyname 2")]
      p = Printer.new(data)
      cols = p.send(:columns)
      expect(cols.length).to eq 2
      expect(cols.collect(&:name).sort).to eq ['name', 'surname']
    end
    
    context 'when keys are symbols' do
      it "pulls the column names off the array of hashes" do
        data = [{:name => "User 1",
                  :surname => "Familyname 1"
                },
                {:name => "User 2",
                  :surname => "Familyname 2"}]

        p = Printer.new(data)
        cols = p.send(:columns)
        expect(cols.length).to eq 2
        expect(cols.collect(&:name).sort).to eq ['name', 'surname']
      end
    end

    context 'when keys are strings' do
      it "pulls the column names off the array of hashes" do
        data = [{'name' => "User 1",
                  'surname' => "Familyname 1"
                },
                {'name' => "User 2",
                  'surname' => "Familyname 2"}]

        p = Printer.new(data)
        cols = p.send(:columns)
        expect(cols.length).to eq 2
        expect(cols.collect(&:name).sort).to eq ['name', 'surname']
      end
    end

    it "pulls out excepted columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      p = Printer.new(Sandbox::Post.new, :except => :title)
      cols = p.send(:columns)
      expect(cols.length).to eq 1
      expect(cols.first.name).to eq 'author'
    end

    it "adds included columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      p = Printer.new(Sandbox::Post.new, :include => :author)
      cols = p.send(:columns)
      expect(cols.length).to eq 2
      expect(cols.first.name).to eq 'title'
      expect(cols.last.name).to eq 'author'
    end
  end
end
