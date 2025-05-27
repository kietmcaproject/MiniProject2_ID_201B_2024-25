#==============================================================================
# ** Nyxoria Core System
#------------------------------------------------------------------------------
# This script integrates all Nyxoria systems (Lore Journal, Faction System,
# Companion System, and World Map) and ensures they work together properly.
#==============================================================================

module NyxoriaCore
  # Version information
  VERSION = "1.0.0"
  
  # Game title
  GAME_TITLE = "Nyxoria: Echoes of the Abyss"
  
  # Core Themes
  THEMES = [
    "Destruction",
    "Legacy",
    "Moral Dilemmas",
    "Justice",
    "Corruption",
    "Faction Power Plays"
  ]
  
  # Initialize all Nyxoria systems
  def self.init_all_systems
    # Initialize systems in the correct order
    init_lore_journal
    init_faction_system
    init_companion_system
    init_world_map
    init_calendar_system
    init_language_system
    init_story_acts
    init_region_content
    
    # Set up cross-system integrations
    setup_integrations
  end
  
  # Initialize Story Acts
  def self.init_story_acts
    if defined?(StoryActs)
      StoryActs.init_story_acts
      puts "Story Acts system initialized." if $TEST
    else
      puts "WARNING: Story Acts system not found!" if $TEST
    end
  end
  
  # Initialize Region Content System
  def self.init_region_content
    if defined?(RegionContentSystem)
      RegionContentSystem.init_region_content
      puts "Region Content System initialized." if $TEST
    else
      puts "WARNING: Region Content System not found!" if $TEST
    end
  end
  
  # Initialize Lore Journal
  def self.init_lore_journal
    if defined?(LoreJournal)
      LoreJournal.init_lore
      puts "Lore Journal system initialized." if $TEST
    else
      puts "WARNING: Lore Journal system not found!" if $TEST
    end
  end
  
  # Initialize Faction System
  def self.init_faction_system
    if defined?(FactionSystem)
      FactionSystem.init_factions
      puts "Faction System initialized." if $TEST
    else
      puts "WARNING: Faction System not found!" if $TEST
    end
  end
  
  # Initialize Companion System
  def self.init_companion_system
    if defined?(CompanionSystem)
      CompanionSystem.init_companions
      puts "Companion System initialized." if $TEST
    else
      puts "WARNING: Companion System not found!" if $TEST
    end
  end
  
  # Initialize World Map
  def self.init_world_map
    if defined?(WorldMapSystem)
      WorldMapSystem.init_world_map
      puts "World Map System initialized." if $TEST
    else
      puts "WARNING: World Map System not found!" if $TEST
    end
  end
  
  # Initialize Calendar System
  def self.init_calendar_system
    if defined?(CalendarSystem)
      CalendarSystem.init_calendar
      puts "Calendar System initialized." if $TEST
    else
      puts "WARNING: Calendar System not found!" if $TEST
    end
  end
  
  # Initialize Language System
  def self.init_language_system
    if defined?(LanguageSystem)
      LanguageSystem.init_languages
      puts "Language System initialized." if $TEST
    else
      puts "WARNING: Language System not found!" if $TEST
    end
  end
  
  # Setup cross-system integrations
  def self.setup_integrations
    # These integrations ensure systems work together properly
    # For example, discovering a faction should update both the Faction System
    # and the Lore Journal
    
    # Calendar System integrations
    if defined?(CalendarSystem) && defined?(WorldMapSystem)
      # Calendar events can affect region accessibility
      # For example, certain paths might only be accessible during specific months
      
      # Ember month effects on Nhar'Zhul Wastes
      if CalendarSystem.current_month == CalendarSystem::MONTH_EMBER
        # Enhance fire-based enemies in Nhar'Zhul
        $game_variables[150] = 150 # Fire enemy strength boost
      end
      
      # Thorn month effects on Seldrinar Glade
      if CalendarSystem.current_month == CalendarSystem::MONTH_THORN
        # Open hidden bloom paths in Seldrinar
        $game_switches[70] = true # Bloom paths accessible
      end
    end
    
    # Language System integrations
    if defined?(LanguageSystem) && defined?(LoreJournal)
      # Discovering languages can unlock lore entries
      # For example, learning Old Valebrynic might reveal hidden history
      
      # Feyscript proficiency affects interactions in Seldrinar
      if LanguageSystem.get_proficiency(LanguageSystem::LANGUAGE_FEYSCRIPT) >= LanguageSystem::PROFICIENCY_INTERMEDIATE
        # Unlock hidden dialogues with fey creatures
        $game_switches[75] = true # Fey dialogue accessible
      end
    end
    
    # Story Acts integrations
    if defined?(StoryActs) && defined?(WorldMapSystem)
      # Add Act 3 and Act 4 locations to the World Map
      setup_story_act_locations
    end
    
    # Companion and Story Acts integrations
    if defined?(StoryActs) && defined?(CompanionSystem)
      # Companion side quests affect final battle outcomes
      setup_companion_story_integrations
    end
  end
  
  # Setup Act 3 and Act 4 locations on the World Map
  def self.setup_story_act_locations
    # Only add locations if they don't already exist
    return if $game_variables[220] == 1 # Locations already added flag
    
    # Add Act 3 locations
    StoryActs::ACT_3_LOCATIONS.each do |name, data|
      WorldMapSystem.add_location(
        data[:region_id],
        name,
        data[:description],
        data[:map_id],
        false # Not discovered initially
      )
    end
    
    # Add Act 4 locations
    StoryActs::ACT_4_LOCATIONS.each do |name, data|
      WorldMapSystem.add_location(
        data[:region_id],
        name,
        data[:description],
        data[:map_id],
        false # Not discovered initially
      )
    end
    
    # Set flag to indicate locations have been added
    $game_variables[220] = 1
  end
  
  # Setup companion and story act integrations
  def self.setup_companion_story_integrations
    # Set up companion side quest availability based on relationship levels
    if StoryActs.current_act >= StoryActs::ACT_3
      # Check for companion side quest availability
      if CompanionSystem.get_relationship(CompanionSystem::COMPANION_VALEN) >= 50
        $game_switches[55] = true # Valen side quest available
      end
      
      if CompanionSystem.get_relationship(CompanionSystem::COMPANION_THORNE) >= 50
        $game_switches[56] = true # Thorne side quest available
      end
      
      if CompanionSystem.get_relationship(CompanionSystem::COMPANION_KAIROS) >= 50
        $game_switches[57] = true # Kairos side quest available
      end
    end
  end
  
  # Trigger the fall of Valebryn event (opening sequence)
  def self.trigger_valebryn_fall
    # This would be called at the appropriate time in the story
    if defined?(LoreJournal)
      LoreJournal.discover_lore(301) # The Fall of Valebryn lore ID
    end
    
    if defined?(WorldMapSystem)
      WorldMapSystem.discover_region(WorldMapSystem::REGION_VALEBRYN)
    end
    
    # Set story flags
    $game_switches[1] = true # Assuming switch 1 is "Valebryn Fall Event Complete"
  end
  
  # Check if a moral choice affects faction relationships
  def self.process_moral_choice(choice_id, alignment)
    case choice_id
    when 1 # Example: Decision about Valebryn survivors
      if alignment == :justice
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 5) if defined?(FactionSystem)
      elsif alignment == :power
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, 5) if defined?(FactionSystem)
      end
    when 2 # Example: Decision about ancient magic
      if alignment == :destruction
        FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 5) if defined?(FactionSystem)
      elsif alignment == :nature
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 5) if defined?(FactionSystem)
      end
    end
    
    # Update companion relationships based on moral choices
    update_companions_for_choice(choice_id, alignment)
  end
  
  # Update companion relationships based on moral choices
  def self.update_companions_for_choice(choice_id, alignment)
    return unless defined?(CompanionSystem)
    
    case choice_id
    when 1 # Example: Decision about Valebryn survivors
      if alignment == :justice
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, 5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, -3)
      elsif alignment == :power
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, -5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, 3)
      end
    when 2 # Example: Decision about ancient magic
      if alignment == :destruction
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, 5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, -5)
      elsif alignment == :nature
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, -5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, 5)
      end
    end
  end
  
  # Check if player has enough faction reputation to access an area
  def self.can_access_faction_area?(faction_id, required_level = FactionSystem::REPUTATION_NEUTRAL)
    return false unless defined?(FactionSystem)
    FactionSystem.reputation_at_least?(faction_id, required_level)
  end
  
  # Check if player has discovered enough lore about a topic
  def self.has_sufficient_lore_knowledge?(category, count = 1)
    return false unless defined?(LoreJournal)
    LoreJournal.discovered_lore_by_category(category).size >= count
  end
  
  # Get the player's dominant faction alignment
  def self.dominant_faction_alignment
    return nil unless defined?(FactionSystem)
    
    # Get reputation with each faction
    crimson_rep = FactionSystem.get_reputation(FactionSystem::FACTION_CRIMSON_ACCORD)
    flame_rep = FactionSystem.get_reputation(FactionSystem::FACTION_SHATTERED_FLAME)
    root_rep = FactionSystem.get_reputation(FactionSystem::FACTION_HOLLOW_ROOT)
    dawn_rep = FactionSystem.get_reputation(FactionSystem::FACTION_DAWNSWORN)
    
    # Find the highest reputation
    reps = {
      FactionSystem::FACTION_CRIMSON_ACCORD => crimson_rep,
      FactionSystem::FACTION_SHATTERED_FLAME => flame_rep,
      FactionSystem::FACTION_HOLLOW_ROOT => root_rep,
      FactionSystem::FACTION_DAWNSWORN => dawn_rep
    }
    
    # Return the faction with highest reputation, or nil if all are neutral or negative
    highest = reps.max_by { |k, v| v }
    highest[1] > FactionSystem::REPUTATION_NEUTRAL ? highest[0] : nil
  end
  
  # Get the player's moral alignment based on choices
  def self.moral_alignment
    # This would be based on tracked moral choices throughout the game
    # For now, return a default value
    :neutral
  end
  
  # Unlock a new ending based on player choices
  def self.unlock_ending(ending_id)
    $game_system.unlocked_endings ||= []
    $game_system.unlocked_endings << ending_id unless $game_system.unlocked_endings.include?(ending_id)
  end
  
  # Check if a specific ending is unlocked
  def self.ending_unlocked?(ending_id)
    $game_system.unlocked_endings ||= []
    $game_system.unlocked_endings.include?(ending_id)
  end
  
  # Get all unlocked endings
  def self.unlocked_endings
    $game_system.unlocked_endings ||= []
  end
  
  # Process Sigil Shard choice (Act 3)
  def self.process_sigil_choice(choice)
    return false unless defined?(StoryActs)
    StoryActs.record_sigil_choice(choice)
    
    # Update faction relationships based on choice
    if choice == :fuse
      # Destruction path favored by Shattered Flame
      FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 10) if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, -10) if defined?(FactionSystem)
    elsif choice == :resist
      # Preservation path favored by Hollow Root
      FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 10) if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, -10) if defined?(FactionSystem)
    elsif choice == :share
      # Justice path favored by Dawnsworn
      FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 10) if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -5) if defined?(FactionSystem)
    end
    
    return true
  end
  
  # Process faction allies choice (Act 4)
  def self.process_faction_allies(faction_ids)
    return false unless defined?(StoryActs)
    StoryActs.record_faction_allies(faction_ids)
    return true
  end
  
  # Process legacy choice (Act 4)
  def self.process_legacy_choice(choice)
    return false unless defined?(StoryActs)
    StoryActs.record_legacy_choice(choice)
    return true
  end
  
  # Process final path choice (Act 4)
  def self.process_final_path(path)
    return false unless defined?(StoryActs)
    StoryActs.record_final_path(path)
    return true
  end
  
  # Check if a companion will betray in final battle
  def self.will_companion_betray?(companion_id)
    return false unless defined?(StoryActs) && defined?(CompanionSystem)
    
    # Get companion relationship and player choices
    relationship = CompanionSystem.get_relationship(companion_id)
    final_path = $game_system.story_acts_data[:act4_choices][:final_path]
    
    # Very low relationship leads to betrayal
    return true if relationship < -50
    
    # Path conflicts with companion values
    if final_path == :flame && companion_id == CompanionSystem::COMPANION_THORNE
      return true # Thorne opposes destruction
    elsif final_path == :chains && companion_id == CompanionSystem::COMPANION_KAIROS
      return true # Kairos opposes rigid order
    end
    
    return false
  end
  
  # Get the epilogue text based on choices
  def self.get_epilogue_text
    return "The story continues..." unless defined?(StoryActs)
    
    final_path = $game_system.story_acts_data[:act4_choices][:final_path]
    return "Your journey is not yet complete." unless final_path
    
    # Return the appropriate ending description
    StoryActs::ENDING_DESCRIPTIONS[StoryActs.const_get("ENDING_#{final_path.upcase}")]
  end
end

# Initialize all systems when a new game starts
class << DataManager
  alias nyxoria_core_setup_new_game setup_new_game
  def setup_new_game
    nyxoria_core_setup_new_game
    NyxoriaCore.init_all_systems
  end
end

# Add Nyxoria version to title screen
class Scene_Title < Scene_Base
  alias nyxoria_core_create_foreground create_foreground
  def create_foreground
    nyxoria_core_create_foreground
    create_version_text
  end
  
  def create_version_text
    @version_text = Sprite.new
    @version_text.bitmap = Bitmap.new(Graphics.width, 24)
    @version_text.bitmap.font.size = 16
    @version_text.bitmap.draw_text(0, 0, Graphics.width, 24, "Nyxoria v#{NyxoriaCore::VERSION}", 2)
    @version_text.x = 0
    @version_text.y = Graphics.height - 24
  end
  
  alias nyxoria_core_dispose_foreground dispose_foreground
  def dispose_foreground
    nyxoria_core_dispose_foreground
    @version_text.bitmap.dispose
    @version_text.dispose
  end
end

# Add custom game over processing based on player choices
class Scene_Gameover < Scene_Base
  alias nyxoria_core_start start
  def start
    nyxoria_core_start
    # Custom game over processing could go here
  end
end