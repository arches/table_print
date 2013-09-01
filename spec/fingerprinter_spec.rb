require 'spec_helper'

class TablePrint::Row
  attr_accessor :groups, :cells
end

include TablePrint

describe Fingerprinter do

  before(:each) do
    Sandbox.cleanup!
  end

  describe "#lift" do
    it "turns a single level of columns into a single row" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name")], OpenStruct.new(:name => "dale carnegie"))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 0
      row.cells.should == {'name' => "dale carnegie"}
    end

    it "uses the display_method to get the data" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name of work", :display_method => "title")], OpenStruct.new(:title => "of mice and men"))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 0
      row.cells.should == {'name of work' => "of mice and men"}
    end

    it "turns multiple levels of columns into multiple rows" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name"), Column.new(:name => "books.title")], OpenStruct.new(:name => "dale carnegie", :books => [OpenStruct.new(:title => "how to make influences")]))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 1
      row.cells.should == {'name' => "dale carnegie"}
      row.children.first.children.first.cells.should == {'books.title' => "how to make influences"}
    end

    it "doesn't choke if an association doesn't exist" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name"), Column.new(:name => "books.title")], OpenStruct.new(:name => "dale carnegie", :books => []))

      rows.length.should == 1

      row = rows.first
      row.children.length.should == 0
    end

    it "allows a lambda as the display_method" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name", :display_method => lambda { |row| row.name.gsub(/[aeiou]/, "") })], OpenStruct.new(:name => "dale carnegie"))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 0
      row.cells.should == {'name' => "dl crng"}
    end

    it "doesn't puke if a lambda returns nil" do
      rows = Fingerprinter.new.lift([Column.new(:name => "name", :display_method => lambda { |row| nil })], OpenStruct.new(:name => "dale carnegie"))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 0
      row.cells.should == {'name' => nil}
    end
  end

  describe "#hash_to_rows" do
    it "uses hashes with empty values as column names" do
      f = Fingerprinter.new
      f.instance_variable_set("@column_names_by_display_method", {"name" => "name"})
      rows = f.hash_to_rows("", {'name' => {}}, OpenStruct.new(:name => "dale carnegie"))
      rows.length.should == 1
      row = rows.first
      row.children.length.should == 0
      row.cells.should == {'name' => 'dale carnegie'}
    end

    it 'recurses for subsequent levels of hash' do
      f = Fingerprinter.new
      f.instance_variable_set("@column_names_by_display_method", {"name" => "name", "books.title" => "books.title"})
      rows = f.hash_to_rows("", {'name' => {}, 'books' => {'title' => {}}}, [OpenStruct.new(:name => 'dale carnegie', :books => [OpenStruct.new(:title => "hallmark")])])
      rows.length.should == 1

      top_row = rows.first
      top_row.cells.should == {'name' => 'dale carnegie'}
      top_row.children.length.should == 1
      top_row.children.first.child_count.should == 1

      bottom_row = top_row.children.first.children.first
      bottom_row.cells.should == {'books.title' => 'hallmark'}
    end
  end

  describe "#populate_row" do
    it "fills a row by calling methods on the target object" do
      f = Fingerprinter.new
      f.instance_variable_set("@column_names_by_display_method", {"title" => "title", "author" => "author"})
      row = f.populate_row("", {'title' => {}, 'author' => {}, 'publisher' => {'address' => {}}}, OpenStruct.new(:title => "foobar", :author => "bobby"))
      row.cells.should == {'title' => "foobar", 'author' => 'bobby'}
    end

    it "uses the provided prefix to name the cells" do
      f = Fingerprinter.new
      f.instance_variable_set("@column_names_by_display_method", {"bar.title" => "bar.title", "bar.author" => "bar.author"})
      row = f.populate_row("bar", {'title' => {}, 'author' => {}, 'publisher' => {'address' => {}}}, OpenStruct.new(:title => "foobar", :author => "bobby"))
      row.cells.should == {'bar.title' => "foobar", 'bar.author' => 'bobby'}
    end

    it "uses the column name as the cell name but uses the display method to get the value" do
      f = Fingerprinter.new
      f.instance_variable_set("@column_names_by_display_method", {"bar.title" => "title", "bar.author" => "bar.author"})
      row = f.populate_row("bar", {'title' => {}, 'author' => {}, 'publisher' => {'address' => {}}}, OpenStruct.new(:title => "foobar", :author => "bobby"))
      row.cells.should == {'title' => "foobar", 'bar.author' => 'bobby'}
    end

    context 'using a hash as input_data' do
      it "fills a row by calling methods on the target object" do
        f = Fingerprinter.new
        f.instance_variable_set('@column_names_by_display_method', {'title' => 'title', 'author' => 'author'})
        input_data = {:title => 'foobar', :author => 'bobby'}
        row = f.populate_row('', {'title' => {}, 'author' => {}, 'publisher' => {'address' => {}}}, input_data)
        row.cells.should == {'title' => 'foobar', 'author' => 'bobby'}
      end

      it "fills a row by calling methods on the target object" do
        f = Fingerprinter.new
        f.instance_variable_set('@column_names_by_display_method', {'title' => 'title', 'author' => 'author'})
        input_data = {'title' => 'foobar', 'author' => 'bobby'}
        row = f.populate_row('', {'title' => {}, 'author' => {}, 'publisher' => {'address' => {}}}, input_data)
        row.cells.should == {'title' => 'foobar', 'author' => 'bobby'}
      end
    end

    context "when the method isn't found" do
      it "sets the cell value to an error string" do
        f = Fingerprinter.new
        f.instance_variable_set('@column_names_by_display_method', {'foo' => 'foo'})
        row = f.populate_row('', {'foo' => {}}, Hash.new)
        row.cells.should == {'foo' => 'Method Missing'}
      end
    end
  end

  describe "#create_child_group" do
    it "adds the next level of column information to the prefix" do
      f = Fingerprinter.new
      books = []

      f.should_receive(:hash_to_rows).with("author.books", {'title' => {}}, books).and_return([])
      groups = f.create_child_group("author", {'books' => {'title' => {}}}, OpenStruct.new(:name => "bobby", :books => books))
      groups.length.should == 1
      groups.first.should be_a TablePrint::RowGroup
    end
  end

  describe "#columns_to_handle" do
    it "returns hash keys that have an empty hash as the value" do
      Fingerprinter.new.handleable_columns({'name' => {}, 'books' => {'title' => {}}}).should == ["name"]
    end
  end

  describe "#columns_to_pass" do
    it "returns hash keys that do not have an empty hash as the value" do
      Fingerprinter.new.passable_columns({'name' => {}, 'books' => {'title' => {}}}).should == ["books"]
    end
  end

  describe "#chain_to_nested_hash" do
    it "turns a list of methods into a nested hash" do
      Fingerprinter.new.display_method_to_nested_hash("books").should == {'books' => {}}
      Fingerprinter.new.display_method_to_nested_hash("reviews.user").should == {'reviews' => {'user' => {}}}
    end
  end

  describe "#columns_to_nested_hash" do
    it "splits the column names into a nested hash" do
      Fingerprinter.new.display_methods_to_nested_hash(["books.name"]).should == {'books' => {'name' => {}}}
      Fingerprinter.new.display_methods_to_nested_hash(
          ["books.name", "books.publisher", "reviews.rating", "reviews.user.email", "reviews.user.id"]
      ).should == {'books' => {'name' => {}, 'publisher' => {}}, 'reviews' => {'rating' => {}, 'user' => {'email' => {}, 'id' => {}}}}
    end
  end
end
