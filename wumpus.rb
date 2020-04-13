class Cave
  attr_reader :rooms, :entrance
  attr_accessor :player, :location, :wumpus, :giant_bats, :bottomless_pit

  def initialize
    connections = [[2, 5, 8],
                   [1, 3, 10],
                   [2, 4, 12],
                   [3, 5, 14],
                   [1, 4, 6],
                   [5, 7, 15],
                   [6, 8, 17],
                   [1, 7, 11],
                   [10, 12, 19],
                   [2, 9, 11],
                   [8, 10, 20],
                   [3, 9, 13],
                   [12, 14, 18],
                   [4, 13, 15],
                   [6, 14, 16],
                   [15, 17, 18],
                   [7, 16, 20],
                   [13, 16, 19],
                   [9, 18, 20],
                   [11, 17, 19]]
    @rooms = []
    connections.each_with_index do |arr, idx|
      self.rooms << Room.new(idx + 1, arr)
    end 
    @entrance = rand(@rooms.length)
    @location = []
    @location << @entrance  
    self.rooms[@entrance - 1].contents[:player] = :yes
    
    wumpus_starts_here = rand(@rooms.length)
    @wumpus = wumpus_starts_here
    self.rooms[wumpus_starts_here - 1].contents[:wumpus] = :yes

    3.times do
      giant_bats_be_here = rand(@rooms.length)
      @giant_bats = giant_bats_be_here
      self.rooms[giant_bats_be_here - 1].contents[:giant_bats] = :yes
    end
    
    2.times do
      bottomless_pit_is_here = rand(@rooms.length)
      @bottomless_pit = bottomless_pit_is_here
      self.rooms[bottomless_pit_is_here - 1].contents[:bottomless_pit] = :yes
    end

  end
 
  def possible_paths_from_here
    @rooms[@location[-1]-1].connections
  end
  
  def move_to(room_number)
    if possible_paths_from_here.include?(room_number)
      self.rooms[@location[-1] - 1].contents[:player] = :no
      @location << room_number
      self.rooms[room_number - 1].contents[:player] = :yes
    else
      puts "There's no passageway to that room from here."
    end
  end  
  
  def show_contents
   self.rooms.each { |room| puts "#{room.number}: #{room.contents}" }
  end

end 

class Room
  attr_reader :number, :connections
  attr_accessor :contents

  def initialize(number, connections, contents={:player => :no,
                                                :wumpus => :no, 
                                                :giant_bats => :no, 
                                                :bottomless_pit => :no})
    @number = number
    @connections = connections
    @contents = contents
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

  def take_some_damage(points)
    self.health -= points
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
  system("clear")
  puts "                            HUNT THE WUMPUS                                  " 
  puts
  puts "   -----------------------------------------------------------------------   "
  sleep(2.0)
  cave = Cave.new
  puts "The wumpus is in room #{cave.wumpus}."
  player = Player.new(cave.entrance, 100)

  while player.health > 0
    cave.show_contents
    player.status
    puts "From here you can get to the following rooms: " + cave.possible_paths_from_here.to_s
    print "Where to? "
    choice = gets.chomp.to_i
    if cave.move_to(choice) 
      player.location = choice
      if player.location == cave.wumpus
        system("clear")
        sleep(0.5)
        player.take_some_damage(rand(100))
        puts "Whoa that's a terrible smell. You just ran into the wumpus and have taken damage. It seems like you'll make it, but it's pitch black in here so you can't see how badly you're hurt."
        sleep(2.0)
      end
    end
    puts "   -----------------------------------------------------------------------   "
  end
  puts player.status
end

new_game 

# 
# next steps:
#   add actions corresponding to hazards
#   add warning messages in rooms adjoining to hazards
#   add shooting method
