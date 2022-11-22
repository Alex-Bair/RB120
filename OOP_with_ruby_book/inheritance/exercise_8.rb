=begin
The issue with the original code was that the #hi method is a private method, meaning it cannot be called from outside of the instance/object.

To fix this I would either move the #hi method to be a public method in the class definition or I would move the required functionality from the #hi method to a different public method.
=end


class Person
  
  def hi
    puts "Hi there!"
  end
end

bob = Person.new
bob.hi