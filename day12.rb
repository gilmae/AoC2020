require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)


class Direction
    attr_accessor :x, :y

    def initialize x, y
        @x = x
        @y = y
    end
end

directions = [Direction.new(0,1), Direction.new(-1,0), Direction.new(0,-1), Direction.new(1,0)]

north = 0
west = 1
south = 2
east = 3

class Position
    attr_accessor :x, :y, :facing

    def initialize x, y, facing
        @y = y
        @x = x
        @facing = facing
    end

    def move direction, steps
        direction = @facing if direction.nil?
        
        @x += direction.x * steps
        @y += direction.y * steps
    end

    def rotate_counter_clockwise
        return Position.new(@y*-1, @x, nil)
    end

    def rotate_clockwise
        return Position.new(@y, @x*-1, nil)
    end
end



position = Position.new(0,0, directions[east])

data.each {|line|
    /(?<direction>[NEWSLRF])(?<steps>\d+)/ =~ line
    case direction
    when 'F'
        position.move nil, steps.to_i
    when 'R'
        new_facing = directions.index(position.facing) - (steps.to_i/90)
        while new_facing < 0
            new_facing = directions.length + new_facing
        end
        position.facing = directions[new_facing]
    when 'L'
        new_facing = directions.index(position.facing) + (steps.to_i/90)
        
        while new_facing >= directions.length
            new_facing = new_facing % directions.length
        end
        position.facing = directions[new_facing]
    when 'N'
        position.move directions[north], steps.to_i
    when 'E'
        position.move directions[east], steps.to_i
    when 'W'
        position.move directions[west], steps.to_i
    when 'S'
        position.move directions[south], steps.to_i
    end
}

puts position.x.abs  + position.y.abs

ship = Position.new(0,0,directions[east])
waypoint = Position.new(10,1, nil)


data.each {|line|
    /(?<direction>[NEWSLRF])(?<steps>\d+)/ =~ line
    case direction
    when 'F'
        ship.move waypoint, steps.to_i
    when 'R'
        rotations = steps.to_i/90
        (rotations.times).each{|i|waypoint = waypoint.rotate_clockwise}
    when 'L'
        rotations = steps.to_i/90
        (rotations.times).each{|i|waypoint = waypoint.rotate_counter_clockwise}
    when 'N'
        waypoint.move directions[north], steps.to_i
    when 'E'
        waypoint.move directions[east], steps.to_i
    when 'W'
        waypoint.move directions[west], steps.to_i
    when 'S'
        waypoint.move directions[south], steps.to_i
    end
}

puts ship.x.abs  + ship.y.abs