# Exercises: Easy 3.4

class Cat
  attr_reader :type
  def initialize(type)
    @type = type
  end

  def to_s
    puts "I am a #{type} cat"
  end
end

gertrude = Cat.new("tabby")
gertrude.to_s