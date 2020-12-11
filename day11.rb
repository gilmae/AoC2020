require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map{|line|line.chars}

states = [data]

def surrounding_seat_occupancy state, row, col
    occupied_seats = 0
    (-1..1).each {|drow|
        (-1..1).each {|dcol|
            next if row+drow == row && col+dcol == col
            next if state[row+drow].nil? || row+drow < 0
            next if col+dcol >= state[row+drow].length || col+dcol < 0
            occupied_seats += 1 if state[row+drow][col+dcol] == "#"
        }
    }

    return occupied_seats
end



def will_become_occupied? state, row, col 
    return state[row][col] == "L" && surrounding_seat_occupancy(state,row,col) == 0
end

def will_become_unoccupied? state, row, col
    return true if state[row][col] =="L"

    return surrounding_seat_occupancy(state, row, col) >=4
end



def tick state
    next_state = []
    state.each_with_index { |row, row_index|
        new_row = []
        row.each_with_index { |col, col_index|
            seat = row[col_index]
            if seat == "L"
                seat = "#" if will_become_occupied?(state,row_index,col_index)
            elsif seat == "#"
                seat = "L" if will_become_unoccupied?(state,row_index,col_index)
            end
            new_row.push seat
        }
        next_state.push new_row
    }
    return next_state
end

def print_state state
    state.each_with_index { |row, row_index|
        puts(row.join(""))
    }
end

def count_total_occupancy state
    state.map {|row|
        row.reduce(0) {|m,v| m + (v=="#"?1:0)}
    }.reduce(&:+)
end

state = data
last_state = []

# index = 0
# while (state != last_state)
#     last_state = state
#     state = tick(state)
#     index +=1
# end

# puts index
# #print_state state
# puts count_total_occupancy state

def seeable_seat_occupancy state, row, col
    occupied_seats = 0
    (-1..1).each {|drow|
        (-1..1).each {|dcol|
            next if drow == 0 && dcol == 0
            
            cur_row = row + drow
            cur_col = col + dcol
            sight_blocked = false
            while !sight_blocked && cur_row<state.length && cur_row >= 0 && cur_col < state[row].length && cur_col >= 0
                if state[cur_row][cur_col] == "#"
                    occupied_seats += 1
                    sight_blocked = true
                elsif state[cur_row][cur_col] == "L"
                    sight_blocked = true
                end
                cur_row = cur_row + drow
                cur_col = cur_col + dcol
            end
        }
    }
    return occupied_seats
end

def partB_will_become_occupied? state, row, col 
    return state[row][col] == "L" && seeable_seat_occupancy(state,row,col) == 0
end

def partB_will_become_unoccupied? state, row, col
    return true if state[row][col] =="L"

    return seeable_seat_occupancy(state, row, col) >=5
end

def tick state
    next_state = []
    state.each_with_index { |row, row_index|
        new_row = []
        row.each_with_index { |col, col_index|
            seat = row[col_index]
            if seat == "L"
                seat = "#" if partB_will_become_occupied?(state,row_index,col_index)
            elsif seat == "#"
                seat = "L" if partB_will_become_unoccupied?(state,row_index,col_index)
            end
            new_row.push seat
        }
        next_state.push new_row
    }
    return next_state
end

index = 0
while (state != last_state)
    last_state = state
    state = partB_tick(state)
    index +=1
end

puts index
#print_state state
puts count_total_occupancy state
