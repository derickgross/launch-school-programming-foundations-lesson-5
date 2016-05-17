require 'pry'

class Participant
  attr_accessor :hand

  def busted?
    calculate_hand_value > 21
  end

  def twenty_one?
    calculate_hand_value == 21
  end

  def joinand(array, delimiter=', ', word='and')
    arr = array
    arr[-1] = "#{word} #{arr.last}" if arr.size > 1
    arr.join(delimiter)
  end

  def card_name(card)
    "#{card[1]} of #{card[0]}"
  end

  def named_hand
    named_cards = []
    hand.each do |card|
      named_cards << card_name(card)
    end

    joinand(named_cards)
  end

  def display_hand
    puts "#{name}'s hand is #{named_hand}."
  end

  def calculate_hand_value
    value = 0
    aces = 0
    hand.each do |card|
      aces += 1 if card[1] == "A"
    end

    hand.each do |card|
      value += calculate_card_value(card)
    end
    while (value > 21) && (aces > 0)
      value -= 10
      aces -= 1
    end
    value
  end

  def calculate_card_value(card)
    rank = card[1]
    case
    when ["J", "Q", "K"].include?(rank)
      10
    when rank == "A"
      11
    when *(2..10).include?(rank.to_i)
      rank.to_i
    end
  end

  def display_hand_value
    puts "#{name}'s hand value is #{calculate_hand_value}."
  end

  def display_hand_and_hand_value
    puts "#{name}'s hand is #{named_hand}, with a value of #{calculate_hand_value}."
  end

  def hit(card)
    hand << card
  end

  def game_over?
    busted? || twenty_one?
  end
end

class Player < Participant
  attr_accessor :name

  def initialize
    @hand = []
    @hitting = true
    @name = set_name
  end

  def set_name
    system "clear"
    name = ''
    loop do
      puts "What's your name?"
      name = gets.chomp
      break unless name.empty?
      puts "Sorry, must enter a value."
    end
    self.name = name
  end

  def hit_or_stay
    answer = ""
    loop do
      puts "Would you like to hit or stay?"
      answer = gets.chomp
      break if answer == "hit" || answer == "stay"
      puts "That is not a valid response.  Please type hit or stay."
    end
    answer
  end
end

class Dealer < Participant
  attr_accessor :name
  OPPONENTS = ["The Lone Stranger", "Tommy Two-Sleeves", "Cat Thievens", "The Heiress", "Fat Stacks McGee", "Bux McMillions", "Millie Ann Cashington", "Josh from college"]

  def initialize
    @hand = []
    @active_turn = false
    @name = OPPONENTS.sample
  end

  def display_initial_hand
    puts "#{name} shows #{card_name(hand[0])}.  The second card is face down."
  end
end

class Deck
  attr_accessor :cards

  RANKS = *(2..10).map(&:to_s) + ["J", "Q", "K", "A"]
  SUITS = ["Spades", "Hearts", "Diamonds", "Clubs"]

  def initialize
    @cards = SUITS.product(RANKS).shuffle!
  end

  def deal
    cards.pop
  end
end

class Game
  attr_accessor :deck, :human, :computer

  def start
    @deck = Deck.new
    @human = Player.new
    welcome_message
    play
    goodbye_message
  end

  def play
    loop do
      @computer = Dealer.new
      deal_initial_cards
      show_initial_cards
      player_turn unless human.game_over? || computer.game_over?
      display_player_turn_results
      dealer_turn unless human.game_over?
      show_result
      play_again? ? reset : break
    end
  end

  def welcome_message
    system "clear"
    puts "Welcome to Twenty-One!"
  end

  def goodbye_message
    puts "Thanks for playing Twenty-One!  Goodbye!"
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include? answer
      puts "Sorry, must be y or n."
    end

    answer == 'y'
  end

  def reset
    system "clear"
    self.deck = Deck.new
    human.hand = []
    computer.hand = []
  end

  def deal_initial_cards
    2.times do
      human.hit(deck.deal)
    end

    2.times do
      computer.hit(deck.deal)
    end
  end

  def show_initial_cards
    human.display_hand
    computer.display_initial_hand
  end

  def player_turn
    human.display_hand_value
    while !human.game_over? && human.hit_or_stay == "hit"
      player_hits
    end
  end

  def player_hits
    human.hit(deck.deal)
    puts "You chose to hit, and were dealt the #{human.card_name(human.hand.last)}."
    human.display_hand_value
  end

  def display_player_turn_results
    system "clear"
    human.display_hand_and_hand_value
    puts "You busted!  #{computer.name} wins." if human.busted?
    puts "Twenty-One!  You win!" if human.twenty_one?
  end

  def dealer_hand_value_target
    target = 17
    target = human.calculate_hand_value if human.calculate_hand_value > 17
    target
  end

  def dealer_turn
    computer.display_hand_and_hand_value
    while computer.calculate_hand_value < dealer_hand_value_target
      dealer_hits
    end
  end

  def dealer_hits
    system "clear"
    computer.hit(deck.deal)
    puts "#{computer.name} chose to hit, and was dealt the #{computer.card_name(computer.hand.last)}."
    computer.display_hand_and_hand_value
    sleep 3
  end

  def show_result
    if dealer_busts_condition
      puts "#{computer.name} busts!  You win!"
    elsif player_wins_condition
      puts "You win!"
    elsif tie_condition
      puts "It's a tie!"
    else
      puts "#{computer.name} wins."
    end
  end

  def dealer_busts_condition
    computer.calculate_hand_value > 21
  end

  def player_wins_condition
    human.calculate_hand_value > computer.calculate_hand_value && human.calculate_hand_value <= 21
  end

  def tie_condition
    human.calculate_hand_value == computer.calculate_hand_value
  end
end

Game.new.start
