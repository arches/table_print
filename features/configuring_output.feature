Feature: Configuring output
  Scenario: Setting a (max? or specific?) width for all columns
  Scenario: Setting a specific width for an individual column
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And table_print Blog, {:include => {:author => {:width => 10}}}
    Then the output should contain
    """
    TITLE | AUTHOR    
    ------------------
    post! | Ryan
    """
  Scenario: Specifying configuration on a per-object basis
  Scenario: Setting a default date format
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
