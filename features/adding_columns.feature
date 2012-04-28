Feature: Adding columns
  Scenario: With the :include option
    Given a class named Foo
    Given Foo has attributes herp, blog

    Given a class named Foo::Blog
    Given Foo::Blog has attributes title, author
    Given Foo::Blog has a class method named foo with lambda{"just testing!"}
    Given Foo::Blog has a method named two_args with lambda{|a, b| "Called with #{a}, #{b}"}

    When I instantiate a Foo with {:herp => "derp"}
    When I instantiate a Foo::Blog with {:title => "post!", :author => 'Ryan'} and assign it to foo.blog
    And table_print Foo, {:include => "blog.title"}
    Then the output should contain
    """
    BLOG.TITLE | HERP
    -----------------
    post!      | derp
    """

  Scenario: Specifying a method name as a string
  Scenario: Specifying a method name as a symbol
#  Scenario: Traversing associations
#    Given a class named Foo
#    Given Foo has attributes herp, blog
#
#    Given a class named Foo::Blog
#    Given Foo::Blog has attributes title, author
#    Given Foo::Blog has a class method named foo with lambda{"just testing!"}
#    Given Foo::Blog has a method named two_args with lambda{|a, b| "Called with #{a}, #{b}"}
#    Given Foo::Blog has a method named to_s with lambda{"blog"}
#
#    When I instantiate a Foo with {:herp => "derp"}
#    When I instantiate a Foo::Blog with {:title => "post!", :author => 'Ryan'} and assign it to foo.blog
#    And table_print Foo, "blog.title"
#    Then the output should contain
#    """
#    BLOG.TITLE
#    ----------
#    post!
#    """

  Scenario: Providing a proc
  Scenario: Providing a named proc
  Scenario: Using a proc as a filter (ie, overriding an existing column with a proc)

