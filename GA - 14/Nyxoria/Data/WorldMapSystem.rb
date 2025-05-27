# encoding: UTF-8
#==============================================================================
# ** World Map System
#------------------------------------------------------------------------------
# This script implements a World Map system for Nyxoria, allowing players
# to explore the five major regions and discover lore about the world.
#==============================================================================

module WorldMapSystem
  # Region IDs (matching those in LoreJournal)
  REGION_VALEBRYN = 0
  REGION_NHARZHUL = 1
  REGION_SELDRINAR = 2
  REGION_CINDRAL = 3
  REGION_KARRGORN = 4
  
  # Region Names
  REGION_NAMES = {
    REGION_VALEBRYN => "Valebryn",
    REGION_NHARZHUL => "Nhar'Zhul Wastes",
    REGION_SELDRINAR => "Seldrinar Glade",
    REGION_CINDRAL => "Cindral Expanse",
    REGION_KARRGORN => "Karrgorn Mountains"
  }
  
  # Region Descriptions
  REGION_DESCRIPTIONS = {
    REGION_VALEBRYN => "The fallen kingdom, once the seat of power in Nyxoria. Now a land of ruins, scorched battlefields, and scattered survivors. A haunting, melancholic realm of noble decay where echoes of the past linger in crumbling architecture.",
    REGION_NHARZHUL => "A blighted land of lava flows, bone forests, and volcanic crags. Home to the Order of the Shattered Flame. A realm of charred ambition, madness, and buried secrets where militarized war-priests rule from the edge of a lava flow.",
    REGION_SELDRINAR => "A twisted fey realm of overgrown jungles, deadly flora, and bioluminescent swamps. Domain of the Hollow Root Kin. An ethereal, mysterious landscape of tangled beauty with creeping corruption where flowers glow and trees murmur rumors.",
    REGION_CINDRAL => "The desert of echoes, filled with shifting dunes, underground tombs, and shattered ancient cities. Unclaimed by any faction. An enigmatic, sun-scorched expanse filled with strange echoes where ruins shift in time and merchants from other eras come and go.",
    REGION_KARRGORN => "A militarized fortress state of ice peaks and fortified citadels. Base of operations for The Crimson Accord. A stoic, battle-worn realm where pride has turned to prison, and soldiers serve cause over country."
  }
  
  # Region Controlling Factions
  REGION_FACTIONS = {
    REGION_VALEBRYN => nil, # Contested/Ruined
    REGION_NHARZHUL => FactionSystem::FACTION_SHATTERED_FLAME,
    REGION_SELDRINAR => FactionSystem::FACTION_HOLLOW_ROOT,
    REGION_CINDRAL => nil, # Neutral/Unclaimed
    REGION_KARRGORN => FactionSystem::FACTION_CRIMSON_ACCORD
  }
  
  # Region Map IDs (for teleporting to region maps)
  REGION_MAP_IDS = {
    REGION_VALEBRYN => 2,   # Map ID for Valebryn
    REGION_NHARZHUL => 3,   # Map ID for Nhar'Zhul Wastes
    REGION_SELDRINAR => 4,  # Map ID for Seldrinar Glade
    REGION_CINDRAL => 5,    # Map ID for Cindral Expanse
    REGION_KARRGORN => 6    # Map ID for Karrgorn Mountains
  }
  
  # Region Lore IDs (for LoreJournal integration)
  REGION_LORE_IDS = {
    REGION_VALEBRYN => 1,
    REGION_NHARZHUL => 2,
    REGION_SELDRINAR => 3,
    REGION_CINDRAL => 4,
    REGION_KARRGORN => 5
  }
  
  # Key Locations within Regions
  KEY_LOCATIONS = {
    REGION_VALEBRYN => [
      {name: "Echo Vale Refuge", description: "Built in the remains of a collapsed chapel, this hideout shelters survivors, scavengers, and broken warriors.", map_id: 7, x: 15, y: 10, is_town: true},
      {name: "Crimson Keep", description: "The royal castle, now in ruins.", map_id: 8, x: 20, y: 15},
      {name: "Ashen Gate", description: "A magical ruin tied to the prince's bloodline.", map_id: 9, x: 10, y: 20}
    ],
    REGION_NHARZHUL => [
      {name: "Cinderpost Bastion", description: "A fortress-city clinging to the edge of a lava flow, ruled by militarized war-priests.", map_id: 10, x: 15, y: 10, is_town: true},
      {name: "The Flame Spiral", description: "A spire temple harnessing destructive leyline magic.", map_id: 11, x: 20, y: 15},
      {name: "Ember Hollow", description: "Underground refuge of cursed fire-born elves.", map_id: 12, x: 25, y: 20}
    ],
    REGION_SELDRINAR => [
      {name: "Whisperbloom Village", description: "Fey-touched settlement where flowers glow and trees murmur rumors.", map_id: 13, x: 15, y: 10, is_town: true},
      {name: "The Blooming Grave", description: "Where trees bloom from corpses.", map_id: 14, x: 20, y: 15},
      {name: "Crown of Thorns", description: "The court of the last true fey queen, now twisted.", map_id: 15, x: 25, y: 20}
    ],
    REGION_CINDRAL => [
      {name: "Dunebarrow Outpost", description: "Caravan trading post over ruins that shift in time. Merchants come and go — sometimes from other eras.", map_id: 16, x: 15, y: 10, is_town: true},
      {name: "The Mirror Crater", description: "Meteor impact site, tied to celestial magic.", map_id: 17, x: 20, y: 15},
      {name: "Vault of Whispers", description: "Tomb of a forgotten demigod.", map_id: 18, x: 25, y: 20}
    ],
    REGION_KARRGORN => [
      {name: "Fort Bladewatch", description: "Holds together the mountain pass. Soldiers serve cause over country.", map_id: 19, x: 15, y: 10, is_town: true},
      {name: "Veinspire", description: "A soulstone mine where soldiers are infused with power.", map_id: 20, x: 20, y: 15},
      {name: "The Echoing Wall", description: "A mural which changes based on your party's deeds across other towns.", map_id: 21, x: 25, y: 20}
    ]
  }
  
  # Town NPCs
  TOWN_NPCS = {
    # Echo Vale Refuge NPCs
    "Echo Vale Refuge" => [
      {name: "Mara", title: "the Seamstress-Healer", description: "Once tailored robes for the king, now sews enchanted bandages and recounts poetic dreams."},
      {name: "Brann", title: "Silent Knight", description: "Won't speak until the player reclaims his lost sword from the Crimson Keep."},
      {name: "Tomas", title: "the Tinkerer", description: "Has built a 'memory prism' device that reconstructs visual echoes of the past."}
    ],
    
    # Cinderpost Bastion NPCs
    "Cinderpost Bastion" => [
      {name: "Laxa", title: "Scarred Flamecaller", description: "Trains you in unstable magic if you pass her trial."},
      {name: "Forge-Singer", title: "", description: "Forges weapons using living fire spirits, needs soul-essence items."},
      {name: "Ash Maiden", title: "", description: "Appears only at dusk, sells forbidden relics."}
    ],
    
    # Whisperbloom Village NPCs
    "Whisperbloom Village" => [
      {name: "Elder Teth", title: "", description: "Blind druid who sees visions through the 'third wind'."},
      {name: "Myria", title: "", description: "Orphan girl who speaks only in plant metaphors, possibly the reincarnation of the Fey Queen."},
      {name: "The Bloomwitch", title: "", description: "Hidden in a mushroom cellar, trades in 'Petals of Memory'."}
    ],
    
    # Dunebarrow Outpost NPCs
    "Dunebarrow Outpost" => [
      {name: "Kal", title: "the Seeker", description: "Cursed to wander until forgotten."},
      {name: "Zevi", title: "", description: "Child with perfect memory, will recite past dialogues if paid in 'Echo Coins'."},
      {name: "The Hourglass Twins", title: "", description: "One ages forward, one backward."}
    ],
    
    # Fort Bladewatch NPCs
    "Fort Bladewatch" => [
      {name: "Commander Elrik", title: "", description: "Former hero turned fanatic; can be swayed."},
      {name: "Silen", title: "shadowbroker", description: "Sells illegal maps and whispers."},
      {name: "Harke", title: "the Bonekeeper", description: "Archives war-dead and will animate one if you bring them justice."}
    ]
  }
  
  # Town Shops
  TOWN_SHOPS = {
    # Echo Vale Refuge Shops
    "Echo Vale Refuge" => [
      {name: "The Frayed Stitch", description: "Cloaks, capes, and relics made from royal silks.", type: :armor},
      {name: "Ash & Ember Forge", description: "Upgrades with 'Royal Steel' shards.", type: :weapon},
      {name: "Lore Ink", description: "Sells lost texts — each unlocks lore in your codex + potential passive buffs.", type: :item}
    ],
    
    # Cinderpost Bastion Shops
    "Cinderpost Bastion" => [
      {name: "Emberheart Forge", description: "High-risk, high-reward gear.", type: :weapon},
      {name: "Scorched Tome", description: "Fire-based scrolls, explode if misused.", type: :item},
      {name: "The Shard Market", description: "Soulshard trader who rotates inventory each day.", type: :accessory}
    ],
    
    # Whisperbloom Village Shops
    "Whisperbloom Village" => [
      {name: "Root & Thorn", description: "Nature-infused gear (regens health during day/night cycles).", type: :armor},
      {name: "The Pollen Lantern", description: "Travel item shop, sells scent-based navigation tools.", type: :item},
      {name: "Feycraft", description: "Time-sensitive deals on ephemeral charms.", type: :accessory}
    ],
    
    # Dunebarrow Outpost Shops
    "Dunebarrow Outpost" => [
      {name: "Mirage Market", description: "Items change based on time of day.", type: :item},
      {name: "Dustlock Blades", description: "Glass weapons that shatter on crit.", type: :weapon},
      {name: "Hourglass Hollow", description: "Limited-time deals that disappear permanently.", type: :accessory}
    ],
    
    # Fort Bladewatch Shops
    "Fort Bladewatch" => [
      {name: "Steel & Spite", description: "Powerful but cursed armor.", type: :armor},
      {name: "Powder Cry", description: "Snowborne alchemical grenades.", type: :item},
      {name: "The Chain Registry", description: "Mercenaries for hire, can temporarily fill in as party members.", type: :service}
    ]
  }
  
  # Town Quests
  TOWN_QUESTS = {
    # Echo Vale Refuge Quests
    "Echo Vale Refuge" => [
      {name: "The Dreamer's Thread", description: "Collect glowing threads that only appear during sleep-like states. Leads to a dream realm side-dungeon.", icon: "🕯️", quest_id: 101},
      {name: "Echoes of a Voice", description: "Brann's memory prism, when completed, triggers a cutscene flashback of the kingdom's last stand.", icon: "⚔️", quest_id: 102}
    ],
    
    # Cinderpost Bastion Quests
    "Cinderpost Bastion" => [
      {name: "Trial by Ember", description: "Enter a memory-pit and battle past versions of yourself.", icon: "🔥", quest_id: 201},
      {name: "Whispers in the Ash", description: "Retrieve the tongue of a buried giant who speaks in future-tenses.", icon: "🕳️", quest_id: 202}
    ],
    
    # Whisperbloom Village Quests
    "Whisperbloom Village" => [
      {name: "The Wilted Crown", description: "Track corrupted root-vines back to a fallen guardian tree (mini-boss). Unlocks new bloom paths.", icon: "🌸", quest_id: 301},
      {name: "Wings of the Past", description: "Use pollen powder to see how the forest looked 100 years ago; optional dungeon through time.", icon: "⏳", quest_id: 302}
    ],
    
    # Dunebarrow Outpost Quests
    "Dunebarrow Outpost" => [
      {name: "The Future Buried", description: "Fall into a sand trap and end up in a warped version of the town where your party is dead.", icon: "⏱️", quest_id: 401},
      {name: "Desert of Forgotten Kings", description: "Piece together the names of rulers removed from history.", icon: "🌒", quest_id: 402}
    ],
    
    # Fort Bladewatch Quests
    "Fort Bladewatch" => [
      {name: "Weight of the Chain", description: "Free an imprisoned monk whose chants hold a barrier spell protecting the world below.", icon: "⚖️", quest_id: 501},
      {name: "The Echoing Wall", description: "Solve the riddle of the mural which changes based on your party's deeds across other towns.", icon: "🪓", quest_id: 502}
    ]
  }
  
  # Initialize world map data
  def self.init_world_map
    $game_system.world_map_data ||= {}
    
    # Only initialize if world map data is empty
    return unless $game_system.world_map_data.empty?
    
    # Set initial region discovery status (only Valebryn discovered at start)
    $game_system.world_map_data[:discovered_regions] = [REGION_VALEBRYN]
    
    # Set initial key location discovery status (none discovered at start)
    $game_system.world_map_data[:discovered_locations] = []
    
    # Discover Valebryn lore if LoreJournal is available
    if defined?(LoreJournal) && REGION_LORE_IDS[REGION_VALEBRYN]
      LoreJournal.discover_lore(REGION_LORE_IDS[REGION_VALEBRYN])
    end
  end
  
  # Discover a region
  def self.discover_region(region_id)
    $game_system.world_map_data[:discovered_regions] ||= []
    unless $game_system.world_map_data[:discovered_regions].include?(region_id)
      $game_system.world_map_data[:discovered_regions] << region_id
      
      # Show discovery message
      region_name = REGION_NAMES[region_id]
      $game_message.add("New region discovered: #{region_name}")
      
      # Play discovery sound
      Sound.play_system_sound(1) # Assuming sound ID 1 is appropriate
      
      # Discover region lore if LoreJournal is available
      if defined?(LoreJournal) && REGION_LORE_IDS[region_id]
        LoreJournal.discover_lore(REGION_LORE_IDS[region_id])
      end
      
      # Discover controlling faction if FactionSystem is available
      if defined?(FactionSystem) && REGION_FACTIONS[region_id]
        FactionSystem.discover_faction(REGION_FACTIONS[region_id])
      end
      
      return true
    end
    return false
  end
  
  # Discover a key location
  def self.discover_location(region_id, location_index)
    $game_system.world_map_data[:discovered_locations] ||= []
    location_key = "#{region_id}_#{location_index}"
    
    unless $game_system.world_map_data[:discovered_locations].include?(location_key)
      $game_system.world_map_data[:discovered_locations] << location_key
      
      # Get location data
      location = KEY_LOCATIONS[region_id][location_index]
      return false unless location
      
      # Show discovery message
      $game_message.add("New location discovered: #{location[:name]}")
      $game_message.add(location[:description])
      
      # Play discovery sound
      Sound.play_system_sound(1) # Assuming sound ID 1 is appropriate
      
      return true
    end
    return false
  end
  
  # Check if a region is discovered
  def self.region_discovered?(region_id)
    $game_system.world_map_data[:discovered_regions] ||= []
    $game_system.world_map_data[:discovered_regions].include?(region_id)
  end
  
  # Check if a location is discovered
  def self.location_discovered?(region_id, location_index)
    $game_system.world_map_data[:discovered_locations] ||= []
    location_key = "#{region_id}_#{location_index}"
    $game_system.world_map_data[:discovered_locations].include?(location_key)
  end
  
  # Get all discovered regions
  def self.discovered_regions
    $game_system.world_map_data[:discovered_regions] || []
  end
  
  # Get all discovered locations
  def self.discovered_locations
    $game_system.world_map_data[:discovered_locations] || []
  end
  
  # Get region name
  def self.region_name(region_id)
    REGION_NAMES[region_id] || "Unknown Region"
  end
  
  # Get region description
  def self.region_description(region_id)
    REGION_DESCRIPTIONS[region_id] || "No information available."
  end
  
  # Get region controlling faction
  def self.region_faction(region_id)
    REGION_FACTIONS[region_id]
  end
  
  # Get region map ID
  def self.region_map_id(region_id)
    REGION_MAP_IDS[region_id]
  end
  
  # Travel to a region
  def self.travel_to_region(region_id)
    return false unless region_discovered?(region_id)
    
    map_id = region_map_id(region_id)
    return false unless map_id
    
    # Transfer player to the region map
    $game_player.reserve_transfer(map_id, 0, 0) # Default position, adjust as needed
    return true
  end
  
  # Travel to a location within a region
  def self.travel_to_location(region_id, location_index)
    return false unless region_discovered?(region_id)
    return false unless location_discovered?(region_id, location_index)
    
    location = KEY_LOCATIONS[region_id][location_index]
    return false unless location
    
    # Transfer player to the location map
    $game_player.reserve_transfer(location[:map_id], location[:x], location[:y])
    return true
  end
