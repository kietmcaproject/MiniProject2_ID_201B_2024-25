#==============================================================================
# ** Moral Choice System
#------------------------------------------------------------------------------
# This script implements a Moral Choice system for Nyxoria, tracking player
# decisions and their impact on the world, factions, and companions.
#==============================================================================

module MoralChoiceSystem
  # Choice Alignments
  ALIGNMENT_JUSTICE = 0
  ALIGNMENT_POWER = 1
  ALIGNMENT_MERCY = 2
  ALIGNMENT_VENGEANCE = 3
  ALIGNMENT_ORDER = 4
  ALIGNMENT_CHAOS = 5
  ALIGNMENT_PRESERVATION = 6
  ALIGNMENT_DESTRUCTION = 7
  
  # Alignment Names
  ALIGNMENT_NAMES = {
    ALIGNMENT_JUSTICE => "Justice",
    ALIGNMENT_POWER => "Power",
    ALIGNMENT_MERCY => "Mercy",
    ALIGNMENT_VENGEANCE => "Vengeance",
    ALIGNMENT_ORDER => "Order",
    ALIGNMENT_CHAOS => "Chaos",
    ALIGNMENT_PRESERVATION => "Preservation",
    ALIGNMENT_DESTRUCTION => "Destruction"
  }
  
  # Alignment Opposites
  ALIGNMENT_OPPOSITES = {
    ALIGNMENT_JUSTICE => ALIGNMENT_POWER,
    ALIGNMENT_POWER => ALIGNMENT_JUSTICE,
    ALIGNMENT_MERCY => ALIGNMENT_VENGEANCE,
    ALIGNMENT_VENGEANCE => ALIGNMENT_MERCY,
    ALIGNMENT_ORDER => ALIGNMENT_CHAOS,
    ALIGNMENT_CHAOS => ALIGNMENT_ORDER,
    ALIGNMENT_PRESERVATION => ALIGNMENT_DESTRUCTION,
    ALIGNMENT_DESTRUCTION => ALIGNMENT_PRESERVATION
  }
  
  # Faction Alignment Preferences
  FACTION_ALIGNMENTS = {
    FactionSystem::FACTION_CRIMSON_ACCORD => {
      preferred: [ALIGNMENT_ORDER, ALIGNMENT_POWER],
      disliked: [ALIGNMENT_CHAOS, ALIGNMENT_MERCY]
    },
    FactionSystem::FACTION_SHATTERED_FLAME => {
      preferred: [ALIGNMENT_DESTRUCTION, ALIGNMENT_CHAOS],
      disliked: [ALIGNMENT_PRESERVATION, ALIGNMENT_ORDER]
    },
    FactionSystem::FACTION_HOLLOW_ROOT => {
      preferred: [ALIGNMENT_CHAOS, ALIGNMENT_PRESERVATION],
      disliked: [ALIGNMENT_ORDER, ALIGNMENT_DESTRUCTION]
    },
    FactionSystem::FACTION_DAWNSWORN => {
      preferred: [ALIGNMENT_JUSTICE, ALIGNMENT_MERCY],
      disliked: [ALIGNMENT_POWER, ALIGNMENT_VENGEANCE]
    }
  }
  
  # Companion Alignment Preferences
  COMPANION_ALIGNMENTS = {
    CompanionSystem::COMPANION_VALEN => {
      preferred: [ALIGNMENT_JUSTICE, ALIGNMENT_MERCY],
      disliked: [ALIGNMENT_POWER, ALIGNMENT_VENGEANCE]
    },
    CompanionSystem::COMPANION_LYRA => {
      preferred: [ALIGNMENT_ORDER, ALIGNMENT_JUSTICE],
      disliked: [ALIGNMENT_CHAOS, ALIGNMENT_DESTRUCTION]
    },
    CompanionSystem::COMPANION_KAIROS => {
      preferred: [ALIGNMENT_DESTRUCTION, ALIGNMENT_POWER],
      disliked: [ALIGNMENT_PRESERVATION, ALIGNMENT_MERCY]
    },
    CompanionSystem::COMPANION_THORNE => {
      preferred: [ALIGNMENT_PRESERVATION, ALIGNMENT_CHAOS],
      disliked: [ALIGNMENT_DESTRUCTION, ALIGNMENT_ORDER]
    },
    CompanionSystem::COMPANION_ZEPHYR => {
      preferred: [ALIGNMENT_CHAOS, ALIGNMENT_PRESERVATION],
      disliked: [ALIGNMENT_ORDER, ALIGNMENT_DESTRUCTION]
    }
  }
  
  # Initialize moral choice data
  def self.init_moral_choices
    $game_system.moral_choices ||= {}
    
    # Only initialize if moral choice data is empty
    return unless $game_system.moral_choices.empty?
    
    # Set initial alignment values (all neutral)
    $game_system.moral_choices[:alignments] = {
      ALIGNMENT_JUSTICE => 0,
      ALIGNMENT_POWER => 0,
      ALIGNMENT_MERCY => 0,
      ALIGNMENT_VENGEANCE => 0,
      ALIGNMENT_ORDER => 0,
      ALIGNMENT_CHAOS => 0,
      ALIGNMENT_PRESERVATION => 0,
      ALIGNMENT_DESTRUCTION => 0
    }
    
    # Initialize choice history
    $game_system.moral_choices[:history] = []
    
    # Initialize ending flags
    $game_system.moral_choices[:endings] = {
      :justice_ending => false,
      :power_ending => false,
      :order_ending => false,
      :chaos_ending => false,
      :neutral_ending => true # Default ending
    }
  end
  
  # Record a moral choice
  def self.record_choice(choice_id, description, alignment)
    $game_system.moral_choices[:history] << {
      id: choice_id,
      description: description,
      alignment: alignment,
      timestamp: Graphics.frame_count
    }
    
    # Update alignment values
    update_alignment(alignment)
    
    # Update faction relationships
    update_factions(alignment)
    
    # Update companion relationships
    update_companions(alignment)
    
    # Check for ending unlocks
    check_ending_unlocks
    
    return true
  end
  
  # Update alignment values based on a choice
  def self.update_alignment(alignment, amount = 10)
    # Increase the chosen alignment
    $game_system.moral_choices[:alignments][alignment] += amount
    
    # Decrease the opposite alignment
    opposite = ALIGNMENT_OPPOSITES[alignment]
    $game_system.moral_choices[:alignments][opposite] -= amount / 2
    
    # Ensure values stay within bounds (-100 to 100)
    $game_system.moral_choices[:alignments].each do |align, value|
      $game_system.moral_choices[:alignments][align] = [[-100, value].max, 100].min
    end
  end
  
  # Update faction relationships based on alignment choice
  def self.update_factions(alignment)
    return unless defined?(FactionSystem)
    
    FACTION_ALIGNMENTS.each do |faction_id, preferences|
      # Increase reputation with factions that prefer this alignment
      if preferences[:preferred].include?(alignment)
        FactionSystem.change_reputation(faction_id, 3)
      end
      
      # Decrease reputation with factions that dislike this alignment
      if preferences[:disliked].include?(alignment)
        FactionSystem.change_reputation(faction_id, -3)
      end
    end
  end
  
  # Update companion relationships based on alignment choice
  def self.update_companions(alignment)
    return unless defined?(CompanionSystem)
    
    COMPANION_ALIGNMENTS.each do |companion_id, preferences|
      # Only affect recruited companions
      next unless CompanionSystem.recruited?(companion_id)
      
      # Increase relationship with companions that prefer this alignment
      if preferences[:preferred].include?(alignment)
        CompanionSystem.change_relationship(companion_id, 5)
      end
      
      # Decrease relationship with companions that dislike this alignment
      if preferences[:disliked].include?(alignment)
        CompanionSystem.change_relationship(companion_id, -5)
      end
    end
  end
  
  # Check for ending unlocks based on alignment values
  def self.check_ending_unlocks
    alignments = $game_system.moral_choices[:alignments]
    endings = $game_system.moral_choices[:endings]
    
    # Justice ending
    if alignments[ALIGNMENT_JUSTICE] >= 75 && alignments[ALIGNMENT_MERCY] >= 50
      endings[:justice_ending] = true
      endings[:neutral_ending] = false
    end
    
    # Power ending
    if alignments[ALIGNMENT_POWER] >= 75 && alignments[ALIGNMENT_VENGEANCE] >= 50
      endings[:power_ending] = true
      endings[:neutral_ending] = false
    end
    
    # Order ending
    if alignments[ALIGNMENT_ORDER] >= 75 && alignments[ALIGNMENT_PRESERVATION] >= 50
      endings[:order_ending] = true
      endings[:neutral_ending] = false
    end
    
    # Chaos ending
    if alignments[ALIGNMENT_CHAOS] >= 75 && alignments[ALIGNMENT_DESTRUCTION] >= 50
      endings[:chaos_ending] = true
      endings[:neutral_ending] = false
    end
  end
  
  # Get the player's dominant moral alignment
  def self.dominant_alignment
    alignments = $game_system.moral_choices[:alignments]
    highest = alignments.max_by { |k, v| v }
    
    # Only return if the value is significant
    highest[1] >= 30 ? highest[0] : nil
  end
  
  # Get the player's alignment value for a specific alignment
  def self.get_alignment_value(alignment)
    $game_system.moral_choices[:alignments][alignment] || 0
  end
  
  # Get the name of an alignment
  def self.alignment_name(alignment)
    ALIGNMENT_NAMES[alignment] || "Unknown"
  end
  
  # Get all choice history
  def self.choice_history
    $game_system.moral_choices[:history] || []
  end
  
  # Check if a specific ending is unlocked
  def self.ending_unlocked?(ending_key)
    $game_system.moral_choices[:endings][ending_key] || false
  end
  
  # Get all unlocked endings
  def self.unlocked_endings
    unlocked = []
    $game_system.moral_choices[:endings].each do |key, value|
      unlocked << key if value
    end
    return unlocked
  end
  
  # Get a description of the player's moral character
  def self.character_description
    alignments = $game_system.moral_choices[:alignments]
    
    justice = alignments[ALIGNMENT_JUSTICE]
    power = alignments[ALIGNMENT_POWER]
    mercy = alignments[ALIGNMENT_MERCY]
    vengeance = alignments[ALIGNMENT_VENGEANCE]
    order = alignments[ALIGNMENT_ORDER]
    chaos = alignments[ALIGNMENT_CHAOS]
    preservation = alignments[ALIGNMENT_PRESERVATION]
    destruction = alignments[ALIGNMENT_DESTRUCTION]
    
    if justice > 50 && mercy > 30
      return "A champion of justice and mercy, seeking to heal the wounds of Nyxoria."
    elsif power > 50 && vengeance > 30
      return "A ruler who wields power with vengeance, making enemies pay for their transgressions."
    elsif order > 50 && preservation > 30
      return "A guardian of order and preservation, maintaining the stability of the realm."
    elsif chaos > 50 && destruction > 30
      return "An agent of chaos and destruction, tearing down the old to make way for the new."
    elsif justice > 30 && power > 30
      return "Balanced between justice and power, pragmatic in approach to leadership."
    elsif mercy > 30 && vengeance > 30
      return "Conflicted between mercy and vengeance, showing compassion to some and wrath to others."
    elsif order > 30 && chaos > 30
      return "Walking the line between order and chaos, embracing both structure and freedom."
    elsif preservation > 30 && destruction > 30
      return "Selective in preservation and destruction, knowing when to save and when to sacrifice."
    else
      return "A balanced ruler, not defined by extremes but by measured judgment."
    end
  end
