require './helper.rb'
include Helper
data = get_data("#{__FILE__}".gsub(/\.rb/, ".input")).join("")

groups = data.split("\n\n")

yeses = groups.map { | g |
    g.gsub(/[^a-z]/,"").chars.uniq.length
}

puts yeses.reduce(0){ |m,v|
    m+v
}

