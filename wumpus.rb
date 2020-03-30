class Cave
  attr_reader :rooms, :entrance
  #attr_accessor :player, :wumpus, :bats, :pit

  def initialize
    @rooms = {}
    (1..20).each { |num| self.rooms[num] = Room.new(num, [], :empty) }
    @entrance = rand(@rooms.length)
  end
end

class Room
  attr_reader :number, :connections
  attr_accessor :contents

  def initialize(number, connections, contents)
    @number = number
    @connections = connections
    @contents = contents
  end

  def contains?(hazard)
    contents.has_key?(hazard) end
end

class Player
  attr_accessor :location
  
  def initialize(location)
    @location = location
  end
end

class GameEngine
end

cave = Cave.new
p cave


# next steps:
#   connect the rooms
#   add wumpus
#   add hazards

