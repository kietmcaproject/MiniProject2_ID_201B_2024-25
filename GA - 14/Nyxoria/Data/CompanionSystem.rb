#==============================================================================
# ** Companion System
#------------------------------------------------------------------------------
# This script implements a Companion System for Nyxoria, allowing recruitment
# of companions with faction affiliations, personal quests, and dialogue.
#==============================================================================

module CompanionSystem
  # Companion IDs
  COMPANION_VALEN = 0   # Dawnsworn representative
  COMPANION_LYRA = 1    # Crimson Accord representative
  COMPANION_KAIROS = 2  # Shattered Flame representative
  COMPANION_THORNE = 3  # Hollow Root representative
  COMPANION_ZEPHYR = 4  # Neutral/unaffiliated
  
  # Companion Names
  COMPANION_NAMES = {
    COMPANION_VALEN => "Valen",
    COMPANION_LYRA => "Lyra",
    COMPANION_KAIROS => "Kairos",
    COMPANION_THORNE => "Thorne",
    COMPANION_ZEPHYR => "Zephyr"
  }
  
  # Companion Faction Affiliations
  COMPANION_FACTIONS = {
    COMPANION_VALEN => FactionSystem::FACTION_DAWNSWORN,
    COMPANION_LYRA => FactionSystem::FACTION_CRIMSON_ACCORD,
    COMPANION_KAIROS => FactionSystem::FACTION_SHATTERED_FLAME,
    COMPANION_THORNE => FactionSystem::FACTION_HOLLOW_ROOT,
    COMPANION_ZEPHYR => nil # Neutral
  }
  
  # Companion Actor IDs (for battle party members)
  COMPANION_ACTOR_IDS = {
    COMPANION_VALEN => 2,   # Actor ID in database
    COMPANION_LYRA => 3,    # Actor ID in database
    COMPANION_KAIROS => 4,  # Actor ID in database
    COMPANION_THORNE => 5,  # Actor ID in database
    COMPANION_ZEPHYR => 6   # Actor ID in database
  }
  
  # Companion Descriptions
  COMPANION_DESCRIPTIONS = {
    COMPANION_VALEN => "A former royal guard of Valebryn who survived the kingdom's fall. Valen is dedicated to the Dawnsworn cause and believes in restoring rightful rule to Nyxoria. Skilled with a sword and shield, he is a stalwart defender and loyal ally.",
    COMPANION_LYRA => "A high-ranking officer in the Crimson Accord with conflicted loyalties. Lyra joined the military organization seeking order but has grown suspicious of its leadership. She excels at tactical combat and ranged weapons.",
    COMPANION_KAIROS => "A brilliant but unstable mage from the Order of the Shattered Flame. Kairos believes in the purifying power of destruction but may have deeper motives for joining your cause. Wields devastating fire and chaos magic.",
    COMPANION_THORNE => "Once a noble elf protector, now twisted by fey magic. Thorne struggles between his Hollow Root nature and his desire to reclaim his former self. Commands powerful nature magic that can heal allies or strangle enemies.",
    COMPANION_ZEPHYR => "A mysterious wanderer with knowledge of ancient ruins and forgotten magic. Zephyr's true origins and motivations remain unclear, but their skills as a scout and archaeologist are unmatched. Specializes in artifact-based abilities."
  }
  
  # Companion Lore IDs (for LoreJournal integration)
  COMPANION_LORE_IDS = {
    COMPANION_VALEN => 202,
    COMPANION_LYRA => 203,
    COMPANION_KAIROS => 204,
    COMPANION_THORNE => 205,
    COMPANION_ZEPHYR => 206
  }
  
  # Initialize companion data
  def self.init_companions
    $game_system.companion_data ||= {}
    
    # Only initialize if companion data is empty
    return unless $game_system.companion_data.empty?
    
    # Set initial companion states (all unavailable at start)
    [COMPANION_VALEN, COMPANION_LYRA, COMPANION_KAIROS, COMPANION_THORNE, COMPANION_ZEPHYR].each do |id|
      $game_system.companion_data[id] = {
        recruited: false,
        available: false,
        relationship: 0,  # -100 to 100 scale for relationship value
        quest_active: false,
        quest_complete: false
      }
    end
    
    # Make Valen available early (first companion)
    $game_system.companion_data[COMPANION_VALEN][:available] = true
    
    # Add companion lore to LoreJournal if available
    if defined?(LoreJournal)
      add_companion_lore
    end
  end
  
  # Add companion lore to the LoreJournal
  def self.add_companion_lore
    # Valen - Dawnsworn Representative
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 202,
        category: CATEGORY_CHARACTERS,
        title: "Valen - Dawnsworn Guardian",
        description: CompanionSystem::COMPANION_DESCRIPTIONS[CompanionSystem::COMPANION_VALEN],
        discovered: false,
        region_id: nil,
        faction_id: FactionSystem::FACTION_DAWNSWORN,
        character_id: CompanionSystem::COMPANION_VALEN
      }
    end
    
    # Lyra - Crimson Accord Representative
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 203,
        category: CATEGORY_CHARACTERS,
        title: "Lyra - Crimson Accord Officer",
        description: CompanionSystem::COMPANION_DESCRIPTIONS[CompanionSystem::COMPANION_LYRA],
        discovered: false,
        region_id: nil,
        faction_id: FactionSystem::FACTION_CRIMSON_ACCORD,
        character_id: CompanionSystem::COMPANION_LYRA
      }
    end
    
    # Kairos - Shattered Flame Representative
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 204,
        category: CATEGORY_CHARACTERS,
        title: "Kairos - Shattered Flame Mage",
        description: CompanionSystem::COMPANION_DESCRIPTIONS[CompanionSystem::COMPANION_KAIROS],
        discovered: false,
        region_id: nil,
        faction_id: FactionSystem::FACTION_SHATTERED_FLAME,
        character_id: CompanionSystem::COMPANION_KAIROS
      }
    end
    
    # Thorne - Hollow Root Representative
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 205,
        category: CATEGORY_CHARACTERS,
        title: "Thorne - Hollow Root Druid",
        description: CompanionSystem::COMPANION_DESCRIPTIONS[CompanionSystem::COMPANION_THORNE],
        discovered: false,
        region_id: nil,
        faction_id: FactionSystem::FACTION_HOLLOW_ROOT,
        character_id: CompanionSystem::COMPANION_THORNE
      }
    end
    
    # Zephyr - Neutral Representative
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 206,
        category: CATEGORY_CHARACTERS,
        title: "Zephyr - Enigmatic Wanderer",
        description: CompanionSystem::COMPANION_DESCRIPTIONS[CompanionSystem::COMPANION_ZEPHYR],
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: CompanionSystem::COMPANION_ZEPHYR
      }
    end
  end
  
  # Make a companion available for recruitment
  def self.make_available(companion_id)
    return unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:available] = true
  end
  
  # Recruit a companion
  def self.recruit(companion_id)
    return false unless $game_system.companion_data[companion_id]
    return false unless $game_system.companion_data[companion_id][:available]
    return true if $game_system.companion_data[companion_id][:recruited] # Already recruited
    
    $game_system.companion_data[companion_id][:recruited] = true
    
    # Add companion to party if there's room
    actor_id = COMPANION_ACTOR_IDS[companion_id]
    if $game_party.members.size < 4 && actor_id
      $game_party.add_actor(actor_id)
    end
    
    # Discover companion lore
    if defined?(LoreJournal) && COMPANION_LORE_IDS[companion_id]
      LoreJournal.discover_lore(COMPANION_LORE_IDS[companion_id])
    end
    
    # Discover associated faction
    faction_id = COMPANION_FACTIONS[companion_id]
    if defined?(FactionSystem) && faction_id
      FactionSystem.discover_faction(faction_id)
    end
    
    # Show recruitment message
    companion_name = COMPANION_NAMES[companion_id]
    $game_message.add("#{companion_name} has joined your party!")
    
    # Play recruitment sound
    Sound.play_system_sound(14) # Assuming sound ID 14 is appropriate
    
    return true
  end
  
  # Dismiss a companion
  def self.dismiss(companion_id)
    return false unless $game_system.companion_data[companion_id]
    return false unless $game_system.companion_data[companion_id][:recruited]
    
    $game_system.companion_data[companion_id][:recruited] = false
    
    # Remove companion from party
    actor_id = COMPANION_ACTOR_IDS[companion_id]
    if actor_id
      $game_party.remove_actor(actor_id)
    end
    
    # Show dismissal message
    companion_name = COMPANION_NAMES[companion_id]
    $game_message.add("#{companion_name} has left your party.")
    
    return true
  end
  
  # Check if a companion is recruited
  def self.recruited?(companion_id)
    return false unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:recruited]
  end
  
  # Check if a companion is available for recruitment
  def self.available?(companion_id)
    return false unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:available]
  end
  
  # Change relationship with a companion
  def self.change_relationship(companion_id, amount)
    return unless $game_system.companion_data[companion_id]
    
    old_rel = $game_system.companion_data[companion_id][:relationship]
    new_rel = [[old_rel + amount, -100].max, 100].min
    $game_system.companion_data[companion_id][:relationship] = new_rel
    
    # Show relationship change message if significant
    if (old_rel < 0 && new_rel >= 0) || (old_rel >= 0 && new_rel < 0) ||
       (old_rel < 50 && new_rel >= 50) || (old_rel >= 50 && new_rel < 50)
      companion_name = COMPANION_NAMES[companion_id]
      if new_rel > old_rel
        $game_message.add("#{companion_name} seems to approve of your actions.")
        Sound.play_system_sound(8) # Positive sound
      else
        $game_message.add("#{companion_name} seems to disapprove of your actions.")
        Sound.play_system_sound(10) # Negative sound
      end
    end
    
    return new_rel
  end
  
  # Get relationship with a companion
  def self.get_relationship(companion_id)
    return 0 unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:relationship]
  end
  
  # Get relationship status text
  def self.relationship_status(companion_id)
    rel = get_relationship(companion_id)
    
    if rel >= 75
      return "Devoted"
    elsif rel >= 50
      return "Trusting"
    elsif rel >= 25
      return "Friendly"
    elsif rel >= 0
      return "Neutral"
    elsif rel >= -25
      return "Wary"
    elsif rel >= -50
      return "Distrustful"
    elsif rel >= -75
      return "Hostile"
    else
      return "Antagonistic"
    end
  end
  
  # Activate a companion's personal quest
  def self.activate_quest(companion_id)
    return unless $game_system.companion_data[companion_id]
    return if $game_system.companion_data[companion_id][:quest_active] # Already active
    return if $game_system.companion_data[companion_id][:quest_complete] # Already complete
    
    $game_system.companion_data[companion_id][:quest_active] = true
    
    # Show quest activation message
    companion_name = COMPANION_NAMES[companion_id]
    $game_message.add("#{companion_name}'s personal quest has begun.")
    
    # Play quest activation sound
    Sound.play_system_sound(15) # Assuming sound ID 15 is appropriate
    
    return true
  end
  
  # Complete a companion's personal quest
  def self.complete_quest(companion_id)
    return unless $game_system.companion_data[companion_id]
    return unless $game_system.companion_data[companion_id][:quest_active] # Must be active
    return if $game_system.companion_data[companion_id][:quest_complete] # Already complete
    
    $game_system.companion_data[companion_id][:quest_active] = false
    $game_system.companion_data[companion_id][:quest_complete] = true
    
    # Improve relationship significantly
    change_relationship(companion_id, 25)
    
    # Show quest completion message
    companion_name = COMPANION_NAMES[companion_id]
    $game_message.add("#{companion_name}'s personal quest has been completed!")
    
    # Play quest completion sound
    Sound.play_system_sound(14) # Assuming sound ID 14 is appropriate
    
    return true
  end
  
  # Check if a companion's quest is active
  def self.quest_active?(companion_id)
    return false unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:quest_active]
  end
  
  # Check if a companion's quest is complete
  def self.quest_complete?(companion_id)
    return false unless $game_system.companion_data[companion_id]
    $game_system.companion_data[companion_id][:quest_complete]
  end
  
  # Get all recruited companions
  def self.recruited_companions
    result = []
    $game_system.companion_data.each do |id, data|
      result << id if data[:recruited]
    end
    return result
  end
  
  # Get all available companions
  def self.available_companions
    result = []
    $game_system.companion_data.each do |id, data|
      result << id if data[:available] && !data[:recruited]
    end
    return result
  end
  
  # Get companion name
  def self.companion_name(companion_id)
    COMPANION_NAMES[companion_id] || "Unknown Companion"
  end
  
  # Get companion description
  def self.companion_description(companion_id)
    COMPANION_DESCRIPTIONS[companion_id] || "No information available."
  end
  
  # Get companion faction
  def self.companion_faction(companion_id)
    COMPANION_FACTIONS[companion_id]
  end