end

# Initialize world map when a new game starts
class << DataManager
  alias world_map_setup_new_game setup_new_game
  def setup_new_game
    world_map_setup_new_game
    WorldMapSystem.init_world_map
  end
end

#==============================================================================
# ** Window_WorldMap
#------------------------------------------------------------------------------
# This window displays the world map with discovered regions.
#==============================================================================
class Window_WorldMap < Window_Base
  def initialize(x, y, width, height)
    super
    refresh
  end
  
  def refresh
    contents.clear
    draw_map_background
    draw_discovered_regions
  end
  
  def draw_map_background
    # Draw a basic map background
    # In a real implementation, this would use a map image
    rect = Rect.new(0, 0, contents.width, contents.height)
    contents.fill_rect(rect, Color.new(200, 200, 200))
    contents.font.color = Color.new(100, 100, 100)
    contents.draw_text(0, 0, contents.width, 24, "World of Nyxoria", 1)
  end
  
  def draw_discovered_regions
    # Draw each discovered region
    # In a real implementation, this would highlight regions on the map image
    y_pos = 32
    WorldMapSystem.discovered_regions.each do |region_id|
      region_name = WorldMapSystem.region_name(region_id)
      
      # Draw region with faction color if available
      faction_id = WorldMapSystem.region_faction(region_id)
      if defined?(FactionSystem) && faction_id && FactionSystem.faction_discovered?(faction_id)
        color = FactionSystem.faction_color(faction_id)
        contents.font.color = color
        faction_name = FactionSystem.faction_name(faction_id)
        contents.draw_text(4, y_pos, contents.width - 8, 24, region_name)
        contents.font.color = Color.new(150, 150, 150)
        contents.draw_text(4, y_pos + 24, contents.width - 8, 24, "(#{faction_name})")
      else
        contents.font.color = Color.new(0, 0, 0)
        contents.draw_text(4, y_pos, contents.width - 8, 24, region_name)
      end
      
      y_pos += 48
    end
  end
