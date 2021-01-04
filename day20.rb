require "./helper.rb"
require "optparse"

TOP = 0
RIGHT = 1
BOTTOM = 2
LEFT = 3

COS90 = Math.cos(1.5708)
SIN90 = Math.sin(1.5708)

MONSTER_LINE_TWO = /#.{4}##.{4}##.{4}###/
MONSTER_LINE_THREE = /.#.{2}#.{2}#.{2}#.{2}#.{2}#/

Options = {}
OptionParser.new do |opt|
  opt.on("--input INPUT") { |o| Options[:input] = o }
  opt.on("-v", "--[no-]verbose", "Run verbosely") do |v|
    Options[:verbose] = v
  end
end.parse!

include Helper
input = Options[:input] || "#{__FILE__}".gsub(/\.rb/, ".input")

data = get_data(input).map(&:strip)

class String
  def scan_with_overlap(regex, position)
    return if position >= self.length
    matches = []
    m = regex =~ self.slice(position, self.length)
    if !m.nil?
      matches.push m + position
      matches += self.scan_with_overlap regex, m + 1 + position
    end
    matches
  end
end

class Tile
  attr_accessor :id, :pixels, :edges, :flipped_edges

  def initialize(id, pixels)
    @id = id
    @pixels = pixels
  end

  def edges
    @edges unless @edges.nil?
    @edges = [0, 0, 0, 0]

    @pixels[0].each_with_index { |v, i|
      if v
        @edges[TOP] |= 1 << i
      end
    }

    @pixels.last.each_with_index { |v, i|
      if v
        @edges[BOTTOM] |= 1 << i
      end
    }

    @pixels.each_with_index { |r, i|
      if r[0]
        @edges[LEFT] |= 1 << i
      end

      if r.last
        @edges[RIGHT] |= 1 << i
      end
    }

    @edges
  end

  def flip_x #flips horizontally
    new_pixels = []
    @pixels.each_with_index { |r, i|
      new_pixels[i] = r.reverse
    }
    return Tile.new(@id, new_pixels)
  end

  def flip_y #flips vertically
    new_pixels = @pixels.reverse
    return Tile.new(@id, new_pixels)
  end

  def rotate_clockwise #flips horizontally
    side_length = pixels.length
    half_side_length = (side_length - 1).to_f / 2.0
    new_pixels = Array.new(side_length, nil)

    (0..side_length - 1).each { |x|
      row = []
      (0..side_length - 1).each { |y|
        dx, dy = rotate_pixels x, y, half_side_length, half_side_length
        new_pixels[dx] = Array.new(pixels.length, nil) if new_pixels[dx].nil?
        new_pixels[dx][dy] = @pixels[x][y]
      }
    }
    return Tile.new(@id, new_pixels)
  end

  def crop_border
    side_length = @pixels.length
    new_pixels = @pixels.slice(1..side_length - 2)

    new_pixels.each_with_index { |r, i|
      new_pixels[i] = r.slice(1..side_length - 2)
    }
    return Tile.new(@id, new_pixels)
  end

  def self.flip_edge(edge)
    flipped = 0
    (0..9).each { |i|
      flipped |= ((edge >> i) & 1) << (9 - i)
    }
    flipped
  end

  def flipped_edges
    @flipped_edges unless @flipped_edges.nil?
    @flipped_edges = [0, 0, 0, 0]
    normal_edges = edges

    # left to right
    (0..3).each { |e|
      @flipped_edges[e] = Tile.flip_edge normal_edges[e]
    }

    @flipped_edges
  end
end

def print_image(image, tiles, with_gutter = false)
  print = ""
  image_size = image.length
  tile_size = tiles[image[0][0]].pixels.length

  (image_size).times { |image_row|
    (0..tile_size - 1).each_with_index { |row, y|
      combined_row = ""
      image[image_row].each { |i|
        tile = tiles[i]
        tile.pixels[y].each { |p|
          combined_row += p ? "#" : "."
        }
        combined_row += " " if with_gutter
      }
      print += "#{combined_row}\n"
    }
    print += "\n" if with_gutter
  }
end

def print_tile(tile)
  print = ""
  tile.pixels.each_with_index { |row, x|
    line = ""
    row.each_with_index { |p, y|
      line += p ? "#" : "."
    }
    print += "#{line}\n"
  }
  print
end

def rotate_pixels(x, y, cx, cy)
  dx = cx + (x - cx) * COS90 + (y - cy) * SIN90
  dy = cy - (x - cx) * SIN90 + (y - cy) * COS90

  return dx.round, dy.round
end

