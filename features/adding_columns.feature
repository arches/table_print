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
    And table_print Foo, {:include => ["blog.author", "blog.title"]}
    Then the output should contain
    """
    HERP | BLOG.AUTHOR | BLOG.TITLE
    -----|-------------|-----------
    derp | Ryan        | post!
    """

  Scenario: Providing a named proc
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And table_print Blog, {:wombat => {:display_method => lambda{|blog| blog.author.gsub(/[aeiou]/, "").downcase}}}
    Then the output should contain
    """
    WOMBAT
    ------
    ryn
    """
  Scenario: Providing a named proc without saying 'display_method', eg :foo => lambda{}
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And table_print Blog, {:wombat => lambda{|blog| blog.author.gsub(/[aeiou]/, "").downcase}}
    Then the output should contain
    """
    WOMBAT
    ------
    ryn
    """
  Scenario: Using a proc as a filter (ie, overriding an existing column with a proc)

