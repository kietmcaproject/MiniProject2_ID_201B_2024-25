# encoding: UTF-8
#==============================================================================
# ** Lore Journal System
#------------------------------------------------------------------------------
# This script implements a Lore Journal system for Nyxoria, allowing players
# to collect and review lore about the world, factions, and characters.
#==============================================================================

module LoreJournal
  # Lore Categories
  CATEGORY_REGIONS = 0
  CATEGORY_FACTIONS = 1
  CATEGORY_CHARACTERS = 2
  CATEGORY_HISTORY = 3
  
  # Lore Entry Structure
  # id: unique identifier for the lore entry
  # category: the category this entry belongs to
  # title: the title of the lore entry
  # description: the full text of the lore entry
  # discovered: whether this entry has been discovered by the player
  # region_id: associated region (if applicable)
  # faction_id: associated faction (if applicable)
  # character_id: associated character (if applicable)
  
  # Region IDs
  REGION_VALEBRYN = 0
  REGION_NHARZHUL = 1
  REGION_SELDRINAR = 2
  REGION_CINDRAL = 3
  REGION_KARRGORN = 4
  
  # Faction IDs
  FACTION_CRIMSON_ACCORD = 0
  FACTION_SHATTERED_FLAME = 1
  FACTION_HOLLOW_ROOT = 2
  FACTION_DAWNSWORN = 3
  
  # Initialize the lore database
  def self.init_lore
    $game_system.lore_entries ||= []
    
    # Only initialize if the lore database is empty
    return unless $game_system.lore_entries.empty?
    
    # Region Lore
    add_region_lore
    
    # Faction Lore
    add_faction_lore
    
    # Character Lore
    add_character_lore
    
    # Historical Lore
    add_historical_lore
  end
  
  # Add Region Lore
  def self.add_region_lore
    # Valebryn
    $game_system.lore_entries << {
      id: 1,
      category: CATEGORY_REGIONS,
      title: "Valebryn - The Fallen Crown",
      description: "Once the seat of power in Nyxoria, Valebryn was a prosperous kingdom known for its rolling highlands and majestic fortresses. Now it lies in ruins, destroyed in a mysterious attack that left the royal family dead - or so most believe. The land is scarred with scorched battlefields and the remnants of a once-great civilization.\n\nThe region has a haunting, melancholic tone with an atmosphere of noble decay. Echo Vale Refuge, built in the remains of a collapsed chapel, serves as the main town hub, sheltering survivors, scavengers, and broken warriors. Notable figures include Mara the Seamstress-Healer, who once tailored robes for the king, Brann the Silent Knight who won't speak until his lost sword is reclaimed, and Tomas the Tinkerer with his memory prism device.",
      discovered: false,
      region_id: REGION_VALEBRYN,
      faction_id: nil,
      character_id: nil
    }
    
    # Nhar'Zhul Wastes
    $game_system.lore_entries << {
      id: 2,
      category: CATEGORY_REGIONS,
      title: "Nhar'Zhul Wastes - Flame of the Broken",
      description: "A desolate region dominated by lava flows, bone forests, and volcanic crags. The Nhar'Zhul Wastes are home to warped creatures and corrupt magic. The Order of the Shattered Flame has claimed this harsh territory as their domain, harnessing the destructive leyline magic that flows beneath the blighted surface.\n\nThe region embodies charred ambition, madness, and buried secrets, with deep drums and rising infernos echoing across the landscape. Cinderpost Bastion, a fortress-city clinging to the edge of a lava flow, is ruled by militarized war-priests. Notable figures include Laxa the Scarred Flamecaller who trains those who pass her trial, the Forge-Singer who crafts weapons using living fire spirits, and the mysterious Ash Maiden who appears only at dusk.",
      discovered: false,
      region_id: REGION_NHARZHUL,
      faction_id: FACTION_SHATTERED_FLAME,
      character_id: nil
    }
    
    # Seldrinar Glade
    $game_system.lore_entries << {
      id: 3,
      category: CATEGORY_REGIONS,
      title: "Seldrinar Glade - The Living Wild",
      description: "Once a paradise of natural beauty, Seldrinar Glade has become a twisted and haunted realm. Overgrown jungles, deadly flora, and bioluminescent swamps dominate the landscape. The Hollow Root Kin, corrupted nature-worshippers, rule over this dangerous territory from their court at the Crown of Thorns.\n\nThe region has an ethereal, mysterious atmosphere of tangled beauty with creeping corruption. Whisperbloom Village, a fey-touched settlement where flowers glow and trees murmur rumors, serves as the main hub. Notable figures include Elder Teth, a blind druid who sees visions through the 'third wind', Myria, an orphan girl who speaks only in plant metaphors and may be the reincarnation of the Fey Queen, and the Bloomwitch who trades in 'Petals of Memory' from her mushroom cellar.",
      discovered: false,
      region_id: REGION_SELDRINAR,
      faction_id: FACTION_HOLLOW_ROOT,
      character_id: nil
    }
    
    # Cindral Expanse
    $game_system.lore_entries << {
      id: 4,
      category: CATEGORY_REGIONS,
      title: "Cindral Expanse - Time's Forgotten Dust",
      description: "A vast desert filled with shifting dunes, underground tombs, and the shattered remains of ancient cities. The Cindral Expanse is unclaimed by any faction, making it a neutral ground where ghost-bound warriors wander and ancient secrets lie buried beneath the sands. The Mirror Crater, a meteor impact site, is said to be tied to celestial magic.\n\nThe region has an enigmatic, sun-scorched atmosphere filled with strange echoes and whispering winds. Dunebarrow Outpost serves as a caravan trading post built over ruins that shift in time, where merchants come and go — sometimes from other eras. Notable figures include Kal the Seeker who is cursed to wander until forgotten, Zevi, a child with perfect memory who recites past dialogues for Echo Coins, and the Hourglass Twins — one aging forward, one backward.",
      discovered: false,
      region_id: REGION_CINDRAL,
      faction_id: nil,
      character_id: nil
    }
    
    # Karrgorn Mountains
    $game_system.lore_entries << {
      id: 5,
      category: CATEGORY_REGIONS,
      title: "Karrgorn Mountains - Honor Buried in Ice",
      description: "A harsh region of ice peaks and fortified citadels, the Karrgorn Mountains serve as the base of operations for The Crimson Accord. The mountains are rich with soulstone, a rare mineral used to infuse soldiers with power at the infamous Veinspire mines. Fort Bladewatch, the headquarters of the Accord, stands as an imposing symbol of military might.\n\nThe region has a stoic, battle-worn atmosphere where pride has turned to prison, with echoing horns and ice percussion setting the tone. Fort Bladewatch holds together the mountain pass, where soldiers serve cause over country. Notable figures include Commander Elrik, a former hero turned fanatic who can be swayed, Silen the shadowbroker who sells illegal maps and whispers, and Harke the Bonekeeper who archives war-dead and will animate one if you bring them justice.",
      discovered: false,
      region_id: REGION_KARRGORN,
      faction_id: FACTION_CRIMSON_ACCORD,
      character_id: nil
    }
  end
  
  # Add Faction Lore
  def self.add_faction_lore
    # The Crimson Accord
    $game_system.lore_entries << {
      id: 101,
      category: CATEGORY_FACTIONS,
      title: "The Crimson Accord",
      description: "A powerful military organization that claims to maintain peace and order throughout Nyxoria. Their motto, 'Enforce order through strength,' reflects their authoritarian approach to governance. The Crimson Accord is headquartered at Fort Bladewatch in the Karrgorn Mountains. Unknown to most, the organization is controlled by a shadowy triumvirate with their own agenda. Their symbol is a red phoenix sword.",
      discovered: false,
      region_id: REGION_KARRGORN,
      faction_id: FACTION_CRIMSON_ACCORD,
      character_id: nil
    }
    
    # Order of the Shattered Flame
    $game_system.lore_entries << {
      id: 102,
      category: CATEGORY_FACTIONS,
      title: "Order of the Shattered Flame",
      description: "A radical group of mages who believe in using destructive magic to purge what they see as an impure world. They control the Nhar'Zhul Wastes and harness the volatile leyline magic that flows beneath the region. Rumors suggest they were involved in the destruction of Valebryn, though their true motives remain unclear. Their symbol is a broken flame surrounding an eye.",
      discovered: false,
      region_id: REGION_NHARZHUL,
      faction_id: FACTION_SHATTERED_FLAME,
      character_id: nil
    }
    
    # Hollow Root Kin
    $game_system.lore_entries << {
      id: 103,
      category: CATEGORY_FACTIONS,
      title: "Hollow Root Kin",
      description: "Once noble elves who protected the natural world, the Hollow Root Kin have been corrupted by fey magic and now seek to return Nyxoria to a state of primal chaos. They rule over the twisted Seldrinar Glade from their court at the Crown of Thorns. Their symbol, a thorn-wrapped skull, represents their fall from grace and their embrace of nature's darker aspects.",
      discovered: false,
      region_id: REGION_SELDRINAR,
      faction_id: FACTION_HOLLOW_ROOT,
      character_id: nil
    }
    
    # The Dawnsworn
    $game_system.lore_entries << {
      id: 104,
      category: CATEGORY_FACTIONS,
      title: "The Dawnsworn",
      description: "An underground resistance movement dedicated to restoring rightful rule and peace to Nyxoria. They operate in secret throughout the continent, gathering information and recruiting those who oppose the current power structures. The Dawnsworn believe in the prophecy of a returning heir who will unite the fractured lands. Their symbol is a sunburst on a black background.",
      discovered: false,
      region_id: nil,
      faction_id: FACTION_DAWNSWORN,
      character_id: nil
    }
  end
  
  # Add Character Lore
  def self.add_character_lore
    # The Exiled Prince
    $game_system.lore_entries << {
      id: 201,
      category: CATEGORY_CHARACTERS,
      title: "The Exiled Prince",
      description: "The last surviving member of Valebryn's royal family, believed dead by most of the world. Forced into hiding after the destruction of his kingdom, the prince must navigate a dangerous path of survival, revenge, and potential redemption. Every choice he makes will impact not only his own fate but the future of Nyxoria itself.",
      discovered: true, # Start with this discovered
      region_id: REGION_VALEBRYN,
      faction_id: nil,
      character_id: 1 # Assuming player character ID
    }
  end
  
  # Add Historical Lore
  def self.add_historical_lore
    # The Fall of Valebryn
    $game_system.lore_entries << {
      id: 301,
      category: CATEGORY_HISTORY,
      title: "The Fall of Valebryn",
      description: "Once the greatest kingdom in Nyxoria, Valebryn fell in a single night of fire and destruction. Unknown forces breached the defenses of the Crimson Keep, slaughtering the royal family and leaving the city in ruins. Only whispers remain of what truly happened, and of the rumored survival of the young prince, heir to the throne.",
      discovered: false,
      region_id: REGION_VALEBRYN,
      faction_id: nil,
      character_id: nil
    }
  end
  
  # Discover a lore entry by ID
  def self.discover_lore(id)
    entry = $game_system.lore_entries.find { |e| e[:id] == id }
    return false unless entry
    
    if !entry[:discovered]
      entry[:discovered] = true
      # Play discovery sound
      Sound.play_system_sound(1) # Assuming sound ID 1 is appropriate
      # Show discovery message
      $game_message.add("New lore discovered: #{entry[:title]}")
      return true
    end
    return false
  end
  
  # Get all discovered lore entries
  def self.discovered_lore
    $game_system.lore_entries.select { |e| e[:discovered] }
  end
  
  # Get all discovered lore entries by category
  def self.discovered_lore_by_category(category)
    $game_system.lore_entries.select { |e| e[:discovered] && e[:category] == category }
  end
  
  # Get all discovered lore entries by region
  def self.discovered_lore_by_region(region_id)
    $game_system.lore_entries.select { |e| e[:discovered] && e[:region_id] == region_id }
  end
  
  # Get all discovered lore entries by faction
  def self.discovered_lore_by_faction(faction_id)
    $game_system.lore_entries.select { |e| e[:discovered] && e[:faction_id] == faction_id }
  end
  
  # Get a specific lore entry by ID
  def self.get_lore_entry(id)
    $game_system.lore_entries.find { |e| e[:id] == id }
  end
