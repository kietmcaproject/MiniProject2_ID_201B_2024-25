#==============================================================================
# ** Calendar System
#------------------------------------------------------------------------------
# This script implements a Calendar system for Nyxoria, tracking the cycle of
# Shards and their effects on the game world, events, and mechanics.
#==============================================================================

module CalendarSystem
  # Month IDs
  MONTH_EMBER = 0     # Fire, destruction, courage
  MONTH_THORN = 1     # Nature, decay, trickery
  MONTH_TIDE = 2      # Water, memory, time
  MONTH_HOLLOW = 3    # Death, silence, sorrow
  MONTH_SKY = 4       # Wind, freedom, prophecy
  MONTH_PALE = 5      # Moon, illusions, reflection
  MONTH_FLAME = 6     # Chaos, rebirth, power
  
  # Month Names
  MONTH_NAMES = {
    MONTH_EMBER => "Ember",
    MONTH_THORN => "Thorn",
    MONTH_TIDE => "Tide",
    MONTH_HOLLOW => "Hollow",
    MONTH_SKY => "Sky",
    MONTH_PALE => "Pale",
    MONTH_FLAME => "Flame"
  }
  
  # Month Descriptions
  MONTH_DESCRIPTIONS = {
    MONTH_EMBER => "Month of fire, destruction, and courage. Combat abilities are enhanced, but healing is reduced.",
    MONTH_THORN => "Month of nature, decay, and trickery. Plant-based enemies are stronger, but more vulnerable to fire.",
    MONTH_TIDE => "Month of water, memory, and time. Water-based magic is enhanced, and certain memories become accessible.",
    MONTH_HOLLOW => "Month of death, silence, and sorrow. Undead enemies are more common, but drop better loot.",
    MONTH_SKY => "Month of wind, freedom, and prophecy. Movement speed increases, and prophetic dreams may occur.",
    MONTH_PALE => "Month of moon, illusions, and reflection. Illusion magic is stronger, and hidden paths may appear.",
    MONTH_FLAME => "Month of chaos, rebirth, and power. All magical effects are amplified, for better or worse."
  }
  
  # Month Themes (for gameplay effects)
  MONTH_THEMES = {
    MONTH_EMBER => [:fire, :destruction, :courage],
    MONTH_THORN => [:nature, :decay, :trickery],
    MONTH_TIDE => [:water, :memory, :time],
    MONTH_HOLLOW => [:death, :silence, :sorrow],
    MONTH_SKY => [:wind, :freedom, :prophecy],
    MONTH_PALE => [:moon, :illusion, :reflection],
    MONTH_FLAME => [:chaos, :rebirth, :power]
  }
  
  # Month Effects on Gameplay
  MONTH_EFFECTS = {
    MONTH_EMBER => {
      combat: {attack: 1.2, healing: 0.8},
      enemies: {fire: 1.5, ice: 0.7},
      events: [:volcano_active, :forge_discount]
    },
    MONTH_THORN => {
      combat: {poison: 1.3, nature_magic: 1.2},
      enemies: {plant: 1.4, undead: 0.9},
      events: [:bloom_festival, :forest_paths_open]
    },
    MONTH_TIDE => {
      combat: {water_magic: 1.3, lightning: 0.8},
      enemies: {aquatic: 1.4, fire: 0.7},
      events: [:memory_pools_active, :flood_plains_accessible]
    },
    MONTH_HOLLOW => {
      combat: {dark_magic: 1.3, holy: 0.8},
      enemies: {undead: 1.5, drop_rate: 1.3},
      events: [:spirit_communion, :crypt_access]
    },
    MONTH_SKY => {
      combat: {agility: 1.2, evasion: 1.2},
      enemies: {flying: 1.4, earth: 0.8},
      events: [:wind_bridges, :prophet_appears]
    },
    MONTH_PALE => {
      combat: {illusion_magic: 1.4, accuracy: 0.9},
      enemies: {spirit: 1.3, beast: 0.9},
      events: [:moon_market, :hidden_paths]
    },
    MONTH_FLAME => {
      combat: {all_magic: 1.3, all_physical: 1.1, critical: 1.2},
      enemies: {all: 1.2, boss: 1.3},
      events: [:chaos_rifts, :rebirth_shrines]
    }
  }
  
  # Days per month
  DAYS_PER_MONTH = 30
  
  # Special days in each month
  SPECIAL_DAYS = {
    MONTH_EMBER => {15 => "Ember Peak", 30 => "Ash Fall"},
    MONTH_THORN => {10 => "Bloom Day", 25 => "Withering"},
    MONTH_TIDE => {7 => "High Tide", 21 => "Memory Pool"},
    MONTH_HOLLOW => {13 => "Veil Thins", 26 => "Silent Hour"},
    MONTH_SKY => {5 => "Wind Dance", 19 => "Prophet's Voice"},
    MONTH_PALE => {1 => "New Moon", 14 => "Full Moon", 28 => "Blood Moon"},
    MONTH_FLAME => {3 => "Chaos Spark", 17 => "Rebirth Flame", 30 => "Year's End"}
  }
  
  # Initialize calendar data
  def self.init_calendar
    $game_system.calendar_data ||= {}
    
    # Only initialize if calendar data is empty
    return unless $game_system.calendar_data.empty?
    
    # Start at the first day of Ember (new year)
    $game_system.calendar_data[:current_month] = MONTH_EMBER
    $game_system.calendar_data[:current_day] = 1
    $game_system.calendar_data[:elapsed_days] = 0
    
    # Track special events that have occurred
    $game_system.calendar_data[:special_events] = []
    
    # Apply initial month effects
    apply_month_effects
  end
  
  # Advance the calendar by a specified number of days
  def self.advance_days(days = 1)
    days.times do
      advance_single_day
    end
    
    # Return the current date information
    return {
      month: current_month_name,
      day: current_day,
      special: current_special_day
    }
  end
  
  # Advance a single day
  def self.advance_single_day
    $game_system.calendar_data[:current_day] += 1
    $game_system.calendar_data[:elapsed_days] += 1
    
    # Check if we need to advance to the next month
    if $game_system.calendar_data[:current_day] > DAYS_PER_MONTH
      $game_system.calendar_data[:current_day] = 1
      $game_system.calendar_data[:current_month] = ($game_system.calendar_data[:current_month] + 1) % 7
      
      # Apply new month effects
      apply_month_effects
      
      # Announce month change
      month_name = current_month_name
      $game_message.add("The month has changed to #{month_name}.")
      $game_message.add(MONTH_DESCRIPTIONS[$game_system.calendar_data[:current_month]])
    end
    
    # Check for special days
    check_special_days
  end
  
  # Apply effects based on the current month
  def self.apply_month_effects
    current = $game_system.calendar_data[:current_month]
    effects = MONTH_EFFECTS[current]
    
    # Here you would apply the actual gameplay effects
    # This is a placeholder for where you'd implement the actual effects
    # For example, modifying damage formulas, enemy spawn rates, etc.
    
    # For demonstration, we'll just set some game variables
    $game_variables[100] = current # Store current month in variable 100
    $game_variables[101] = effects[:combat][:attack] * 100 if effects[:combat][:attack] # Attack modifier
    
    # Enable/disable appropriate events
    effects[:events].each do |event_symbol|
      case event_symbol
      when :volcano_active
        $game_switches[50] = true # Assuming switch 50 controls volcano activity
      when :forge_discount
        $game_variables[110] = 80 # 20% discount at forges (variable 110 = price percentage)
      # Add cases for other events as needed
      end
    end
  end
  
  # Check for special days and trigger events
  def self.check_special_days
    current_month = $game_system.calendar_data[:current_month]
    current_day = $game_system.calendar_data[:current_day]
    
    # Check if today is a special day
    if SPECIAL_DAYS[current_month] && SPECIAL_DAYS[current_month][current_day]
      special_day_name = SPECIAL_DAYS[current_month][current_day]
      event_key = "#{current_month}_#{current_day}"
      
      # Only trigger if we haven't already triggered this event
      unless $game_system.calendar_data[:special_events].include?(event_key)
        $game_system.calendar_data[:special_events] << event_key
        
        # Announce special day
        $game_message.add("Today is #{special_day_name}!")
        
        # Trigger special effects based on the day
        trigger_special_day_effects(current_month, current_day, special_day_name)
      end
    end
  end
  
  # Trigger effects for special days
  def self.trigger_special_day_effects(month, day, name)
    case name
    when "Ember Peak"
      # Increase fire damage by 50% for the day
      $game_variables[120] = 150 # Assuming variable 120 controls fire damage percentage
    when "Ash Fall"
      # Special enemies appear
      $game_switches[60] = true # Assuming switch 60 controls ash wraith spawns
    when "Full Moon"
      # Illusion magic boosted, werewolf enemies appear
      $game_variables[121] = 200 # Illusion magic boost
      $game_switches[61] = true # Werewolf spawns
    # Add cases for other special days
    end
  end
  
  # Get the current month ID
  def self.current_month
    $game_system.calendar_data[:current_month]
  end
  
  # Get the current month name
  def self.current_month_name
    MONTH_NAMES[$game_system.calendar_data[:current_month]]
  end
  
  # Get the current day
  def self.current_day
    $game_system.calendar_data[:current_day]
  end
  
  # Get the name of the current special day (if any)
  def self.current_special_day
    month = $game_system.calendar_data[:current_month]
    day = $game_system.calendar_data[:current_day]
    
    if SPECIAL_DAYS[month] && SPECIAL_DAYS[month][day]
      return SPECIAL_DAYS[month][day]
    else
      return nil
    end
  end
  
  # Get the total elapsed days
  def self.elapsed_days
    $game_system.calendar_data[:elapsed_days]
  end
  
  # Check if a specific month theme is active
  def self.month_theme_active?(theme)
    MONTH_THEMES[$game_system.calendar_data[:current_month]].include?(theme)
  end
  
  # Get all active month themes
  def self.active_themes
    MONTH_THEMES[$game_system.calendar_data[:current_month]]
  end
  
  # Get the current month's effect on a specific stat
  def self.get_effect_modifier(category, stat)
    month = $game_system.calendar_data[:current_month]
    effects = MONTH_EFFECTS[month]
    
    if effects[category] && effects[category][stat]
      return effects[category][stat]
    else
      return 1.0 # No modifier
    end
  end
  
  # Format the current date as a string
  def self.date_string
    "#{current_day} #{current_month_name}"
  end
  
  # Check if a specific event is active this month
  def self.event_active?(event_symbol)
    MONTH_EFFECTS[$game_system.calendar_data[:current_month]][:events].include?(event_symbol)
  end
