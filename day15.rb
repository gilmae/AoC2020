require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
  opt.on('--turns TURNS') {|o| options[:turns] = o.to_i}
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)[0].split(",").map{|d|d.to_i}

rounds = options[:turns] || 2020
numbers = {}
current_turn = 1
last_spoken = nil
data.each {|n,i| 
  last_spoken = n.to_i
  numbers[n] = [current_turn]
  current_turn +=1
}

while current_turn <= rounds
   spoken_at = numbers[last_spoken] || []

   #puts "TURN #{current_turn}"
   #puts "#{last_spoken} was spoken at #{spoken_at.join("|")}"
   if spoken_at.length == 1
     last_spoken = 0
     #puts "That was the first time it was spoken, so now we say #{last_spoken}"
    else
     ages = spoken_at.slice(-2..-1)

     last_spoken = ages[1]-ages[0]
     #puts "It has been spoken #{spoken_at.length} times, so now we say #{last_spoken}"

    end

   if !numbers.include? last_spoken
    numbers[last_spoken] = []
   end
   numbers[last_spoken].push current_turn
   

   current_turn +=1
 end

 #p turns

 puts "Last spoken after #{rounds} turns: #{last_spoken}"



