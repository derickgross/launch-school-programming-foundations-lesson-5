# Exercises: Medium 1.4

class Greeting
  def greet(message)
    puts message
  end
end

class Hello < Greeting
 def hi
  greet("Hello")
 end
end

class Goodbye < Greeting
  def bye
    greet("Goodbye")
  end
end

top_o_the_mornin_to_ya = Hello.new
top_o_the_mornin_to_ya.hi

sayonara = Goodbye.new
sayonara.bye