end

# Initialize lore when a new game starts
class << DataManager
  alias lore_journal_make_save_contents make_save_contents
  def make_save_contents
    contents = lore_journal_make_save_contents
    contents
  end
  
  alias lore_journal_extract_save_contents extract_save_contents
  def extract_save_contents(contents)
    lore_journal_extract_save_contents(contents)
  end
  
  alias lore_journal_setup_new_game setup_new_game
  def setup_new_game
    lore_journal_setup_new_game
    LoreJournal.init_lore
  end
end

#==============================================================================
# ** Window_LoreList
#------------------------------------------------------------------------------
# This window displays a list of lore entries.
#==============================================================================
class Window_LoreList < Window_Selectable
  def initialize(x, y, width, height)
    super
    @data = []
    refresh
  end
  
  def set_category(category)
    @category = category
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
    @data = LoreJournal.discovered_lore_by_category(@category || LoreJournal::CATEGORY_REGIONS)
  end
  
  def draw_item(index)
    item = @data[index]
    return unless item
    rect = item_rect(index)
    draw_text(rect.x, rect.y, rect.width, line_height, item[:title])
  end
end

#==============================================================================
# ** Window_LoreDetail
#------------------------------------------------------------------------------
# This window displays the details of a selected lore entry.
#==============================================================================
class Window_LoreDetail < Window_Base
  def initialize(x, y, width, height)
    super
    @lore_entry = nil
    refresh
  end
  
  def set_lore_entry(lore_entry)
    @lore_entry = lore_entry
    refresh
  end
  
  def refresh
    contents.clear
    return unless @lore_entry
    
    draw_text_ex(4, 0, @lore_entry[:title])
    draw_text_ex(4, line_height, @lore_entry[:description])
  end
