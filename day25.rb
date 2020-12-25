require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:to_i)

def get_key subject, loop_size
  t = 1
  loop_size.times {|_|
    t = (t * subject) % 20201227
  }
  t
end

def brute_force_loop_size public_key
  loop_size = 0
  t = 1
  while t != public_key
    t = (t * 7) % 20201227
    loop_size += 1
  end
  loop_size
end
room_loop_size = brute_force_loop_size data[0]
door_loop_size = brute_force_loop_size data[1]

p room_loop_size
p door_loop_size

p get_key data[0], door_loop_size

