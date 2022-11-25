=begin
To do:
- check flow of game & determine when to have sleeps and how long & when to clear screen
- review interface
- do full runs of all different opponents
- add the option to randomly choose the opponent
- rubocop program

Ask LS Slack question about how Ruby looks up constants for child and parent classes.
See exploration_space.rb and
https://stackoverflow.com/questions/48817287/accessing-a-childs-constant-from-the-parents-class
https://stackoverflow.com/questions/9949655/get-child-constant-in-parent-method-ruby
for examples of what I'm talking about.

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

  attr_accessor :move, :name, :score, :move_history

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
      prompt("Sorry, must enter a value.")
    end
    self.name = n
    puts
  end

  def choose
    choice = nil

    loop do
      prompt(MESSAGES['choose_move'])
      choice = gets.chomp
      break if USER_INPUT_CONVERSION.include?(choice)
      prompt("Sorry, invalid choice.")
    end

    self.move = USER_INPUT_CONVERSION[choice]
  end

  def set_opening
    @opening = gets.chomp.strip
  end
end

class Computer < Player
  def set_name
    @name = self.class.to_s
  end

  def choose_random
    self.move = USER_INPUT_CONVERSION[(USER_INPUT_CONVERSION.keys.sample)]
  end

  def prompt(message)
    puts "#{@name} => #{message}"
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
    self.move = human_move.class::WINS_AGAINST[0]
  end

  def choose_winning_move(human_move)
    self.move = human_move.class::LOSES_AGAINST[0]
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
  attr_accessor :history

  ROUND_COL_SIZE = 11
  HUMAN_COL_SIZE = 15
  COMP_COL_SIZE = 15
  TABLE_WIDTH = ROUND_COL_SIZE + HUMAN_COL_SIZE + COMP_COL_SIZE + 2

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

# Game Orchestration Engine
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

  attr_accessor :human, :computer, :round, :history

  def initialize
    display_welcome_message
    @human = Human.new
    choose_opponent
    @round = 0
    @history = MoveHistory.new
  end

  def increase_round
    @round += 1
  end

  def record_moves
    history.record(round, human.move.to_s, computer.move.to_s)
  end

  def choose_opponent
    input = ''
    loop do
      prompt(MESSAGES['choose_opponent'])
      list_opponents
      input = gets.chomp.downcase
      break if OPPONENTS.key?(input)
      prompt(MESSAGES['invalid_opponent'])
    end
    @computer = OPPONENTS[input]
  end

  def list_opponents
    OPPONENTS.each_value do |opponent|
      puts "- #{opponent.name}"
    end
  end

  def display_welcome_message
    system 'clear'
    prompt(MESSAGES['welcome'])
    gets
  end

  def display_header
    clear_screen
    puts "========== R O U N D  #{round} =========="
    display_score
    puts
  end

  def display_round_over_header
    clear_screen
    puts "========== R O U N D  #{round}  O V E R =========="
    display_score
    puts
  end

  def display_game_over_header
    clear_screen
    puts "========== G A M E  O V E R =========="
    display_score
    puts
  end

  def display_goodbye_message
    prompt(MESSAGES['goodbye'])
  end

  def display_moves
    prompt("#{human} chose #{human.move}.")
    prompt("#{computer} chose #{computer.move}.")
    pause
  end

  def display_score
    human_output = "#{human}'s score: #{human.score}"
    computer_output = "#{computer}'s score: #{computer.score}"
    puts "#{human_output}   #{computer_output}"
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

  def update_score_and_history
    if human.move > computer.move
      human.score.increase
    elsif human.move < computer.move
      computer.score.increase
    end
    record_moves
  end

  def reset
    [human.score, computer.score, history].each(&:reset)
    @round = 0
    choose_opponent
  end

  def winning_score?
    human.score.win? || computer.score.win?
  end

  def display_overall_winner
    winner = human.win? ? human : computer
    puts "#{winner} reached #{Score::WINNING_SCORE} points and won the game!"
  end

  def play_again?
    answer = nil

    loop do
      puts MESSAGES['play_again?']
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      answer == 'history' ? display_move_history : puts(MESSAGES['bad_input'])
    end

    answer.downcase == 'y'
  end

  def clear_screen
    system 'clear'
  end

  def pause(duration = 1.5)
    sleep duration
  end

  def quit_early?
    answer = nil
    loop do
      puts MESSAGES['quit_early?']
      answer = gets.chomp
      break unless answer == 'history'
      display_move_history
    end
    VALID_QUITS.include?(answer)
  end

  def display_move_history
    history.display(computer.name)
    puts
    pause
  end

  def announcer_response_to_human_opening
    clear_screen
    human_opening_length = human.opening.length
    if human_opening_length == 0
      prompt(MESSAGES['announcer_response_1'])
    elsif human_opening_length > 30
      prompt(MESSAGES['announcer_response_2'])
    else
      prompt(MESSAGES['announcer_response_3'])
    end
  end

  def human_opening_phase
    clear_screen
    prompt(MESSAGES['announcer_opening_1'])
    prompt("#{human}, do you have anything to say to #{computer}?")
    human.set_opening
    announcer_response_to_human_opening
    pause(5)
  end

  def computer_opening_phase
    clear_screen
    prompt("#{computer}, are you going to take that lying down? What's your response?")
    pause(5)
    clear_screen
    computer.opening
    pause(5)
  end

  def game_start_announcement
    clear_screen
    prompt(MESSAGES['announcer_opening_2'])
    pause(5)
  end

  def pregame_phase
    human_opening_phase
    computer_opening_phase
    game_start_announcement
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

  def endgame_phase
    display_game_over_header
    display_overall_winner
    prompt("It looks like #{computer} has some final words!")
    computer.win? ? computer.win : computer.lose
  end

  def taunt_phase
    prompt "Looks like #{computer} has something to say to you! Could they be...taunting you?"
    computer.taunt
    pause(5)
  end

  def round_phase
    move_phase
    endround_phase
    taunt_phase if round == TAUNT_ROUND
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

  def postgame_phase
    display_goodbye_message
  end

  def play
    pregame_phase

    main_game_phase_loop

    postgame_phase
  end
end

RPSGame.new.play