def combine_tiles(image, tiles)
  pixels = []
  image_size = image.length
  tile_size = tiles[image[0][0]].pixels.length

  (image_size).times { |image_row|
    tile_size.times { |y|
      combined_row = []
      image[image_row].each { |i|
        tile = tiles[i]
        combined_row += tile.pixels[y]
      }
      pixels.push combined_row
    }
  }

  return Tile.new(0, pixels)
end

def find_tile_with_matching_border(tiles, tile_id, direction, used)
  tile = tiles[tile_id]
  hash = tile.edges[direction]
  tiles.each { |k, v| next if k == tile.id || used[k]; return k if (v.edges.include?(hash) || v.flipped_edges.include?(hash)) }
  nil
end

def scan_for_monsters(image)
  monsters = []
  printed = print_tile(image).split("\n").map(&:strip)
  (0..printed.length - 3).each { |i|
    pos1 = printed[i + 1].scan_with_overlap MONSTER_LINE_TWO, 0
    pos2 = printed[i + 2].scan_with_overlap MONSTER_LINE_THREE, 0

    joint_positions = pos1.intersection(pos2)

    joint_positions.each { |p|
      if printed[i].chars[p + 18] == "#"
        monsters.push [i, p]
        puts "Found monster on line #{i}, head at position #{p + 18}" if Options[:verbose]
      end
    }
  }

  monsters
end

def highlight_monsters(image, monsters)
  printed = print_tile(image).split("\n").map(&:strip)
  line_1_offsets = [18]
  line_2_offsets = [0, 5, 6, 11, 12, 17, 18, 19]
  line_3_offsets = [1, 4, 7, 10, 13, 16]

  monsters.each { |m|
    line_1_offsets.each { |o|
      printed[m[0]][m[1] + o] = "O"
    }

    line_2_offsets.each { |o|
      printed[m[0] + 1][m[1] + o] = "O"
    }

    line_3_offsets.each { |o|
      printed[m[0] + 2][m[1] + o] = "O"
    }
  }
  printed.join("\n")
end

tiles = {}

# Read Tiles
index = 0
while index < data.length
  tile_def = data[index..index + 10]
  id = tile_def[0][5..-2].to_i
  pixels = []
  tile_def[1..-1].each_with_index { |l, x|
    pixels[x] = []
    l.chars.each_with_index { |c, y| pixels[x][y] = c == "#" }
  }

  tiles[id] = Tile.new(id, pixels)
  index += 12
end

if Options[:verbose]
  tiles.each { |k, v|
    puts "Tile ##{k}: #{v.edges} (Flipped #{v.flipped_edges})"
  }
end

