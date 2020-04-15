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
    @entrance = rand(1..@rooms.length)
    @location = []
    @location << @entrance  
    self.rooms[@entrance - 1].contents[:player] = :yes
    
    wumpus_starts_here = rand(@rooms.length)
    @wumpus = wumpus_starts_here
    self.rooms[wumpus_starts_here - 1].contents[:wumpus] = :yes

    @giant_bats = []
    3.times do
      loop do
        giant_bats_be_here = rand(@rooms.length)
        unless self.rooms[giant_bats_be_here - 1].contents[:giant_bats] == :yes
          @giant_bats << giant_bats_be_here
          self.rooms[giant_bats_be_here - 1].contents[:giant_bats] = :yes
          break 
        end
      end
    end
    
    @bottomless_pit = []
    2.times do
      bottomless_pit_is_here = rand(@rooms.length)
      @bottomless_pit << bottomless_pit_is_here
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
  
  def player_taken_by_bats
      random_room = rand(1..20)
      self.rooms[@location[-1] - 1].contents[:player] = :no
      @location << random_room
      self.rooms[random_room - 1].contents[:player] = :yes
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
      player.dead
    end
  end
  
  def dead
    puts "Oh my, you just died. Guess your ghost will be hanging out with the Wumpus eternally. Good thing ghosts don't have a sense of smell... or do they?" 
  end
end
 
def new_game
  system("clear")
  puts "                            HUNT THE WUMPUS                                  " 
  puts
  puts "   -----------------------------------------------------------------------   "
  sleep(1.0)
  cave = Cave.new
  puts "You've come to the lair of the Wumpus to prove your bravery and hunting prowess. Many have come here before you, but none have returned."
  player = Player.new(cave.entrance, 100)

  while player.health > 0
    puts
    player.status

    # detect and provide a warning of nearby hazards to player     
    adjoining_rooms = cave.possible_paths_from_here
    alerts = []
    adjoining_rooms.each do |room|
      alerts << "You hear a rustling noise." if cave.rooms[room-1].contents[:giant_bats] == :yes
      alerts << "You feel a breeze." if cave.rooms[room-1].contents[:bottomless_pit] == :yes
      alerts << "A terrible smell hangs in the air." if cave.rooms[room-1].contents[:wumpus] == :yes
    end 
    
    alerts.uniq!
    alerts.each { |alert| puts alert }
    
    
    print "From here you can get to the following rooms: "
    adjoining_rooms.each { |room| print room.to_s + " " }
    puts
    print "(M)ove or (S)hoot? "
    choice = gets.chomp
    
    if choice.downcase == "m" or choice.downcase == "move"
      # logic for moving rooms and potentially running into hazards
      print "Which room? "
      choice = gets.chomp
      if choice == "map"
        cave.show_contents
      elsif cave.move_to(choice.to_i) 
        player.location = choice.to_i
        case
        when player.location == cave.wumpus
          system("clear")
          sleep(0.5)
          player.take_some_damage(rand(100))
          puts "The Wumpus attacks with savage intensity and runs away before you can fight back. You have taken damage. It seems like you'll make it, but it's pitch black in here so you can't see how badly you're hurt."
  
          sleep(2.0)
        when cave.giant_bats.include?(player.location)
          system("clear")
          sleep(0.5)
          player.take_some_damage(rand(20))
          puts "Giant bats pick you up and drop you on your head in another room. Ouch!"
          cave.rooms[player.location - 1].contents[:giant_bats] = :no
          cave.player_taken_by_bats
          player.location = cave.location[-1]
          moved = false
          until moved
            random_room = rand(1..20)
            if cave.rooms[random_room - 1].contents[:giant_bats] = :no
              cave.rooms[random_room - 1].contents[:giant_bats] = :yes
              moved = true
            end
          end
        when cave.bottomless_pit.include?(player.location)
          system("clear")
          sleep(0.5)
          puts "You've fallen into a bottomless pit!"
          20.times { puts "Ahhhhhhh!"; sleep(0.25); }
          player.dead
          exit(1)
        end
      end
    elsif choice.downcase == "s" or choice.downcase == "shoot"
      print "Into which room? "
      choice = gets.chomp.to_i
      if cave.wumpus == choice
        system("clear")
        puts "Bang!"
        sleep(1.0)
        puts "A blood-curdling howl rends the air..."
        sleep(1.0)
        puts "You killed the Wumpus! Good job!"
        sleep(2.0)
        exit(1)
      else
        system("clear")
        puts "Bang!"
        sleep(1.0)
        puts 
        puts "You missed! What's worse, you've startled the Wumpus! Hopefully he doesn't run in your direction."
        cave.rooms[cave.wumpus - 1].contents[:wumpus] = :no
        cave.wumpus = rand(1..20)
        cave.rooms[cave.wumpus - 1].contents[:wumpus] = :yes
      end
    end
  end
end

new_game 

# next steps:
#   fix bat movement after carrying off player (adjust cave.giant_bats array)
