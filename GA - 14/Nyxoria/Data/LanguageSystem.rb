#==============================================================================
# ** Language System
#------------------------------------------------------------------------------
# This script implements a Language system for Nyxoria, allowing players
# to discover and translate different languages throughout the world.
#==============================================================================

module LanguageSystem
  # Language IDs
  LANGUAGE_OLD_VALEBRYNIC = 0  # Ancient noble tongue — used in court ruins
  LANGUAGE_FEYSCRIPT = 1       # Appears as glowing vines; readable only with Myria
  LANGUAGE_ASHMARK = 2         # War runes etched in bloodstone
  LANGUAGE_THRENETIAN = 3      # Song-magic language — cast via instruments
  
  # Language Names
  LANGUAGE_NAMES = {
    LANGUAGE_OLD_VALEBRYNIC => "Old Valebrynic",
    LANGUAGE_FEYSCRIPT => "Feyscript",
    LANGUAGE_ASHMARK => "Ashmark",
    LANGUAGE_THRENETIAN => "Threnetian"
  }
  
  # Language Descriptions
  LANGUAGE_DESCRIPTIONS = {
    LANGUAGE_OLD_VALEBRYNIC => "The ancient noble tongue used in the courts of Valebryn before its fall. Found in ruins, old texts, and ceremonial items throughout the fallen kingdom.",
    LANGUAGE_FEYSCRIPT => "A mystical language that appears as glowing vines or patterns. It can only be read with the help of Myria, the orphan girl from Whisperbloom Village who may be the reincarnation of the Fey Queen.",
    LANGUAGE_ASHMARK => "War runes etched in bloodstone, used by the Order of the Shattered Flame. These harsh, angular symbols contain destructive power when properly activated.",
    LANGUAGE_THRENETIAN => "A song-magic language that can only be cast through musical instruments. Each phrase creates different magical effects when played correctly."
  }
  
  # Language Regions (primary locations)
  LANGUAGE_REGIONS = {
    LANGUAGE_OLD_VALEBRYNIC => WorldMapSystem::REGION_VALEBRYN,
    LANGUAGE_FEYSCRIPT => WorldMapSystem::REGION_SELDRINAR,
    LANGUAGE_ASHMARK => WorldMapSystem::REGION_NHARZHUL,
    LANGUAGE_THRENETIAN => WorldMapSystem::REGION_CINDRAL
  }
  
  # Language Proficiency Levels
  PROFICIENCY_NONE = 0      # Cannot understand at all
  PROFICIENCY_BASIC = 1     # Can understand simple phrases
  PROFICIENCY_INTERMEDIATE = 2  # Can understand most text
  PROFICIENCY_ADVANCED = 3  # Can understand complex text
  PROFICIENCY_FLUENT = 4    # Complete mastery
  
  # Requirements for reading/using each language
  LANGUAGE_REQUIREMENTS = {
    LANGUAGE_OLD_VALEBRYNIC => nil, # Can be learned by anyone
    LANGUAGE_FEYSCRIPT => {companion: CompanionSystem::COMPANION_MYRIA}, # Requires Myria in party
    LANGUAGE_ASHMARK => {item: 45}, # Requires Bloodstone Cipher (item ID 45)
    LANGUAGE_THRENETIAN => {item: 46, skill: 25} # Requires Resonant Flute (item ID 46) and Musical Aptitude skill (ID 25)
  }
  
  # Initialize language data
  def self.init_languages
    $game_system.language_data ||= {}
    
    # Only initialize if language data is empty
    return unless $game_system.language_data.empty?
    
    # Set initial language proficiencies (all none except Old Valebrynic at basic)
    $game_system.language_data[:proficiencies] = {
      LANGUAGE_OLD_VALEBRYNIC => PROFICIENCY_BASIC,
      LANGUAGE_FEYSCRIPT => PROFICIENCY_NONE,
      LANGUAGE_ASHMARK => PROFICIENCY_NONE,
      LANGUAGE_THRENETIAN => PROFICIENCY_NONE
    }
    
    # Initialize discovered texts in each language
    $game_system.language_data[:discovered_texts] = {
      LANGUAGE_OLD_VALEBRYNIC => [],
      LANGUAGE_FEYSCRIPT => [],
      LANGUAGE_ASHMARK => [],
      LANGUAGE_THRENETIAN => []
    }
    
    # Initialize translated texts
    $game_system.language_data[:translated_texts] = []
  end
  
  # Discover a new text in a language
  def self.discover_text(language_id, text_id, content)
    $game_system.language_data[:discovered_texts][language_id] ||= []
    
    # Check if this text has already been discovered
    unless $game_system.language_data[:discovered_texts][language_id].any? { |t| t[:id] == text_id }
      # Add the new text
      $game_system.language_data[:discovered_texts][language_id] << {
        id: text_id,
        content: content,
        discovered_on: CalendarSystem.elapsed_days,
        translated: false
      }
      
      # Show discovery message
      language_name = LANGUAGE_NAMES[language_id]
      $game_message.add("Discovered new text in #{language_name}!")
      
      # Play discovery sound
      Sound.play_system_sound(1) # Assuming sound ID 1 is appropriate
      
      # If player has sufficient proficiency, automatically translate
      if can_translate?(language_id)
        translate_text(language_id, text_id)
      end
      
      return true
    end
    return false
  end
  
  # Translate a discovered text
  def self.translate_text(language_id, text_id)
    # Find the text
    text = nil
    $game_system.language_data[:discovered_texts][language_id].each do |t|
      if t[:id] == text_id
        text = t
        break
      end
    end
    
    return false unless text && !text[:translated]
    
    # Check if player can translate this language
    return false unless can_translate?(language_id)
    
    # Mark as translated
    text[:translated] = true
    $game_system.language_data[:translated_texts] << {
      language_id: language_id,
      text_id: text_id,
      content: text[:content],
      translated_on: CalendarSystem.elapsed_days
    }
    
    # Show translation message
    language_name = LANGUAGE_NAMES[language_id]
    $game_message.add("Translated text from #{language_name}!")
    $game_message.add(text[:content])
    
    # Play translation sound
    Sound.play_system_sound(2) # Assuming sound ID 2 is appropriate
    
    # Increase proficiency if not already fluent
    increase_proficiency(language_id)
    
    # Check if this translation unlocks any lore
    check_lore_unlocks(language_id, text_id)
    
    return true
  end
  
  # Check if player can translate a language
  def self.can_translate?(language_id)
    # Check proficiency level
    proficiency = get_proficiency(language_id)
    return true if proficiency >= PROFICIENCY_BASIC
    
    # Check special requirements
    requirements = LANGUAGE_REQUIREMENTS[language_id]
    return true unless requirements # No special requirements
    
    # Check companion requirement
    if requirements[:companion] && defined?(CompanionSystem)
      return false unless CompanionSystem.active_party_member?(requirements[:companion])
    end
    
    # Check item requirement
    if requirements[:item]
      return false unless $game_party.has_item?($data_items[requirements[:item]])
    end
    
    # Check skill requirement
    if requirements[:skill]
      return false unless $game_party.members.any? { |actor| actor.skill_learn?($data_skills[requirements[:skill]]) }
    end
    
    return true
  end
  
  # Increase proficiency in a language
  def self.increase_proficiency(language_id, amount = 1)
    current = $game_system.language_data[:proficiencies][language_id] || PROFICIENCY_NONE
    new_level = [current + amount, PROFICIENCY_FLUENT].min
    
    if new_level > current
      $game_system.language_data[:proficiencies][language_id] = new_level
      language_name = LANGUAGE_NAMES[language_id]
      $game_message.add("Your proficiency in #{language_name} has increased!")
      return true
    end
    return false
  end
  
  # Get current proficiency in a language
  def self.get_proficiency(language_id)
    $game_system.language_data[:proficiencies][language_id] || PROFICIENCY_NONE
  end
  
  # Get proficiency name
  def self.proficiency_name(level)
    case level
    when PROFICIENCY_NONE
      "None"
    when PROFICIENCY_BASIC
      "Basic"
    when PROFICIENCY_INTERMEDIATE
      "Intermediate"
    when PROFICIENCY_ADVANCED
      "Advanced"
    when PROFICIENCY_FLUENT
      "Fluent"
    else
      "Unknown"
    end
  end
  
  # Check if a text has been discovered
  def self.text_discovered?(language_id, text_id)
    $game_system.language_data[:discovered_texts][language_id].any? { |t| t[:id] == text_id }
  end
  
  # Check if a text has been translated
  def self.text_translated?(language_id, text_id)
    $game_system.language_data[:discovered_texts][language_id].any? { |t| t[:id] == text_id && t[:translated] }
  end
  
  # Get all discovered texts in a language
  def self.discovered_texts(language_id)
    $game_system.language_data[:discovered_texts][language_id] || []
  end
  
  # Get all translated texts
  def self.translated_texts
    $game_system.language_data[:translated_texts] || []
  end
  
  # Get language name
  def self.language_name(language_id)
    LANGUAGE_NAMES[language_id] || "Unknown Language"
  end
  
  # Get language description
  def self.language_description(language_id)
    LANGUAGE_DESCRIPTIONS[language_id] || "No information available."
  end
  
  # Check if translating a text unlocks any lore
  def self.check_lore_unlocks(language_id, text_id)
    # This would be implemented based on your lore system
    # For example, certain translations might unlock specific lore entries
    
    # Example implementation:
    if defined?(LoreJournal)
      case language_id
      when LANGUAGE_OLD_VALEBRYNIC
        if text_id == 1
          LoreJournal.discover_lore(301) # The Fall of Valebryn lore
        end
      when LANGUAGE_FEYSCRIPT
        if text_id == 5
          LoreJournal.discover_lore(103) # Hollow Root Kin lore
        end
      when LANGUAGE_ASHMARK
        if text_id == 3
          LoreJournal.discover_lore(102) # Order of the Shattered Flame lore
        end
      when LANGUAGE_THRENETIAN
        if text_id == 7
          LoreJournal.discover_lore(401) # Some historical lore
        end
      end
    end
  end
