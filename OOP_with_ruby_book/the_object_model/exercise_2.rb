=begin

A module is a group of reusable code, including methods. Modules exist in order to allow common methods to be used in multiple classes.

A module is used within a class by invoking the `include` method, like below.

=end

module CommonMethods
  def test_method
    puts 'This is a test!'
  end
end

class MyClass
  include CommonMethods
end

test_obj = MyClass.new
test_obj.test_method