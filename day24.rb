require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

EAST = 0
SOUTHEAST = 1
SOUTHWEST = 2
WEST = 3
NORTHWEST = 4
NORTHEAST = 5

tiles = Hash.new(false)

def next_tile x, y, direction
  new_x = x
  new_y = y
  case direction
  when EAST
    new_x += 1
  when WEST
    new_x -= 1
  when SOUTHEAST
    new_y -=1
    new_x +=1 if y%2==1
  when SOUTHWEST
    new_y -=1
    new_x -=1 if y%2==0
  when NORTHEAST
    new_y +=1
    new_x +=1 if y%2==1
  when NORTHWEST
    new_y +=1
    new_x -=1 if y%2==0
  end

  return new_x, new_y
end

def get_neighbours x,y, tiles
  neighbours = []
  (EAST..NORTHEAST).each {|direction|
    new_x, new_y = next_tile x,y, direction
    neighbours.push [new_x,new_y]
  }
  neighbours
end

def tick tiles
  
  working = Hash.new(false)

  tiles.each {|k,v|
    working[k] = true
    neighbours = get_neighbours k[0], k[1], tiles

    neighbours.each {|n|
      working[n] = tiles.include? n
    }
  }

  next_state = Hash.new(false)

  working.each {|k,v|
    neighbours = get_neighbours k[0], k[1], tiles
    neighbour_count = neighbours.map{|n|
      tiles[n] ? 1 : 0
    }.sum

    if v 
      next_state[k] = neighbour_count == 1 || neighbour_count == 2
    else
      next_state[k] = neighbour_count == 2
    end
  }
  return next_state.delete_if {|k,v| !v}
end

def get_direction directions
  direction = directions.shift
  direction += directions.shift if direction == 's' || direction == 'n'
  case direction
  when 'e'
    return EAST, directions
  when 'w'
    return WEST, directions
  when 'se'
    return SOUTHEAST, directions
  when 'sw'
    return SOUTHWEST, directions
  when 'ne'
    return NORTHEAST, directions
  when 'nw'
    return NORTHWEST, directions
  else
    abort("Unknown direction *#{direction}*")
  end  
end

data.each {|line|
  x = 0
  y = 0
  directions = line.chars
    
  while directions.length > 0
    next_direction, directions = get_direction directions
    x, y = next_tile x,y, next_direction

    
  end
  tiles[[x,y]] = tiles[[x,y]] ^ true
}

tiles.delete_if {|k,v| !v}

p tiles.select{|t| t}.length
100.times {|_|
  tiles = tick tiles
}
p tiles.select{|t| t}.length


