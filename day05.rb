require './helper.rb'
include Helper
data = get_data("#{__FILE__}".gsub(/\.rb/, ".input"))

def row_number code
    rows = (0..127).to_a
    
    code.chars.each { |c| 
        if c == "F"
            rows = rows.each_slice(rows.length/2).to_a[0]    
        else
            rows = rows.each_slice(rows.length/2).to_a[1]
        end
    }
    return rows
end

def seat_number code
    rows = (0..7).to_a
    
    code.chars.each { |c| 
        if c == "L"
            rows = rows.each_slice(rows.length/2).to_a[0]    
        else
            rows = rows.each_slice(rows.length/2).to_a[1]
        end
    }
    return rows
end

seat_ids = data.map{ |code| 
    row_number(code[0,7])[0]*8 +seat_number(code[7,3])[0]
}

seat_ids = seat_ids.sort

puts seat_ids.last

sum_of_seat_numbers = (seat_ids.first..seat_ids.last).reduce(0) { |memo, i |
    memo + i
}

sum_of_actual_seats = seat_ids.reduce(0){ |m,i| 
    m + i
}

puts sum_of_seat_numbers - sum_of_actual_seats