allEdges = {}
tiles.each { |k, v|
  edges = v.edges
  edges.each { |e|
    f = Tile.flip_edge e

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
allEdges.each { |k, v|
  unmatchedEdgesCount[v[0]] = ((unmatchedEdgesCount[v[0]] || 0) + 1) if v.length < 2
}

corners = []
sides = []

unmatchedEdgesCount.each { |k, v|
  corners.push k if v == 4
  sides.push k if v == 2
}

p corners.reduce(&:*)
cur_tile = nil

# # Put together the jigsaw
# # Let's find a corner piece to put in the top left under the assumption is is in the right orientation

image = []
used = {}

side_length = Math.sqrt(tiles.keys.length).to_i
begin
  side_length.times { |row|
    cur_tile = 0
    if row > 0
      puts "Look for tile below #{image[row - 1][0]} for row #{row}" if Options[:verbose]
      cur_tile = find_tile_with_matching_border tiles, image[row - 1][0], BOTTOM, used
      next_tile = tiles[cur_tile]
      next_edges = tiles[cur_tile].edges
      next_flipped_edges = tiles[cur_tile].flipped_edges

      case tiles[image[row - 1][0]].edges[BOTTOM]
      when next_edges[LEFT]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on LEFT" if Options[:verbose]
        tiles[cur_tile] = next_tile.rotate_clockwise.flip_x
      when next_edges[BOTTOM]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on BOTTOM" if Options[:verbose]
        tiles[cur_tile] = next_tile.flip_y
      when next_edges[RIGHT] #, next_edges[RIGHT]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on RIGHT" if Options[:verbose]
        tiles[cur_tile] = next_tile.flip_x.flip_y.rotate_clockwise
      when next_flipped_edges[TOP]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on FLIPPED TOP AND I DON'T KNOW HOW TO HANDLE THAT" if Options[:verbose]
        #tiles[cur_tile] = next_tile.flip_x
      when next_flipped_edges[BOTTOM]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on FLIPPED BOTTOMAND I DON'T KNOW HOW TO HANDLE THAT" if Options[:verbose]
        #tiles[cur_tile] = next_tile.flip_x
      when next_flipped_edges[RIGHT]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on FLIPPED RIGHT, so rotate and flip vertically" if Options[:verbose]
        tiles[cur_tile] = next_tile.rotate_clockwise.flip_y
      when next_flipped_edges[LEFT]
        p "#{cur_tile} has matching edge for BOTTOM OF #{image[row - 1][0]} on FLIPPED LEFT" if Options[:verbose]
        tiles[cur_tile] = next_tile.rotate_clockwise
      end
    else
      # Make a top left corner, rotating and flipping as required
      cur_tile = nil
      corners.each { |c|
        t = tiles[c]

        4.times { |_|
          edges = t.edges
          if allEdges[edges[TOP]].length == 1 && allEdges[edges[LEFT]].length == 1
            tiles[c] = t
            cur_tile = c
          end
          t = t.rotate_clockwise
        }
        break unless cur_tile.nil?
      }
      abort "Could not find a top left tile" if cur_tile.nil?
    end

    image[row] = [cur_tile]
    used[cur_tile] = true
    next_tile_id = find_tile_with_matching_border tiles, cur_tile, RIGHT, used
    puts "Look for tile with edge matching RIGHT of #{cur_tile}, found #{next_tile_id}" if Options[:verbose]
    while !next_tile_id.nil?
      puts "#{cur_tile}=>#{next_tile_id}" if Options[:verbose]
      next_tile = tiles[next_tile_id]
      next_edges = next_tile.edges
      next_flipped_edges = next_tile.flipped_edges

      case tiles[cur_tile].edges[RIGHT]
      when next_edges[BOTTOM]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on BOTTOM" if Options[:verbose]
        tiles[next_tile_id] = next_tile.rotate_clockwise
      when next_edges[TOP]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on TOP" if Options[:verbose]
        tiles[next_tile_id] = next_tile.rotate_clockwise.flip_x
      when next_edges[RIGHT]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on RIGHT" if Options[:verbose]
        tiles[next_tile_id] = next_tile.flip_x
      when next_flipped_edges[RIGHT]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FlIPPED RIGHT" if Options[:verbose]
        tiles[next_tile_id] = next_tile.rotate_clockwise.rotate_clockwise
      when next_flipped_edges[TOP]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FLIPPED TOP" if Options[:verbose]
        tiles[next_tile_id] = next_tile.rotate_clockwise.rotate_clockwise.rotate_clockwise
      when next_flipped_edges[BOTTOM]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FLIPPED BOTTOM" if Options[:verbose]
        tiles[next_tile_id] = next_tile.rotate_clockwise.flip_y
      when next_flipped_edges[LEFT]
        p "#{next_tile_id}  has matching edge for RIGHT of #{cur_tile} on FLIPPED LEFT" if Options[:verbose]
        tiles[next_tile_id] = next_tile.flip_y
      end
      image[row].push next_tile_id
      used[next_tile_id] = true
      cur_tile = next_tile_id
      next_tile_id = find_tile_with_matching_border tiles, cur_tile, RIGHT, used
    end

    if image[row].length < side_length
      puts "Row #{row} is not long enough, should be #{side_length} but is #{image[row].length}" if Options[:verbose]
      break
    end
  }
rescue => exception
  puts exception.backtrace
end

tiles.each { |k, v|
  tiles[k] = v.crop_border
}

print_image image, tiles, true
mosaic = combine_tiles image, tiles

monsters = 0

# Try finding monsters. If none found, rotate clockwise.
# If not found after a full rotation, flip the image on the x axis and try rotating again
2.times { |_|
  4.times { |_|
    monsters = scan_for_monsters mosaic
    if monsters.length > 0
      highlighted_image = highlight_monsters mosaic, monsters
      puts highlighted_image if Options[:verbose]
      puts "Found #{monsters.length} monsters"
      roughness = highlighted_image.split("\n").map { |line| line.chars.select { |p| p == "#" }.length }.sum

      puts "Sea roughness: #{roughness}"

      abort
    end
    puts monsters
    mosaic = mosaic.rotate_clockwise
    puts "Rotate" if Options[:verbose]
  }
  mosaic = mosaic.flip_x
  puts "Flip" if Options[:verbose]
}

## This is cheesing it by guessing how many monsters there might be, counting how many #'s there are in the combined image, and then subtracting guess * 15 (#s in monster)
#cropped = tiles.values.map { |t| t.crop }

# p tiles.values.map { |t|
#   t.pixels.map { |row| row.select { |p| p }.length }.sum
# }.sum - (24 * 15)
