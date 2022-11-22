class MyCar
  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
  end
  
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
malibu.speed_up(20)
malibu.current_speed
malibu.speed_up(20)
malibu.current_speed
malibu.brake(20)
malibu.current_speed
malibu.brake(10)
malibu.current_speed
malibu.shut_off
malibu.current_speed