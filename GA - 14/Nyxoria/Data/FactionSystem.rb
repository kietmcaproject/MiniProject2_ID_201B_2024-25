#==============================================================================
# ** Faction System
#------------------------------------------------------------------------------
# This script implements a Faction System for Nyxoria, allowing tracking of
# player reputation with different factions and faction-specific events.
#==============================================================================

module FactionSystem
  # Faction IDs (matching those in LoreJournal)
  FACTION_CRIMSON_ACCORD = 0
  FACTION_SHATTERED_FLAME = 1
  FACTION_HOLLOW_ROOT = 2
  FACTION_DAWNSWORN = 3
  
  # Reputation Levels
  REPUTATION_HATED = -3
  REPUTATION_HOSTILE = -2
  REPUTATION_UNFRIENDLY = -1
  REPUTATION_NEUTRAL = 0
  REPUTATION_FRIENDLY = 1
  REPUTATION_HONORED = 2
  REPUTATION_EXALTED = 3
  
  # Faction Names
  FACTION_NAMES = {
    FACTION_CRIMSON_ACCORD => "The Crimson Accord",
    FACTION_SHATTERED_FLAME => "Order of the Shattered Flame",
    FACTION_HOLLOW_ROOT => "Hollow Root Kin",
    FACTION_DAWNSWORN => "The Dawnsworn"
  }
  
  # Reputation Level Names
  REPUTATION_NAMES = {
    REPUTATION_HATED => "Hated",
    REPUTATION_HOSTILE => "Hostile",
    REPUTATION_UNFRIENDLY => "Unfriendly",
    REPUTATION_NEUTRAL => "Neutral",
    REPUTATION_FRIENDLY => "Friendly",
    REPUTATION_HONORED => "Honored",
    REPUTATION_EXALTED => "Exalted"
  }
  
  # Faction Colors (for UI display)
  FACTION_COLORS = {
    FACTION_CRIMSON_ACCORD => Color.new(180, 0, 0),    # Dark Red
    FACTION_SHATTERED_FLAME => Color.new(255, 128, 0), # Orange
    FACTION_HOLLOW_ROOT => Color.new(0, 100, 0),       # Dark Green
    FACTION_DAWNSWORN => Color.new(255, 215, 0)        # Gold
  }
  
  # Initialize faction data
  def self.init_factions
    $game_system.faction_data ||= {}
    
    # Only initialize if faction data is empty
    return unless $game_system.faction_data.empty?
    
    # Set initial reputation levels
    $game_system.faction_data[FACTION_CRIMSON_ACCORD] = REPUTATION_NEUTRAL
    $game_system.faction_data[FACTION_SHATTERED_FLAME] = REPUTATION_UNFRIENDLY
    $game_system.faction_data[FACTION_HOLLOW_ROOT] = REPUTATION_UNFRIENDLY
    $game_system.faction_data[FACTION_DAWNSWORN] = REPUTATION_NEUTRAL
    
    # Set faction discovery status
    $game_system.discovered_factions ||= []
    $game_system.discovered_factions << FACTION_CRIMSON_ACCORD # Start with Crimson Accord discovered
  end
  
  # Get reputation with a faction
  def self.get_reputation(faction_id)
    $game_system.faction_data[faction_id] || REPUTATION_NEUTRAL
  end
  
  # Change reputation with a faction
  def self.change_reputation(faction_id, amount)
    return unless $game_system.faction_data[faction_id]
    
    old_rep = $game_system.faction_data[faction_id]
    new_rep = [REPUTATION_HATED, [old_rep + amount, REPUTATION_EXALTED].min].max
    $game_system.faction_data[faction_id] = new_rep
    
    # Discover faction if not already discovered
    discover_faction(faction_id)
    
    # Show reputation change message if significant
    if old_rep != new_rep
      faction_name = FACTION_NAMES[faction_id]
      rep_name = REPUTATION_NAMES[new_rep]
      $game_message.add("Your reputation with #{faction_name} is now #{rep_name}.")
      
      # Play appropriate sound
      if new_rep > old_rep
        Sound.play_system_sound(8) # Positive sound
      else
        Sound.play_system_sound(10) # Negative sound
      end
    end
    
    return new_rep
  end
  
  # Set reputation with a faction to a specific level
  def self.set_reputation(faction_id, level)
    return unless $game_system.faction_data[faction_id]
    level = [[level, REPUTATION_HATED].max, REPUTATION_EXALTED].min
    $game_system.faction_data[faction_id] = level
    discover_faction(faction_id)
  end
  
  # Check if reputation is at least at a certain level
  def self.reputation_at_least?(faction_id, level)
    rep = get_reputation(faction_id)
    rep >= level
  end
  
  # Check if reputation is at most at a certain level
  def self.reputation_at_most?(faction_id, level)
    rep = get_reputation(faction_id)
    rep <= level
  end
  
  # Discover a faction
  def self.discover_faction(faction_id)
    $game_system.discovered_factions ||= []
    unless $game_system.discovered_factions.include?(faction_id)
      $game_system.discovered_factions << faction_id
      
      # Show discovery message
      faction_name = FACTION_NAMES[faction_id]
      $game_message.add("New faction discovered: #{faction_name}")
      
      # Play discovery sound
      Sound.play_system_sound(1) # Assuming sound ID 1 is appropriate
      
      # Discover related lore if LoreJournal is available
      if defined?(LoreJournal)
        case faction_id
        when FACTION_CRIMSON_ACCORD
          LoreJournal.discover_lore(101) # Crimson Accord lore ID
        when FACTION_SHATTERED_FLAME
          LoreJournal.discover_lore(102) # Shattered Flame lore ID
        when FACTION_HOLLOW_ROOT
          LoreJournal.discover_lore(103) # Hollow Root lore ID
        when FACTION_DAWNSWORN
          LoreJournal.discover_lore(104) # Dawnsworn lore ID
        end
      end
      
      return true
    end
    return false
  end
  
  # Get all discovered factions
  def self.discovered_factions
    $game_system.discovered_factions || []
  end
  
  # Check if a faction is discovered
  def self.faction_discovered?(faction_id)
    $game_system.discovered_factions ||= []
    $game_system.discovered_factions.include?(faction_id)
  end
  
  # Get reputation name for a faction
  def self.reputation_name(faction_id)
    rep = get_reputation(faction_id)
    REPUTATION_NAMES[rep]
  end
  
  # Get faction color
  def self.faction_color(faction_id)
    FACTION_COLORS[faction_id] || Color.new(255, 255, 255) # Default to white
  end
  
  # Get faction name
  def self.faction_name(faction_id)
    FACTION_NAMES[faction_id] || "Unknown Faction"
  end