end

# Initialize companions when a new game starts
class << DataManager
  alias companion_system_setup_new_game setup_new_game
  def setup_new_game
    companion_system_setup_new_game
    CompanionSystem.init_companions
  end
end

#==============================================================================
# ** Window_CompanionList
#------------------------------------------------------------------------------
# This window displays a list of companions.
#==============================================================================
class Window_CompanionList < Window_Selectable
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
    @data = CompanionSystem.recruited_companions
  end
  
  def draw_item(index)
    companion_id = @data[index]
    return unless companion_id
    rect = item_rect(index)
    companion_name = CompanionSystem.companion_name(companion_id)
    relationship = CompanionSystem.relationship_status(companion_id)
    
    # Get faction color if available
    faction_id = CompanionSystem.companion_faction(companion_id)
    if defined?(FactionSystem) && faction_id
      color = FactionSystem.faction_color(faction_id)
      change_color(color)
    else
      change_color(normal_color)
    end
    
    draw_text(rect.x, rect.y, rect.width / 2, line_height, companion_name)
    change_color(normal_color)
    draw_text(rect.x + rect.width / 2, rect.y, rect.width / 2, line_height, relationship, 2)
  end
end

#==============================================================================
# ** Window_CompanionDetail
#------------------------------------------------------------------------------
# This window displays details about a selected companion.
#==============================================================================
class Window_CompanionDetail < Window_Base
  def initialize(x, y, width, height)
    super
    @companion_id = nil
    refresh
  end
  
  def set_companion(companion_id)
    @companion_id = companion_id
    refresh
  end
  
  def refresh
    contents.clear
    return unless @companion_id
    
    companion_name = CompanionSystem.companion_name(@companion_id)
    relationship = CompanionSystem.relationship_status(@companion_id)
    description = CompanionSystem.companion_description(@companion_id)
    faction_id = CompanionSystem.companion_faction(@companion_id)
    
    # Get faction color and name if available
    if defined?(FactionSystem) && faction_id
      color = FactionSystem.faction_color(faction_id)
      faction_name = FactionSystem.faction_name(faction_id)
      change_color(color)
    else
      color = normal_color
      faction_name = "None"
      change_color(normal_color)
    end
    
    # Draw companion name
    draw_text(0, 0, contents.width, line_height, companion_name, 1)
    
    # Draw faction affiliation
    change_color(normal_color)
    draw_text(0, line_height, contents.width / 2, line_height, "Faction:")
    change_color(color)
    draw_text(contents.width / 2, line_height, contents.width / 2, line_height, faction_name)
    
    # Draw relationship status
    change_color(normal_color)
    draw_text(0, line_height * 2, contents.width / 2, line_height, "Relationship:")
    draw_text(contents.width / 2, line_height * 2, contents.width / 2, line_height, relationship)
    
    # Draw quest status if applicable
    if CompanionSystem.quest_complete?(@companion_id)
      draw_text(0, line_height * 3, contents.width, line_height, "Personal Quest: Complete", 1)
    elsif CompanionSystem.quest_active?(@companion_id)
      draw_text(0, line_height * 3, contents.width, line_height, "Personal Quest: Active", 1)
    end
    
    # Draw description
    draw_text_ex(4, line_height * 4, description)
  end
