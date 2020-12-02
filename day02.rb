require './helper.rb'
include Helper

data = get_data("day02.input").map{|l|l.chomp}



def part1(data)
    count = 0
    data.each {|l|
        /(?<min>\d+)-(?<max>\d+)\s(?<req>[a-z]{1}):\s(?<pwd>[a-z]+)/ =~ l
        a = pwd.count(req)
        count += 1 if a>=min.to_i && a<=max.to_i
    
    }
    p count
end

def part2(data)
    count = 0
    count = data.reduce(0) {|memo,l|
        /(?<min>\d+)-(?<max>\d+)\s(?<req>[a-z]{1}):\s(?<pwd>[a-z]+)/ =~ l
        if ((pwd[min.to_i-1] == req) ^ (pwd[max.to_i-1] == req))
            memo + 1 
        else
            memo
        end
    
    }
    p count
end

part1(data)
part2(data)

