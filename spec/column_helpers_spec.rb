require 'spec_helper'

include TablePrint

using TablePrint::ColumnHelpers

describe TablePrint::ColumnHelpers do

  context "when using the .as helper" do
    it "works on symbol names, and returns the hash with :display_name" do
      :field.as('Field Name').should ==
        { :field => { :display_name => 'Field Name' } }
    end
    it "works on strings, returning the hash with the :display_name" do
      'field'.as('Field Name').should ==
        { :field => { :display_name => 'Field Name' } }
    end
    it "works on hashes, returning the merged hash with the :display_name" do
      :field.width(10).as('Field Name').should ==
        { :field => { :width => 10, :display_name => 'Field Name' } }
    end
  end

  context "when using the .from helper" do
    it "works on symbol names, and returns the hash with :display_method" do
      :field.from('some_other_field').should ==
        { :field => { :display_method => 'some_other_field' }}
    end
    it "works on string names and returns the hash with :display_method" do
      'field'.from('some_other_field').should ==
        { :field => { :display_method => 'some_other_field' }}
    end
    it "works on hashes and returns the merged hash with :display_method" do
      :field.as('Field Name').from('some_other_field').should ==
        { :field => { :display_name => 'Field Name', :display_method => 'some_other_field' }}
    end
  end

  context "when using the .width helper" do
    it "works on symbol names, and returns the hash with :width set" do
      :field.width(10).should == { :field => { :width => 10 } }
    end
    it "works on string names and returns the hash with the :width set" do
      'field'.width(10).should == { :field => { :width => 10 } }
    end
    it "works on hashes and returns the merged hash with the :width set" do
      :field.as('Field Name').width(10) ==
        { :field => { :display_name => 'Field Name', :width => 10 } }
    end
  end

  context "when using the :align helpers without a width spec" do
    it ":left returns the hash with :align set to :left" do
      :field.left.should             == { :field => {               :align => :left }}
      'field'.left.should            == { :field => {               :align => :left }}
      :field.width(10).left.should   == { :field => { :width => 10, :align => :left }}
    end
    it ":right returns the hash with :align set to :right" do
      :field.right.should            == { :field => {               :align => :right }}
      'field'.right.should           == { :field => {               :align => :right }}
      :field.width(10).right.should  == { :field => { :width => 10, :align => :right }}
    end
    it ":center returns the hash with :align set to :center" do
      :field.center.should           == { :field => {               :align => :center }}
      'field'.center.should          == { :field => {               :align => :center }}
      :field.width(10).center.should == { :field => { :width => 10, :align => :center }}
    end
  end

  context "when using the :align helpers with a width spec" do
    it ":left returns the hash with both :align and :width set" do
      :field.left(8).should              == { :field => {                         :align => :left, :width => 8 }}
      'field'.left(9).should             == { :field => {                         :align => :left, :width => 9 }}
      :field.as('foo').left(10).should   == { :field => { :display_name => 'foo', :align => :left, :width => 10 }}
    end
    it ":right returns the hash with both :align and :width set" do
      :field.right(8).should             == { :field => {                         :align => :right, :width => 8 }}
      'field'.right(9).should            == { :field => {                         :align => :right, :width => 9 }}
      :field.as('bar').right(10).should  == { :field => { :display_name => 'bar', :align => :right, :width => 10 }}
    end
    it ":center returns the hash with both :align and :width set" do
      :field.center(8).should            == { :field => {                         :align => :center, :width => 8 }}
      'field'.center(9).should           == { :field => {                         :align => :center, :width => 9 }}
      :field.as('baz').center(10).should == { :field => { :display_name => 'baz', :align => :center, :width => 10 }}
    end
  end

  context "when using the .as_num helper without a width spec" do
    it "sets the column spec hash with a custom formatter for numbers" do
      f = :field.as_num
      fmt = f[:field][:formatters].first
      fmt.to_s.should =~ /TablePrint::NumFormatter/
    end
    it "formats numbers with a default width of 4" do
      f = :field.as_num
      fmt = f[:field][:formatters].first
      fmt.format(123).should == ' 123'
    end
  end

  context "when using the .as_num helper with a width spec" do
    it "sets the column spec hash with the NumFormatter and the width spec" do
      f = :field.as_num(10)
      fmt = f[:field][:formatters].first
      fmt.to_s.should =~ /TablePrint::NumFormatter/
      f[:field][:width].should == 10
      fmt.format(123).should == '       123'
    end
  end

  context "when using the .as_money helper without a width spec" do
    it "sets the column spec hash with a custom formatter for money" do
      f = :field.as_money
      fmt = f[:field][:formatters].first
      fmt.to_s.should =~ /TablePrint::MoneyFormatter/
      fmt.format(123.45).should == '$123.45'
    end
  end

  context "when using the .as_money helper with a width spec" do
    it "sets the column spec hash with the MoneyFormatter and the width spec" do
      f = :field.as_money(10)
      fmt = f[:field][:formatters].first
      fmt.to_s.should =~ /TablePrint::MoneyFormatter/
      f[:field][:width].should == 10
      fmt.format(123.45).should == '$   123.45'
    end
  end

end