end

#==============================================================================
# ** Window_RegionList
#------------------------------------------------------------------------------
# This window displays a list of discovered regions.
#==============================================================================
class Window_RegionList < Window_Selectable
  def initialize(x, y, width, height)
    super
    @data = []
    refresh
  end
  
  def item_max
    @data ? @data.size : 0
  end
  
  def item
    @data[index]
  end
  
  def current_item_enabled?
    true
  end
  
  def refresh
    make_item_list
    create_contents
    draw_all_items
  end
  
  def make_item_list
    @data = WorldMapSystem.discovered_regions
  end
  
  def draw_item(index)
    region_id = @data[index]
    return unless region_id
    rect = item_rect(index)
    region_name = WorldMapSystem.region_name(region_id)
    
    # Draw region with faction color if available
    faction_id = WorldMapSystem.region_faction(region_id)
    if defined?(FactionSystem) && faction_id && FactionSystem.faction_discovered?(faction_id)
      color = FactionSystem.faction_color(faction_id)
      change_color(color)
    else
      change_color(normal_color)
    end
    
    draw_text(rect.x, rect.y, rect.width, line_height, region_name)
  end
end

#==============================================================================
# ** Window_RegionDetail
#------------------------------------------------------------------------------
# This window displays details about a selected region.
#==============================================================================
class Window_RegionDetail < Window_Base
  def initialize(x, y, width, height)
    super
    @region_id = nil
    refresh
  end
  
  def set_region(region_id)
    @region_id = region_id
    refresh
  end
  
  def refresh
    contents.clear
    return unless @region_id
    
    region_name = WorldMapSystem.region_name(@region_id)
    description = WorldMapSystem.region_description(@region_id)
    faction_id = WorldMapSystem.region_faction(@region_id)
    
    # Draw region name
    contents.font.size = 24
    draw_text(0, 0, contents.width, 32, region_name, 1)
    contents.font.size = Font.default_size
    
    # Draw controlling faction if available
    if defined?(FactionSystem) && faction_id && FactionSystem.faction_discovered?(faction_id)
      faction_name = FactionSystem.faction_name(faction_id)
      color = FactionSystem.faction_color(faction_id)
      change_color(normal_color)
      draw_text(0, 32, contents.width / 2, 24, "Controlling Faction:")
      change_color(color)
      draw_text(contents.width / 2, 32, contents.width / 2, 24, faction_name)
    elsif faction_id.nil?
      change_color(normal_color)
      draw_text(0, 32, contents.width, 24, "Status: Contested/Unclaimed", 1)
    end
    
    # Draw region description
    change_color(normal_color)
    draw_text_ex(4, 64, description)
    
    # Draw key locations
    draw_text(0, 120, contents.width, 24, "Key Locations:", 1)
    y_pos = 144
    
    locations = WorldMapSystem::KEY_LOCATIONS[@region_id] || []
    locations.each_with_index do |location, index|
      if WorldMapSystem.location_discovered?(@region_id, index)
        change_color(normal_color)
        draw_text(4, y_pos, contents.width - 8, 24, location[:name])
        draw_text(24, y_pos + 24, contents.width - 28, 24, location[:description])
        y_pos += 48
      else
        change_color(Color.new(150, 150, 150))
        draw_text(4, y_pos, contents.width - 8, 24, "[Undiscovered Location]")
        y_pos += 24
      end
    end
  end
