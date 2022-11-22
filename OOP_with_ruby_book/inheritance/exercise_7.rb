class Student
  def initialize(name, grade)
    @name = name
    @grade = grade
  end
  
  def better_grade_than?(other_person)
    self.grade > other_person.grade
  end
  
  protected
  
  def grade
    @grade
  end
end

joe = Student.new('Joe', 95)
bob = Student.new('Bob', 85)

puts "Well done!" if joe.better_grade_than?(bob)