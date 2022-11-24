=begin
To do:
- clear the screen after each round
- keep track of the round number
- standardize display
  - better interface

- organize RPSGame#play method into different phases
  - opening phase
  - gameplay phase
  - post-game phase
- allow user and opponent to make opening statements prior to beginning main game loop
- have computer taunt after 8 rounds
- have computer make a statement after winning and after losing
- check flow of game & determine when to have sleeps and how long
- implement move history (see exploration_space.rb for initial thoughts and draft ideas)
  - allow user to check move history by typing 'history' before choosing a move
- rubocop program

Ask LS Slack question about how Ruby looks up constants for child and parent classes.
See exploration_space.rb and 
https://stackoverflow.com/questions/48817287/accessing-a-childs-constant-from-the-parents-class
https://stackoverflow.com/questions/9949655/get-child-constant-in-parent-method-ruby
for examples of what I'm talking about.


=end

class Score
  WINNING_SCORE = 10
  STARTING_SCORE = 0

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
    @score >= WINNING_SCORE
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

class MoveHistory
  attr_accessor :history
  
  def initialize
    @history = []
  end
  
  def reset
    @history = []
  end
  
  def record(move)
    history << move
  end
  
  def to_s
    history
  end
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
    @move_history = MoveHistory.new
  end
  
  def record_move
    move_history.record(move.to_s)
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
    self.record_move
  end
end

class Computer < Player
  def set_name
    @name = self.class.to_s
  end

  def choose_random
    self.move = USER_INPUT_CONVERSION[(USER_INPUT_CONVERSION.keys.sample)]
    self.record_move
  end
  
  def choose_rock
    self.move = Rock.new
    self.record_move
  end
  
  def choose_paper
    self.move = Paper.new
    self.record_move
  end
  
  def choose_scissors
    self.move = Scissors.new
    self.record_move
  end
  
  def choose_lizard
    self.move = Lizard.new
    self.record_move
  end
  
  def choose_spock
    self.move = Spock.new
    self.record_move
  end
  
  def choose_losing_move(human_move)
    self.move = human_move.class::WINS_AGAINST[0]
    self.record_move
  end
  
  def choose_winning_move(human_move)
    self.move = human_move.class::LOSES_AGAINST[0]
    self.record_move
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

  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    choose_opponent
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
    ['Rockman', 'Papyrus', 'DJ Cutman', 'Martin', 'Picard', 'Glass Joe', 'GLaDOS', 'Zenos'].each do |name|
      puts "- #{name}"
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

  def update_score
    if human.move > computer.move
      human.score.increase
    elsif human.move < computer.move
      computer.score.increase
    end
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

  def clear_screen
    system 'clear'
  end

  def pause
    sleep 1
  end

  def play
    display_welcome_message

    loop do
      clear_screen
      display_score
      human.choose
      computer.choose(human.move, human.score)
      display_moves
      update_score
      display_round_winner
      pause
      if winning_score?
        display_overall_winner
        break unless play_again?
        reset_scores
      end
    end

    display_goodbye_message
  end
end

RPSGame.new.play
