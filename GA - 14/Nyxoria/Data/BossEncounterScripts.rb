#==============================================================================
# ** Boss Encounter Scripts
#------------------------------------------------------------------------------
# This script implements detailed boss encounters for Nyxoria, including setup
# cutscenes, dialogue (pre-fight, mid-fight, death), and choice integration.
#==============================================================================

module BossEncounterScripts
  # Version information
  VERSION = "1.0.0"
  
  #==============================================================================
  # ** Pre-Battle Cutscenes
  #==============================================================================
  
  # Boss Intro: "Echo of the Fallen King" (Final Dungeon)
  def self.echo_king_intro
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
  
  # Boss Intro: "The Crimson Commander" (Karrgorn Fortress)
  def self.crimson_commander_intro
    # Set up the boss introduction
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Iron and Blood", 100, 100))
    
    # Show commander picture
    $game_screen.pictures[1].show("Boss_CrimsonCommander", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(30)
    
    # Tint screen to military red
    $game_screen.start_tone_change(Tone.new(20, -20, -20, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Crimson Commander", "The last heir of Valebryn. I've been waiting for this day.")
    message_and_wait("Crimson Commander", "Your father was weak. He couldn't make the hard choices necessary for survival.")
    
    # Present choice to player
    result = $game_message.choice("My father was a just king", "What hard choices?")
    
    if result == 0 # Defend father
      message_and_wait("Prince", "My father was a just king who cared for his people. Something you wouldn't understand.")
      message_and_wait("Crimson Commander", "Justice? In the face of the Abyss? Such naivety will be your downfall.")
      
      # Commander gets confidence boost
      $game_variables[62] = 10 # Commander defense boost %
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 5)
      end
    else # Ask about choices
      message_and_wait("Prince", "What hard choices? What was my father unwilling to do?")
      message_and_wait("Crimson Commander", "He discovered our preparations for the Abyss's return. The sacrifices we've made.")
      message_and_wait("Crimson Commander", "He threatened to expose us, to stop us. We couldn't allow that.")
      
      # Player gets insight bonus
      $game_variables[63] = 15 # Player accuracy boost %
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(230) # Accord's Dark Secret lore ID
      end
    end
    
    # Final pre-battle dialogue
    message_and_wait("Crimson Commander", "Enough talk. Draw your weapon, heir of Valebryn. Let us settle this with steel.")
    
    # Fade out picture before battle
    $game_screen.pictures[1].start_opacity_change(0, 60)
    $game_screen.wait(60)
    
    # Restore screen tone gradually during battle
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 120)
    
    # Battle will start after this script completes
  end
  
  # Boss Intro: "The Hollow Queen" (Seldrinar Depths)
  def self.hollow_queen_intro
    # Set up the boss introduction
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Corrupted Nature", 90, 100))
    
    # Show queen picture
    $game_screen.pictures[1].show("Boss_HollowQueen", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(30)
    
    # Tint screen to corrupted green
    $game_screen.start_tone_change(Tone.new(-20, 30, -30, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Hollow Queen", "Child of the betrayer king... you dare enter my domain?")
    message_and_wait("Hollow Queen", "Your ancestor promised protection, then abandoned us to the darkness.")
    
    # Show animation: Roots emerging
    $game_player.animation_id = 109 # Root animation ID
    $game_player.wait(60)
    
    message_and_wait("Hollow Queen", "Now your blood will feed the roots, and the cycle will be complete.")
    
    # Present choice to player
    result = $game_message.choice("I am not my ancestor", "The past cannot be changed")
    
    if result == 0 # Not my ancestor
      message_and_wait("Prince", "I am not my ancestor. I seek to heal the wounds of the past, not perpetuate them.")
      message_and_wait("Hollow Queen", "Words... empty words. Show me with actions if you truly mean to break the cycle.")
      
      # Queen slightly hesitates
      $game_variables[64] = 1 # Queen hesitation turns
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 5)
      end
    else # Past cannot change
      message_and_wait("Prince", "The past cannot be changed, but the future is still unwritten. Let us end this conflict.")
      message_and_wait("Hollow Queen", "The future was written in blood long ago. Your blood, royal child.")
      
      # Player gets defensive bonus
      $game_variables[65] = 15 # Player defense boost %
      
      # Update companion relationships
      if defined?(CompanionSystem) && CompanionSystem.companion_active?(CompanionSystem::COMPANION_THORNE)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, 5)
      end
    end
    
    # Final pre-battle dialogue
    message_and_wait("Hollow Queen", "Come then. Let us see if royal blood still has power in these corrupted woods.")
    
    # Fade out picture before battle
    $game_screen.pictures[1].start_opacity_change(0, 60)
    $game_screen.wait(60)
    
    # Restore screen tone gradually during battle
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 120)
    
    # Battle will start after this script completes
  end
  
  #==============================================================================
  # ** Mid-Battle Events
  #==============================================================================
  
  # Mid-Battle Event: "Crimson Commander Revelation"
  def self.crimson_commander_mid_battle
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
  
  # Mid-Battle Event: "Hollow Queen Transformation"
  def self.hollow_queen_transformation
    # This would be triggered when the Hollow Queen reaches 30% HP
    
    # Pause battle momentarily
    $game_message.background = 1 # Dim background
    
    # Display dialogue
    message_and_wait("Hollow Queen", "Enough! If I cannot have justice, I will have vengeance!")
    
    # Visual effect for transformation
    $game_screen.start_shake(power: 5, speed: 5, duration: 60)
    $game_screen.start_flash(Color.new(0, 255, 0, 180), 60)
    $game_screen.wait(60)
    
    message_and_wait("Hollow Queen", "Behold my true form! The corruption you ancestors unleashed, made flesh!")
    
    # Present choice to player
    result = $game_message.choice("Appeal to her former self", "Prepare for the worst")
    
    if result == 0 # Appeal to former self
      message_and_wait("Prince", "Remember who you were! A protector of the Glade, not its destroyer!")
      
      # Check if Thorne is in the party for special dialogue
      if defined?(CompanionSystem) && CompanionSystem.companion_active?(CompanionSystem::COMPANION_THORNE)
        message_and_wait("Thorne", "My Queen! Listen to him! The corruption speaks through you, not your heart!")
        
        # Queen hesitates due to Thorne's presence
        $game_variables[66] = 2 # Queen vulnerability turns
        
        message_and_wait("Hollow Queen", "Thorne? You... you still live? How...")
        message_and_wait("System", "The Hollow Queen is vulnerable for 2 turns due to Thorne's presence!")
      else
        # Queen partially affected by appeal
        $game_variables[66] = 1 # Queen vulnerability turns
        
        message_and_wait("Hollow Queen", "I... I remember. But it changes nothing. The corruption is too deep.")
        message_and_wait("System", "The Hollow Queen is vulnerable for 1 turn!")
      end
    else # Prepare for worst
      message_and_wait("Prince", "Do your worst. I've faced corruption before, and I'll defeat it again.")
      
      # Player gets attack boost from determination
      $game_variables[67] = 25 # Player attack boost %
      
      message_and_wait("Hollow Queen", "Such bravado! Let's see if it survives when the roots pierce your heart!")
      message_and_wait("System", "Your determination increases your attack power by 25%!")
    end
    
    # Resume battle
    $game_message.background = 0 # Normal background
  end
  
  #==============================================================================
  # ** Post-Battle Events
  #==============================================================================
  
  # Post-Battle: "Echo King's Revelation"
  def self.echo_king_defeat
    # Set up post-battle scene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Ancestral Truth", 80, 100))
    
    # Tint screen to ethereal blue
    $game_screen.start_tone_change(Tone.new(-20, -20, 30, 0), 60)
    $game_screen.wait(60)
    
    # Show fading Echo King
    $game_screen.pictures[1].show("Boss_EchoKingDefeated", 0, 400, 300, 100, 100, 200, 0)
    $game_screen.wait(30)
    
    # Display dialogue
    message_and_wait("Echo King", "So... you have surpassed me. Perhaps there is hope after all.")
    message_and_wait("Prince", "Tell me the truth. What happened? What did you do?")
    
    message_and_wait("Echo King", "I tried to control the Abyss. To use its power to protect our kingdom.")
    message_and_wait("Echo King", "But it cannot be controlled. It uses you, consumes you, until nothing remains but an echo.")
    
    # Present choice to player
    result = $game_message.choice("How do I stop it?", "Why did you make the pact?")
    
    if result == 0 # How to stop it
      message_and_wait("Echo King", "You cannot stop it. You can only contain it, delay it. The Abyss is eternal.")
      message_and_wait("Echo King", "But there is a way to seal it again. Seek the three Sigil Shards. Together, they can renew the ancient barriers.")
      
      # Update quest information
      $game_switches[180] = true # Sigil Shard quest available
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(240) # Sigil Shards lore ID
      end
    else # Why make the pact
      message_and_wait("Echo King", "For power. For protection. The neighboring kingdoms threatened us, and we were weak.")
      message_and_wait("Echo King", "The dying god offered strength in exchange for blood. A bargain that seemed fair... until the price became clear.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(241) # Royal Pact Origin lore ID
      end
    end
    
    # Final words
    message_and_wait("Echo King", "The blood of Valebryn carries both blessing and curse. Use it wisely, my child.")
    message_and_wait("Echo King", "Remember... the true enemy is not the factions that divide Nyxoria... but what lurks beneath...")
    
    # Echo King fades away
    $game_screen.pictures[1].start_opacity_change(0, 120)
    $game_screen.wait(120)
    
    # Restore screen settings
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 60)
    $game_screen.wait(60)
    
    # Restore original BGM
    $game_system.replay_bgm
  end
  
  # Post-Battle: "Crimson Commander's Choice"
  def self.crimson_commander_defeat
    # Set up post-battle scene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Fallen Leader", 75, 100))
    
    # Show wounded Commander
    $game_screen.pictures[1].show("Boss_CommanderDefeated", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(30)
    
    # Display dialogue
    message_and_wait("Crimson Commander", "Finish it... heir of Valebryn. Prove you have what it takes to rule.")
    
    # Present choice to player
    result = $game_message.choice("Execute him", "Spare him", "Imprison him")
    
    if result == 0 # Execute
      message_and_wait("Prince", "For Valebryn. For my father. For all those who died by your order.")
      
      # Execution animation
      $game_screen.start_fadeout(30)
      $game_system.se_play(RPG::SE.new("Slash2", 80, 100))
      $game_screen.wait(60)
      $game_screen.start_fadein(60)
      
      message_and_wait("Crimson Commander", "Well done... you are... truly your father's son...")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -20)
        FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 10)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, -15)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, 10)
      end
      
      # Set story flag
      $game_switches[181] = true # Commander executed
    elsif result == 1 # Spare
      message_and_wait("Prince", "No. I will not become what I hate. Your life is spared, but you will answer for your crimes.")
      message_and_wait("Crimson Commander", "Mercy... just like your father. Let's hope it doesn't lead you to the same fate.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 15)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, 5)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, 10)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, -10)
      end
      
      # Set story flag
      $game_switches[182] = true # Commander spared
    else # Imprison
      message_and_wait("Prince", "You will face justice for your crimes. Not by my hand, but by the judgment of the people.")
      message_and_wait("Crimson Commander", "The people... they don't understand what's coming. They need strong leadership, not justice.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 10)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -5)
      end
      
      # Update companion relationships
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, 5)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, 5)
      end
      
      # Set story flag
      $game_switches[183] = true # Commander imprisoned
    end
    
    # Fade out scene
    $game_screen.pictures[1].start_opacity_change(0, 60)
    $game_screen.wait(60)
    
    # Restore original BGM
    $game_system.replay_bgm
  end
  
  # Post-Battle: "Hollow Queen's Purification"
  def self.hollow_queen_defeat
    # Set up post-battle scene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Nature's Redemption", 80, 100))
    
    # Show defeated Queen
    $game_screen.pictures[1].show("Boss_QueenDefeated", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(30)
    
    # Display dialogue
    message_and_wait("Hollow Queen", "The cycle... it continues. Violence begets violence.")
    message_and_wait("Prince", "It doesn't have to be this way. The cycle can be broken.")
    
    # Present choice to player
    result = $game_message.choice("Purify with royal blood", "Offer mercy and healing", "Let nature reclaim her")
    
    if result == 0 # Purify with blood
      message_and_wait("Prince", "My ancestor's blood caused this corruption. Perhaps my blood can heal it.")
      
      # Blood sacrifice animation
      $game_screen.start_flash(Color.new(255, 0, 0, 180), 60)
      $game_system.se_play(RPG::SE.new("Slash1", 80, 100))
      $game_screen.wait(60)
      
      message_and_wait("Hollow Queen", "Your sacrifice... I can feel the corruption receding...")
      
      # Transformation animation
      $game_screen.start_flash(Color.new(255, 255, 255, 180), 120)
      $game_screen.wait(120)
      
      # Show purified Queen
      $game_screen.pictures[1].show("Boss_QueenPurified", 0, 400, 300, 100, 100, 255, 0)
      $game_screen.wait(30)
      
      message_and_wait("Purified Queen", "You have paid the blood debt. The Glade will remember this sacrifice.")
      
      # Player loses max HP permanently
      $game_variables[68] = 20 # % max HP reduction
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 20)
      end
      
      # Set story flag
      $game_switches[184] = true # Queen purified with blood
    elsif result == 1 # Offer mercy
      message_and_wait("Prince", "I offer healing, not destruction. Let us work together to cleanse the corruption.")
      
      # Check if player has the Heart Bloom item
      if $game_party.has_item?($data_items[175]) # Heart Bloom item
        message_and_wait("Prince", "This Heart Bloom... I was told it could cleanse corruption. Take it.")
        
        # Use the item
        $game_party.lose_item($data_items[175], 1)
        
        # Healing animation
        $game_screen.start_flash(Color.new(0, 255, 0, 180), 120)
        $game_screen.wait(120)
        
        # Show partially healed Queen
        $game_screen.pictures[1].show("Boss_QueenHealed", 0, 400, 300, 100, 100, 255, 0)
        $game_screen.wait(30)
        
        message_and_wait("Healing Queen", "The Heart Bloom... its power is ancient. The corruption recedes, but is not gone.")
        message_and_wait("Healing Queen", "I will retreat to the deepest grove to continue my healing. The Glade will remember your mercy.")
        
        # Update faction relationships
        if defined?(FactionSystem)
          FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 15)
          FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 5)
        end
        
        # Set story flag
        $game_switches[185] = true # Queen healed with Heart Bloom
      else
        message_and_wait("Hollow Queen", "Mercy? Without means? Words alone cannot heal what centuries of corruption have wrought.")
        message_and_wait("Hollow Queen", "I will retreat... to recover. But the corruption remains. Remember that, heir of Valebryn.")
        
        # Update faction relationships
        if defined?(FactionSystem)
          FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 5)
        end
        
        # Set story flag
        $game_switches[186] = true # Queen retreated, still corrupted
      end
    else # Let nature reclaim
      message_and_wait("Prince", "Your time has passed. Return to the earth and let new growth take your place.")
      
      message_and_wait("Hollow Queen", "Yes... perhaps that is best. The cycle of nature demands renewal through death.")
      
      # Reclamation animation
      $game_screen.start_flash(Color.new(0, 100, 0, 180), 60)
      $game_screen.wait(60)
      
      # Queen fades as roots grow
      $game_screen.pictures[1].start_opacity_change(0, 120)
      $game_screen.wait(120)
      
      message_and_wait("Voice from the Earth", "The Queen returns to us. A new guardian will rise when the time is right.")
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 10)
        FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, 5)
      end
      
      # Set story flag
      $game_switches[187] = true # Queen returned to nature
    end
    
    # Restore original BGM
    $game_system.replay_bgm
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
    when "Echo King"
      $game_message.face_name = "Evil"
      $game_message.face_index = 0
    when "Crimson Commander"
      $game_message.face_name = "Evil"
      $game_message.face_index = 1
    when "Hollow Queen", "Purified Queen", "Healing Queen"
      $game_message.face_name = "Evil"
      $