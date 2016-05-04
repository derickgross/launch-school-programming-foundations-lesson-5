require 'pry'

module Joinable
  def joinor(array, delimiter=', ', word='or')
    arr = array
    arr[-1] = "#{word} #{arr.last}" if arr.size > 1
    arr.join(delimiter)
  end
end

class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]] # diagonals
  def initialize
    @squares = {}
    reset
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?(human_marker, computer_marker)
    !!winning_marker(human_marker, computer_marker)
  end

  def count_human_marker(squares, human_marker)
    squares.collect(&:marker).count(human_marker)
  end

  def count_computer_marker(squares, computer_marker)
    squares.collect(&:marker).count(computer_marker)
  end

  def winning_marker(human_marker, computer_marker)
    WINNING_LINES.each do |line|
      if count_human_marker(@squares.values_at(*line), human_marker) == 3
        return @squares[line[0]].marker
      elsif count_computer_marker(@squares.values_at(*line), computer_marker) == 3
        return @squares[line[0]].marker
      end
    end
    nil
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def at_risk_square_calculator(icon)
    at_risk_square = nil

    WINNING_LINES.each do |line|
      line_values = [@squares[line[0]].marker, @squares[line[1]].marker, @squares[line[2]].marker]
      if (line_values.count(icon) == 2) && (line_values.count(" ") == 1)
        at_risk_square = line[line_values.index(" ")]
      end
    end

    at_risk_square
  end

  def offensive_choice(computer_marker)
    at_risk_square_calculator(computer_marker)
  end

  def defensive_choice(human_marker)
    at_risk_square_calculator(human_marker)
  end

  def choose_center_key
    if @squares[5].unmarked?
      5
    end
  end

  def choose_random_key
    unmarked_keys.sample
  end

  def computer_choice_logic(computer_marker, human_marker)
    key = offensive_choice(computer_marker)
    key = defensive_choice(human_marker) unless key
    key = choose_center_key unless key
    key = choose_random_key unless key
    key
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1].marker}  |  #{@squares[2].marker}  |  #{@squares[3].marker}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4].marker}  |  #{@squares[5].marker}  |  #{@squares[6].marker}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7].marker}  |  #{@squares[8].marker}  |  #{@squares[9].marker}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  include Joinable

  ALPHABET = [*'1'..'9', *'A'..'N', *'P'..'Z']

  attr_reader :name, :marker

  def initialize
    @name = choose_player_name
    @marker = choose_player_marker
  end

  def choose_player_name
    "Player"
  end

  def choose_player_marker
    "X"
  end
end

class Human < Player
  def choose_player_name
    puts "What is your name?"

    name = nil
    loop do
      name = gets.chomp
      break if name.length > 0
      puts "Sorry, please enter at least one letter for your name."
    end

    name
  end

  def choose_player_marker
    puts "Choose a marker: (#{joinor(ALPHABET)})"

    marker = nil
    loop do
      marker = gets.chomp
      break if ALPHABET.include?(marker.upcase)
      puts "Sorry, that's not a valid choice."
    end

    marker
  end
end

class Computer < Player
  def choose_player_name
    ["Deep Blue", "Brainiac", "HAL", "J-5"].sample
  end

  def choose_player_marker
    "O"
  end
end

class TTTGame
  include Joinable

  attr_reader :board, :human, :computer
  attr_accessor :human_wins, :computer_wins, :winner

  def initialize
    display_welcome_message
    @board = Board.new
    @human = Human.new
    @computer = Computer.new
    @human_wins = 0
    @computer_wins = 0
    @winner = nil
  end

  WIN_THRESHOLD = 5

  def display_welcome_message
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe!  Goodbye!"
  end

  def display_board
    puts "#{human.name}, your marker is #{human.marker}.  Your computer opponent #{computer.name}'s marker is #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def human_moves
    puts "Choose a square from the following: (#{joinor(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves(computer_marker, player_marker)
    board[board.computer_choice_logic(computer_marker, player_marker)] = computer.marker
  end

  def display_result
    display_board

    case board.winning_marker(human.marker, computer.marker)
    when human.marker
      puts "You won the round!"
    when computer.marker
      puts "#{computer.name} won the round!"
    else
      puts "This round is a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include? answer
      puts "Sorry, must be y or n"
    end

    answer == "y"
  end

  def clear_screen
    system 'clear'
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def reset
    board.reset
    clear_screen
    @winner = nil
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def update_win_count(human_marker, computer_marker)
    case board.winning_marker(human_marker, computer_marker)
    when human.marker
      @human_wins += 1
    when computer.marker
      @computer_wins += 1
    end
  end

  def pluralize_win(player_wins)
    player_wins == 1 ? "win." : "wins."
  end

  def display_total_wins
    puts "#{human.name} has #{human_wins} " + pluralize_win(human_wins)
    puts "#{computer.name} has #{computer_wins} " + pluralize_win(computer_wins)
  end

  def win_threshold?
    if (human_wins == WIN_THRESHOLD) || (computer_wins == WIN_THRESHOLD)
      true
    else
      false
    end
  end

  def set_winner
    winner = nil
    winner = "#{human.name}" if human_wins > computer_wins
    winner = "#{computer.name}" if computer_wins > human_wins
    winner
  end

  def display_winner_message
    if set_winner
      puts "#{set_winner} wins!"
    else
      puts "It's a tie!"
    end
  end

  def play
    clear_screen

    loop do
      display_board

      loop do
        human_moves
        break if board.someone_won?(human.marker, computer.marker) || board.full?

        computer_moves(human.marker, computer.marker)
        break if board.someone_won?(human.marker, computer.marker) || board.full?

        clear_screen_and_display_board
      end

      display_result
      update_win_count(human.marker, computer.marker)
      display_total_wins

      break if win_threshold?
      break unless play_again?
      reset
      display_play_again_message
    end
    set_winner
    display_winner_message
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