end

#==============================================================================
# ** Window_LoreCategory
#------------------------------------------------------------------------------
# This window displays lore categories.
#==============================================================================
class Window_LoreCategory < Window_Command
  def initialize(x, y)
    super(x, y)
  end
  
  def window_width
    return 160
  end
  
  def make_command_list
    add_command("Regions", :regions)
    add_command("Factions", :factions)
    add_command("Characters", :characters)
    add_command("History", :history)
  end
end

#==============================================================================
# ** Scene_LoreJournal
#------------------------------------------------------------------------------
# This scene handles the lore journal interface.
#==============================================================================
class Scene_LoreJournal < Scene_MenuBase
  def start
    super
    create_category_window
    create_list_window
    create_detail_window
  end
  
  def create_category_window
    @category_window = Window_LoreCategory.new(0, 0)
    @category_window.set_handler(:ok, method(:on_category_ok))
    @category_window.set_handler(:cancel, method(:return_scene))
  end
  
  def create_list_window
    x = @category_window.width
    y = 0
    width = Graphics.width - x
    height = Graphics.height / 3
    @list_window = Window_LoreList.new(x, y, width, height)
    @list_window.set_handler(:ok, method(:on_list_ok))
    @list_window.set_handler(:cancel, method(:on_list_cancel))
    @category_window.activate
  end
  
  def create_detail_window
    x = @category_window.width
    y = @list_window.height
    width = Graphics.width - x
    height = Graphics.height - y
    @detail_window = Window_LoreDetail.new(x, y, width, height)
    @list_window.select(0)
    update_detail_window
  end
  
  def on_category_ok
    case @category_window.current_symbol
    when :regions
      @list_window.set_category(LoreJournal::CATEGORY_REGIONS)
    when :factions
      @list_window.set_category(LoreJournal::CATEGORY_FACTIONS)
    when :characters
      @list_window.set_category(LoreJournal::CATEGORY_CHARACTERS)
    when :history
      @list_window.set_category(LoreJournal::CATEGORY_HISTORY)
    end
    @list_window.activate
    @list_window.select(0)
    update_detail_window
  end
  
  def on_list_ok
    update_detail_window
  end
  
  def on_list_cancel
    @list_window.unselect
    @category_window.activate
  end
  
  def update_detail_window
    @detail_window.set_lore_entry(@list_window.item)
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias lore_journal_add_original_commands add_original_commands
  def add_original_commands
    lore_journal_add_original_commands
    add_command("Lore Journal", :lore_journal)
  end
end

class Scene_Menu < Scene_MenuBase
  alias lore_journal_create_command_window create_command_window
  def create_command_window
    lore_journal_create_command_window
    @command_window.set_handler(:lore_journal, method(:command_lore_journal))
  end
  
  def command_lore_journal
    SceneManager.call(Scene_LoreJournal)
  end
end