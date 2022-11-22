=begin
We get the the undefined method `name=` error because no setter method was created in the Person class for the name attribute.

In order to have both a getter and setter method for the `name` attribute, the attr_reader on line 2 should be attr_accessor instead.
=end

class Person
  attr_accessor :name
  def initialize(name)
    @name = name
  end
end

bob = Person.new("Steve")
bob.name = "Bob"