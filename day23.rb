require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

cups = data[0].split("").map(&:to_i)


# class Ring
#   attr_accessor :size
  
#   def initialize size, values = nil
#     @buffer = Array(size, nil)

#     if !values.nil? && values.is_a? Array
#       values.each {|a| @buffer.push a}
#     end
#   end

#   def is_full?

#   end
# end

current_cup_pointer = 0

def pickup_cups cups, cur
  pointer = cur
  pickup = []
  (1..3).each {|i|
    pickup.push (cur+i)%cups.length
  }
  pickup
end

def find_next_destination cups, cur, pickup
  min,max = cups.minmax
  pickup_values = pickup.map {|p| cups[p]}
  if cur>=cups.length
    pos = cups.last-1
  else
    pos = cups[cur] -1
  end

  while cups.index(pos).nil? || pickup_values.include?(pos)
    if pos <= min
      pos = max
      next
    end
    pos-=1
  end
  return cups.index(pos)
end

def place_cups cups, cur, destination, pickup
  current_cup_value = cups[cur]

  destination_value = cups[destination]

  pickup_values = pickup.map{|p|cups[p]}
  pickup_values.each{|p|cups.delete(p)}

  puts "Placing pickup at index #{cups.index(destination_value)}"
  cups.insert(cups.index(destination_value)+1, pickup_values).flatten!

  while cups[cur] != current_cup_value
    cups.push cups.shift
  end
end


100.times {|move|
  puts "-- move #{move+1} --"
  puts "cups: #{cups.map.with_index {|c,i| i==current_cup_pointer ? "(#{c})" : c.to_s}.join(", ")}"
  pickup = pickup_cups cups, current_cup_pointer
  puts "pick up: #{pickup.map{|i|cups[i].to_s}.join(", ")}"
  destination = find_next_destination cups, current_cup_pointer, pickup
  puts "destination: #{cups[destination]} (#{destination})"
  place_cups cups, current_cup_pointer, destination, pickup
  current_cup_pointer = (current_cup_pointer + 1) % cups.length
  puts ""

}

puts "-- final --"
puts "cups: #{cups.map.with_index {|c,i| i==current_cup_pointer ? "(#{c})" : c.to_s}.join(", ")}"
  