class Parent
  def say_hi
    p "Hi from Parent."
  end
end

Parent.superclass

class Child < Parent
  def say_hi
    p "Hi from Child."
  end
  
  def instance_of?
    p "I'm a fake instance"
  end
end

c = Child.new
c.instance_of? Child
c.instance_of? Parent