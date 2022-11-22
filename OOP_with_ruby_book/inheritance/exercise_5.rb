class Vehicle
  @@total_number_of_vehicles = 0
  
  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @speed = 0
    @@total_number_of_vehicles += 1
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
    puts "You stopped the vehicle and turned it off."
  end
  
  def spray_paint(new_color)
    puts "You spray painted your #{year} #{model} from #{color} to #{new_color}!"
    self.color = new_color
  end
  
  def self.gas_mileage(miles, gallons)
    puts "#{miles / gallons} miles per gallon of gas."
  end
  
  def self.total_number_of_vehicles
    puts "There are #{@@total_number_of_vehicles} vehicles."
  end
  
end

module TruckBedLowerable
  attr_accessor :truck_bed
end

class MyCar < Vehicle
  VEHICLE_TYPE = 'car'
  TRUNK_SPACE = '5 square feet'
  
  def to_s
    "Your #{VEHICLE_TYPE} is a #{color}, #{year}, #{model}."
  end
end


class MyTruck < Vehicle
  VEHICLE_TYPE = 'truck'
  BED_SPACE = '10 square feet'
  
  include TruckBedLowerable
  
  def to_s
    "Your #{VEHICLE_TYPE} is a #{color}, #{year}, #{model}."
  end
end

malibu = MyCar.new(2020, 'gray', 'Chevy Malibu')
tundra = MyTruck.new(2010, 'white', 'Ford Tundra')

malibu.speed_up(20)
malibu.brake(10)
malibu.current_speed
malibu.shut_off
malibu.spray_paint('blue')
MyCar.gas_mileage(351, 13)

tundra.speed_up(25)
tundra.brake(5)
tundra.current_speed
tundra.shut_off
tundra.spray_paint('black')
MyTruck.gas_mileage(351, 13)