=begin
To do:
- check flow of game & determine when to have sleeps and how long & when to clear screen
- do full runs of all different opponents
- rubocop program
=end

require 'yaml'

module Promptable
  MESSAGES = YAML.load_file('rps_message.yml')

  def prompt(message)
    puts "=> #{message}"
  end
end

class Score
  WINNING_SCORE = 10
  STARTING_SCORE = 0

  attr_reader :score

  def initialize
    @score = STARTING_SCORE
  end

  def reset
    @score = STARTING_SCORE
  end

  def increase
    @score += 1
  end

  def win?
    score >= WINNING_SCORE
  end

  def <=>(other_score)
    score <=> other_score.score
  end

  def to_s
    @score.to_s
  end
end

class Move
  def >(other_move)
    self.class::WINS_AGAINST.include?(other_move.to_s)
  end

  def <(other_move)
    self.class::LOSES_AGAINST.include?(other_move.to_s)
  end

  def to_s
    self.class.to_s.downcase
  end
end

class Rock < Move
  WINS_AGAINST = ['scissors', 'lizard']
  LOSES_AGAINST = ['paper', 'spock']
end

class Paper < Move
  WINS_AGAINST = ['rock', 'spock']
  LOSES_AGAINST = ['scissors', 'lizard']
end

class Scissors < Move
  WINS_AGAINST = ['paper', 'lizard']
  LOSES_AGAINST = ['rock', 'spock']
end

class Lizard < Move
  WINS_AGAINST = ['spock', 'paper']
  LOSES_AGAINST = ['rock', 'scissors']
end

class Spock < Move
  WINS_AGAINST = ['scissors', 'rock']
  LOSES_AGAINST = ['lizard', 'paper']
end

class Player
  include Promptable

  USER_INPUT_CONVERSION = {
    'rock' => Rock.new,
    'r' => Rock.new,
    'paper' => Paper.new,
    'p' => Paper.new,
    'scissors' => Scissors.new,
    'sc' => Scissors.new,
    'lizard' => Lizard.new,
    'l' => Lizard.new,
    'spock' => Spock.new,
    'sp' => Spock.new
  }

  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = Score.new
  end

  def win?
    score.win?
  end

  def to_s
    name
  end
end

class Human < Player
  attr_reader :opening

  def set_name
    n = ''
    loop do
      prompt("What's your name?")
      n = gets.chomp
      break unless n.empty?
      prompt("Sorry, you must enter a value.")
    end
    self.name = n
    puts
  end

  def set_opening
    print "#{name}: "
    @opening = gets.chomp.strip
  end

  def choose
    choice = nil
    loop do
      prompt(MESSAGES['choose_move'])
      choice = gets.chomp
      break if USER_INPUT_CONVERSION.include?(choice)
      prompt(MESSAGES['invalid_move'])
    end
    self.move = USER_INPUT_CONVERSION[choice]
  end
end

class Computer < Player
  def set_name
    @name = self.class.to_s
  end

  def opening
    yaml_key = self.class.to_s.downcase + "_opening"
    prompt(MESSAGES[yaml_key])
  end

  def taunt
    yaml_key = self.class.to_s.downcase + "_taunt"
    prompt(MESSAGES[yaml_key])
  end

  def win
    yaml_key = self.class.to_s.downcase + "_win"
    prompt(MESSAGES[yaml_key])
  end

  def lose
    yaml_key = self.class.to_s.downcase + "_lose"
    prompt(MESSAGES[yaml_key])
  end

  private

  def prompt(message)
    puts "#{@name}: #{message}"
  end

  def choose_rock
    self.move = Rock.new
  end

  def choose_paper
    self.move = Paper.new
  end

  def choose_scissors
    self.move = Scissors.new
  end

  def choose_lizard
    self.move = Lizard.new
  end

  def choose_spock
    self.move = Spock.new
  end

  def choose_losing_move(human_move)
    self.move = human_move.class::WINS_AGAINST.sample
  end

  def choose_winning_move(human_move)
    self.move = human_move.class::LOSES_AGAINST.sample
  end

  def choose_random
    self.move = USER_INPUT_CONVERSION.values.sample
  end
end

class Rockman < Computer
  def choose(*)
    choose_rock
  end
end

class Papyrus < Computer
  def choose(*)
    choose_paper
  end
end

class DJCutman < Computer
  def set_name
    @name = 'DJ Cutman'
  end

  def choose(*)
    choose_scissors
  end
