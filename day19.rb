require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
  opt.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    options[:verbose] = v
  end
  opt.on("-b", "--partB", "Run part B") do |v|
    options[:partB] = v
  end
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:chomp)

class Rule
  attr_accessor :literal, :children

  def initialize literal, children
    @literal = literal
    @children = children
  end
end

def match ruleId, rules, s
  #puts "Match Rule# #{ruleId} vs #{s}" if options[:verbose]
  rule = rules[ruleId]

  if (rule.children.length == 0) # leaf node
    #puts "#{ruleId} is a child node" if options[:verbose]
    if s.length < rule.literal.length
      #puts "Length of s (#{s.length} < length of rule literal (#{rule.literal.length}, so not this." if options[:verbose]
      return nil # can't be this
    end
    if s[0..rule.literal.length-1] == rule.literal
      #puts "s (#{s.length} matches literal (#{rule.literal}, so it matches" if options[:verbose]
      return [rule.literal.length]
    end
  end

  matchedChars = []
  rule.children.each {|c|
    potentialMatches = [0]
    c.each {|g|
      newPotentialMatches = []

      potentialMatches.each {|m|
        matches = match(g, rules, s[m..s.length])

        if matches.nil? || matches.length == 0
          #not this one
          next
        end
        matches.each{|v|
          newPotentialMatches.push m+v
        }
      }
      potentialMatches = newPotentialMatches
    }
    matchedChars = matchedChars + potentialMatches
  }

  return matchedChars

end


# Parse Rules
rule_regex = /(?<id>\d+):(?<rule>.+)/
baseline_rule_regex = /(?<id>\d+): "(?<rule>\w)"/
rules = data.select{|r| rule_regex =~ r}
unknown_rules = {}
known_rules = {}

index = 0

while index < data.length && data[index] != ""
  if matches = data[index].match(baseline_rule_regex)
    #puts "Add #{matches[:id]}=>#{matches[:rule]} to known rules"
    r = Rule.new(matches[:rule], [])
    rules[matches[:id].to_i] = r
  else
    matches = data[index].match(rule_regex)
    children = matches[:rule].split("|").map{|sr|
      sr.split(" ").map(&:to_i)
    }

    r = Rule.new("", children)
    rules[matches[:id].to_i] = r
  end
  
  index +=1

end

if options[:partB]
  rules[8] = Rule.new("", [[42],[42,8]])
  rules[11] = Rule.new("", [[42,31],[42,11,31]])
end

index +=1

matchedToRule0 = 0

messages = data[index..-1].map(&:strip)

messages.each {|msg|
  matches = match 0,rules,msg
  matches.each {|m|
    matchedToRule0 +=1 if m == msg.length
  }
}

puts matchedToRule0

#p match 0, rules, "bababa"
#p rules
# while rules.length > 0 and loops < 20
#   r = rules.shift
#   if matches = r.match(baseline_rule_regex)
#     #puts "Add #{matches[:id]}=>#{matches[:rule]} to known rules"
#     known_rules[matches[:id]] = matches[:rule]
#     next
#   end

#   matches = r.match(rule_regex)
#   parts = matches[:rule].split("|").map(&:strip)

#   ids = parts.map{|p|
#     p.split(" ").map(&:strip)
#   }

#   if ids.flatten.select{|id| !known_rules.include? id}.length > 0
#     rules.push r
#   else
#     matched_to_rules = ids.map{|id|
#       id.map{|i| known_rules[i]}.join("")
#     }
    
#     known_rules[matches[:id]] = "(#{matched_to_rules.join("|")})"

#     #puts "Add #{matches[:id]}=>#{matched_to_rules.join("|")} to known rules"
#   end
  
# end

# p known_rules["0"]
# # Parse Messages
# messages = data.select{|line| /^[ab]+$/ =~ line}.map(&:strip)

# p messages.select{|m| Regexp.new("^#{known_rules["0"]}$") =~ m}.length