end

# Initialize languages when a new game starts
class << DataManager
  alias language_system_setup_new_game setup_new_game
  def setup_new_game
    language_system_setup_new_game
    LanguageSystem.init_languages
  end
end

#==============================================================================
# ** Window_Languages
#------------------------------------------------------------------------------
# This window displays the player's language proficiencies.
#==============================================================================
class Window_Languages < Window_Selectable
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
    @data = []
    LanguageSystem::LANGUAGE_NAMES.each do |id, name|
      @data << id
    end
  end
  
  def draw_item(index)
    language_id = @data[index]
    return unless language_id
    rect = item_rect(index)
    
    language_name = LanguageSystem.language_name(language_id)
    proficiency = LanguageSystem.get_proficiency(language_id)
    proficiency_name = LanguageSystem.proficiency_name(proficiency)
    
    # Draw language name
    draw_text(rect.x, rect.y, rect.width / 2, rect.height, language_name)
    
    # Draw proficiency
    case proficiency
    when LanguageSystem::PROFICIENCY_NONE
      change_color(normal_color)
    when LanguageSystem::PROFICIENCY_BASIC
      change_color(text_color(3)) # Usually green
    when LanguageSystem::PROFICIENCY_INTERMEDIATE
      change_color(text_color(2)) # Usually blue
    when LanguageSystem::PROFICIENCY_ADVANCED
      change_color(text_color(1)) # Usually red
    when LanguageSystem::PROFICIENCY_FLUENT
      change_color(text_color(6)) # Usually yellow
    end
    
    draw_text(rect.x + rect.width / 2, rect.y, rect.width / 2, rect.height, proficiency_name, 2)
    change_color(normal_color)
  end
