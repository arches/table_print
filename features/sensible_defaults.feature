Feature: Sensible defaults

  By default, table_print shows all "getter" methods defined on your object itself. This includes anything except:

  * Methods defined in an object's parent class
  * Methods defined in an object's included modules
  * Methods whose name ends with an equals sign (ie, setter methods)
  * Methods with an arity > 0 (ie, methods that take arguments)

  Scenario: A simple object
    Given a class named Foo
    Given Foo has attributes herp
    Given Foo has a method named derp with lambda{"hurrrrr"}

    Given a class named Foo::Blog
    Given Foo::Blog has attributes title, author
    Given Foo::Blog has a class method named foo with lambda{"just testing!"}
    Given Foo::Blog has a method named two_args with lambda{|a, b| "Called with #{a}, #{b}"}

    When I instantiate a Foo::Blog with {:title => "First post!", :author => 'Ryan'}
    And table_print Foo::Blog
    Then the output should contain
    """
    TITLE       | AUTHOR
    ------------|-------
    First post! | Ryan
    """

  Scenario: An array of objects
    Given a class named Post
    Given Post has attributes title, author
    Given Post has a class method named foo with lambda{"just testing!"}
    Given Post has a method named two_args with lambda{|a, b| "Called with #{a}, #{b}"}

    Given a class named Blog
    Given Blog has attributes posts
    
    When I instantiate a Blog with {:posts => []}
    When I instantiate a Post with {:title => "First post!", :author => 'Ryan'} and add it to blog.posts
    When I instantiate a Post with {:title => "Second post!", :author => 'Ryan'} and add it to blog.posts
    When I instantiate a Post with {:title => "Third post!", :author => 'Ryan'} and add it to blog.posts
    And table_print blog.posts
    Then the output should contain
    """
    TITLE        | AUTHOR
    -------------|-------
    First post!  | Ryan  
    Second post! | Ryan  
    Third post!  | Ryan
    """

  Scenario: Nested objects
    Given a class named Comment
    Given Comment has attributes id, username, body

    Given a class named Blog
    Given Blog has attributes id, comments

    Given I instantiate a Blog with {:id => 1, :comments => []}
    And I instantiate a Comment with {:id => 1, :username => 'chris', :body => 'once upon a time'} and add it to blog.comments
    And I instantiate a Comment with {:id => 2, :username => 'joe', :body => 'once upon a time'} and add it to blog.comments
    When I table_print Blog, [:id, "comments.id", "comments.username"]
    Then the output should contain
    """
    ID | COMMENTS.ID | COMMENTS.USERNAME
    ---|-------------|------------------
    1  | 1           | chris            
       | 2           | joe
    """

  Scenario: An object with column info (like an ActiveRecord object)
    Given a class named ColumnInfo
    Given ColumnInfo has attributes name
    
    Given a class named Blog
    Given Blog has attributes title, author
    Given Blog has a class method named columns with lambda{[Sandbox::ColumnInfo.new(:name => :title)]}

    When I instantiate a Blog with {:title => "First post!", :author => 'Ryan'}
    And table_print Blog
    Then the output should contain
    """
    TITLE      
    -----------
    First post!
    """

  Scenario: An object with field info (like a Mongoid object)
    Given a class named Mongoid

    Given a class named Blog
    Given Blog has attributes title, author
    Given Blog has a method named fields with lambda{{"title" => Sandbox::Mongoid.new}}

    When I instantiate a Blog with {:title => "First post!", :author => 'Ryan'}
    And table_print Blog
    Then the output should contain
    """
    TITLE      
    -----------
    First post!
    """
