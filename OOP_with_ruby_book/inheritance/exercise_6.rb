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
  
  def age
    "Your #{self.model} is #{years_old} years old."
  end
  
  private
  
  def years_old
    Time.new.year - self.year.to_i
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

puts malibu.age