class Cave
  attr_reader :rooms, :entrance
  #attr_accessor :player, :wumpus, :bats, :pit

  def initialize
    @rooms = {}
    (1..20).each { |num| self.rooms[num] = Room.new(num, [], :empty) }
    self.rooms.each do |room|
      until room[1].connections.length == 3
        new_connection = rand(20)
        room[1].connections << new_connection unless room[1].connections.include?(new_connection)
      end
    end
    
    @entrance = rand(@rooms.length)
    @player = Player.new(entrance)
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
    contents.has_key?(hazard) 
  end
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
#   add wumpus
#   add hazards
#   add player location method (=> you are in room x)