end

class Martin < Computer
  def choose(*)
    choose_lizard
  end
end

class Picard < Computer
  def choose(*)
    choose_spock
  end
end

class GlassJoe < Computer
  def set_name
    @name = 'Glass Joe'
  end

  def choose(human_move, _)
    choose_losing_move(human_move)
  end
end

class Glados < Computer
  def set_name
    @name = 'GLaDOS'
  end

  def choose(human_move, _)
    choose_winning_move(human_move)
  end
end

class Zenos < Computer
  def choose(human_move, human_score)
    case human_score <=> score
    when 0 then choose_random
    when -1 then choose_losing_move(human_move)
    when 1 then choose_winning_move(human_move)
    end
  end
end

class BMO < Computer
  def choose(*)
    choose_random
  end
end

class MoveHistory
  ROUND_COL_SIZE = 11
  HUMAN_COL_SIZE = 15
  COMP_COL_SIZE = 15
  TABLE_WIDTH = ROUND_COL_SIZE + HUMAN_COL_SIZE + COMP_COL_SIZE + 2

  attr_reader :history

  def initialize
    @history = Hash.new
  end

  def reset
    @history = Hash.new
  end

  def record(round, human_move, computer_move)
    history[round] = [human_move, computer_move]
  end

  def display(computer_name)
    display_title
    display_top_bottom_line
    display_header(computer_name)
    display_round_lines
    display_top_bottom_line
  end

  private

  def display_title
    puts "MOVE HISTORY".center(TABLE_WIDTH + 2)
  end

  def display_header(computer_name)
    round_header = "Round".center(ROUND_COL_SIZE)
    human_header = "You".center(HUMAN_COL_SIZE)
    computer_header = computer_name.center(COMP_COL_SIZE)
    puts "|#{round_header}|#{human_header}|#{computer_header}|"
  end

  def display_top_bottom_line
    puts "+#{'-' * TABLE_WIDTH}+"
  end

  def display_middle_line
    puts "|#{'-' * TABLE_WIDTH}|"
  end

  def display_round(round, player_move, computer_move)
    round = round.to_s.center(ROUND_COL_SIZE)
    player_move = player_move.center(HUMAN_COL_SIZE)
    computer_move = computer_move.center(COMP_COL_SIZE)
    puts "|#{round}|#{player_move}|#{computer_move}|"
  end

  def display_round_lines
    history.each do |round, (player_move, computer_move)|
      display_middle_line
      display_round(round, player_move, computer_move)
    end
  end
end

