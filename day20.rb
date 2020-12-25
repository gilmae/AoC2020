require './helper.rb'
require 'optparse'

TOP = 0
RIGHT = 1
BOTTOM = 2
LEFT = 3

COS90 = Math.cos(1.5708)
SIN90 = Math.sin(1.5708)


Options = {}
OptionParser.new do |opt|
  opt.on('--input INPUT') { |o| Options[:input] = o }
  opt.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    Options[:verbose] = v
  end
end.parse!

include Helper
input = Options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

class RotatedTile
  attr_accessor :id, :rotation, :flipped

  def initialize id, rotation=0, flipped=false
    @id = id
    @rotation = rotation
    @flipped = flipped
  end
end

class Tile
  attr_accessor :id, :pixels, :matches, :edges, :flipped_edges

  def initialize id, pixels
    @id = id
    @pixels = pixels
    @matches = []
  end

  def edges 
    @edges unless @edges.nil?
    @edges = [0,0,0,0] 
    
    # # left to right
    # (0..9).each {|i|
    #   @edges[TOP] |= 1<< i if @pixels[i][0]
    #   @edges[BOTTOM] |= 1<<i if @pixels[i][9]
    #   @edges[LEFT] |= 1<<i if @pixels[0][i]
    #   @edges[RIGHT] |= 1<<i if @pixels[9][i]
    # }
    
    @pixels[0].each_with_index {|v,i|
      if v
        @edges[TOP] |= 1 << i
      end
    }

    @pixels[9].each_with_index {|v,i|
      if v
        @edges[BOTTOM] |= 1 << i
      end
    }
    
    @pixels.each_with_index {|r,i|
      if r[0]
        @edges[LEFT] |= 1<<i
      end

      if r[9]
        @edges[RIGHT] |= 1<<i
      end
    }

    @edges
  end

  def flip_image #flips horizontally
    new_pixels = []
    @pixels.each_with_index {|r,i|
      new_pixels[i] = r.reverse
    }
    return Tile.new(@id, new_pixels)
  end

  def flip_vertical_image #flips vertically
    new_pixels = @pixels.reverse
    return Tile.new(@id, new_pixels)
  end

  def rotate_image #flips horizontally
    new_pixels = Array.new(10,nil)

    (0..9).each {|x|
      row = []
      (0..9).each {|y|
        dx,dy = rotate_pixels x,y,4.5,4.5
        new_pixels[dx] = Array.new(10,nil) if new_pixels[dx].nil?
        new_pixels[dx][dy] = @pixels[x][y]  
      }

    }
    return Tile.new(@id, new_pixels)
  end

  def crop
    new_pixels = @pixels.slice(1..8)

    new_pixels.each_with_index {|r, i|
      new_pixels[i] = r.slice(1..8)
    }
    return Tile.new(@id, new_pixels)
  end

  def self.flip edge
    flipped = 0
    (0..9).each {|i|
      flipped |= ((edge >> i) & 1) << (9 - i)
    }
    flipped
  end

  def flipped_edges 
    @flipped_edges unless @flipped_edges.nil?
    @flipped_edges = [0,0,0,0]
    normal_edges = edges
    
    # left to right
    (0..3).each {|e|
        @flipped_edges[e] = Tile.flip normal_edges[e]
    }
    
    @flipped_edges
  end

  def joins? tile
    return false if @id == tile.id
    return true if edges.intersection(tile.edges).length > 0
    return true if edges.intersection(tile.flipped_edges).length > 0
    return true if flipped_edges.intersection(tile.edges).length > 0
    return flipped_edges.intersection(tile.edges).length > 0
  end
end

tiles = {}

# Read Tiles
index = 0
while index < data.length
  tile_def = data[index..index+10]
  id = tile_def[0][5..-2].to_i
  pixels = []
  tile_def[1..-1].each_with_index{|l, x| 
    pixels[x] = []
    l.chars.each_with_index{|c, y| pixels[x][y] = c=="#"}
  }
  
  tiles[id] = Tile.new(id, pixels)
  index += 12
end

if Options[:verbose]
  tiles.each {|k,v|
    puts "Tile ##{k}: #{v.edges} (Flipped #{v.flipped_edges})"
  }
end



def print_tile tile
  tile.pixels.each_with_index {|row, x|
    line = ""
    row.each_with_index{|p, y|
      line += p ? "#" : "."
    }
    puts line
  }
end

def rotate_pixels x,y, cx, cy
  dx = cx + (x-cx) * COS90 + (y-cy) * SIN90
  dy = cy - (x-cx) * SIN90  + (y-cy) * COS90

  return dx.round, dy.round
end

# tiles.values.each {|tile1|
#   tile1.matches = []
#   tiles.values.each {|tile2|
#     if tile1.joins?(tile2)
#       tile1.matches << tile2.id unless tile1.matches.include? tile2.id
#       tile2.matches << tile1.id unless tile2.matches.include? tile1.id
#     end
#   }
# }

# corners = tiles.values.select{|t|t.matches.length==2}.map(&:id)
# sides = tiles.values.select{|t|t.matches.length==3}.map(&:id)

# puts "Found #{corners.length} corners and #{sides.length} sides"

# p corners.reduce(&:*)

allEdges = {}
tiles.each {|k,v|
  edges = v.edges
  edges.each {|e|
    f = Tile.flip e

    allEdges[e] = [] if allEdges[e].nil?
    allEdges[f] = [] if allEdges[f].nil?
    allEdges[e].push k
    allEdges[f].push k
  }
}

# All Edges will contain some Edge hashes that only occur on one Tile Id, 
# i.e. edges that don't match to another tile
# A Corner tile will have two edges that don't match to anotehr tile, Side tiles have one
# However because we add both the normal hash and the flipped hash, it is Corner == 4, Side == 2
unmatchedEdgesCount = {}
allEdges.each {|k,v|
  unmatchedEdgesCount[v[0]] = ((unmatchedEdgesCount[v[0]]||0) + 1) if v.length < 2
}

