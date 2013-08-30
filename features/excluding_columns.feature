Feature: Excluding columns
  Scenario: With the :except option
    Given a class named Blog

    Given Blog has attributes title, author

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan'}
    And table_print Blog, {:except => :title}
    Then the output should contain
    """
    AUTHOR
    ------
    Ryan
    """

  Scenario: By specifying columns
    Given a class named Blog

    Given Blog has attributes title, author, url

    When I instantiate a Blog with {:title => "post!", :author => 'Ryan', :url => "http://google.com"}
    And table_print Blog, [:author, :url]
    Then the output should contain
    """
    AUTHOR | URL              
    -------|------------------
    Ryan   | http://google.com
    """
