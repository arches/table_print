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