corners = []
sides = []

unmatchedEdgesCount.each {|k,v|
  corners.push k if v == 4
  sides.push k if v == 2
}

p corners.reduce(&:*)
cur_tile = nil


# # Put together the jigsaw
# # Let's find a corner piece to put in the top left under the assumption is is in the right orientation

image = []
used = {}
def find_next_tile tiles, tile_id, direction, used
  tile = tiles[tile_id]
  hash = tile.edges[direction]
  tiles.each {|k,v| next if k==tile.id || used[k] ;return k if (v.edges.include?(hash) || v.flipped_edges.include?(hash))}
  nil
end

side_length = Math.sqrt(tiles.keys.length).to_i
begin
side_length.times {|row|
  cur_tile  = 0
  if row > 0
    puts "Look for tile below #{image[row-1][0]} for row #{row}"
    cur_tile = find_next_tile tiles, image[row-1][0], BOTTOM, used
    next_tile = tiles[cur_tile]
    next_edges = tiles[cur_tile].edges
    next_flipped_edges = tiles[cur_tile].flipped_edges

    case tiles[image[row-1][0]].edges[BOTTOM]
    when next_edges[LEFT]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on LEFT"
      tiles[cur_tile] = next_tile.rotate_image.flip_image
    when next_edges[BOTTOM]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on BOTTOM"
      tiles[cur_tile] = next_tile.flip_vertical_image
    when next_edges[RIGHT]#, next_edges[RIGHT]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on RIGHT"
      tiles[cur_tile] = next_tile.flip_image.flip_vertical_image.rotate_image
    when next_flipped_edges[TOP]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on FLIPPED TOP AND I DON'T KNOW HOW TO HANDLE THAT" 
      #tiles[cur_tile] = next_tile.flip_image
     when next_flipped_edges[BOTTOM]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on FLIPPED BOTTOMAND I DON'T KNOW HOW TO HANDLE THAT" 
      #tiles[cur_tile] = next_tile.flip_image
     when next_flipped_edges[RIGHT]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on FLIPPED RIGHTAND I DON'T KNOW HOW TO HANDLE THAT" 
    when next_flipped_edges[LEFT]
      p "#{cur_tile} has matching edge for BOTTOM OF #{image[row-1][0]} on FLIPPED LEFT" 
      tiles[cur_tile] = next_tile.rotate_image
    end
  else
    # Make a top left corner, rotating and flipping as required
    cur_tile = nil
    corners.each {|c|
      t = tiles[c]

      4.times{|_|
        edges = t.edges
        if allEdges[edges[TOP]].length == 1 && allEdges[edges[LEFT]].length == 1
          tiles[c] = t
          cur_tile = c
        end
        t = t.rotate_image
      }
      break unless cur_tile.nil?
    }
    abort "Could not find a top left tile" if cur_tile.nil?
    
  end

  image[row] = [cur_tile]
  used[cur_tile] = true
  next_tile_id = find_next_tile tiles, cur_tile, RIGHT, used
  puts "Look for tile with edge matching RIGHT of #{cur_tile}, found #{next_tile_id}"
  while !next_tile_id.nil?
    puts "#{cur_tile}=>#{next_tile_id}"
    next_tile = tiles[next_tile_id]
    next_edges = next_tile.edges
    next_flipped_edges = next_tile.flipped_edges

    case tiles[cur_tile].edges[RIGHT]
    when next_edges[BOTTOM]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on BOTTOM"
      tiles[next_tile_id] = next_tile.rotate_image
    when next_edges[TOP]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on TOP"
      tiles[next_tile_id] = next_tile.rotate_image.flip_image
    when next_edges[RIGHT]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on RIGHT"
      tiles[next_tile_id] = next_tile.flip_image
    when next_flipped_edges[RIGHT]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FlIPPED RIGHT"
      tiles[next_tile_id] = next_tile.flip_vertical_image
    when next_flipped_edges[TOP]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FLIPPED TOP"
      tiles[next_tile_id] = next_tile.flip_image.rotate_image
    when next_flipped_edges[BOTTOM]
      p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FLIPPED BOTTOM"
      tiles[next_tile_id] = next_tile.flip_image.flip_vertical_image.rotate_image
    end
    image[row].push next_tile_id
    used[next_tile_id] = true
    cur_tile = next_tile_id
    next_tile_id = find_next_tile tiles, cur_tile, RIGHT, used
  end

  puts "Row #{row} is not long enough, should be #{side_length} but is #{image[row].length}" if image[row].length < side_length
  break
}
rescue  => exception
  puts exception.backtrace
end

cropped = tiles.values.map {|t| t.crop}

p cropped.map {|t|
  t.pixels.map{|row| row.select{|p| p}.length}.sum
}.sum - (24*15)

# # image[2].each {|tid|
# #   print_tile tiles[tid]
# #   puts""
# # }


p image
# index = 0
# while index < 12
  
#   p image[0][index].id
#    t = find_next_tile tiles, image[0][index].id, RIGHT, used
#    break if t.nil?
#    rt = RotatedTile.new(t)
#    if tiles[t].edges[LEFT] == tiles[image[0][index]].edges[RIGHT]
#     #nothing
#    else 

    
#    end
   
#    index+=1
#    image[0][index] = rt
# #     p "Needs work"
# #   end
# #   image[0][i+1] = t
# #   used[t] = true
# end

# # p image

# #  p tiles[1489].edges
# #  p tiles[1171].edges
# #  p tiles[1171].flipped_edges
# #  p tiles[2473].edges
