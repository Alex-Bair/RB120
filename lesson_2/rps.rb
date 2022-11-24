=begin
To do:
- clear the screen after each round
- standardize display
- organize RPSGame#play method into different phases
  - opening phase
  - gameplay phase
  - post-game phase
- check flow of game & determine when to have sleeps and how long

Ask LS Slack question about how Ruby looks up constants for child and parent classes.
See exploration_space.rb and 
https://stackoverflow.com/questions/48817287/accessing-a-childs-constant-from-the-parents-class
https://stackoverflow.com/questions/9949655/get-child-constant-in-parent-method-ruby
for examples of what I'm talking about.


=end

class Score
  WINNING_SCORE = 10
  STARTING_SCORE = 9

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

class Player
  USER_INPUT_CONVERSION = {
    'rock' => Rock.new,
    'paper' => Paper.new,
    'scissors' => Scissors.new,
    'lizard' => Lizard.new,
    'spock' => Spock.new
  }
  
  attr_accessor :move, :name, :score

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
    self.name = ['Robot1', 'Robot2', 'Robot3'].sample
  end

  def choose
    self.move = USER_INPUT_CONVERSION[(USER_INPUT_CONVERSION.keys.sample)]
  end
end

# Game Orchestration Engine
class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
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
      computer.choose
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
