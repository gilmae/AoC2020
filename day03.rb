require './helper.rb'
include Helper

data = get_data("day03.input").map{|l|l.chomp.split("")}

def traverse_path(world, x_step, y_step)
    height = world.length

    x=0
    y=0
    trees = 0

    while x < height
        trees +=1 if world[x][y] == "#"
        y = (y+y_step)%world[x].length
        x+=x_step
    end

    return trees
end

p "Part 1: #{traverse_path(data,1,3)}"

paths = [[1,1], [1,3], [1,5],[1,7], [2,1]]

p "Part 2: #{paths.reduce(1){|memo, value|
    memo * traverse_path(data, value[0], value[1])
}}"
