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

class ThreeDimenionalBoard
  attr_reader :cells
  def initialize cells
    @cells = cells
    @generations = []
  end

  def get_neighbours x,y,z
    neighbours = []
    (-1..1).each {|xd|
      (-1..1).each{|yd|
        (-1..1).map{|zd|
          next if xd==0 && yd==0 && zd==0
          neighbours.push([x+xd,y+yd,z+zd]) if @cells[[x+xd, y+yd,z+zd]]
        }
      }
    }
    neighbours
  end


  def get_next_generation
    next_state = Hash.new(false)

    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
  
    (xmin-1..xmax+1).each { |nx|
      (ymin-1..ymax+1).each { |ny|
        (zmin-1..zmax+1).each { |nz|
          neighbours = get_neighbours nx,ny,nz
          case @cells[[nx,ny,nz]]
          when true
            next_state[[nx,ny,nz]] = true if (neighbours.length==2 || neighbours.length==3)
          else
            next_state[[nx,ny,nz]] = true if neighbours.length==3
          end
        }
      }
    }

    next_state
  end

  def print_generation
    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
  
    (zmin..zmax).each { |z|
      puts "\nz=#{z}"
      (ymin..ymax).each { |y|
        row = ""
        (xmin..xmax).each { |x|
          row += @cells[[x,y,z]]?"#":"."
        }
        puts row

      }
    }
  end

  def get_active_cells
    active = []
    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
  
    (zmin..zmax).each { |z|
      (ymin..ymax).each { |y|
        (xmin..xmax).each { |x|
          active.push [x,y,z] if @cells[[x,y,z]]
        }
      }
    }
    active
  end

  def get_board_size
  
    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
  
    (xmin..xmax).to_a.length * (xmin..ymax).to_a.length * (zmin..zmax).to_a.length
  end

  def tick
    @cells = get_next_generation
  end
end

board = ThreeDimenionalBoard.new(cells)
(1..6).each {|i|
  board.tick
}

puts board.get_active_cells.length
puts board.get_board_size

class FourDimenionalBoard
  attr_reader :cells
  def initialize cells
    @cells = cells
    @generations = []
  end

  def get_neighbours x,y,z, w
    neighbours = []
    (-1..1).each {|xd|
      (-1..1).each{|yd|
        (-1..1).map{|zd|
          (-1..1).map{|wd|
            next if xd==0 && yd==0 && zd==0 && wd==0
            neighbours.push([x+xd,y+yd,z+zd, w+wd]) if @cells[[x+xd, y+yd,z+zd, w+wd]]
          }
        }
      }
    }
    neighbours
  end

  def get_next_generation
    next_state = Hash.new(false)

    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
    wmin,wmax = @cells.keys.map{|k|k[3]}.minmax
  
    (xmin-1..xmax+1).each { |nx|
      (ymin-1..ymax+1).each { |ny|
        (zmin-1..zmax+1).each { |nz|
          (wmin-1..wmax+1).each { |nw|
            neighbours = get_neighbours nx,ny,nz, nw
            case @cells[[nx,ny,nz,nw]]
            when true
              next_state[[nx,ny,nz,nw]] = true if (neighbours.length==2 || neighbours.length==3)
            else
              next_state[[nx,ny,nz,nw]] = true if neighbours.length==3
            end
          }
        }
      }
    }

    next_state
  end

  # def print_generation
  #   xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
  #   ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
  #   zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
  
  #   (zmin..zmax).each { |z|
  #     puts "\nz=#{z}"
  #     (ymin..ymax).each { |y|
  #       row = ""
  #       (xmin..xmax).each { |x|
  #         row += @cells[[x,y,z]]?"#":"."
  #       }
  #       puts row

  #     }
  #   }
  # end

  def get_active_cells
    active = []
    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
    wmin,wmax = @cells.keys.map{|k|k[3]}.minmax
  
    (wmin..wmax).each { |w|
      (zmin..zmax).each { |z|
        (ymin..ymax).each { |y|
          (xmin..xmax).each { |x|
            active.push [x,y,z,w] if @cells[[x,y,z,w]]
          }
        }
      }
    }
    active
  end

  def get_board_size
  
    xmin,xmax = @cells.keys.map{|k|k[0]}.minmax
    ymin,ymax = @cells.keys.map{|k|k[1]}.minmax
    zmin,zmax = @cells.keys.map{|k|k[2]}.minmax
    wmin,wmax = @cells.keys.map{|k|k[3]}.minmax
  
    (xmin..xmax).to_a.length * (xmin..ymax).to_a.length * (zmin..zmax).to_a.length * (wmin..wmax).to_a.length
  end

  def tick
    @cells = get_next_generation
  end
end

fourDCells = Hash.new(false)
data.each_with_index {|line, y|
  line.chomp.split("").each_with_index {|c, x|
  fourDCells[[x,y,0,0]] = (c == "#")
  }
}

board = FourDimenionalBoard.new(fourDCells)
(1..6).each {|i|
  board.tick
}

puts board.get_active_cells.length
puts board.get_board_size


