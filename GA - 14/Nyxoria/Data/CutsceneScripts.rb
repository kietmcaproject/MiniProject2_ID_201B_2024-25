#==============================================================================
# ** Cutscene Scripts
#------------------------------------------------------------------------------
# This script contains all the cutscene and event scripts for Nyxoria, including
# regional vision events, companion cutscenes, and boss encounters.
#==============================================================================

module CutsceneScripts
  # Version information
  VERSION = "1.0.0"
  
  #==============================================================================
  # ** Regional Vision Event Scripts
  #==============================================================================
  
  # Regional Vision: "The Iron Blossom of Mydran"
  # Trigger: Interact with a rusted statue in the Mydran Ruins after acquiring the "Windswept Pendant"
  def self.execute_mydran_vision
    # This method would be called from a common event
    
    # Store current screen settings to restore later
    original_tone = $game_screen.tone.clone
    
    # Set up the vision atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Forgotten Tomb", 80, 100))
    
    # Tint screen to sepia
    $game_screen.start_tone_change(Tone.new(30, 10, -20, 0), 60)
    $game_screen.wait(60)
    
    # Show animation: Flash of Light
    $game_player.animation_id = 101 # Flash animation ID
    $game_player.wait(40)
    
    # Change tileset to Vision Realm (would be handled in the common event)
    # This is just a placeholder for the script logic
    
    # Display text messages
    message_and_wait("Ancient Voice", "Steel was never meant to bloom... but in blood and silence, it did.")
    message_and_wait("Prince", "This voice... it knows my name.")
    
    # Reveal Mural on Wall (would be handled by showing a picture in the common event)
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
      
      # Update faction relationships based on this choice
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
  
  # Regional Vision: "The Whispering Depths of Seldrinar"
  def self.execute_seldrinar_vision
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
  # ** Companion Cutscene Scripts
  #==============================================================================
  
  # Companion Cutscene: Veyra's Judgment (Betrayal Path)
  # Trigger: Choose "Path of Flame" after reaching Trust Level 3+
  def self.execute_veyra_betrayal
    # Set up cutscene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Crimson Silence", 90, 100))
    
    # Ensure we're on the correct map (Throne of Embers)
    # This would normally be handled by the event that calls this method
    
    # Move Veyra forward (would be handled in the common event)
    # This is just a placeholder for the script logic
    
    # Display dialogue
    message_and_wait("Veyra", "You chose power... I chose you.")
    message_and_wait("Veyra", "But not like this.")
    
    # Fadeout and play slash sound
    $game_screen.start_fadeout(30)
    $game_system.se_play(RPG::SE.new("Slash1", 80, 100))
    $game_screen.wait(60)
    
    # Fade back in with Veyra wounded
    $game_screen.start_fadein(60)
    
    # Change Veyra's sprite to wounded pose (would be handled in the common event)
    # This is just a placeholder for the script logic
    
    # Final dialogue
    message_and_wait("Veyra", "Forgive me, Kael... I couldn't stop him...")
    
    # Update game state - Veyra leaves party permanently unless rare item is used in final battle
    $game_switches[130] = true # Veyra betrayal flag
    
    # Remove Veyra from party
    $game_party.remove_actor(7) # Assuming Veyra's actor ID is 7
    
    # Update faction relationships
    if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, -15)
    end
    
    # Restore original BGM
    $game_system.replay_bgm
  end
  
  # Companion Cutscene: Kairos's Revelation (Trust Path)
  def self.execute_kairos_trust
    # Set up cutscene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Arcane Secrets", 80, 100))
    
    # Tint screen slightly red
    $game_screen.start_tone_change(Tone.new(20, -10, -10, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Kairos", "I've watched you closely, observing your choices.")
    message_and_wait("Kairos", "Most who seek power as you do... they become consumed by it.")
    message_and_wait("Kairos", "But you... you bend it to your will. You control the flame rather than letting it control you.")
    
    # Show animation: Flame Circle
    $game_player.animation_id = 103 # Flame animation ID
    $game_player.wait(60)
    
    message_and_wait("Kairos", "The Shattered Flame taught me to embrace destruction... but you've shown me that destruction can be directed, focused.")
    message_and_wait("Kairos", "I want to share something with you. A technique I've perfected.")
    
    # Visual effect for power transfer
    $game_screen.start_flash(Color.new(200, 50, 0, 180), 120)
    $game_screen.wait(120)
    
    # Gain new ability
    $game_switches[122] = true # Focused Flame ability unlocked
    
    message_and_wait("Kairos", "Use it wisely. Remember, true power lies not in how much you can destroy, but in knowing exactly what to destroy.")
    
    # Update relationship
    if defined?(CompanionSystem)
      CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, 15)
    end
    
    # Update faction relationship
    if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 10)
    end
    
    # Restore screen tone
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 60)
    $game_screen.wait(60)
    
    # Restore original BGM
    $game_system.replay_bgm
  end
  
  #==============================================================================
  # ** Boss Encounter Scripts
  #==============================================================================
  
  # Boss Intro: "Echo of the Fallen King" (Final Dungeon)
  def self.execute_echo_king_intro
    # Set up the boss introduction
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Legacy Broken", 100, 100))
    
    # Show shadowy king picture
    $game_screen.pictures[1].show("Boss_EchoKing", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(30)
    
    # Tint screen deep red
    $game_screen.start_tone_change(Tone.new(40, -40, -40, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Echo King", "You carry my blood... and my sin.")
    message_and_wait("Echo King", "Let this be your coronation.")
    
    # Present choice to player
    result = $game_message.choice("Demand Truth", "Stay Silent")
    
    if result == 0 # Demand Truth
      # Player gains tactical advantage - stun for 2 turns
      $game_variables[60] = 2 # Stun duration
      
      message_and_wait("Echo King", "You... you would question me? Even now?")
      message_and_wait("Echo King", "The truth? The truth is that I FAILED! And now you bear the weight of my failure!")
      
      # Visual effect for Echo King being momentarily stunned
      $game_screen.start_flash(Color.new(255, 255, 255, 180), 60)
      $game_screen.wait(60)
      
      message_and_wait("System", "The Echo King is stunned by your demand for truth. He will be unable to act for 2 turns.")
    else # Stay Silent
      # Player gains attack buff
      $game_variables[61] = 30 # Attack % increase
      
      message_and_wait("Echo King", "Silence... just like before. The apple doesn't fall far from the tree.")
      message_and_wait("Echo King", "Your silence fuels your rage. Good. You'll need it.")
      
      # Visual effect for player powering up
      $game_player.animation_id = 104 # Power up animation ID
      $game_player.wait(60)
      
      message_and_wait("System", "Your focused rage increases your attack power by 30% for this battle.")
    end
    
    # Fade out picture before battle
    $game_screen.pictures[1].start_opacity_change(0, 60)
    $game_screen.wait(60)
    
    # Restore screen tone gradually during battle
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 120)
    
    # Battle will start after this script completes
  end
  
  # Boss Mid-Battle Event: "Crimson Commander Revelation"
  def self.execute_commander_mid_battle
    # This would be triggered when the Crimson Commander reaches 50% HP
    
    # Pause battle momentarily
    $game_message.background = 1 # Dim background
    
    # Display dialogue
    message_and_wait("Crimson Commander", "You fight well... too well. The blood of Valebryn flows strong in you.")
    message_and_wait("Crimson Commander", "Did you know? It was I who gave the order. I who commanded the fall of your kingdom.")
    
    # Present choice to player
    result = $game_message.choice("Why? Tell me why!", "Your words mean nothing!")
    
    if result == 0 # Ask why
      message_and_wait("Crimson Commander", "Your father discovered our true purpose. The Accord was never about order...")
      message_and_wait("Crimson Commander", "It was about preparing for the return of the Abyss. Some sacrifices were necessary.")
      
      # Update lore journal with this revelation
      if defined?(LoreJournal)
        LoreJournal.discover_lore(190) # Crimson Accord secret purpose lore
      end
      
      # This choice affects later story options
      $game_switches[140] = true # Learned Accord secret
    else # Reject explanation
      message_and_wait("Crimson Commander", "Then die in ignorance, like your father before you!")
      
      # Commander gets attack boost from player's anger
      $game_variables[62] = 20 # Enemy attack boost %
      
      # Visual effect for Commander powering up
      $game_screen.start_flash(Color.new(255, 0, 0, 180), 60)
      $game_screen.wait(60)
    end
    
    # Resume battle
    $game_message.background = 0 # Normal background
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
    when "Veyra"
      $game_message.face_name = "Actor1"
      $game_message.face_index = 1
    when "Kairos"
      $game_message.face_name = "Actor2"
      $game_message.face_index = 0
    when "Echo King"
      $game_message.face_name = "Evil"
      $game_message.face_index = 0
    when "Crimson Commander"
      $game_message.face_name = "Evil"
      $game_message.face_index = 1
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

# Register cutscene scripts with the Region Content System
module RegionContentSystem
  class << self
    # Link common events to cutscene scripts
    def execute_cutscene(event_id)
      case event_id
      # Regional Vision Events
      when 60 # The King's Pact vision
        CutsceneScripts.execute_mydran_vision
      when 64 # The Fey Court vision
        CutsceneScripts.execute_seldrinar_vision
        
      # Companion Cutscenes
      when 71 # Veyra's betrayal
        CutsceneScripts.execute_veyra_betrayal
      when 78 # Kairos's trust scene
        CutsceneScripts.execute_kairos_trust
        
      # Boss Encounters
      when 90 # Echo King intro
        CutsceneScripts.execute_echo_king_intro
      when 95 # Crimson Commander mid-battle
        CutsceneScripts.execute_commander_mid_battle
      end
    end

    # Original common event reservation method
    def reserve_common_event(common_event_id)
      # Check if this is one of our cutscene events
      cutscene_ids = [60, 64, 71, 78, 90, 95] # IDs of cutscene common events
      
      if cutscene_ids.include?(common_event_id)
        execute_cutscene(common_event_id)
      else
        # Call the game system's default common event handler
        $game_system.reserve_common_event(common_event_id)
      end
    end
  end
end