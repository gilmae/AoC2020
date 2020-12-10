require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map{|i|i.to_i}

adapters = data.sort
jolt_gaps = Hash.new(0)
last_adapter = 0
adapter = 0

while adapters.length > 0
    (0..2).each{|i|
        adapter = adapters.shift
        
        gap = adapter - last_adapter
        #puts "#{last_adapter} -> #{adapter} is #{gap} jolts"
        if gap >=1 && gap <=3
            jolt_gaps[gap]+=1
            last_adapter = adapter
            break
        end
    }
end

jolt_gaps[3] += 1 # Device is always 3 higher than highest adapter

puts jolt_gaps[1], jolt_gaps[3]
puts jolt_gaps[1] * jolt_gaps[3]