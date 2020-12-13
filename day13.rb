require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)
earliest_departure_time = data[0].to_i

buses = data[1].split(',').delete_if{|b| b == 'x'}

first_times = buses.map {|b| [b.to_i, ((earliest_departure_time*1.0) / b.to_i).ceil()]}.map {|t| [t[0], t[1], t[0]*t[1]]}

min = earliest_departure_time * earliest_departure_time
wait = 0
first_times.each {|time|
  if min > time[2]
    min = time[2]
    wait = time[0] * (time[2]-earliest_departure_time)
  end
}

puts wait

# Part 2
buses = data[1].split(',').map{|b| b.to_i}
minValue = 0
runningProduct = 1
buses.each_with_index {|b,i|
  next if b == 0
  while (minValue + i) % b != 0
    minValue += runningProduct
  end
  runningProduct *= b
  puts "Sum so far #{minValue}, product so far #{runningProduct}"
}

puts minValue


