# Exercises: Medium 1.5

class KrispyKreme
  attr_reader :filling_type, :glazing
  def initialize(filling_type, glazing)
    @filling_type = filling_type
    @glazing = glazing
  end

  def to_s
    if (@glazing != nil) && (@filling_type != nil)
      "#{self.filling_type} with #{self.glazing}"
    elsif (@glazing == nil) && (@filling_type != nil)
      "#{filling_type}"
    elsif (@glazing != nil) && (@filling_type == nil)
      "Plain with #{glazing}"
    else
      "Plain"
    end
  end
end

donut1 = KrispyKreme.new(nil, nil)
donut2 = KrispyKreme.new("Vanilla", nil)
donut3 = KrispyKreme.new(nil, "sugar")
donut4 = KrispyKreme.new(nil, "chocolate sprinkles")
donut5 = KrispyKreme.new("Custard", "icing")

puts donut1

puts donut2

puts donut3

puts donut4

puts donut5