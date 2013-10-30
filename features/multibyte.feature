# coding: utf-8

@ruby19
Feature: Fix the column width for multibyte character
  Scenario: A simple array of hashes
    Given a variable named data with
      |title             | author   |
      |これは日本語です。| 山田太郎 |
      |English           | Bob      |
    When I configure multibyte with true
    When I table_print data
    Then the output should contain
    """
    TITLE              | AUTHOR  
    -------------------|---------
    これは日本語です。 | 山田太郎
    English            | Bob     
    """
