require './helper.rb'
require 'optparse'

TOP = 0
BOTTOM = 1
LEFT = 2
RIGHT = 3

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

class Tile
  attr_accessor :id, :pixels, :matches, :edges, :flipped_edges

  def initialize id, pixels
    @id = id
    @pixels = pixels
    @matches = []
  end

  def edges 
    @edges unless @edges.nil?
    @edges = [0,0,0,0] 
    
    # left to right
    (0..9).each {|i|
      @edges[TOP] |= 1<< i if @pixels[[i,0]]
      @edges[BOTTOM] |= 1<<i if @pixels[[i,9]]
      @edges[LEFT] |= 1<<i if @pixels[[0,i]]
      @edges[RIGHT] |= 1<<i if @pixels[[9,i]]
    }
    
    @edges
  end

  def flipped_edges 
    @flipped_edges unless @flipped_edges.nil?
    @flipped_edges = [0,0,0,0]
    normal_edges = edges
    
    # left to right
    (0..3).each {|e|
      (0..9).each {|i|
        @flipped_edges[e] |= ((normal_edges[e] >> i) & 1) << (9 - i)
      }
    }
    
    @flipped_edges
  end

  def joins? tile
    return false if @id == tile.id
    return true if edges.intersection(tile.edges).length > 0
    return true if edges.intersection(tile.flipped_edges).length > 0
    return true if flipped_edges.intersection(tile.edges).length > 0
    return flipped_edges.intersection(tile.edges).length > 0
  end
end

tiles = {}

# Read Tiles
index = 0
while index < data.length
  tile_def = data[index..index+10]
  id = tile_def[0][5..-2].to_i
  pixels = {}
  tile_def[1..-1].each_with_index{|l, y| 
    l.chars.each_with_index{|c, x| pixels[[x,y]] = c=="#"}
  }
  
  tiles[id] = Tile.new(id, pixels)
  index += 12
end

def print_tile tile
  (0..9).each {|y|
    line = ""
    (0..9).each {|x|
      line += tile.pixels[[x,y]]? "#" : "."
    }
    puts line
  }
end

tiles.values.each {|tile1|
  tile1.matches = []
  tiles.values.each {|tile2|
    if tile1.joins?(tile2)
      tile1.matches << tile2.id unless tile1.matches.include? tile2.id
      tile2.matches << tile1.id unless tile2.matches.include? tile1.id
    end
  }
}

corners = tiles.values.select{|t|t.matches.length==2}.map(&:id)
sides = tiles.values.select{|t|t.matches.length==3}.map(&:id)

puts "Found #{corners.length} corners and #{sides.length} sides"

p corners.reduce(&:*)