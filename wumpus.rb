class Cave
  attr_reader :rooms, :entrance
  attr_accessor :player, :location, :wumpus, :bats, :pit

  def initialize
    @rooms = {}
    (1..20).each { |num| self.rooms[num] = Room.new(num, [], :empty) }
    self.rooms.each do |room|
      until room[1].connections.length == 3
        new_connection = rand(1..20)
        room[1].connections << new_connection unless room[1].connections.include?(new_connection) || room[1].number == new_connection
      end
    end
    @entrance = rand(@rooms.length)
    @location = []
    @location << self.entrance
  end

  def possible_paths_from_here
    self.rooms[self.location[-1]].connections
  end

  def move_to(room)
    if self.rooms[self.location[-1]].connections.include?(room)
      update_path(room)
      return self.rooms[room]
    else
      puts "You can't get there from here."
    end
  end

  def update_path(room)
    @location << room
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
  attr_accessor :location, :health
  
  def initialize(location, health)
    @location = location
    @health = health
  end

  def where_am_i
    puts "You are in room #{self.location}"
  end

  def move_to(room_number)
    self.location = room_number
  end

  def alive?
    TRUE if self.health > 0
  end

  def status
    if self.alive?
      puts "You're in room #{self.location}"
      puts "Health is at #{self.health}/100."
    else
      puts "You're dead. Enjoy hanging out with the wumpus as a ghost."
    end
  end
end

def new_game
  cave = Cave.new
  player = Player.new(cave.entrance, 100)

  while player.health > 0
    player.status
    puts "From here you can get to the following rooms: " + cave.possible_paths_from_here.join(', ')
    print "Where to? "
    choice = gets.chomp.to_i
    if cave.move_to(choice) 
      player.location = choice
    end
    puts "------------------------"
  end
end

new_game 

# next steps:
#   add wumpus
#   add hazards
