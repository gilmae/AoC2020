require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

memory = {}



values = data

def apply_mask mask, number
  binary = number.to_s(2).chars.reverse
  reverse_mask = mask.chars.reverse
  reverse_mask.map.with_index {|bit,i|
    case bit
    when 'X'
      binary[i].to_i * 2 ** i
    else
      bit.to_i * 2 ** i
    end

  }.sum
end

def binary_to_decimal binary
  binary = binary.chars.reverse
  binary.map.with_index {|bit,i|
     bit.to_i * 2 ** i
  }.sum
end

def apply_mask_with_floating mask, number
  binary = number.to_s(2).chars
  reverse_mask = mask.chars

  if (binary.length < mask.length)
    binary = ("0"*(mask.length - binary.length)).chars + binary
  elsif (binary.length > mask.length)
    mask = ("0"*(binary.length - mask.length)).chars + mask
  end 
  length = [binary.length, mask.length].max
  masked = []
  i = 0
  while i < length
    case mask[i]
    when 'X'
      masked[i] = 'X'
    when '1'
      masked[i] = '1'
    else
      masked[i] = binary[i]
    end
    i +=1
  end
  
  return masked.join('')
end

def get_memory_locations floating_addr
  addr = ['']
  floating_addr.chars.reverse.each{|bit|
    case bit
    when 'X'
      addr = addr.map{|a| a + '0'} + addr.map{|a| a + '1'}
    else
      addr = addr.map{|a| a + bit}
    end
  }
  addr.map{|a| a.reverse}
end


# part A
mask = "X" * 64
values.each {|line|
  if line[0..3] == "mask"
    /mask = (?<new_mask>.+)/ =~ line.chomp
    mask = new_mask
    next
  end

  /mem\[(?<mem>\d+)\] = (?<value>\d+)/ =~ line

  memory[mem] = apply_mask mask, value.to_i
}

p memory.values.sum


# part b
memory = {}
mask = "X" * 64
values.each {|line|
  if line[0..3] == "mask"
    /mask = (?<new_mask>.+)/ =~ line.chomp
    mask = new_mask
    next
  end

  /mem\[(?<mem>\d+)\] = (?<value>\d+)/ =~ line
  #puts "Masking #{mem} with #{mask}"
  get_memory_locations(apply_mask_with_floating(mask, mem.to_i)).each{|addr| memory[binary_to_decimal(addr)] = value.to_i}
}
p memory.values.sum

