module Displayable
  def clear_screen
    system "clear"
  end

  def wait_for_input
    puts
    puts "Press [ENTER] to continue."
    gets
  end

  # rubocop:disable Metrics/MethodLength
  def display_welcome_message
    clear_screen
    text = <<~TXT
    Welcome to TicTacToe!
    Rules: https://en.wikipedia.org/wiki/Tic-tac-toe

    Before we begin, you'll need to:
    - select a marker
    - provide your name
    - decide the turn order
    - choose a difficulty
    TXT
    puts text
    wait_for_input
  end

  def display_opening_message
    clear_screen
    text = <<~TXT
    You chose to use #{human.marker} as your marker.

    #{computer.name} will be your opponent, using #{computer.marker} as their marker.

    You can quit early after each completed board if #{computer.name} is too difficult.

    #{TTTGame::FIRST_TO_MOVE}'s will move first.

    First to #{GameElements::Score::WINNING_SCORE} points wins!

    Squares will be chosen using the numbering scheme below:

         |     |
      1  |  2  |  3
         |     |
    -----+-----+-----
         |     |
      4  |  5  |  6
         |     |
    -----+-----+-----
         |     |
      7  |  8  |  9
         |     |
    TXT
    puts text
    wait_for_input
    clear_screen
  end
  # rubocop:enable Metrics/MethodLength

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "#{human.name} won a board!"
    when computer.marker
      puts "#{computer.name} won a board!"
    else
      puts "It's a tie!"
    end
  end

  def display_endgame
    if winner
      puts "#{winner} won! The score was #{human.score} to #{computer.score}"
    else
      puts "You quit early!"
      sleep 1
    end
  end

  def display_goodbye_message
    clear_screen
    puts "Thanks for playing TicTacToe! Goodbye!"
    sleep 1
  end

  def display_board
    display_status
    puts
    board.draw
  end

  def display_status
    text = <<~TXT
    #{human.name} is #{human.marker}'s        #{computer.name} is #{computer.marker}'s
    #{human.name}'s score: #{human.score}    #{computer.name}'s score: #{computer.score}
    
    First to #{GameElements::Score::WINNING_SCORE} points wins!
    TXT
    puts text
  end

  def clear_screen_and_display_board
    clear_screen
    display_board
  end
end

module Inputable
  VALID_YES = ['y', 'yes']
  VALID_NO = ['n', 'no']
  VALID_YES_AND_NO = VALID_YES + VALID_NO

  def quit?
    prompt = "Would you like to give up? (y/n)"
    error = "Sorry, must be y or n."
    answer = get_input(prompt, VALID_YES_AND_NO, error)

    self.quit_early = true if VALID_YES.include?(answer)

    quit_early
  end

  def play_again?
    prompt = "Would you like to play again? (y/n)"
    error = "Sorry, must be y or n."
    answer = get_input(prompt, VALID_YES_AND_NO, error)

    VALID_YES.include?(answer)
  end

  def get_input(prompt_str, validation_array, error_str)
    puts prompt_str

    loop do
      answer = gets.chomp.strip.downcase
      return answer if validation_array.include?(answer)
      puts error_str
    end
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
end