end

#==============================================================================
# ** Window_LanguageDetail
#------------------------------------------------------------------------------
# This window displays details about a selected language.
#==============================================================================
class Window_LanguageDetail < Window_Base
  def initialize(x, y, width, height)
    super
    @language_id = nil
    refresh
  end
  
  def set_language(language_id)
    @language_id = language_id
    refresh
  end
  
  def refresh
    contents.clear
    return unless @language_id
    
    language_name = LanguageSystem.language_name(@language_id)
    description = LanguageSystem.language_description(@language_id)
    proficiency = LanguageSystem.get_proficiency(@language_id)
    proficiency_name = LanguageSystem.proficiency_name(proficiency)
    
    # Draw language name
    contents.font.size = 24
    draw_text(0, 0, contents.width, 32, language_name, 1)
    contents.font.size = Font.default_size
    
    # Draw proficiency
    draw_text(0, 32, contents.width / 2, 24, "Proficiency:")
    case proficiency
    when LanguageSystem::PROFICIENCY_NONE
      change_color(normal_color)
    when LanguageSystem::PROFICIENCY_BASIC
      change_color(text_color(3)) # Usually green
    when LanguageSystem::PROFICIENCY_INTERMEDIATE
      change_color(text_color(2)) # Usually blue
    when LanguageSystem::PROFICIENCY_ADVANCED
      change_color(text_color(1)) # Usually red
    when LanguageSystem::PROFICIENCY_FLUENT
      change_color(text_color(6)) # Usually yellow
    end
    draw_text(contents.width / 2, 32, contents.width / 2, 24, proficiency_name, 2)
    change_color(normal_color)
    
    # Draw language description
    draw_text_ex(4, 64, description)
    
    # Draw discovered texts count
    discovered = LanguageSystem.discovered_texts(@language_id).size
    translated = LanguageSystem.discovered_texts(@language_id).count { |t| t[:translated] }
    
    y_pos = 140
    draw_text(0, y_pos, contents.width, 24, "Discovered Texts: #{discovered}")
    draw_text(0, y_pos + 24, contents.width, 24, "Translated Texts: #{translated}")
    
    # Draw special requirements if any
    requirements = LanguageSystem::LANGUAGE_REQUIREMENTS[@language_id]
    if requirements
      y_pos += 48
      draw_text(0, y_pos, contents.width, 24, "Special Requirements:", 1)
      y_pos += 24
      
      if requirements[:companion] && defined?(CompanionSystem)
        companion_name = CompanionSystem.companion_name(requirements[:companion])
        draw_text(4, y_pos, contents.width - 8, 24, "- Requires #{companion_name} in party")
        y_pos += 24
      end
      
      if requirements[:item]
        item_name = $data_items[requirements[:item]].name
        draw_text(4, y_pos, contents.width - 8, 24, "- Requires #{item_name}")
        y_pos += 24
      end
      
      if requirements[:skill]
        skill_name = $data_skills[requirements[:skill]].name
        draw_text(4, y_pos, contents.width - 8, 24, "- Requires #{skill_name} skill")
        y_pos += 24
      end
    end
  end
