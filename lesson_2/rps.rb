=begin
To do:
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

module Tableable
  ROUND_COL_SIZE = 11
  HUMAN_COL_SIZE = 15
  COMP_COL_SIZE = 15
  TABLE_WIDTH = ROUND_COL_SIZE + HUMAN_COL_SIZE + COMP_COL_SIZE + 2

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

module Headerable
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

  def display_score
    human_output = "#{human}'s score: #{human.score}"
    computer_output = "#{computer}'s score: #{computer.score}"
    puts "#{human_output}   #{computer_output}"
  end
end

module GameplayDisplayable
  include Promptable

  def clear_screen
    system 'clear'
  end

  def display_welcome_message
    clear_screen
    prompt(MESSAGES['welcome'])
    gets
    clear_screen
  end

  def display_announcer_response_to_human_opening
    human_opening_length = human.opening.length
    if human_opening_length == 0
      prompt(MESSAGES['announcer_response_1'])
    elsif human_opening_length > 30
      prompt(MESSAGES['announcer_response_2'])
    else
      prompt(MESSAGES['announcer_response_3'])
    end
  end

  def display_game_start_announcement
    prompt(MESSAGES['announcer_opening_2'])
    gets
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
    elsif computer.move > human.move
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

  def display_goodbye_message
    prompt(MESSAGES['goodbye'])
  end
end

module Inputable
  include Promptable

  VALID_QUITS = [
    'quit',
    'q',
    'exit',
    'e',
    'give up',
    'g'
  ]

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

  def opponent_input_loop
    input = ''
    loop do
      prompt(MESSAGES['choose_opponent'])
      list_opponents
      input = gets.chomp.downcase.strip
      break if RPSGame::OPPONENTS.key?(input) || input == 'random'
      prompt(MESSAGES['invalid_opponent'])
    end
    input
  end

  def list_opponents
    RPSGame::OPPONENTS.each_value do |opponent|
      puts "- #{opponent.name}"
    end
  end
end

module Pausable
  DEFAULT_PAUSE_DURATION = 2

  def pause(duration = DEFAULT_PAUSE_DURATION)
    sleep duration
  end
end

module Moves
  class Move
    def >(other_move)
      self.class::WINS_AGAINST.include?(other_move.to_s)
    end

    def to_s
      self.class.to_s.split(":")[-1].downcase
    end
  end

  class Rock < Move
    WINS_AGAINST = ['scissors', 'lizard']
  end

  class Paper < Move
    WINS_AGAINST = ['rock', 'spock']
  end

  class Scissors < Move
    WINS_AGAINST = ['paper', 'lizard']
  end

  class Lizard < Move
    WINS_AGAINST = ['spock', 'paper']
  end

  class Spock < Move
    WINS_AGAINST = ['scissors', 'rock']
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

module Players
  class Player
    include Promptable

    attr_accessor :move
    attr_reader :score, :name

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

    private

    USER_INPUT_CONVERSION = {
      'rock' => Moves::Rock.new,
      'r' => Moves::Rock.new,
      'paper' => Moves::Paper.new,
      'p' => Moves::Paper.new,
      'scissors' => Moves::Scissors.new,
      'sc' => Moves::Scissors.new,
      'lizard' => Moves::Lizard.new,
      'l' => Moves::Lizard.new,
      'spock' => Moves::Spock.new,
      'sp' => Moves::Spock.new
    }

    attr_writer :name
  end

  class Human < Player
    attr_reader :opening

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

    private

    def set_name
      n = ''
      loop do
        prompt(MESSAGES['choose_name'])
        n = gets.chomp.strip
        break unless n.empty?
        prompt(MESSAGES['invalid_name'])
      end
      self.name = n
      puts
    end
  end

  class Computer < Player
    def initialize
      @yaml_key = self.class.to_s.split(":")[-1].downcase
      super
    end

    def opening
      prompt(MESSAGES[yaml_key + "_opening"])
    end

    def taunt
      prompt(MESSAGES[yaml_key + "_taunt"])
    end

    def win
      prompt(MESSAGES[yaml_key + "_win"])
    end

    def lose
      prompt(MESSAGES[yaml_key + "_lose"])
    end

    private

    attr_reader :yaml_key

    def set_name
      @name = yaml_key.capitalize
    end

    def prompt(message)
      puts "#{@name}: #{message}"
    end

    def choose_rock
      self.move = Moves::Rock.new
    end

    def choose_paper
      self.move = Moves::Paper.new
    end

    def choose_scissors
      self.move = Moves::Scissors.new
    end

    def choose_lizard
      self.move = Moves::Lizard.new
    end

    def choose_spock
      self.move = Moves::Spock.new
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

  module NPCs
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
      def choose(*)
        choose_scissors
      end

      private

      def set_name
        @name = 'DJ Cutman'
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
      def choose(human_move, _)
        choose_losing_move(human_move)
      end

      private

      def set_name
        @name = 'Glass Joe'
      end
    end

    class Glados < Computer
      def choose(human_move, _)
        choose_winning_move(human_move)
      end

      private

      def set_name
        @name = 'GLaDOS'
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

      private

      def set_name
        @name = "BMO"
      end
    end
  end
end

class MoveHistory
  include Tableable

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
end

class RPSGame
  def play
    pregame_phase

    main_game_phase_loop

    postgame_phase
  end

  private

  include Headerable
  include Pausable
  include Inputable
  include GameplayDisplayable

  OPPONENTS = {
    'rockman' => Players::NPCs::Rockman.new,
    'papyrus' => Players::NPCs::Papyrus.new,
    'dj cutman' => Players::NPCs::DJCutman.new,
    'martin' => Players::NPCs::Martin.new,
    'picard' => Players::NPCs::Picard.new,
    'glass joe' => Players::NPCs::GlassJoe.new,
    'glados' => Players::NPCs::Glados.new,
    'zenos' => Players::NPCs::Zenos.new,
    'bmo' => Players::NPCs::BMO.new
  }

  TAUNT_ROUND = Score::WINNING_SCORE / 2

  attr_accessor :round
  attr_reader :history, :human, :computer

  def initialize
    display_welcome_message
    @human = Players::Human.new
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

  def choose_opponent
    clear_screen
    input = opponent_input_loop
    @computer = OPPONENTS[input] || OPPONENTS.values.sample
    prompt("Your opponent is #{computer}.")
    pause
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
    elsif computer.move > human.move
      computer.score.increase
    end
    record_moves
  end

  def winning_score?
    human.score.win? || computer.score.win?
  end

  def pregame_phase
    human_opening_phase
    computer_opening_phase
    display_game_start_announcement
  end

  def human_opening_phase
    clear_screen
    prompt(MESSAGES['announcer_opening_1'])
    prompt("#{human}, do you have anything to say to #{computer}?")
    puts
    human.set_opening
    puts
    display_announcer_response_to_human_opening
    pause(4)
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
end

RPSGame.new.play