end

# Initialize factions when a new game starts
class << DataManager
  alias faction_system_setup_new_game setup_new_game
  def setup_new_game
    faction_system_setup_new_game
    FactionSystem.init_factions
  end
end

#==============================================================================
# ** Window_FactionList
#------------------------------------------------------------------------------
# This window displays a list of discovered factions.
#==============================================================================
class Window_FactionList < Window_Selectable
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
    @data = FactionSystem.discovered_factions
  end
  
  def draw_item(index)
    faction_id = @data[index]
    return unless faction_id
    rect = item_rect(index)
    faction_name = FactionSystem.faction_name(faction_id)
    reputation = FactionSystem.reputation_name(faction_id)
    color = FactionSystem.faction_color(faction_id)
    change_color(color)
    draw_text(rect.x, rect.y, rect.width / 2, line_height, faction_name)
    change_color(normal_color)
    draw_text(rect.x + rect.width / 2, rect.y, rect.width / 2, line_height, reputation, 2)
  end
end

#==============================================================================
# ** Window_FactionDetail
#------------------------------------------------------------------------------
# This window displays details about a selected faction.
#==============================================================================
class Window_FactionDetail < Window_Base
  def initialize(x, y, width, height)
    super
    @faction_id = nil
    refresh
  end
  
  def set_faction(faction_id)
    @faction_id = faction_id
    refresh
  end
  
  def refresh
    contents.clear
    return unless @faction_id
    
    faction_name = FactionSystem.faction_name(@faction_id)
    reputation = FactionSystem.reputation_name(@faction_id)
    color = FactionSystem.faction_color(@faction_id)
    
    change_color(color)
    draw_text(0, 0, contents.width, line_height, faction_name, 1)
    change_color(normal_color)
    draw_text(0, line_height, contents.width, line_height, "Reputation: #{reputation}", 1)
    
    # Draw faction description if LoreJournal is available
    if defined?(LoreJournal)
      lore_id = case @faction_id
                when FactionSystem::FACTION_CRIMSON_ACCORD
                  101 # Crimson Accord lore ID
                when FactionSystem::FACTION_SHATTERED_FLAME
                  102 # Shattered Flame lore ID
                when FactionSystem::FACTION_HOLLOW_ROOT
                  103 # Hollow Root lore ID
                when FactionSystem::FACTION_DAWNSWORN
                  104 # Dawnsworn lore ID
                end
      
      if lore_id
        lore_entry = LoreJournal.get_lore_entry(lore_id)
        if lore_entry && lore_entry[:discovered]
          draw_text_ex(4, line_height * 3, lore_entry[:description])
        else
          draw_text(0, line_height * 3, contents.width, line_height, "Information locked. Discover more about this faction.")
        end
      end
    end
  end
end

#==============================================================================
# ** Scene_Factions
#------------------------------------------------------------------------------
# This scene handles the faction interface.
#==============================================================================
class Scene_Factions < Scene_MenuBase
  def start
    super
    create_help_window
    create_list_window
    create_detail_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("Factions of Nyxoria")
  end
  
  def create_list_window
    y = @help_window.height
    width = Graphics.width / 3
    height = Graphics.height - y
    @list_window = Window_FactionList.new(0, y, width, height)
    @list_window.set_handler(:ok, method(:on_list_ok))
    @list_window.set_handler(:cancel, method(:return_scene))
    @list_window.activate
  end
  
  def create_detail_window
    y = @help_window.height
    width = Graphics.width - @list_window.width
    height = Graphics.height - y
    @detail_window = Window_FactionDetail.new(@list_window.width, y, width, height)
    @list_window.select(0)
    update_detail_window
  end
  
  def on_list_ok
    update_detail_window
  end
  
  def update_detail_window
    @detail_window.set_faction(@list_window.item)
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias faction_system_add_original_commands add_original_commands
  def add_original_commands
    faction_system_add_original_commands
    add_command("Factions", :factions)
  end
end

class Scene_Menu < Scene_MenuBase
  alias faction_system_create_command_window create_command_window
  def create_command_window
    faction_system_create_command_window
    @command_window.set_handler(:factions, method(:command_factions))
  end
  
  def command_factions
    SceneManager.call(Scene_Factions)
  end
end