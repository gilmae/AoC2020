require './helper.rb'
include Helper

data = get_data("day01.input").map{|i|i.to_i}.sort
def partA data
    data.each_with_index {|a, ii|
        data.each_with_index {|b,jj|
            break if jj >=ii
            if (a+b == 2020)
                    p a*b
                    return
            end
        }
    }
end

def partB data
    data.each_with_index {|a, ii|
        data.each_with_index {|b,jj|
            break if jj >=ii
            data.each_with_index {|c,kk|
            break if kk >=jj
                sumAB = a+b
                if sumAB+c == 2020
                   p a*b*c 
                end
            }
        }
    }
end

partA(data)
partB(data)