end

#==============================================================================
# ** Scene_Languages
#------------------------------------------------------------------------------
# This scene displays the player's language proficiencies and discovered texts.
#==============================================================================
class Scene_Languages < Scene_MenuBase
  def start
    super
    create_help_window
    create_language_list_window
    create_language_detail_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("Languages of Nyxoria")
  end
  
  def create_language_list_window
    y = @help_window.height
    width = Graphics.width / 3
    height = Graphics.height - y
    @language_list_window = Window_Languages.new(0, y, width, height)
    @language_list_window.set_handler(:ok, method(:on_language_ok))
    @language_list_window.set_handler(:cancel, method(:return_scene))
    @language_list_window.activate
  end
  
  def create_language_detail_window
    y = @help_window.height
    width = Graphics.width * 2 / 3
    height = Graphics.height - y
    @language_detail_window = Window_LanguageDetail.new(Graphics.width / 3, y, width, height)
    update_language_detail
  end
  
  def on_language_ok
    # Could implement a submenu for viewing discovered texts
    @language_list_window.activate
  end
  
  def update
    super
    update_language_detail if @language_list_window.active
  end
  
  def update_language_detail
    @language_detail_window.set_language(@language_list_window.item)
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias language_system_add_original_commands add_original_commands
  def add_original_commands
    language_system_add_original_commands
    add_command("Languages", :languages)
  end
end

class Scene_Menu < Scene_MenuBase
  alias language_system_create_command_window create_command_window
  def create_command_window
    language_system_create_command_window
    @command_window.set_handler(:languages, method(:command_languages))
  end
  
  def command_languages
    SceneManager.call(Scene_Languages)
  end
end