end

# Initialize moral choices when a new game starts
class << DataManager
  alias moral_choice_system_setup_new_game setup_new_game
  def setup_new_game
    moral_choice_system_setup_new_game
    MoralChoiceSystem.init_moral_choices
  end
end

#==============================================================================
# ** Window_MoralChoices
#------------------------------------------------------------------------------
# This window displays the player's moral alignment values.
#==============================================================================
class Window_MoralChoices < Window_Base
  def initialize(x, y, width, height)
    super
    refresh
  end
  
  def refresh
    contents.clear
    draw_alignments
    draw_character_description
  end
  
  def draw_alignments
    alignments = $game_system.moral_choices[:alignments]
    return unless alignments
    
    draw_text(0, 0, contents.width, line_height, "Moral Alignments", 1)
    
    y_pos = line_height * 2
    alignments.each do |alignment, value|
      name = MoralChoiceSystem.alignment_name(alignment)
      draw_alignment_bar(4, y_pos, contents.width - 8, line_height, name, value)
      y_pos += line_height + 4
    end
  end
  
  def draw_alignment_bar(x, y, width, height, name, value)
    # Draw name
    draw_text(x, y, width / 2, height, name)
    
    # Draw value
    draw_text(x + width / 2, y, width / 2, height, value.to_s, 2)
    
    # Draw bar background
    bar_y = y + height - 4
    bar_height = 4
    bar_width = width - 8
    contents.fill_rect(x + 4, bar_y, bar_width, bar_height, Color.new(100, 100, 100))
    
    # Draw bar fill
    if value != 0
      fill_width = [(value.abs * bar_width / 100.0).to_i, bar_width].min
      fill_x = value < 0 ? x + 4 + (bar_width / 2) - fill_width : x + 4 + (bar_width / 2)
      
      if value > 0
        contents.fill_rect(fill_x, bar_y, fill_width, bar_height, Color.new(0, 200, 0))
      else
        contents.fill_rect(fill_x, bar_y, fill_width, bar_height, Color.new(200, 0, 0))
      end
    end
    
    # Draw center marker
    center_x = x + 4 + (bar_width / 2)
    contents.fill_rect(center_x, bar_y - 1, 1, bar_height + 2, Color.new(255, 255, 255))
  end
  
  def draw_character_description
    description = MoralChoiceSystem.character_description
    y_pos = line_height * (2 + $game_system.moral_choices[:alignments].size) + 8
    
    draw_text(0, y_pos, contents.width, line_height, "Character Assessment", 1)
    draw_text_ex(4, y_pos + line_height * 2, description)
  end
end

#==============================================================================
# ** Scene_MoralChoices
#------------------------------------------------------------------------------
# This scene displays the player's moral alignment values.
#==============================================================================
class Scene_MoralChoices < Scene_MenuBase
  def start
    super
    create_help_window
    create_moral_choices_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("Moral Alignments")
  end
  
  def create_moral_choices_window
    y = @help_window.height
    width = Graphics.width
    height = Graphics.height - y
    @moral_choices_window = Window_MoralChoices.new(0, y, width, height)
  end
  
  def update
    super
    if Input.trigger?(:B)
      Sound.play_cancel
      return_scene
    end
  end
end

#==============================================================================
# ** Add to the menu
#==============================================================================
class Window_MenuCommand < Window_Command
  alias moral_choice_system_add_original_commands add_original_commands
  def add_original_commands
    moral_choice_system_add_original_commands
    add_command("Moral Alignments", :moral_alignments)
  end
end

class Scene_Menu < Scene_MenuBase
  alias moral_choice_system_create_command_window create_command_window
  def create_command_window
    moral_choice_system_create_command_window
    @command_window.set_handler(:moral_alignments, method(:command_moral_alignments))
  end
  
  def command_moral_alignments
    SceneManager.call(Scene_MoralChoices)
  end
end