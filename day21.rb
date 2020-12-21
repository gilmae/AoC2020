require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

allergens = {}
all_foods = Hash.new(0)

data.each {|line|
  parts = line.split(" (contains ")
  foods = parts[0].split(" ")
  foods.each {|f|
    all_foods[f] = all_foods[f] + 1
  }
  agens = parts[1][0..-2].split(", ")
  agens.each {|a|
    if !allergens.include? a
      allergens[a] = foods
    else
      allergens[a] = allergens[a].intersection foods
    end
  }
}

allergen_ingredients = {}
allergens.each {|k,v|
  v.each{|f|
    all_foods.delete(f)
    if v.length == 1
      allergen_ingredients[v.first] = k
    end
  }
}
p all_foods.values.sum
while allergens.keys.length > allergen_ingredients.keys.length
  allergens.each {|k,v|
    v = v.difference(allergen_ingredients.keys)
    allergen_ingredients[v.first] = k if v.length == 1
  }
end

flipped = {}

allergen_ingredients.each {|k,v|
  flipped[v] = k
}
p flipped.keys.sort.map {|k|
  flipped[k]
}.join(",")





