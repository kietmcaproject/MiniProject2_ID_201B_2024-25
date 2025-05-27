#==============================================================================
# ** Region Content System
#------------------------------------------------------------------------------
# A simplified system for managing region-specific content in Nyxoria.
#==============================================================================

module RegionContentSystem
  VERSION = "1.1.0"

  def self.init_region_content
    # Initialize any required data structures
    $game_system.discovered_murals ||= []
    $game_system.experienced_visions ||= []
    puts "Region Content System initialized." if $TEST
  end

  def self.execute_cutscene(event_id)
    case event_id
    # Regional Vision Events
    when 60 # The King's Pact vision
      RegionalVisionEvents.valebryn_throne_vision
    when 64 # The Fey Court vision
      RegionalVisionEvents.mydran_statue_vision
    when 71 # Ancient vision
      RegionalVisionEvents.seldrinar_pool_vision
    end
  end
  
  #--------------------------------------------------------------------------
  # * Game_System Extension
  #--------------------------------------------------------------------------
  class Game_System
    attr_accessor :discovered_murals
    attr_accessor :experienced_visions
    
    alias region_content_initialize initialize
    def initialize
      region_content_initialize
      @discovered_murals = []
      @experienced_visions = []
    end
  end
  
  #--------------------------------------------------------------------------
  # * Game_Player Extension
  #--------------------------------------------------------------------------
  class Game_Player < Game_Character
    alias region_content_update update
    def update
      region_content_update
      check_region_content if $game_map && $game_system
    end
    
    def check_region_content
      region_id = $game_map.region_id(@x, @y)
      return if region_id == 0 || !region_id
      
      check_mural_discovery(region_id)
      check_vision_trigger(region_id)
    end
    
    private
    
    def check_mural_discovery(region_id)
      return unless $game_map && $game_system
      return if $game_system.discovered_murals.include?(region_id)
      
      if trigger_mural_event(region_id)
        $game_system.discovered_murals.push(region_id)
      end
    end
    
    def check_vision_trigger(region_id)
      return unless $game_map && $game_system
      return if $game_system.experienced_visions.include?(region_id)
      
      if trigger_vision_event(region_id)
        $game_system.experienced_visions.push(region_id)
      end
    end
    
    def trigger_mural_event(region_id)
      return false unless $game_map
      if region_id > 0 && $game_map.map_id > 0
        $game_temp.reserve_common_event(region_id)
        return true
      end
      false
    end
    
    def trigger_vision_event(region_id)
      return false unless $game_map
      if region_id > 0 && $game_switches[region_id]
        $game_temp.reserve_common_event(region_id)
        return true
      end
      false
    end
  end
end