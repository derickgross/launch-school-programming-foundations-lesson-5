# Exercises: Easy 1.2

module Speed
  def go_fast
    puts "I am a #{self.class} and going super fast!"
  end
end

class Car
  include Speed

  def go_slow
    puts "I am safe and driving slow."
  end
end

class Truck
  include Speed

  def go_very_slow
    puts "I am a heavy truck and like going very slow."
  end
end

nissan = Truck.new

#puts Car.methods#

#puts Truck.methods

p nissan.methods.include? :go_fast

puts nissan.go_fast