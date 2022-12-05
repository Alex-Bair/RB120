=begin
To do:

- include welcome and ending message
- add pauses to make gameplay smoother
- anything can be refactored?
=end

module Hand
  BUST_LIMIT = 21

  def hit(deck)
    puts "#{name} hit!"
    deck.deal_card_to!(self)
    puts "#{name} drew a #{cards.last}."
  end

  def stay
    puts "#{name} stayed with a total of #{total}."
  end

  def busted?
    total > BUST_LIMIT
  end

  def total
    prelim_total = sum_card_values

    if prelim_total > BUST_LIMIT && any_card_worth_11?
      ace = cards.select {|card| card.value == 11}.first
      ace.reduce_value_to_1
      total
    else
      prelim_total
    end
  end

  def show_hand(hide_last_card: false)
    puts "#{name} has:"
    if hide_last_card
      puts cards[0...-1]
      puts "Face down card"
    else
      puts cards
    end
  end

  private

  def any_card_worth_11?
    cards.any? {|card| card.value == 11}
  end

  def sum_card_values
    cards.reduce(0) do |sum, card|
      sum += card.value
    end
  end
end

class Participant
  include Hand
  attr_reader :cards, :name

  def initialize
    @cards = []
  end

  def to_s
    name
  end
end

class Player < Participant
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp.strip
      break unless n.empty?
      puts 'Invalid name. Please enter a name ' \
      'with at least one non-space character.'
    end
    self.name = n
  end

  private

  attr_writer :name

end

class Dealer < Participant
  def initialize
    super
    @name = 'Dealer'
  end
end

class Deck
  attr_accessor :cards

  CARD_VALUES = {
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "Jack" => 10,
    "Queen" => 10,
    "King" => 10,
    "Ace" => 11
  }

  CARD_NAMES = CARD_VALUES.keys

  CARD_SUITS = %w(Hearts Diamonds Spades Clubs)

  def initialize
    @cards = new_deck
    shuffle!
  end

  def new_deck
    c = []

    CARD_SUITS.each do |suit|
      CARD_NAMES.each do |name|
        c << Card.new(suit, name, CARD_VALUES[name])
      end
    end

    c
  end

  def shuffle!
    cards.shuffle!
  end

  def deal_card_to!(person)
    person.cards << cards.pop
  end
end

class Card
  attr_reader :suit, :name, :value, :article

  def initialize(suit, name, value)
    @suit = suit
    @name = name
    @value = value
  end

  def reduce_value_to_1
    @value = 1
  end

  def to_s
    "#{name} of #{suit}"
  end
end

class Game
  NUM_CARDS_IN_OPENING_HAND = 2
  DEALER_LIMIT = 17
  VALID_STAY = ['stay', 's']
  VALID_HIT = ['hit', 'h', '']
  PAUSE_DURATION = 1

  attr_reader :deck, :player, :dealer
  attr_accessor :busted_person, :winner


  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
    @busted_person = nil
    @winner = nil
  end

  def clear_screen
    system 'clear'
  end

  def wait_for_input
    gets
  end

  def pause(duration = PAUSE_DURATION)
    sleep duration
  end

  def press_enter
    puts "Press [ENTER] to continue."
    wait_for_input
  end

  def play
    welcome_phase
    deal_opening_hands!
    display_initial_cards
    player_turn
    dealer_turn unless player.busted?
    show_result
  end

  def welcome_phase
    puts "Welcome to the single player game 21!"
    puts "Rules for 21 can be found at https://www.instructables.com/How-to-Play-21Blackjack/"
    press_enter
    player.set_name
  end

  def deal_opening_hands!
    NUM_CARDS_IN_OPENING_HAND.times do |_|
      deck.deal_card_to!(player)
      deck.deal_card_to!(dealer)
    end
  end

  def display_initial_cards
    player.show_hand
    puts
    dealer.show_hand(hide_last_card: true)
  end

  def player_turn
    loop do
      puts "You have:"
      puts player.cards
      puts "You have a total of #{player.total}"
      if player.busted?
        puts "You went over #{Hand::BUST_LIMIT} and busted!"
        self.busted_person = player
        self.winner = dealer
        break
      end
      puts "Would you like to hit or stay?"
      puts "Type 's' to stay, or press [ENTER] to hit."
      answer = gets.chomp.strip.downcase #need to validate input
      if VALID_HIT.include?(answer)
        player.hit(deck)
      else
        player.stay
        break
      end
    end
  end

  def dealer_turn
    puts "The dealer reveals their face down card!"
    puts "It was the #{dealer.cards.last}!"
    loop do
      puts "Dealer has:"
      puts dealer.cards
      puts "Dealer total is #{dealer.total}"
      if dealer.busted?
        puts "Dealer went over #{Hand::BUST_LIMIT} and busted!"
        self.busted_person = dealer
        self.winner = player
        break
      end
      if dealer.total < DEALER_LIMIT
        dealer.hit(deck)
      else
        dealer.stay
        break
      end
    end
  end

  def show_result
    if busted_person
      puts "#{busted_person} busted! #{winner} won!"
    else
      puts "Results!!"
      puts "Your total: #{player.total}"
      puts "Dealer total: #{dealer.total}"
      case player.total <=> dealer.total
      when 0
        puts "It's a tie!"
      when -1
        puts "Dealer won!"
      when 1
        puts "You won!"
      end
    end
  end

end

Game.new.play