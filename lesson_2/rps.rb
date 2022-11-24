=begin
To do:
- clear the screen after each round
- standardize display
  - better interface
  - show round number, point total, names

- organize RPSGame#play method into different phases
  - opening phase
  - gameplay phase
  - post-game phase
- allow user and opponent to make opening statements prior to beginning main game loop
- have computer taunt after 8 rounds
- have computer make a statement after winning and after losing
- check flow of game & determine when to have sleeps and how long
- rubocop program

Ask LS Slack question about how Ruby looks up constants for child and parent classes.
See exploration_space.rb and 
https://stackoverflow.com/questions/48817287/accessing-a-childs-constant-from-the-parents-class
https://stackoverflow.com/questions/9949655/get-child-constant-in-parent-method-ruby
for examples of what I'm talking about.


=end

require 'pry'

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
  USER_INPUT_CONVERSION = {
    'rock' => Rock.new,
    'paper' => Paper.new,
    'scissors' => Scissors.new,
    'lizard' => Lizard.new,
    'spock' => Spock.new
  }
  
  attr_accessor :move, :name, :score, :move_history

  def initialize
    set_name
    @score = Score.new
  end
  
  def to_s
    self.name
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil

    loop do
      puts "Please choose rock, paper, scissors, lizard, or spock:"
      choice = gets.chomp
      break if USER_INPUT_CONVERSION.include?(choice)
      puts "Sorry, invalid choice."
    end

    self.move = USER_INPUT_CONVERSION[choice]
  end
end

class Computer < Player
  def set_name
    @name = self.class.to_s
  end

  def choose_random
    puts "Choosing random move"
    self.move = USER_INPUT_CONVERSION[(USER_INPUT_CONVERSION.keys.sample)]
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
end

class Rockman < Computer
  def choose(human_move, human_score)
    choose_rock
  end
end

class Papyrus < Computer
  def choose(human_move, human_score)
    choose_paper
  end
end

class DJCutman < Computer
  def set_name
    @name = 'DJ Cutman'
  end
  
  def choose(human_move, human_score)
    choose_scissors
  end
end

class Martin < Computer
  def choose(human_move, human_score)
    choose_lizard
  end
end

class Picard < Computer
  def choose(human_move, human_score)
    choose_spock
  end
end

class GlassJoe < Computer
  def set_name
    @name = 'Glass Joe'
  end
  
  def choose(human_move, human_score)
    choose_losing_move(human_move)
  end
end

class Glados < Computer
  def set_name
    @name = 'GLaDOS'
  end
  
  def choose(human_move, human_score)
    choose_winning_move(human_move)
  end
end

class Zenos < Computer
  def choose(human_move, human_score)
    case human_score <=> self.score
    when 0 then choose_random
    when -1 then choose_losing_move(human_move)
    when 1 then choose_winning_move(human_move)
    end
  end
end

class MoveHistory
  attr_accessor :history
  ROUND_COLUMN_SIZE = 11
  PLAYER_COLUMN_SIZE = 15
  COMPUTER_COLUMN_SIZE = 15
  TABLE_WIDTH = ROUND_COLUMN_SIZE + PLAYER_COLUMN_SIZE + COMPUTER_COLUMN_SIZE + 2
  
  def initialize
    @history = Hash.new
  end
  
  def reset
    @history = Hash.new
  end
  
  def record(round, human_move, computer_move)
    history[round] = [human_move, computer_move] #Does this need self at the beginning of history[round] =??
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
    round_header = "Round".center(ROUND_COLUMN_SIZE)
    human_header = "You".center(PLAYER_COLUMN_SIZE)
    computer_header = computer_name.center(COMPUTER_COLUMN_SIZE)
    puts "|#{round_header}|#{human_header}|#{computer_header}|"
  end
  
  def display_top_bottom_line
    puts "+#{'-' * TABLE_WIDTH}+"
  end
  
  def display_middle_line
    puts "|#{'-' * TABLE_WIDTH}|"
  end
  
  def display_round(round, player_move, computer_move)
    round = round.to_s.center(ROUND_COLUMN_SIZE)
    player_move = player_move.center(PLAYER_COLUMN_SIZE)
    computer_move = computer_move.center(COMPUTER_COLUMN_SIZE)
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
  OPPONENTS = {
    'rockman' => Rockman.new,
    'papyrus' => Papyrus.new,
    'dj cutman' => DJCutman.new,
    'martin' => Martin.new,
    'picard' => Picard.new,
    'glass joe' => GlassJoe.new,
    'glados' => Glados.new,
    'zenos' => Zenos.new
  }

  VALID_QUITS = [
    'quit',
    'q',
    'exit',
    'e',
    'give up',
    'g'
    ]

  attr_accessor :human, :computer, :round, :history

  def initialize
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
      puts "Please choose your opponent:"
      list_opponents
      input = gets.chomp.downcase
      break if OPPONENTS.has_key?(input)
      puts "Invalid opponent. Please type in a valid opponent."
    end
    @computer = OPPONENTS[input] #where would be best to put the hash to convert the string input into the actual opponent object?
  end

  def list_opponents
    OPPONENTS.each_value do |opponent|
      puts "- #{opponent.name}"
    end
  end

  def display_welcome_message
    system 'clear'
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock (RPSLS)! You'll be playing against #{computer}. Each round will be worth one point, and the winner is whoever reaches 10 points first."
    puts "Press any key to start!"
    gets
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Goodbye!"
  end

  def display_moves
    puts "#{human} chose #{human.move}."
    puts "#{computer} chose #{computer.move}."
  end

  def display_score
    puts "#{human}'s score: #{human.score}. #{computer}'s score: #{computer.score}"
  end

  def display_round_winner
    if human.move > computer.move
      puts "#{human} won this round!"
    elsif human.move < computer.move
      puts "#{computer} won this round!"
    else
      puts "It's a tie!"
    end
  end

  def update_score_and_history
    if human.move > computer.move
      human.score.increase
    elsif human.move < computer.move
      computer.score.increase
    end
    record_moves
  end

  def reset_scores
    human.score.reset
    computer.score.reset
  end

  def winning_score?
    human.score.win? || computer.score.win?
  end

  def display_overall_winner
    winner = human.score.win? ? human : computer
    puts "#{winner} reached 10 points and is the overall winner!"
  end

  def play_again?
    answer = nil

    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    answer.downcase == 'y'
  end

  def continue?
    
  end

  def clear_screen
    system 'clear'
  end

  def pause
    sleep 1
  end

  def quit?
    answer = nil
    loop do
      puts "Type 'quit', 'exit', or 'give up' to stop playing. Type 'history' to see move history. Press [ENTER] to continue playing."
      answer = gets.chomp
      break unless answer == 'history'
      display_move_history
    end
    VALID_QUITS.include?(answer)
  end

  def display_move_history
    history.display(computer.name)
    wait_for_input
    clear_screen
  end

  def wait_for_input
    gets
  end

  def play
    display_welcome_message

    loop do
      increase_round
      clear_screen
      display_score
      human.choose
      computer.choose(human.move, human.score)
      display_moves
      update_score_and_history
      display_round_winner
      pause
      if winning_score?
        display_overall_winner
        break unless play_again?
        reset_scores #need to reset game (score, history, choose new opponent)
      else
        break if quit?
      end
    end

    display_goodbye_message
  end
end

RPSGame.new.play
