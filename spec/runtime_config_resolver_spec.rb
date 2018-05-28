require 'spec_helper'

include TablePrint
describe RuntimeConfigResolver do
  let(:config) { TablePrint::Config.new }

  before(:each) do
    Sandbox.cleanup!
  end
  
  describe "#default_display_methods" do
    it "returns attribute getters" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")

      columns = RuntimeConfigResolver.new(config, Sandbox::Hat.new).columns

      expect(columns.collect(&:name)).to eq(%w{brand})
      expect(columns.collect(&:display_method)).to eq(%w{brand})
    end

    it "ignores dangerous methods" do
      Sandbox.add_class("Hat")
      Sandbox.add_method("Hat", "brand!") {}

      columns = RuntimeConfigResolver.new(config, Sandbox::Hat.new).columns
      expect(columns).to be_empty
    end

    it "ignores methods defined in a superclass" do
      Sandbox.add_class("Hat::Bowler")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_attributes("Hat::Bowler", "brim_width")

      columns = RuntimeConfigResolver.new(config, Sandbox::Hat::Bowler.new).columns

      expect(columns.collect(&:name)).to eq(%w{brim_width})
      expect(columns.collect(&:display_method)).to eq(%w{brim_width})
    end

    it "ignores methods that require arguments" do
      Sandbox.add_class("Hat")
      Sandbox.add_attributes("Hat", "brand")
      Sandbox.add_method("Hat", "tip?") { |person| person.rapscallion? }

      columns = RuntimeConfigResolver.new(config, Sandbox::Hat.new).columns

      expect(columns.collect(&:name)).to eq(%w{brand})
      expect(columns.collect(&:display_method)).to eq(%w{brand})
    end

    it "ignores methods from an included module" do
      pending "waiting for Cat to support module manipulation"
    end

    it "uses column information when available (eg, from ActiveRecord objects)"
    
    it "uses the members method when passed a Struct" do
      test_struct = Struct.new(:foo, :bar)
      obj = test_struct.new
      obj.foo = 1
      obj.bar = 2

      columns = RuntimeConfigResolver.new(config, obj).columns

      expect(columns.collect(&:name).sort).to eq(%w{bar foo})
      expect(columns.collect(&:display_method).sort).to eq(%w{bar foo})
    end
  end

  describe "#columns" do

    it "pulls the column names off the data object" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      columns = RuntimeConfigResolver.new(config, Sandbox::Post.new).columns
      expect(columns.collect(&:name)).to eq(%w{title})
    end

    it 'pull the column names off of the array of Structs' do
      struct = Struct.new(:name, :surname)
      data = struct.new("User 1", "Familyname 1")

      columns = RuntimeConfigResolver.new(config, data).columns

      expect(columns.collect(&:name).sort).to eq(%w{name surname})
    end

    it "doesn't delete klass config using :include options" do
      Sandbox.add_class("Blog")
      config.set(Sandbox::Blog, [{:include => [:title, :author]}])
      expect(config.for(Sandbox::Blog)).to eq([{:include => [:title, :author]}])

      RuntimeConfigResolver.new(config, Sandbox::Blog.new).columns

      expect(config.for(Sandbox::Blog)).to eq([{:include => [:title, :author]}])
    end

    it "doesn't delete klass config using :except options" do
      Sandbox.add_class("Blog")
      config.set(Sandbox::Blog, [{:except => [:title, :author]}])
      expect(config.for(Sandbox::Blog)).to eq([{:except => [:title, :author]}])

      RuntimeConfigResolver.new(config, Sandbox::Blog.new).columns

      expect(config.for(Sandbox::Blog)).to eq([{:except => [:title, :author]}])
    end
    
    context 'when keys are symbols' do
      it "pulls the column names off the array of hashes" do
        data = { :name => "User 1", :surname => "Familyname 1" }

        columns = RuntimeConfigResolver.new(config, data).columns

        expect(columns.collect(&:name).sort).to eq(%w{name surname})
      end
    end

    context 'when keys are strings' do
      it "pulls the column names off the array of hashes" do
        data = { 'name' => "User 1", 'surname' => "Familyname 1" }

        columns = RuntimeConfigResolver.new(config, data).columns

        expect(columns.collect(&:name).sort).to eq(%w{name surname})
      end
    end

    it "pulls out excepted columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title, :author)

      columns = RuntimeConfigResolver.new(config, Sandbox::Post.new, :except => :title).columns

      expect(columns.collect(&:name)).to eq(%w{author})
    end

    it "adds included columns" do
      Sandbox.add_class("Post")
      Sandbox.add_attributes("Post", :title)

      columns = RuntimeConfigResolver.new(config, Sandbox::Post.new, :include => :author).columns

      expect(columns.collect(&:name)).to eq(%w{title author})
    end
  end

  #it "starts with the specified config" do
  #  Sandbox.add_class("Configged")
  #  Config.set(Sandbox::Configged, [:title, :author])
  #  c = RuntimeConfigResolver.new(Object, Object, [:name])
  #  c.columns.length.should == 2
  #  c.columns.first.name.should == 'title'
  #  c.columns.last.name.should == 'author'
  #end

  describe ":only" do
    context "with a symbol" do
      it "returns a column named foo" do
        columns = RuntimeConfigResolver.new(config, Struct.new(:title), :foo).columns

        expect(columns.collect(&:name)).to eq(%w{foo})
      end
    end
    context "with a string" do
      it "returns a column named foo" do
        columns = RuntimeConfigResolver.new(config, Struct.new(:title), 'foo').columns

        expect(columns.collect(&:name)).to eq(%w{foo})
      end
    end
    context "with an array of symbols and strings" do
      it "returns columns named foo and bar" do
        columns = RuntimeConfigResolver.new(config, Struct.new(:title), :foo, 'bar').columns

        expect(columns.collect(&:name)).to eq(%w{foo bar})
      end
    end
  end

  describe ":include" do
    context "with a symbol" do
      it "adds foo to the list of methods" do
        columns = RuntimeConfigResolver.new(config, Object, [:title], :include => :foo).columns

        expect(columns.collect(&:name)).to eq(%w{title foo})
      end
    end

    context "with an array" do
      it "adds foo and bar to the list of methods" do
        columns = RuntimeConfigResolver.new(config, Object, [:title], :include => [:foo, :bar]).columns

        expect(columns.collect(&:name)).to eq(%w{title foo bar})
      end
    end

    context "with options" do
      it "adds foo to the list of methods and remembers its options" do
        columns = RuntimeConfigResolver.new(config, Object, [:title], :include => {:foo => {:fixed_width => 10}}).columns

        expect(columns.collect(&:name)).to eq(%w{title foo})
        columns.last.config.for(:fixed_width).should == 10
      end
    end
  end

  describe ":except" do
    context "with a symbol" do
      it "removes foo from the list of methods" do
        columns = RuntimeConfigResolver.new(config, Object, [:title, :foo], :except => :foo).columns
        expect(columns.collect(&:name)).to eq(%w{title})
      end
    end
    context "with an array" do
      it "removes foo and bar from the list of methods" do
        columns = RuntimeConfigResolver.new(config, Object, [:title, :foo, :bar], :except => [:foo, 'bar']).columns

        expect(columns.collect(&:name)).to eq(%w{title})
      end
    end
  end

  describe "lambdas" do
    it "uses the key as the name and the lambda as the display method" do
      lam = lambda {}
      columns = RuntimeConfigResolver.new(config, Struct.new(:title), :foo => {:display_method => lam}).columns

      expect(columns.collect(&:name)).to eq(%w{foo})
      expect(columns.collect(&:display_method)).to eq([lam])
    end

    context "without the display_method keyword" do
      it "uses the key as the name and the lambda as the display method" do
        lam = lambda {}
        columns = RuntimeConfigResolver.new(config, Struct.new(:title), :foo => lam).columns

        expect(columns.collect(&:name)).to eq(%w{foo})
        expect(columns.collect(&:display_method)).to eq([lam])
      end
    end
  end

  describe "#usable_column_names" do
    it "returns default columns" do
      columns = RuntimeConfigResolver.new(config, Object, [:title]).columns

      expect(columns.collect(&:name)).to eq(%w{title})
    end

    it "returns specified columns instead of default columns" do
      columns = RuntimeConfigResolver.new(config, Struct.new(:title), [:author]).columns

      expect(columns.collect(&:name)).to eq(%w{author})
    end

    it "applies includes on top of default columns" do
      columns = RuntimeConfigResolver.new(config, Object, [:title], [:include => :author]).columns

      expect(columns.collect(&:name)).to eq(%w{title author})
    end

    it "applies includes on top of specified columns" do
      columns = RuntimeConfigResolver.new(config, Struct.new(:title), [:author, {:include => :pub_date}]).columns

      expect(columns.collect(&:name)).to eq(%w{author pub_date})
    end

    it "doesn't double up if a default column is re-specified" do
      columns = RuntimeConfigResolver.new(config, Object, [:title, :author], [:include => :author]).columns

      expect(columns.collect(&:name)).to eq(%w{title author})
    end

    it "applies excepts on top of default columns" do
      columns = RuntimeConfigResolver.new(config, Object, [:title, :author], [:except => :author]).columns

      expect(columns.collect(&:name)).to eq(%w{title})
    end

    it "doesn't double up on intermediary objects" do
      columns = RuntimeConfigResolver.new(config, Object, [:title, :comment], [:include => ["comment.body", "comment.author"]]).columns

      expect(columns.collect(&:name)).to eq(%w{title comment.body comment.author})
    end

    it "applies excepts on top of specified columns" do
      columns = RuntimeConfigResolver.new(config, Struct.new(:title, :author), [:pub_date, :length, {:except => :length}]).columns

      expect(columns.collect(&:name)).to eq(%w{pub_date})
    end

    it "applies both includes and excepts on top of specified columns" do
      columns = RuntimeConfigResolver.new(config, Struct.new(:title, :author), [:pub_date, :length, {:except => :length, :include => :foobar}]).columns

      expect(columns.collect(&:name)).to eq(%w{pub_date foobar})
    end
  end

  describe "column options" do
    context "display_method" do
      it "sets the display method on the column" do
        columns = RuntimeConfigResolver.new(config, Object, [:title], :title => {:display_method => :boofar}).columns

        expect(columns.collect(&:name)).to eq(%w{title})
        expect(columns.collect(&:display_method)).to eq(%w{boofar})
      end
    end

    context "width" do
      it "sets the default width" do
        columns = RuntimeConfigResolver.new(config, Object, [:title], :title => {:fixed_width => 100}).columns

        expect(columns.collect(&:name)).to eq(%w{title})
        expect(columns.first.config).to eq(TablePrint::Config.new(fixed_width: 100))
      end
    end

    context "formatters" do
      it "adds the formatters to the column" do
        f1 = {}
        f2 = {}
        columns = RuntimeConfigResolver.new(config, Object, [:title], :title => {:formatters => [f1, f2]}).columns

        
        expect(columns.collect(&:name)).to eq(%w{title})
        expect(columns.first.config.for(:formatters)).to eq([f1, f2])
      end
    end

    context "display_name" do
      it "sets the display name on the column" do
        columns = RuntimeConfigResolver.new(config, Object, [], :title => {:display_name => "Ti Tle"}).columns

        expect(columns.collect(&:name)).to eq(['Ti Tle'])
        expect(columns.collect(&:display_method)).to eq(%w{title})
      end
    end
  end
end