end

# Initialize calendar when a new game starts
class << DataManager
  alias calendar_system_setup_new_game setup_new_game
  def setup_new_game
    calendar_system_setup_new_game
    CalendarSystem.init_calendar
  end
end

#==============================================================================
# ** Window_Calendar
#------------------------------------------------------------------------------
# This window displays the current calendar information.
#==============================================================================
class Window_Calendar < Window_Base
  def initialize(x, y, width, height)
    super
    refresh
  end
  
  def refresh
    contents.clear
    draw_calendar_info
  end
  
  def draw_calendar_info
    month_name = CalendarSystem.current_month_name
    day = CalendarSystem.current_day
    special_day = CalendarSystem.current_special_day
    
    # Draw month and day
    draw_text(0, 0, contents.width, line_height, "#{day} #{month_name}", 1)
    
    # Draw month description
    description = CalendarSystem::MONTH_DESCRIPTIONS[CalendarSystem.current_month]
    draw_text_ex(4, line_height * 2, description)
    
    # Draw special day if applicable
    if special_day
      change_color(text_color(6)) # Use color 6 (usually yellow) for special days
      draw_text(0, line_height * 5, contents.width, line_height, "Special: #{special_day}", 1)
      change_color(normal_color)
    end
    
    # Draw active effects
    draw_text(0, line_height * 7, contents.width, line_height, "Active Effects:", 0)
    
    y_pos = line_height * 8
    themes = CalendarSystem.active_themes
    themes.each do |theme|
      draw_text(4, y_pos, contents.width - 8, line_height, theme.to_s.capitalize)
      y_pos += line_height
    end
  end
end

#==============================================================================
# ** Scene_Calendar
#------------------------------------------------------------------------------
# This scene displays the calendar information.
#==============================================================================
class Scene_Calendar < Scene_MenuBase
  def start
    super
    create_help_window
    create_calendar_window
  end
  
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text("Calendar of Shards")
  end
  
  def create_calendar_window
    y = @help_window.height
    width = Graphics.width
    height = Graphics.height - y
    @calendar_window = Window_Calendar.new(0, y, width, height)
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
  alias calendar_system_add_original_commands add_original_commands
  def add_original_commands
    calendar_system_add_original_commands
    add_command("Calendar", :calendar)
  end
end

class Scene_Menu < Scene_MenuBase
  alias calendar_system_create_command_window create_command_window
  def create_command_window
    calendar_system_create_command_window
    @command_window.set_handler(:calendar, method(:command_calendar))
  end
  
  def command_calendar
    SceneManager.call(Scene_Calendar)
  end
end