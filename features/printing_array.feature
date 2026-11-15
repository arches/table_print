Feature: Printing arrays

  Scenario: An array of arrays
    Given an array of arrays named data with
      | First post!  | Ryan |
      | Second post! | John |
    When I table_print data
    Then the output should contain
    """
    0            | 1   
    -------------|-----
    First post!  | Ryan
    Second post! | John
    """

  Scenario: Choosing columns by index
    Given an array of arrays named data with
      | First post!  | Ryan |
      | Second post! | John |
    When I table_print data, ["1"]
    Then the output should contain
    """
    1   
    ----
    Ryan
    John
    """