end

#==============================================================================
# ** Scene_Companions
#------------------------------------------------------------------------------
# This scene handles the companion interface.
#==============================================================================
class Scene_Companions < Scene_MenuBase
  def start
    super
    create_help_window
    create_list_window
    create_detail_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("Companions")
  end
  
  def create_list_window
    y = @help_window.height
    width = Graphics.width / 3
    height = Graphics.height - y
    @list_window = Window_CompanionList.new(0, y, width, height)
    @list_window.set_handler(:ok, method(:on_list_ok))
    @list_window.set_handler(:cancel, method(:return_scene))
    @list_window.activate
  end
  
  def create_detail_window
    y = @help_window.height
    width = Graphics.width - @list_window.width
    height = Graphics.height - y
    @detail_window = Window_CompanionDetail.new(@list_window.width, y, width, height)
    @list_window.select(0)
    update_detail_window
  end
  
  def on_list_ok
    update_detail_window
  end
  
  def update_detail_window
    @detail_window.set_companion(@list_window.item)
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias companion_system_add_original_commands add_original_commands
  def add_original_commands
    companion_system_add_original_commands
    add_command("Companions", :companions)
  end
end

class Scene_Menu < Scene_MenuBase
  alias companion_system_create_command_window create_command_window
  def create_command_window
    companion_system_create_command_window
    @command_window.set_handler(:companions, method(:command_companions))
  end
  
  def command_companions
    SceneManager.call(Scene_Companions)
  end
end