require './helper.rb'
include Helper
data = get_data("#{__FILE__}".gsub(/\.rb/, ".input")).join("")

groups = data.split("\n\n")

# Count of distinct answers after unioning all member's answers
def part1 groups
    yeses = groups.map { | g |
        g.gsub(/[^a-z]/,"").chars.uniq.length
    }

    return yeses.reduce(0){ |m,v|
        m+v
    }
end

# Count of distinct answers after intersecting all member's answers
def part2 groups
    yeses = groups.map { | g |
        members = g.split("\n")
        shared_answers = members.reduce("abcdefghijklmnopqrstuvwxyz".chars) { |m,v |
            m & v.chars
        }.uniq.length
    }

    return yeses.reduce(0){ |m,v|
        m+v
    }
end

puts part1(groups)
puts part2(groups)

