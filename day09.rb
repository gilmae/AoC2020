require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

def find_pair(components, target)
    h = Hash[components.map{|i|[i,true]}]
    half = target/2
    components.each {|i|
        next if i > half

        return [i,target-i] if h[target-i]
    }

    nil
end

def find_invalid_number data
    components = data[0,25]

    stream = data[25..-1]
    
    while stream.length > 0
        target = stream.shift
    
        pair = find_pair(components, target)
    
        if pair.nil?
            return target
        end
    
        components.shift
        components.push target
    end
end

def find_encryption_weakness data, target
    index = 0

    data.each_with_index {|v,i|
        length=0
        slice = data[i..i+length]
        sum = slice.inject(:+)
        while i+length < data.length && sum < target
            length+=1
            slice = data[i..i+length]
            sum = slice.inject(:+)
        end
        
        if sum == target
            min,max = slice.minmax

            return min+max
        end
    }
end

data = get_data(input).map{|i|i.to_i}

invalid = find_invalid_number data

abort ("No invalid number found") if invalid.nil?

puts invalid

puts find_encryption_weakness(data, invalid)





