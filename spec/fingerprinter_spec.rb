require 'spec_helper'
require 'ostruct'
require_relative '../lib/fingerprinter'

class TablePrint::Row
  attr_accessor :groups, :cells
end

include TablePrint

describe Fingerprinter do

  describe "#lift" do
    it "turns a single level of columns into a single row" do
      rows = Fingerprinter.new.lift(["name"], [OpenStruct.new(name: "dale carnegie")])
      rows.length.should == 1
      row = rows.first
      row.groups.length.should == 0
      row.cells.should == {'name' => "dale carnegie"}
    end
  end

  describe "#hash_to_rows" do
    it "uses hashes with empty values as column names" do
      rows = Fingerprinter.new.hash_to_rows("", {'name' => {}}, [OpenStruct.new(name: "dale carnegie")])
      rows.length.should == 1
      row = rows.first
      row.groups.length.should == 0
      row.cells.should == {'name' => 'dale carnegie'}
    end

    it 'recurses for subsequent levels of hash' do
      rows = Fingerprinter.new.hash_to_rows("", {'name' => {}, 'books' => {'title' => {}}}, [OpenStruct.new(name: 'dale carnegie', books: [OpenStruct.new(title: "hallmark")])])
      rows.length.should == 1

      top_row = rows.first
      top_row.cells.should == {'name' => 'dale carnegie'}
      top_row.groups.length.should == 1
      top_row.groups.first.row_count.should == 1

      bottom_row = top_row.groups.first.rows.first
      bottom_row.cells.should == {'books.title' => 'hallmark'}
    end
  end

  describe "#columns_to_handle" do
    it "returns hash keys that have an empty hash as the value" do
      Fingerprinter.new.columns_to_handle({'name' => {}, 'books' => {'title' => {}}}).should == ["name"]
    end
  end

  describe "#columns_to_pass" do
    it "returns hash keys that do not have an empty hash as the value" do
      Fingerprinter.new.columns_to_pass({'name' => {}, 'books' => {'title' => {}}}).should == ["books"]
    end
  end

  describe "#split_into_chain_and_method" do
    it "splits a string in two based on the last period" do
      Fingerprinter.new.split_into_chain_and_method("name").should == ["", "name"]
      Fingerprinter.new.split_into_chain_and_method("books.title").should == ["books", "title"]
      Fingerprinter.new.split_into_chain_and_method("reviews.user.email").should == ["reviews.user", "email"]
    end
  end

  describe "#method_chains" do
    it "returns all but the last part of a column name" do
      Fingerprinter.new.method_chains(["name"]).should == [""]
      Fingerprinter.new.method_chains(["books.title"]).should == ["books"]
      Fingerprinter.new.method_chains(["books.title", "books.publisher"]).should == ["books"]
      Fingerprinter.new.method_chains(["reviews.user.email"]).should == ["reviews.user"]
    end
  end

  describe "#chain_to_nested_hash" do
    it "turns a list of methods into a nested hash" do
      Fingerprinter.new.chain_to_nested_hash("books").should == {'books' => {}}
      Fingerprinter.new.chain_to_nested_hash("reviews.user").should == {'reviews' => {'user' => {}}}
    end
  end

  describe "#columns_to_nested_hash" do
    it "splits the column names into a nested hash" do
      Fingerprinter.new.columns_to_nested_hash(["books.name"]).should == {'books' => {'name' => {}}}
      Fingerprinter.new.columns_to_nested_hash(
          ["books.name", "books.publisher", "reviews.rating", "reviews.user.email", "reviews.user.id"]
      ).should == {'books' => {'name' => {}, 'publisher' => {}}, 'reviews' => {'rating' => {}, 'user' => {'email' => {}, 'id' => {}}}}
    end
  end
end
