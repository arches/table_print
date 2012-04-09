Feature: Sensible defaults

  By default, table_print shows all "getter" methods defined on your object itself. This includes anything except:

  * Methods defined in an object's parent class
  * Methods defined in an object's included modules
  * Methods whose name ends with an equals sign (ie, setter methods)
  * Methods with an arity > 0 (ie, methods that take arguments)

  Scenario: A simple object
    Given a class named Foo
    Given Foo has attributes herp
    Given Foo has a method named derp with lambda{"hurrrrr"}

    Given a class named Foo::Blog
    Given Foo::Blog has attributes title, author
    Given Foo::Blog has a class method named foo with lambda{"just testing!"}
    Given Foo::Blog has a method named two_args with lambda{|a, b| "Called with #{a}, #{b}"}

    When I instantiate a Foo::Blog with {title: "First post!", author: 'Ryan'}
    And table_print Foo::Blog
    Then the output should contain
    """
    TITLE       | AUTHOR
    --------------------
    First post! | Ryan
    """

#  Scenario: A nested object
#    Given a class named Comment
#    Given Comment has attributes id, username, body
#
#    Given a class named Blog
#    Given Blog has attributes id, comments
#
#    Given I instantiate a Blog with {id: 1, comments: []}
#    And I instantiate a Comment with {id: 1, username: 'chris', body: 'once upon a time'} and add it to blog.comments
#    When I table_print
#    Then the output should contain
#    """
#    TODO: review this output string
#    ID | COMMENTS
#    -------------
#    1  | [#<Comment:0x007fb4f38e89d8 @id=1, @username="chris", @body="once upon a time">]
#    """
#
#  Scenario: An object with column info (like an ActiveRecord object)
