Feature: Printing hash

  Scenario: A simple array of hashes
    Given a variable named data with
      |title        | author |
      |First post!  | Ryan   |  
      |Second post! | John   |  
      |Third post!  | Peter  |
    When I table_print data
    Then the output should contain
    """
    TITLE        | AUTHOR
    -------------|-------
    First post!  | Ryan  
    Second post! | John  
    Third post!  | Peter
    """

  Scenario: A lambda column
    Given a variable named data with
      |title        | author |
      |First post!  | Ryan   |  
      |Second post! | John   |  
      |Third post!  | Peter  |
    When I table_print data, [:include => {:two => lambda{|hash| hash[:author]*2}}]
    Then the output should contain
    """
    TITLE        | AUTHOR | TWO       
    -------------|--------|-----------
    First post!  | Ryan   | RyanRyan  
    Second post! | John   | JohnJohn  
    Third post!  | Peter  | PeterPeter
    """

  Scenario: A method on the object
    Given a variable named data with
      |title        | author |
      |First post!  | Ryan   |  
      |Second post! | John   |  
      |Third post!  | Peter  |
    When I table_print data, [:include => :size]
    Then the output should contain
    """
    TITLE        | AUTHOR | SIZE
    -------------|--------|-----
    First post!  | Ryan   | 2   
    Second post! | John   | 2   
    Third post!  | Peter  | 2   
    """


