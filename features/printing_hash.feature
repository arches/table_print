Feature: Printing hash

  Scenario: A simple array of hashes
    Given a variable named data with
      |title        | author |
      |First post!  | Ryan   |  
      |Second post! | John   |  
      |Third post!  | Peter  |
    And table_print data
    Then the output should contain
    """
    TITLE        | AUTHOR
    ---------------------
    First post!  | Ryan  
    Second post! | John  
    Third post!  | Peter
    """