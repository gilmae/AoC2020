require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

# Parse Rules
rule_regex = /(?<id>\d+):(?<rule>.+)/
baseline_rule_regex = /(?<id>\d+): "(?<rule>\w)"/
rules = data.select{|r| rule_regex =~ r}
unknown_rules = {}
known_rules = {}

loops = 0
while rules.length > 0 and loops < 20
  r = rules.shift
  if matches = r.match(baseline_rule_regex)
    #puts "Add #{matches[:id]}=>#{matches[:rule]} to known rules"
    known_rules[matches[:id]] = matches[:rule]
    next
  end

  matches = r.match(rule_regex)
  parts = matches[:rule].split("|").map(&:strip)

  ids = parts.map{|p|
    p.split(" ").map(&:strip)
  }

  if ids.flatten.select{|id| !known_rules.include? id}.length > 0
    rules.push r
  else
    matched_to_rules = ids.map{|id|
      id.map{|i| known_rules[i]}.join("")
    }
    
    known_rules[matches[:id]] = "(#{matched_to_rules.join("|")})"

    #puts "Add #{matches[:id]}=>#{matched_to_rules.join("|")} to known rules"
  end
  
end

p known_rules["0"]
# Parse Messages
messages = data.select{|line| /^[ab]+$/ =~ line}.map(&:strip)

p messages.select{|m| Regexp.new("^#{known_rules["0"]}$") =~ m}.length
