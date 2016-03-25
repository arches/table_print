Feature: Configuring output
  Scenario: Setting a (max? or specific?) width for all columns
  Scenario: Setting a specific width for an individual column
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ryan'}
    And table_print Blog, {:include => {:author => {:width => 40}}}
    Then the output should contain
    """
    TITLE | AUTHOR                                  
    ------|-----------------------------------------
    post! | Ryan Ryan Ryan Ryan Ryan Ryan Ryan Ry... 
    """

  Scenario: Setting a minimum width for an individual column
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan Ryan'}
    And table_print Blog, {:include => {:author => {:min_width => 40}}}
    Then the output should contain
    """
    TITLE | AUTHOR
    ------|-----------------------------------------
    post! | Ryan Ryan
    """

  Scenario: Setting a fixed width for an individual column, when data width is greater than fixed width
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan Ryan Ryan Ryan Ryan Ryan Ryan'}
    And table_print Blog, {:include => {:author => {:fixed_width => 15}}}
    Then the output should contain
    """
    TITLE | AUTHOR
    ------|----------------
    post! | Ryan Ryan Ry...
    """

  Scenario: Setting a fixed width for an individual column, when data width is less than fixed width
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan Ryan'}
    And table_print Blog, {:include => {:author => {:fixed_width => 15}}}
    Then the output should contain
    """
    TITLE | AUTHOR
    ------|----------------
    post! | Ryan Ryan                                
    """

  Scenario: Specifying configuration on a per-object basis
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And configure Blog with :title
    And table_print Blog
    Then the output should contain
    """
    TITLE
    -----
    post!
    """
  Scenario: Specifying configuration on a per-object basis with an included column
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And configure Blog with {:include => {:foobar => lambda{|b| b.title}}}
    And table_print Blog
    Then the output should contain
    """
    TITLE | AUTHOR | FOOBAR
    ------|--------|-------
    post! | Ryan   | post!
    """
  Scenario: Applying a formatter
  Scenario: Setting a column name
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And table_print Blog, {:wombat => {:display_method => :author}}
    Then the output should contain
    """
    WOMBAT
    ------
    Ryan
    """

  Scenario: Setting a lowercase column name
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And I configure capitalize_headers with false
    And table_print Blog, {:author => {:display_name => "Wom Bat"}}
    Then the output should contain
    """
    Wom Bat
    -------
    Ryan
    """

  Scenario: Setting the column separator
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And I configure separator with ','
    And table_print Blog
    Then the output should contain
    """
    TITLE , AUTHOR
    ------,-------
    post! , Ryan
    """
