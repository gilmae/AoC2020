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
    row_number(code[0,7])[0]*8 +seat_number(code[7,2])[0]
}

p seat_ids.sort.last
