#==============================================================================
# ** Regional Vision Events
#------------------------------------------------------------------------------
# This script implements detailed regional vision events for Nyxoria, providing
# rich backstory through scrolls, murals, and visions that are triggered by
# exploration, items, or lore discoveries.
#==============================================================================

module RegionalVisionEvents
  # Version information
  VERSION = "1.0.0"
  
  #==============================================================================
  # ** Valebryn Region Vision Events
  #==============================================================================
  
  # Vision: "The Crimson Throne"
  # Trigger: Interact with the broken throne in the ruins of Valebryn Palace
  def self.valebryn_throne_vision
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Royal Memories", 85, 100))
    
    # Tint screen to royal purple
    $game_screen.start_tone_change(Tone.new(20, -10, 30, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Memory Ripple
    $game_player.animation_id = 105 # Memory animation ID
    $game_player.wait(40)
    
    # Display text messages
    message_and_wait("Royal Voice", "The crown is a burden, not a privilege. Remember this, my child.")
    message_and_wait("Prince", "Father? Is that you?")
    
    # Show throne room in its glory (picture)
    $game_screen.pictures[3].show("Vision_ThroneRoom", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(20, -10, 30, 0), 1) # Match purple tone
    $game_screen.wait(60)
    
    # Display vision text
    message_and_wait("King Aldric", "The blood of Valebryn carries both power and curse. Our ancestors made a pact with dying gods.")
    message_and_wait("King Aldric", "They gained the ability to sense the Abyss, to feel its stirrings. But with it came the temptation to embrace it.")
    
    # Present choice to player
    result = $game_message.choice("Ask about the pact", "Ask about the Abyss")
    
    if result == 0 # Ask about the pact
      message_and_wait("King Aldric", "The pact was sealed with royal blood. Each ruler must renew it, binding their life force to the kingdom's protection.")
      message_and_wait("King Aldric", "I made my sacrifice. One day, you will face the same choice.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(200) # Royal Pact lore ID
      end
    else # Ask about the Abyss
      message_and_wait("King Aldric", "The Abyss is not just a place, but an entity. It hungers for our world, seeking vessels to manifest.")
      message_and_wait("King Aldric", "The royal bloodline was meant to sense its approach, to warn and protect. But some were seduced by its power.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(201) # The Abyss lore ID
      end
    end
    
    # Vision fades as attack begins
    $game_screen.start_shake(power: 5, speed: 5, duration: 60)
    $game_system.se_play(RPG::SE.new("Explosion1", 80, 100))
    
    message_and_wait("King Aldric", "They're here! The Crimson Accord has betrayed us! Take the sigil and flee, my child!")
    
    # Fade out vision
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
    
    # Update faction relationships based on this vision
    if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -5)
      FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 5)
    end
    
    # Unlock memory fragment item
    $game_party.gain_item($data_items[170], 1) # Royal Memory Fragment
  end
  
  #==============================================================================
  # ** Nhar'Zhul Region Vision Events
  #==============================================================================
  
  # Vision: "The Iron Blossom of Mydran"
  # Trigger: Interact with a rusted statue in the Mydran Ruins after acquiring the "Windswept Pendant"
  def self.mydran_statue_vision
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Forgotten Tomb", 80, 100))
    
    # Tint screen to sepia
    $game_screen.start_tone_change(Tone.new(30, 10, -20, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Flash of Light
    $game_player.animation_id = 101 # Flash animation ID
    $game_player.wait(40)
    
    # Display text messages
    message_and_wait("Ancient Voice", "Steel was never meant to bloom... but in blood and silence, it did.")
    message_and_wait("Prince", "This voice... it knows my name.")
    
    # Reveal Mural on Wall (picture)
    $game_screen.pictures[3].show("Mural_Engraving", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(30, 10, -20, 0), 1) # Match sepia tone
    $game_screen.wait(60)
    
    # Display mural text
    message_and_wait("Mural", "The First Pact: Silence for Salvation. A King's tongue, bound by fire.")
    
    # Present choice to player
    result = $game_message.choice("Touch the Sigil", "Step Back")
    
    if result == 0 # Touch the Sigil
      # Increase corruption and unlock Blood Technique
      $game_variables[50] += 10 # Corruption meter
      $game_switches[120] = true # Blood Technique unlocked
      
      # Visual effect for corruption increase
      $game_screen.start_flash(Color.new(120, 0, 0, 180), 60)
      $game_screen.wait(60)
      
      message_and_wait("Ancient Voice", "The blood remembers what the mind forgets...")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 5)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, -5)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, 5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, -5)
      end
    else # Step Back
      # Just gain lore knowledge
      message_and_wait("Ancient Voice", "Wisdom in restraint... but knowledge withheld is power denied.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 5)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, 5)
      end
    end
    
    # Fade out vision
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
    
    # Add to lore journal
    if defined?(LoreJournal)
      LoreJournal.discover_lore(180) # Mydran Vision lore ID
    end
  end
  
  #==============================================================================
  # ** Seldrinar Region Vision Events
  #==============================================================================
  
  # Vision: "The Whispering Depths"
  # Trigger: Drink from the Luminous Pool in Whisperbloom Village
  def self.seldrinar_pool_vision
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Fey Whispers", 80, 100))
    
    # Tint screen to ethereal green
    $game_screen.start_tone_change(Tone.new(-20, 30, -20, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Nature's Embrace
    $game_player.animation_id = 102 # Nature animation ID
    $game_player.wait(40)
    
    # Display text messages
    message_and_wait("Fey Voice", "The roots remember what was promised... what was taken...")
    message_and_wait("Prince", "These whispers... they're coming from the trees themselves.")
    
    # Show living mural (picture)
    $game_screen.pictures[3].show("Mural_LivingBloom", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(-20, 30, -20, 0), 1) # Match green tone
    $game_screen.wait(60)
    
    # Display mural text
    message_and_wait("Living Mural", "The Hollow Root grows where blood was spilled. The corruption feeds on broken oaths.")
    
    # Present choice to player
    result = $game_message.choice("Commune with the Spirits", "Shield Your Mind")
    
    if result == 0 # Commune with Spirits
      # Gain nature insight but risk corruption
      $game_variables[51] += 10 # Nature affinity
      $game_variables[50] += 5 # Slight corruption risk
      
      # Visual effect for nature communion
      $game_screen.start_flash(Color.new(0, 120, 0, 180), 60)
      $game_screen.wait(60)
      
      message_and_wait("Fey Voice", "Your blood carries echoes of the old promise... we will watch your path.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 10)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, 10)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, -5)
      end
      
      # Unlock Fey Sight ability
      $game_switches[121] = true # Fey Sight unlocked
    else # Shield Mind
      # Resist influence
      message_and_wait("Fey Voice", "The walls you build will not protect you when the roots come calling...")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, -5)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, 5)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, -5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, 5)
      end
    end
    
    # Fade out vision
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
    
    # Add to lore journal
    if defined?(LoreJournal)
      LoreJournal.discover_lore(181) # Seldrinar Vision lore ID
    end
  end
  
  #==============================================================================
  # ** Cindral Region Vision Events
  #==============================================================================
  
  # Vision: "Echoes in the Sand"
  # Trigger: Examine the ancient sundial in the Mirror Crater
  def self.cindral_sundial_vision
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Desert Memories", 75, 100))
    
    # Tint screen to golden yellow
    $game_screen.start_tone_change(Tone.new(30, 20, -30, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Time Distortion
    $game_player.animation_id = 106 # Time animation ID
    $game_player.wait(40)
    
    # Display text messages
    message_and_wait("Temporal Voice", "Time is not a river, but a circle. What was, will be. What will be, was.")
    message_and_wait("Prince", "The sand... it's flowing upward!")
    
    # Show ancient city (picture)
    $game_screen.pictures[3].show("Vision_AncientCindral", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(30, 20, -30, 0), 1) # Match golden tone
    $game_screen.wait(60)
    
    # Display vision text
    message_and_wait("Temporal Voice", "Behold Cindral, jewel of the desert, before the sands claimed it. Before the folly of its people.")
    
    # Show citizens using time magic (picture change)
    $game_screen.pictures[3].show("Vision_CindralMages", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(30, 20, -30, 0), 1) # Match golden tone
    $game_screen.wait(60)
    
    message_and_wait("Temporal Voice", "They sought to master time itself, to see beyond the veil of moments. Their hubris tore reality asunder.")
    
    # Present choice to player
    result = $game_message.choice("Ask about their knowledge", "Ask about their fate")
    
    if result == 0 # Ask about knowledge
      message_and_wait("Temporal Voice", "Their secrets lie buried in the Timeless Vault, deep beneath the Mirror Crater.")
      message_and_wait("Temporal Voice", "Seek the three chronoshards. Together, they will reveal the path.")
      
      # Update quest information
      $game_switches[150] = true # Chronoshard quest available
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(182) # Cindral Time Magic lore ID
      end
    else # Ask about fate
      message_and_wait("Temporal Voice", "They became unstuck from time. Neither living nor dead, they exist in all moments at once.")
      message_and_wait("Temporal Voice", "The desert is their prison and their sanctuary. The sands are their flesh.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(183) # Cindral Fate lore ID
      end
      
      # Unlock special enemy encounter
      $game_switches[151] = true # Time-lost enemies can appear
    end
    
    # Show final warning
    message_and_wait("Temporal Voice", "Beware. To walk the path of time is to risk becoming lost within it. Choose wisely.")
    
    # Fade out vision
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
    
    # Add to lore journal
    if defined?(LoreJournal)
      LoreJournal.discover_lore(184) # Cindral Sundial Vision lore ID
    end
  end
  
  #==============================================================================
  # ** Karrgorn Region Vision Events
  #==============================================================================
  
  # Vision: "The Mountain's Heart"
  # Trigger: Place the Crimson Medallion on the altar at Fort Bladewatch
  def self.karrgorn_altar_vision
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Mountain Echoes", 85, 100))
    
    # Tint screen to steel blue
    $game_screen.start_tone_change(Tone.new(-20, -10, 30, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Metal Resonance
    $game_player.animation_id = 107 # Metal animation ID
    $game_player.wait(40)
    
    # Display text messages
    message_and_wait("Commander's Voice", "Blood and iron. The twin pillars of the Accord. One cannot exist without the other.")
    message_and_wait("Prince", "The medallion... it's pulsing like a heartbeat.")
    
    # Show Crimson Accord formation (picture)
    $game_screen.pictures[3].show("Vision_AccordFormation", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(-20, -10, 30, 0), 1) # Match blue tone
    $game_screen.wait(60)
    
    # Display vision text
    message_and_wait("First Commander", "We forge this Accord in blood and bind it with iron. Order must prevail over chaos.")
    message_and_wait("First Commander", "The kingdoms squabble while darkness gathers. We will be the shield that protects them, even from themselves.")
    
    # Show signing of the Accord (picture change)
    $game_screen.pictures[3].show("Vision_AccordSigning", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(-20, -10, 30, 0), 1) # Match blue tone
    $game_screen.wait(60)
    
    # Present choice to player
    result = $game_message.choice("Ask about their methods", "Ask about their purpose")
    
    if result == 0 # Ask about methods
      message_and_wait("First Commander", "We do what must be done. The weak call it cruelty. The strong call it necessity.")
      message_and_wait("First Commander", "When the Abyss comes, there will be no room for hesitation or mercy.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, 5)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, -5)
      end
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(185) # Crimson Accord Methods lore ID
      end
    else # Ask about purpose
      message_and_wait("First Commander", "We exist to prepare. The Abyss stirs every thousand years. The last time, it nearly consumed everything.")
      message_and_wait("First Commander", "Your ancestors helped seal it away, but the seal weakens. We must be ready when it breaks.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, 5)
        FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, -5)
      end
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(186) # Crimson Accord Purpose lore ID
      end
    end
    
    # Show final warning
    message_and_wait("First Commander", "Judge us if you must, but remember: when the darkness comes, it will not care about your moral qualms.")
    
    # Fade out vision
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
    
    # Add to lore journal
    if defined?(LoreJournal)
      LoreJournal.discover_lore(187) # Karrgorn Altar Vision lore ID
    end
    
    # Unlock special dialogue options with Crimson Accord NPCs
    $game_switches[152] = true # Accord history knowledge
  end
  
  #==============================================================================
  # ** Helper Methods
  #==============================================================================
  
  # Display a message with speaker name and wait for player input
  def self.message_and_wait(speaker, text)
    $game_message.face_name = "" # No face graphic by default
    
    # Set appropriate face graphic based on speaker
    case speaker
    when "Prince", "Kael"
      $game_message.face_name = "Actor1"
      $game_message.face_index = 0
    when "King Aldric"
      $game_message.face_name = "Actor3"
      $game_message.face_index = 0
    when "First Commander"
      $game_message.face_name = "People4"
      $game_message.face_index = 7
    end
    
    # Display the message
    $game_message.add("\\c[4]#{speaker}:\\c[0] #{text}")
    
    # Wait for player input (handled by the message system)
  end
  
  # Choice helper that returns the index of the selected option
  def self.choice(*options)
    $game_message.choice_cancel_type = 0
    $game_message.choice_proc = Proc.new {|n| @choice_result = n }
    
    options.each do |option|
      $game_message.choices.push(option)
    end
    
    @choice_result = 0 # Default to first option
    Fiber.yield while $game_message.choice?  
    return @choice_result
  end
end

# Register regional vision events with the Region Content System
module RegionContentSystem
  # Link common events to regional vision events
  def self.execute_regional_vision(event_id)
    case event_id
    # Valebryn Region
    when 50 # The Crimson Throne vision
      RegionalVisionEvents.valebryn_throne_vision
      
    # Nhar'Zhul Region
    when 52 # The Iron Blossom of Mydran vision
      RegionalVisionEvents.mydran_statue_vision
      
    # Seldrinar Region
    when 54 # The Whispering Depths vision
      RegionalVisionEvents.seldrinar_pool_vision
      
    # Cindral Region
    when 56 # Echoes in the Sand vision
      RegionalVisionEvents.cindral_sundial_vision
      
    # Karrgorn Region
    when 58 # The Mountain's Heart vision
      RegionalVisionEvents.karrgorn_altar_vision
    end
  end
  
  # Extend the execute_cutscene method to include regional visions
  alias regional_visions_execute_cutscene execute_cutscene
  def self.execute_cutscene(event_id)
    # Check if this is one of our regional vision events
    regional_vision_ids = [50, 52, 54, 56, 58] # IDs of regional vision common events
    
    if regional_vision_ids.include?(event_id)
      execute_regional_vision(event_id)
    else
      regional_visions_execute_cutscene(event_id)
    end
  end
end