module Settable
  VALID_FIRST_TURNS = ['1', '2', '3']
  VALID_DIFFICULTIES = ['1', '2', '3']

  def set_constant(name, value)
    TTTGame.const_set(name, value)
  end

  def set_computer_difficulty
    clear_screen
    err = "Invalid choice. Please choose #{joinor(VALID_DIFFICULTIES)}"
    computer.difficulty = get_input(difficulty_prompt, VALID_DIFFICULTIES, err)
    puts
  end

  def difficulty_prompt
    <<~TXT
    Please choose a difficulty (#{joinor(VALID_DIFFICULTIES)}):

    1 - Easy
    2 - Medium
    3 - Hard
    TXT
  end

  def set_first_to_move
    clear_screen
    err = "Invalid choice. Please choose #{joinor(VALID_FIRST_TURNS)}"
    marker =  case get_input(first_to_move_prompt, VALID_FIRST_TURNS, err)
              when '1' then human.marker
              when '2' then computer.marker
              else [human.marker, computer.marker].sample
              end
    set_constant('FIRST_TO_MOVE', marker)
  end

  def first_to_move_prompt
    <<~TXT
    Who would you like to move first? (#{joinor(VALID_FIRST_TURNS)})

    1 - You
    2 - Opponent
    3 - Let opponent decide
    TXT
  end
end

module GameElements
  class Board
    attr_reader :open_winning_spots

    WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                    [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                    [[1, 5, 9], [3, 5, 7]]

    # Clarifying convention: a 'spot' is the number indicating
    # a specific Square object's location on the board.

    def initialize
      @squares = {}
      @open_winning_spots = {}
      reset
    end

    def []=(spot, marker)
      squares[spot].marker = marker
    end

    def unmarked_spots
      squares.keys.select { |key| squares[key].unmarked? }
    end

    def full?
      unmarked_spots.empty?
    end

    def someone_won?
      !!winning_marker
    end

    def winning_marker
      WINNING_LINES.each do |line|
        sqs_in_line = squares.values_at(*line)
        if three_identical_markers?(sqs_in_line)
          return sqs_in_line.first.marker
        end
      end
      nil
    end

    def determine_open_winning_spots
      reset_open_winning_spots
      current_markers.each do |mark|
        WINNING_LINES.each do |line|
          if winning_spot?(line, mark)
            open_winning_spots[mark] = empty_spot(line)
          end
        end
      end
    end

    def reset
      (1..9).each { |key| squares[key] = Square.new }
      reset_open_winning_spots
    end

    # rubocop:disable Metrics/AbcSize
    def draw
      puts <<~TXT
           |     |
        #{squares[1]}  |  #{squares[2]}  |  #{squares[3]}
           |     |
      -----+-----+-----
           |     |
        #{squares[4]}  |  #{squares[5]}  |  #{squares[6]}
           |     |
      -----+-----+-----
           |     |
        #{squares[7]}  |  #{squares[8]}  |  #{squares[9]}
           |     |

      TXT
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :squares

    def three_identical_markers?(sqs)
      markers = sqs.select(&:marked?).collect(&:marker)
      return false if markers.size != 3
      markers.uniq.size == 1
    end

    def empty_spot(line)
      line.intersection(unmarked_spots).first
    end

    def empty_square?(line)
      !!empty_spot(line)
    end

    def exactly_2?(mark, line)
      c = squares.values_at(*line).count do |square|
        square.marker == mark
      end
      c == 2
    end

    def winning_spot?(line, mark)
      empty_square?(line) && exactly_2?(mark, line)
    end

    def current_markers
      squares.select { |_, sq| sq.marked? }.values.map(&:marker).uniq
    end

    def reset_open_winning_spots
      open_winning_spots.each_key { |k| open_winning_spots[k] = nil }
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
      marker
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
      self.score = STARTING_SCORE
    end

    def increase
      self.score += 1
    end

    def winning_score?
      score >= WINNING_SCORE
    end

    def to_s
      score.to_s
    end

    private

    attr_writer :score
  end
end

module Players
  class GeneralPlayer
    attr_reader :marker, :score, :name

    def initialize
      set_name
      @score = GameElements::Score.new
    end

    def win?
      score.winning_score?
    end

    def to_s
      name
    end
  end

  class Human < GeneralPlayer
    include Inputable
    include Displayable

    def initialize
      super
      set_marker
    end

    def move(board)
      prompt = "Choose an empty square (#{joinor(board.unmarked_spots)}): "
      validation_array = board.unmarked_spots.map(&:to_s)
      error = "Sorry, that's not a valid choice."

      square = get_input(prompt, validation_array, error).to_i

      board[square] = marker
    end

    private

    def set_name
      clear_screen
      n = ''
      loop do
        puts "What's your name?"
        n = gets.chomp.strip
        break unless n.empty?
        puts 'Invalid name. Please enter a name ' \
        'with at least one non-space character.'
      end
      @name = n
    end

    def set_marker
      clear_screen
      puts "Please enter a single non-space character to be your marker."
      answer = nil
      loop do
        answer = gets.chomp.strip
        break if valid_marker?(answer)
        puts "Invalid marker. Please enter a single non-space character."
      end
      @marker = answer
    end

    def valid_marker?(string)
      string.length == 1
    end
  end

  class Computer < GeneralPlayer
    POTENTIAL_COMPUTER_NAMES = ["N64", "PS2", "PC", "GBC", "NDS", "GC"]
    POTENTIAL_COMPUTER_MARKERS = ['X', 'O']
    PRIORITIZED_MOVE = 5

    attr_writer :difficulty

    def initialize(human)
      super()
      determine_marker(human)
    end

    def move(board)
      board.determine_open_winning_spots
      sp = spot_selection(board.unmarked_spots, board.open_winning_spots)
      board[sp] = marker
    end

    private

    attr_reader :difficulty

    def set_name
      @name = POTENTIAL_COMPUTER_NAMES.sample
    end

    def determine_marker(human)
      choices = POTENTIAL_COMPUTER_MARKERS.select do |char|
        char.downcase != human.marker.downcase
      end
      @marker = choices.sample
    end

    def spot_selection(open_spots, open_winning_spots)
      case difficulty
      when '1' then easy_mode(open_spots)
      when '2' then medium_mode(open_spots, open_winning_spots)
      when '3' then hard_mode(open_spots, open_winning_spots)
      end
    end

    def easy_mode(open_spots)
      open_spots.sample
    end

    def medium_mode(open_spots, open_winning_spots)
      if player_winning_spot?(open_winning_spots)
        defensive_move(open_winning_spots)
      elsif open_spots.include?(PRIORITIZED_MOVE)
        PRIORITIZED_MOVE
      else
        easy_mode(open_spots)
      end
    end

    def hard_mode(open_spots, open_winning_spots)
      if computer_winning_spot?(open_winning_spots)
        offensive_move(open_winning_spots)
      else
        medium_mode(open_spots, open_winning_spots)
      end
    end

    def player_winning_spot?(open_winning_spots)
      !!defensive_move(open_winning_spots)
    end

    def computer_winning_spot?(open_winning_spots)
      !!offensive_move(open_winning_spots)
    end

    def offensive_move(open_winning_spots)
      open_winning_spots[marker]
    end

    def defensive_move(open_winning_spots)
      open_winning_spots.select { |mark, _| mark != marker }.values.first
    end

    def random_move(open_spots)
      open_spots.sample
    end
  end
end

class TTTGame
  def play
    display_opening_message
    main_gameplay_loop
    display_goodbye_message
  end

  private

  include Displayable
  include Inputable
  include Settable

  attr_reader :board, :human, :computer
  attr_accessor :quit_early, :winner, :current_marker

  def initialize
    display_welcome_message
    @board = GameElements::Board.new
    @human = Players::Human.new
    @computer = Players::Computer.new(human)
    set_computer_difficulty
    set_first_to_move
    @current_marker = FIRST_TO_MOVE
    @quit_early = false
    @winner = nil
  end

  def main_gameplay_loop
    loop do
      scoring_gameplay_loop
      determine_winner
      display_endgame
      break if quit_early || !play_again?
      reset
    end
  end

  def scoring_gameplay_loop
    loop do
      display_board
      move_phase
      update_points
      display_result
      break if winning_score? || quit?
      reset_board
    end
  end

  def determine_winner
    self.winner = human if human.win?
    self.winner = computer if computer.win?
  end

  def update_points
    case board.winning_marker
    when human.marker then human.score.increase
    when computer.marker then computer.score.increase
    end
  end

  def winning_score?
    human.win? || computer.win?
  end

  def move_phase
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def current_player_moves
    if human_turn?
      human.move(board)
      self.current_marker = computer.marker
    else
      computer.move(board)
      self.current_marker = human.marker
    end
  end

  def human_turn?
    current_marker == human.marker
  end

  def reset
    reset_board
    reset_scores
    reset_winner
  end

  def reset_board
    board.reset
    self.current_marker = FIRST_TO_MOVE
    clear_screen
  end

  def reset_scores
    human.score.reset
    computer.score.reset
  end

  def reset_winner
    self.winner = nil
  end
end

game = TTTGame.new
game.play
