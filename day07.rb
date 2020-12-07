require './helper.rb'
include Helper
data = get_data("#{__FILE__}".gsub(/\.rb/, ".input"))

bag_contents = {}
outer_bags = {} # bags not contained in any other bag
 
class Content
    attr_accessor :number, :bag_type
    def initialize(number, type)
        @number = number
        @bag_type = type
    end
end

data.each {|i| 
    /(?<bag>[\w\s]+s)\scontain\s(?<contents>.*)/ =~ i
    
    bag = bag.delete_suffix("s")
    bag_contents[bag] = nil
    outer_bags[bag] = true unless (outer_bags[bag] == false)

     if contents != "no other bags."
        bag_contents[bag] = contents.split(", ").map{|c|
            /(?<num>\d+)\s(?<type>[\w\s]+)/ =~ c
            type = type.delete_suffix("s")
            outer_bags[type] = false
            Content.new(num,type)
        }
    end
}

outer_bags.delete_if {|k,v| v == false}

bags_containing_mine = {}

def find_type_in_contents search_bag, bag_type, bag_contents, outer_bag, bags_containing_mine
    # if the bag being inspected is already known to contain mine, add the outer bag to bags_containing mine and return
    # if the bag being inspected has no contents, abort
    # else recurse over contents    

    return if outer_bag == search_bag
    if !bags_containing_mine[bag_type].nil? 
        
        bags_containing_mine[outer_bag] = true
        return
    end

    if search_bag == bag_type
        bags_containing_mine[outer_bag] = true
        return
    end

    return if bag_contents[bag_type].nil?

    bag_contents[bag_type].each {|c|
        find_type_in_contents("shiny gold bag", c.bag_type, bag_contents, outer_bag, bags_containing_mine)
    }
    
end


bag_contents.keys.each { |t|
    find_type_in_contents "shiny gold bag", t, bag_contents, t, bags_containing_mine
}

p bags_containing_mine.length

def get_contents_of_bag bag, bag_contents
    return 1 if bag_contents[bag].nil?
    return 1 + bag_contents[bag].map {|b| # that 1+ introduces an off by one where the bag is the outer bag...deal with it outside
        b.number.to_i * get_contents_of_bag(b.bag_type, bag_contents)
    }.reduce(0){|m,v| m+v}
end

p get_contents_of_bag("shiny gold bag", bag_contents) - 1 # off by one error...ignore myself





