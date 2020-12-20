require './helper.rb'
require 'optparse'

options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| options[:input] = o }
end.parse!

include Helper
input = options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input)

cells = Hash.new(false)

data.each_with_index {|line, y|
  line.chomp.split("").each_with_index {|c, x|
    cells[[x,y,0]] = (c == "#")
  }
}

def get_neighbours x,y,z, cells
  neighbours = []
  (-1..1).each {|xd|
    (-1..1).each{|yd|
      (-1..1).map{|zd|
        next if xd==0 && yd==0 && zd==0
        neighbours.push([x+xd,y+yd,z+zd]) if cells[[x+xd, y+yd,z+zd]]
      }
    }
  }
  neighbours
end


def get_next_generation cells
  next_state = Hash.new(false)

  xmin,xmax = cells.keys.map{|k|k[0]}.minmax
  ymin,ymax = cells.keys.map{|k|k[1]}.minmax
  zmin,zmax = cells.keys.map{|k|k[2]}.minmax
  
  (xmin-1..xmax+1).each { |nx|
    (ymin-1..ymax+1).each { |ny|
      (zmin-1..zmax+1).each { |nz|
        neighbours = get_neighbours nx,ny,nz, cells
        case cells[[nx,ny,nz]]
        when true
          next_state[[nx,ny,nz]] = (neighbours.length==2 || neighbours.length==3)
        else
          next_state[[nx,ny,nz]] = neighbours.length==3
        end
      }
    }
  }

  next_state
end

def print_generation cells
  xmin,xmax = cells.keys.map{|k|k[0]}.minmax
  ymin,ymax = cells.keys.map{|k|k[1]}.minmax
  zmin,zmax = cells.keys.map{|k|k[2]}.minmax
  
  (zmin..zmax).each { |z|
    puts "\nz=#{z}"
    (ymin..ymax).each { |y|
      row = ""
      (xmin..xmax).each { |x|
        row += cells[[x,y,z]]?"#":"."
      }
      puts row

    }
  }
end

def get_active_cells cells
  active = []
  xmin,xmax = cells.keys.map{|k|k[0]}.minmax
  ymin,ymax = cells.keys.map{|k|k[1]}.minmax
  zmin,zmax = cells.keys.map{|k|k[2]}.minmax
  
  (zmin..zmax).each { |z|
    (ymin..ymax).each { |y|
      (xmin..xmax).each { |x|
        active.push [x,y,z] if cells[[x,y,z]]
      }
    }
  }
  active
end

def get_board_size cells
  
  xmin,xmax = cells.keys.map{|k|k[0]}.minmax
  ymin,ymax = cells.keys.map{|k|k[1]}.minmax
  zmin,zmax = cells.keys.map{|k|k[2]}.minmax
  
  (xmin..xmax).to_a.length * (xmin..ymax).to_a.length * (zmin..zmax).to_a.length
end

states = [cells]
(1..6).each {|i|
  states.push(get_next_generation(states.last))
}

puts get_active_cells(states.last).length
puts get_board_size(states.last)



