=begin
To do:

- allow difficulty settings
- allow player to pick any marker (can I use the Module#const_set method for this?)
  - implies that the computer cannot pick the marker the player picked
- allow player to input a name
  - give computer a name
- display rules and grid schematic during welcome message
=end

require 'pry'

class Board
  attr_reader :open_winning_spots
  
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # columns
                  [[1, 5, 9], [3, 5, 7]] # diagonals

  def initialize
    @squares = {}
    @open_winning_spots = {}
    reset
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  # returns winning marker or nil
  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  def determine_open_winning_spots
    reset_open_winning_spots
    [TTTGame::HUMAN_MARKER, TTTGame::COMPUTER_MARKER].each do |mark|
      WINNING_LINES.each do |line|
        if winning_spot?(line, mark)
          @open_winning_spots[mark] = empty_square_key(line)
        end
      end
    end
  end

  def empty_square_key(line)
    line.intersection(unmarked_keys).first
  end

  def empty_square?(line)
    !!empty_square_key(line)
  end

  def exactly_2?(mark, line)
    c = @squares.values_at(*line).count do |square|
          square.marker == mark
        end
    c == 2
  end

  def winning_spot?(line, mark)
    empty_square?(line) && exactly_2?(mark, line)
  end

  def reset_open_winning_spots
    @open_winning_spots.each_key {|k| @open_winning_spots[k] = nil}
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
    reset_open_winning_spots
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
    puts
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).collect(&:marker)
    return false if markers.size != 3
    markers.uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = ' '

  attr_accessor :marker

  def initialize
    @marker = INITIAL_MARKER
  end

  def unmarked?
    marker == INITIAL_MARKER
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end
end

class Score
  attr_reader :score

  STARTING_SCORE = 0
  WINNING_SCORE = 5

  def initialize
    reset
  end
  
  def reset
    @score = STARTING_SCORE
  end

  def increase
    @score += 1
  end

  def winning_score?
    @score >= WINNING_SCORE
  end
  
  def to_s
    @score.to_s
  end
end

class Player
  attr_reader :marker, :score

  def initialize(mark)
    @marker = mark
    @score = Score.new
  end

  def win?
    score.winning_score?
  end
  
  def to_s
    "test_player" #update to be the name of the player once implemented
  end
end

class Computer < Player
  def player_winning_spot?(open_winning_spots)
    !!defensive_move(open_winning_spots)
  end

  def computer_winning_spot?(open_winning_spots)
    !!offensive_move(open_winning_spots)
  end

  def defensive_move(open_winning_spots)
    open_winning_spots.select {|mark, _| mark != marker}.values.first
  end
  
  def offensive_move(open_winning_spots)
    open_winning_spots[marker]
  end
  
  def random_move(open_spots)
    open_spots.sample
  end
  
  def prioritized_move
    5
  end
  
  def spot_selection(open_spots, open_winning_spots)
    if open_spots.include?(prioritized_move)
      prioritized_move
    elsif computer_winning_spot?(open_winning_spots)
      offensive_move(open_winning_spots)
    elsif player_winning_spot?(open_winning_spots)
      defensive_move(open_winning_spots)
    else
      open_spots.sample
    end
  end
end

class TTTGame
  def play
    main_gameplay_loop
    display_goodbye_message
  end

  def main_gameplay_loop
    loop do
      # determine settings (difficulty, marker)
      scoring_gameplay_loop
      determine_winner
      display_endgame
      break if quit_early || !play_again?
      reset
      display_play_again_message
    end
  end

  def determine_winner
    @winner = human if human.win?
    @winner = computer if computer.win?
  end

  def display_endgame
    if @winner
      puts "#{@winner} won! The score was #{human.score} to #{computer.score}"
    else
      puts "You quit early!"
    end
  end

  private

  HUMAN_MARKER = 'X'
  COMPUTER_MARKER = 'O'
  VALID_YES = ['y', 'yes']
  VALID_NO = ['n', 'no']
  VALID_INPUTS = VALID_YES + VALID_NO
  VALID_FIRST_TURNS = [1, 2, 3]

  attr_reader :board, :human, :computer, :quit_early

  def initialize
    display_welcome_message
    @board = Board.new
    #set_markers
    @human = Player.new(HUMAN_MARKER)
    @computer = Computer.new(COMPUTER_MARKER)
    set_first_to_move
    @current_marker = FIRST_TO_MOVE
    @quit_early = false
    @winner = nil
  end

  def set_constant(name, value)
    self.class.const_set(name, value)
  end

  def set_first_to_move
    puts "Who would you like to move first? (1, 2, or 3)"
    puts "1 - You"
    puts "2 - Computer"
    puts "3 - Let the computer decide"
    answer = nil
    loop do
      answer = gets.chomp.to_i
      break if VALID_FIRST_TURNS.include?(answer)
      puts "Invalid choice. Please enter 1, 2, or 3."
    end
    marker =  case answer
              when 1 then HUMAN_MARKER
              when 2 then COMPUTER_MARKER
              else [HUMAN_MARKER, COMPUTER_MARKER].sample
              end
    set_constant('FIRST_TO_MOVE', marker)
  end

  def scoring_gameplay_loop
    loop do
      display_board
      player_move
      update_points
      display_result
      break if winning_score? || quit?
      reset_board
    end
  end

  def winning_score?
    human.win? || computer.win?
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def clear_screen
    system "clear"
  end

  def display_welcome_message #need to significantly build out welcome message
    clear_screen
    puts "Welcome to Tic Tac Toe!"
    puts
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_board
    display_status
    puts
    board.draw
  end

  def display_status
    puts "You're #{human.marker}s       Computer is #{computer.marker}s"
    puts "Your score: #{human.score}   Computer's score: #{computer.score}"
  end

  def joinor(array, delimiter=", ", final_delim='or')
    cloned_array = array.clone
  
    if array.size < 3
      cloned_array.join(" #{final_delim} ")
    else
      cloned_array[-1] = "#{final_delim} #{array[-1]}"
      cloned_array.join(delimiter)
    end
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when HUMAN_MARKER
      puts "You won!"
    when COMPUTER_MARKER
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def update_points
    case board.winning_marker
    when HUMAN_MARKER
      human.score.increase
    when COMPUTER_MARKER
      computer.score.increase
    end
  end

  def human_moves
    puts "Choose an empty square (#{joinor(board.unmarked_keys)}): "
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end
    board[square] = human.marker
  end

  def computer_moves
    board.determine_open_winning_spots
    spot = computer.spot_selection(board.unmarked_keys, board.open_winning_spots)
    board[spot] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = COMPUTER_MARKER
    else
      computer_moves
      @current_marker = HUMAN_MARKER
    end
  end

  def human_turn?
    @current_marker == HUMAN_MARKER
  end

  def quit?
    answer = get_yes_or_no("Would you like to give up? (y/n)")

    @quit_early = true if VALID_YES.include?(answer)

    quit_early
  end

  def play_again?
    answer = get_yes_or_no("Would you like to play again? (y/n)")

    VALID_YES.include?(answer)
  end

  def get_yes_or_no(prompt_string)
    loop do
      puts prompt_string
      answer = gets.chomp.downcase
      return answer if VALID_INPUTS.include?(answer)
      puts "Sorry, must be y or n."
    end
  end

  def reset_board
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear_screen
  end

  def reset
    reset_board
    reset_scores
    reset_winner
  end

  def reset_scores
    human.score.reset
    computer.score.reset
  end

  def reset_winner
    @winner = nil
  end

  def display_play_again_message
    puts "Let's play again!"
    puts
  end
end

# we'll kick off the game like this
game = TTTGame.new
game.play
