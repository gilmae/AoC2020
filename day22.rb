require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)


class Combat
  attr_accessor :player1, :player2

  def initialize p1, p2
    @player1 = p1
    @player2 = p2
  end

  def play
    round = 0
      while @player1.has_cards? && @player2.has_cards?
        round += 1
        card1 = @player1.deal
        card2 = @player2.deal
        
        min,max = [card1,card2].minmax
        if card1 > card2
          @player1.take_winnings max, min
        else
          @player2.take_winnings max, min
        end
      end

      if @player2.has_cards?
        return @player2, @player2.score
      else
        return @player1, @player1.score
      end
  end
end

class RecursiveCombat
  attr_accessor :player1, :player2, :rounds, :parent_game

  def initialize p1, p2, parent_game
    @player1 = p1
    @player2 = p2
    @rounds = []
    @gameid = Games.length + 1
    @parent_game = parent_game
  end

  def play
    puts "\n=== Game #{@gameid} ==="

    if @gameid > 1 && @player1.cards.include?(HighestCard)
      puts "Player 1 is the winner because they have the highest card"
      return @player1, 0
    end
    round = 0
    while @player1.has_cards? && @player2.has_cards?
      round += 1
      puts "\n-- Round #{round} (Game #{@gameid}) --"
        puts "Player 1's deck : #{@player1.cards}"
        puts "Player 2's deck : #{@player2.cards}"
        
        if rounds.include?(hands_state)
          puts "Seen this configuration before, Player 1 wins"
          return @player1, 0
        end
        rounds.push hands_state
        card1 = @player1.deal
        card2 = @player2.deal
        
        puts "Player 1 plays: #{card1}, #{@player1.cards.length} cards remaining"
        puts "Player 2 plays: #{card2}, #{@player2.cards.length} cards remaining"

        # Check to see if new recursion required
        if (card1 <= @player1.cards.length && card2 <= @player2.cards.length)
          puts "Playing a sub-game to determine the winner..."
          np1 = Player.new @player1.id, @player1.cards.slice(0..card1-1)
          np2 = Player.new @player2.id, @player2.cards.slice(0..card2-1)

          game = RecursiveCombat.new(np1, np2, @gameid)
          Games.push game

          w, _ = game.play
          if w.id == @player1.id
            @player1.take_winnings card1, card2
            puts "Player 1 wins round #{round} of game #{@gameid}"
          else
            @player2.take_winnings card2, card1
            puts "Player 2 wins round #{round} of game #{@gameid}"
          end
          
        else
          min,max = [card1,card2].minmax
          
          if card1 > card2
            @player1.take_winnings card1, card2
            puts "Player 1 wins round #{round} of game #{@gameid}"
          else
            @player2.take_winnings card2, card1
            puts "Player 2 wins round #{round} of game #{@gameid}"
          end
        end
    end

    if @player2.has_cards?
      puts "The winner of game #{@gameid} is Player 2"
      puts "...anyway, back to game #{@gameid-1}" if  @gameid > 1
      return @player2, @player2.score
    else
      puts "The winner of game #{@gameid} is Player 1"
      puts "...anyway, back to game #{@parent_game}" if  @gameid > 1
      return @player1, @player1.score
    end
  end

  def hands_state
    "#{@player1.cards.join(",")}|#{@player2.cards.join(",")}"
  end
end

class Player
  attr_accessor :cards, :id

  def initialize id, cards
    @id = id
    @cards = cards
  end

  def deal
    @cards.shift
  end

  def take_winnings card1, card2
    @cards.push card1
    @cards.push card2
    nil
  end

  def has_cards?
    @cards.length > 0
  end

  def score
    total = 0
    multiplier = @cards.length

    cards.each {|c|
      total += c * multiplier
      multiplier -=1
    }
    total
  end
end

players = []
Games = []

data.each {|line|
  if line != ""
    if /Player (?<id>\d):/ =~ line
      players.push Player.new(id, [])
    else
      players.last.cards.push line.to_i
    end
  end
}

HighestCard = (players[0].cards + players[1].cards).max

# game = Combat.new players[0], players[1]
# winner, score = game.play
# p score

game = RecursiveCombat.new players[0], players[1], 0
Games.push game
winner, score = game.play
p score