class RPSGame
  include Promptable

  OPPONENTS = {
    'rockman' => Rockman.new,
    'papyrus' => Papyrus.new,
    'dj cutman' => DJCutman.new,
    'martin' => Martin.new,
    'picard' => Picard.new,
    'glass joe' => GlassJoe.new,
    'glados' => Glados.new,
    'zenos' => Zenos.new,
    'bmo' => BMO.new
  }

  VALID_QUITS = [
    'quit',
    'q',
    'exit',
    'e',
    'give up',
    'g'
  ]

  TAUNT_ROUND = 7

  DEFAULT_PAUSE_DURATION = 2

  attr_accessor :round
  attr_reader :history, :human, :computer

  def initialize
    display_welcome_message
    @human = Human.new
    choose_opponent
    @round = 0
    @history = MoveHistory.new
  end

  def reset
    [human.score, computer.score, history].each(&:reset)
    @round = 0
    choose_opponent
    pregame_phase
  end

  def clear_screen
    system 'clear'
  end

  def pause(duration = DEFAULT_PAUSE_DURATION)
    sleep duration
  end

  def display_welcome_message
    clear_screen
    prompt(MESSAGES['welcome'])
    gets
    clear_screen
  end

  def display_header
    clear_screen
    puts "================ R O U N D  #{round.to_s.center(2)} ================"
    display_score
    puts
  end

  def display_round_over_header
    clear_screen
    puts "============ R O U N D  #{round.to_s.center(2)}  O V E R ==========="
    display_score
    puts
  end

  def display_game_over_header
    clear_screen
    puts "============== G A M E  O V E R ==============="
    display_score
    puts
  end

  def display_goodbye_message
    prompt(MESSAGES['goodbye'])
  end

  def display_score
    human_output = "#{human}'s score: #{human.score}"
    computer_output = "#{computer}'s score: #{computer.score}"
    puts "#{human_output}   #{computer_output}"
  end

  def display_move_history
    history.display(computer.name)
    puts
    pause
  end

  def display_moves
    prompt("#{human} chose #{human.move}.")
    prompt("#{computer} chose #{computer.move}.")
    pause
  end

  def display_round_winner
    if human.move > computer.move
      prompt("#{human} won this round!")
    elsif human.move < computer.move
      prompt("#{computer} won this round!")
    else
      prompt(MESSAGES['tie'])
    end
    pause
  end

  def display_overall_winner
    winner = human.win? ? human : computer
    puts "#{winner} reached #{Score::WINNING_SCORE} points and won the game!"
  end

  def choose_opponent
    clear_screen
    input = opponent_input_loop
    @computer = OPPONENTS[input] || OPPONENTS.values.sample
    prompt("Your opponent is #{computer}.")
    pause
  end

  def opponent_input_loop
    input = ''
    loop do
      prompt(MESSAGES['choose_opponent'])
      list_opponents
      input = gets.chomp.downcase
      break if OPPONENTS.key?(input) || input == 'random'
      prompt(MESSAGES['invalid_opponent'])
    end
    input
  end

  def list_opponents
    OPPONENTS.each_value do |opponent|
      puts "- #{opponent.name}"
    end
  end

  def increase_round
    self.round += 1
  end

  def record_moves
    history.record(round, human.move.to_s, computer.move.to_s)
  end

  def update_score_and_history
    if human.move > computer.move
      human.score.increase
    elsif human.move < computer.move
      computer.score.increase
    end
    record_moves
  end

  def winning_score?
    human.score.win? || computer.score.win?
  end

  def play_again?
    answer = nil
    loop do
      prompt(MESSAGES['play_again?'])
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      play_again_history_check(answer)
    end
    answer.downcase == 'y'
  end

  def play_again_history_check(answer)
    if answer == 'history'
      display_game_over_header
      display_move_history
    else
      prompt(MESSAGES['bad_input'])
    end
  end

  def quit_early?
    answer = nil
    loop do
      prompt(MESSAGES['quit_early?'])
      answer = gets.chomp
      break unless answer == 'history'
      display_round_over_header
      display_move_history
    end
    VALID_QUITS.include?(answer)
  end

  def pregame_phase
    human_opening_phase
    computer_opening_phase
    game_start_announcement
  end

  def human_opening_phase
    clear_screen
    prompt(MESSAGES['announcer_opening_1'])
    prompt("#{human}, do you have anything to say to #{computer}?")
    puts
    human.set_opening
    puts
    announcer_response_to_human_opening
    pause(4)
  end

  def announcer_response_to_human_opening
    human_opening_length = human.opening.length
    if human_opening_length == 0
      prompt(MESSAGES['announcer_response_1'])
    elsif human_opening_length > 30
      prompt(MESSAGES['announcer_response_2'])
    else
      prompt(MESSAGES['announcer_response_3'])
    end
  end

  def computer_opening_phase
    clear_screen
    prompt(computer.to_s + MESSAGES['announcer_prompt_computer'])
    pause(4)
    puts
    computer.opening
    puts
    pause(4)
  end

  def game_start_announcement
    prompt(MESSAGES['announcer_opening_2'])
    gets
  end

  def main_game_phase_loop
    loop do
      round_phase
      if winning_score?
        endgame_phase
        break unless play_again?
        reset
      elsif quit_early?
        break
      end
    end
  end

  def round_phase
    move_phase
    endround_phase
    taunt_phase if round == TAUNT_ROUND
  end

  def move_phase
    increase_round
    display_header
    human.choose
    computer.choose(human.move, human.score)
    display_moves
  end

  def endround_phase
    update_score_and_history
    display_round_over_header
    display_round_winner
  end

  def taunt_phase
    prompt("Sounds like #{computer}" + MESSAGES['announcer_prompt_taunt'])
    pause
    puts
    computer.taunt
    puts
    pause(5)
  end

  def endgame_phase
    display_game_over_header
    display_overall_winner
    pause
    prompt("It looks like #{computer} has some final words!")
    puts
    pause
    computer.win? ? computer.win : computer.lose
    puts
    pause
  end

  def postgame_phase
    display_game_over_header
    display_goodbye_message
    pause
  end

  def play
    pregame_phase

    main_game_phase_loop

    postgame_phase
  end
end

RPSGame.new.play
