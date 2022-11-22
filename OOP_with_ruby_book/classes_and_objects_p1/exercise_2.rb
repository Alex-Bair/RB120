class MyCar

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end
  
  attr_accessor :color
  attr_reader :year, :model
  
  def speed_up(increase)
    @speed += increase
    puts "You press the gas pedal and accelerate #{increase} mph."
  end
  
  def brake(decrease)
    @speed -= decrease
    puts "You press the brake and decelerate #{decrease} mph."
  end
  
  def current_speed
    puts "You are now going #{@speed} mph."
  end
  
  def shut_off
    @speed = 0
    puts "You stopped the car and turned it off."
  end
end

malibu = MyCar.new(2020, 'gray', 'Chevy Malibu')

puts malibu.color
malibu.color = 'blue'
puts malibu.color