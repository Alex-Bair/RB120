class Person
  attr_accessor :last_name, :first_name
  
  def initialize(first_name='', last_name='')
    @first_name = first_name
    @last_name = last_name
  end
  
  def name
    @name = [self.first_name, self.last_name].join(' ').strip
  end
end

bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'