end

#==============================================================================
# ** Scene_WorldMap
#------------------------------------------------------------------------------
# This scene handles the world map interface.
#==============================================================================
class Scene_WorldMap < Scene_MenuBase
  def start
    super
    create_help_window
    create_map_window
    create_list_window
    create_detail_window
    create_command_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("World of Nyxoria")
  end
  
  def create_map_window
    y = @help_window.height
    width = Graphics.width / 2
    height = Graphics.height / 2
    @map_window = Window_WorldMap.new(0, y, width, height)
  end
  
  def create_list_window
    y = @help_window.height + @map_window.height
    width = Graphics.width / 2
    height = Graphics.height - y
    @list_window = Window_RegionList.new(0, y, width, height)
    @list_window.set_handler(:ok, method(:on_list_ok))
    @list_window.set_handler(:cancel, method(:return_scene))
    @list_window.activate
  end
  
  def create_detail_window
    x = Graphics.width / 2
    y = @help_window.height
    width = Graphics.width / 2
    height = Graphics.height - y
    @detail_window = Window_RegionDetail.new(x, y, width, height)
    @list_window.select(0)
    update_detail_window
  end
  
  def create_command_window
    @command_window = Window_Command.new(0, 0)
    @command_window.x = (Graphics.width - @command_window.width) / 2
    @command_window.y = (Graphics.height - @command_window.height) / 2
    @command_window.openness = 0
    @command_window.add_command("Travel to Region", :travel_region)
    @command_window.add_command("Travel to Location", :travel_location)
    @command_window.add_command("Cancel", :cancel)
    @command_window.set_handler(:travel_region, method(:command_travel_region))
    @command_window.set_handler(:travel_location, method(:command_travel_location))
    @command_window.set_handler(:cancel, method(:close_command_window))
  end
  
  def on_list_ok
    update_detail_window
    @command_window.open
    @command_window.activate
  end
  
  def update_detail_window
    @detail_window.set_region(@list_window.item)
  end
  
  def close_command_window
    @command_window.close
    @list_window.activate
  end
  
  def command_travel_region
    region_id = @list_window.item
    if region_id && WorldMapSystem.travel_to_region(region_id)
      SceneManager.goto(Scene_Map)
    else
      # Play buzzer sound if travel fails
      Sound.play_buzzer
      close_command_window
    end
  end
  
  def command_travel_location
    # Open a location selection window
    # This would be implemented in a real game
    # For now, just close the command window
    Sound.play_buzzer
    close_command_window
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias world_map_add_original_commands add_original_commands
  def add_original_commands
    world_map_add_original_commands
    add_command("World Map", :world_map)
  end
end

class Scene_Menu < Scene_MenuBase
  alias world_map_create_command_window create_command_window
  def create_command_window
    world_map_create_command_window
    @command_window.set_handler(:world_map, method(:command_world_map))
  end
  
  def command_world_map
    SceneManager.call(Scene_WorldMap)
  end
end