class Person
  attr_accessor :last_name, :first_name
  
  def initialize(name)
    parse_full_name(name)
  end

  def name
    (self.first_name + ' ' + self.last_name).strip
  end
  
  def name=(name)
    parse_full_name(name)
  end
  
  def to_s
    name
  end
  
  private
  
  def parse_full_name(full_name)
    names = full_name.split(' ')
    if names.size == 1
      self.first_name = full_name
      self.last_name = ''
    else
      self.first_name = names.shift
      self.last_name = names.join(' ')
    end
  end
end


bob = Person.new("Robert Smith")
puts "The person's name is: #{bob}"

#Without a to_s method defined for the Person class, the string interpolation of the bob instance will print out an object ID.