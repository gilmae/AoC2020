require './helper.rb'
require 'optparse'
require './circular_linked_list.rb'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

cups = data[0].split("").map(&:to_i)

Min, Max = cups.minmax

game = CircularList.new
index = {}
cups.each {|c| 
  index[c] = game.insert c
}

current_cup = game.head


def print_cups game, current
  ret = []
  
  game.full_scan {|c| ret.push(c===current ? "(#{c.data})" : c.data.to_s)}
  puts "cups: #{ret.join(", ")}"
end

def pickup_cups game, current_cup
  picked_up = []
  3.times {|_|
    picked_up.push current_cup.next.data
    game.remove_next current_cup
  }

  picked_up
end

def find_next_destination cups, cur, pickup, index
  possibility = cur.data-1
  while  pickup.include?(possibility) || possibility < Min
    
    if possibility < Min
      possibility = Max
      next
    end
    possibility-=1
  end
  return index[possibility]
end

def place_cups game, destination, pickup, index
  prev = destination
  
  pickup.each {|p|
    prev = game.insert_next prev, p
    index[p] = prev
  }
end

100.times {|round|
  puts "\n-- Move #{round+1} --"
  print_cups game, current_cup
  picked_up = pickup_cups game, current_cup
  destination = find_next_destination game, current_cup, picked_up, index
  puts "pick up: #{picked_up.join(", ")}"
  puts "destination: #{destination.data}"

  place_cups game, destination, picked_up, index

  current_cup = current_cup.next

}

puts "\n== final =="
print_cups game, current_cup

start = index[1]
cursor = start.next
ret = ""
while cursor != start
  ret += cursor.data.to_s
  cursor = cursor.next
end

puts ret


# PART B
game = CircularList.new
index = {}
last = nil
cups.each {|c| 
  index[c] = game.insert c
  last = index[c]
}

(Max+1..1000000).each {|c|
  index[c] = game.insert_next last, c
  last = index[c]
}
Max = 1000000
current_cup = game.head

10000000.times {|round|
  picked_up = pickup_cups game, current_cup
  destination = find_next_destination game, current_cup, picked_up, index
  place_cups game, destination, picked_up, index

  current_cup = current_cup.next
}
star_cup_1 = index[1].next
star_cup_2 = star_cup_1.next

puts star_cup_1.data * star_cup_2.data