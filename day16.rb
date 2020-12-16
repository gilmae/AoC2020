require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

def is_valid_for_any_field fields, value
  fields.keys.each {|f|
    return true if fields[f][value]
  }
  return false
end

def valid_fields_for_value fields, value, field_names
  field_names.filter_map {|f|
    f if fields[f][value]
  }
end

# get field defs
fields = {}
index = 0
while data[index] != ""
  parts = data[index].split(": ")
  name = parts[0]
  classes = parts[1].split(" or ")
  field_dict = {}
  classes.each{|c|
    minmax = c.split("-")
    (minmax[0].to_i..minmax[1].to_i).each{|i|
      field_dict[i] = true
    }
  }
  fields[name] = field_dict
  index +=1
end

index+=2

my_data = data[index].split(",").map(&:to_i)

index +=2

# Part ! 
other_tickets = data.slice(index+1..-1)
p other_tickets.map {|ticket|
  ticket_fields = ticket.split(",").map(&:to_i)
  # for each field in ticket, iterate through fields and find at least one field it matches
  field_validities = ticket_fields.map{|tf|
    is_valid_for_any_field(fields, tf) ? 0 : tf
  }
  
  field_validities.sum
}.sum

valid_tickets = other_tickets.select {|ticket|
  ticket_fields = ticket.split(",").map(&:to_i)
  # for each field in ticket, iterate through fields and find at least one field it matches
  field_validities = ticket_fields.map{|tf|
    is_valid_for_any_field(fields, tf) ? 0 : tf
  }
  
  field_validities.sum == 0
}.map{|t|t.split(",").map(&:to_i)}

field_names = fields.keys
field_positions_on_ticket = field_names.map{|i| nil}

# For each position on a ticket, find all the fields it could be valid for
# If there is only one field it can be valid for, assume that that position is that field
# We really only need to do this until we have found all of the fields that start with departure
# Which is good because we can never narrow down what positions "duration", "price", "route", and "wagon" are in
while field_names.length > 0  && field_names.select{|name| name =~ /departure/}.length > 0
  my_data.each_with_index {|_,i|
  
  next unless field_positions_on_ticket[i].nil?

    possible_fields = valid_tickets.reduce(fields.keys){|memo, ticket|
      memo.intersection(valid_fields_for_value(fields, ticket[i], field_names))
    }
    
    
    if possible_fields.length == 1
       field_positions_on_ticket[i] = possible_fields[0]
       field_names.delete(possible_fields[0])
     end
  }
end
p field_names

sum = 1
field_positions_on_ticket.each_with_index {|name,i|
  sum *= my_data[i] if name =~ /departure/
}

p sum
