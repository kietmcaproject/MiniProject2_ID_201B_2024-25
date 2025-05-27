#==============================================================================
# ** Companion Cutscenes
#------------------------------------------------------------------------------
# This script implements detailed companion cutscenes for Nyxoria, including
# trust scenes, betrayal triggers, and personal visions/flashbacks.
#==============================================================================

module CompanionCutscenes
  # Version information
  VERSION = "1.0.0"
  
  #==============================================================================
  # ** Trust Scene Cutscenes
  #==============================================================================
  
  # Trust Scene: "Valen's Oath" (Dawnsworn representative)
  # Trigger: Relationship level reaches 80+ with Valen
  def self.valen_trust_scene
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up cutscene atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Honor Bound", 85, 100))
    
    # Tint screen to dawn light
    $game_screen.start_tone_change(Tone.new(20, 10, 0, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Valen", "My prince... no, my friend. There's something I need to say.")
    message_and_wait("Prince", "What is it, Valen?")
    
    # Show Valen kneeling (picture)
    $game_screen.pictures[3].show("Cutscene_ValenKneel", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    message_and_wait("Valen", "I failed Valebryn once. I was not there when the kingdom fell. I will not fail again.")
    message_and_wait("Valen", "I pledge my sword, my shield, and my life to you and to the restoration of our homeland.")
    
    # Present choice to player
    result = $game_message.choice("Accept his oath formally", "Raise him as an equal")
    
    if result == 0 # Accept formally
      message_and_wait("Prince", "I accept your oath, Valen of the Dawnsworn. May your blade strike true against our enemies.")
      message_and_wait("Valen", "Thank you, my liege. I will not disappoint you.")
      
      # Valen gives formal gift
      message_and_wait("Valen", "Please accept this royal insignia. It belonged to your father's royal guard. I've kept it safe all these years.")
      
      # Gain item
      $game_party.gain_item($data_items[160], 1) # Royal Guard Insignia
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, 10)
      end
    else # Raise as equal
      message_and_wait("Prince", "Rise, Valen. We are not prince and guard anymore. We are companions on this journey.")
      message_and_wait("Valen", "I... thank you. Your father would be proud of the leader you've become.")
      
      # Valen gives personal gift
      message_and_wait("Valen", "I want you to have this. It's a technique passed down through my family for generations.")
      
      # Learn skill
      actor_id = 1 # Player character
      $game_actors[actor_id].learn_skill(30) # Dawn's Shield technique
      
      # Update companion relationship
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, 15)
      end
    end
    
    # Fade out cutscene
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
  end
  
  # Trust Scene: "Lyra's Confession" (Crimson Accord representative)
  # Trigger: Relationship level reaches 80+ with Lyra
  def self.lyra_trust_scene
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up cutscene atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Moonlit Confession", 75, 100))
    
    # Tint screen to night blue
    $game_screen.start_tone_change(Tone.new(-20, -20, 10, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Lyra", "I need to tell you something. Something I've never told anyone.")
    message_and_wait("Prince", "I'm listening.")
    
    # Show Lyra by campfire (picture)
    $game_screen.pictures[3].show("Cutscene_LyraCampfire", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    message_and_wait("Lyra", "I joined the Crimson Accord because I believed in their mission of order. But over time, I saw the corruption within.")
    message_and_wait("Lyra", "The Commander... he knows about the Abyss. He's been preparing for its return, but his methods...")
    message_and_wait("Lyra", "I think he ordered the fall of Valebryn because your father discovered something. Something about the Accord's true purpose.")
    
    # Present choice to player
    result = $game_message.choice("Ask about the Accord's purpose", "Ask about her loyalty now")
    
    if result == 0 # Ask about purpose
      message_and_wait("Lyra", "They believe the Abyss can be controlled, harnessed. They've been collecting artifacts, experimenting with its power.")
      message_and_wait("Lyra", "I've seen what happens to those who get too close to that darkness. It consumes them.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(210) # Crimson Accord Secret Purpose lore ID
      end
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -10)
      end
    else # Ask about loyalty
      message_and_wait("Lyra", "My loyalty is to you now. You've shown me that there's a better way forward than blind obedience or ruthless control.")
      message_and_wait("Lyra", "The Accord will mark me as a traitor for this, but I don't care anymore. Some things are worth the risk.")
      
      # Update companion relationship
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_LYRA, 15)
      end
    end
    
    # Lyra gives gift
    message_and_wait("Lyra", "Take this. It's an officer's key to the Accord's archives. It might help us understand what they're planning.")
    
    # Gain item
    $game_party.gain_item($data_items[161], 1) # Accord Officer's Key
    
    # Fade out cutscene
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
  end
  
  # Trust Scene: "Kairos's Control" (Shattered Flame representative)
  # Trigger: Relationship level reaches 80+ with Kairos
  def self.kairos_trust_scene
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up cutscene atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Arcane Secrets", 80, 100))
    
    # Tint screen to fiery orange
    $game_screen.start_tone_change(Tone.new(30, 0, -20, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Kairos", "I've watched you closely, observing your choices.")
    message_and_wait("Kairos", "Most who seek power as you do... they become consumed by it.")
    
    # Show Kairos with flame magic (picture)
    $game_screen.pictures[3].show("Cutscene_KairosFlame", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    message_and_wait("Kairos", "But you... you bend it to your will. You control the flame rather than letting it control you.")
    
    # Show animation: Flame Circle
    $game_player.animation_id = 103 # Flame animation ID
    $game_player.wait(60)
    
    message_and_wait("Kairos", "The Shattered Flame taught me to embrace destruction... but you've shown me that destruction can be directed, focused.")
    message_and_wait("Kairos", "I want to share something with you. A technique I've perfected.")
    
    # Present choice to player
    result = $game_message.choice("Accept his knowledge", "Question his motives")
    
    if result == 0 # Accept knowledge
      # Visual effect for power transfer
      $game_screen.start_flash(Color.new(200, 50, 0, 180), 120)
      $game_screen.wait(120)
      
      message_and_wait("Kairos", "Feel the flame within you. Not wild and chaotic, but precise. A scalpel rather than a wildfire.")
      
      # Gain new ability
      $game_switches[122] = true # Focused Flame ability unlocked
      actor_id = 1 # Player character
      $game_actors[actor_id].learn_skill(32) # Focused Flame technique
      
      # Update companion relationship
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_KAIROS, 15)
      end
    else # Question motives
      message_and_wait("Prince", "Why share this with me? What do you really want, Kairos?")
      message_and_wait("Kairos", "Perceptive. I want what you want - to understand the Abyss. To master it rather than fear it.")
      message_and_wait("Kairos", "The Shattered Flame seeks to unleash it. The Accord seeks to contain it. Both are wrong.")
      message_and_wait("Kairos", "It must be understood. And you, with your bloodline, might be the key.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(211) # Kairos's True Purpose lore ID
      end
      
      # Still gain the ability, but with a different context
      $game_switches[122] = true # Focused Flame ability unlocked
      actor_id = 1 # Player character
      $game_actors[actor_id].learn_skill(32) # Focused Flame technique
    end
    
    message_and_wait("Kairos", "Use it wisely. Remember, true power lies not in how much you can destroy, but in knowing exactly what to destroy.")
    
    # Fade out cutscene
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
  end
  
  # Trust Scene: "Thorne's Remembrance" (Hollow Root representative)
  # Trigger: Relationship level reaches 80+ with Thorne
  def self.thorne_trust_scene
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up cutscene atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Nature's Lament", 80, 100))
    
    # Tint screen to forest green
    $game_screen.start_tone_change(Tone.new(-10, 20, -10, 0), 60)
    $game_screen.wait(60)
    
    # Display dialogue
    message_and_wait("Thorne", "There was a time when I remembered what it meant to be whole. Before the corruption took root in me.")
    
    # Show Thorne in a clearing (picture)
    $game_screen.pictures[3].show("Cutscene_ThorneClearing", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    message_and_wait("Thorne", "Your presence... it calms the whispers. Helps me remember who I was.")
    message_and_wait("Prince", "Who were you, Thorne?")
    message_and_wait("Thorne", "A guardian of the Seldrinar Glade. A protector of the balance between the fey and mortal realms.")
    message_and_wait("Thorne", "Until the day the corruption came. It spreads from the roots where ancient blood was spilled.")
    
    # Show animation: Nature's Embrace
    $game_player.animation_id = 102 # Nature animation ID
    $game_player.wait(40)
    
    # Present choice to player
    result = $game_message.choice("Ask about healing him", "Ask about the corruption's source")
    
    if result == 0 # Ask about healing
      message_and_wait("Thorne", "Perhaps... there may be a way. The Heart Bloom in the deepest part of Seldrinar.")
      message_and_wait("Thorne", "It blooms once every century. Its nectar might cleanse the corruption, but harvesting it would weaken the Glade's defenses.")
      
      # Update quest information
      $game_switches[160] = true # Heart Bloom quest available
      
      # Update companion relationship
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_THORNE, 15)
      end
    else # Ask about corruption source
      message_and_wait("Thorne", "The corruption began centuries ago, when mortals broke their pact with the fey.")
      message_and_wait("Thorne", "A king of Valebryn promised protection to the Glade in exchange for its magic. But when darkness came, he abandoned us.")
      message_and_wait("Thorne", "His blood was spilled on sacred ground. That blood - your ancestral blood - feeds the corruption.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(212) # Corruption Origin lore ID
      end
      
      # Update faction relationships
      if defined?(FactionSystem)
        FactionSystem.change_reputation(FactionSystem::FACTION_HOLLOW_ROOT, 10)
        FactionSystem.change_reputation(FactionSystem::FACTION_DAWNSWORN, -5)
      end
    end
    
    # Thorne gives gift
    message_and_wait("Thorne", "Take this seedling. It's connected to me, to the Glade. It will guide you when paths are hidden.")
    
    # Gain item
    $game_party.gain_item($data_items[162], 1) # Whispering Seedling
    
    # Fade out cutscene
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(original_tone, 60)
    $game_system.replay_bgm
  end
  
  #==============================================================================
  # ** Betrayal Cutscenes
  #==============================================================================
  
  # Betrayal Scene: "Veyra's Judgment" (Dawnsworn representative)
  # Trigger: Choose "Path of Flame" after reaching Trust Level 3+
  def self.veyra_betrayal_scene
    # Set up cutscene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Crimson Silence", 90, 100))
    
    # Ensure we're on the correct map (Throne of Embers)
    # This would normally be handled by the event that calls this method
    
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
  
  # Betrayal Scene: "Lyra's Return to Order" (Crimson Accord representative)
  # Trigger: Relationship falls below -50 with Lyra
  def self.lyra_betrayal_scene
    # Set up cutscene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Betrayal's March", 90, 100))
    
    # Display dialogue
    message_and_wait("Lyra", "I've watched you sow chaos across Nyxoria. This isn't what I signed up for.")
    message_and_wait("Prince", "Lyra, what are you saying?")
    message_and_wait("Lyra", "The Accord may be flawed, but at least they understand that order is necessary. You're just another agent of destruction.")
    
    # Show Lyra backing away (picture)
    $game_screen.pictures[3].show("Cutscene_LyraBetrayal", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    # Present choice to player
    result = $game_message.choice("Try to convince her to stay", "Let her go")
    
    if result == 0 # Try to convince
      message_and_wait("Prince", "Lyra, please. We can find a middle path. Not chaos, not rigid order. Something better.")
      message_and_wait("Lyra", "It's too late. I've already sent word to the Commander. They're coming for you.")
      message_and_wait("Lyra", "Run if you're smart. I'm done protecting you.")
      
      # Small chance to avoid combat
      $game_variables[70] = 20 # % chance to avoid Accord ambush
    else # Let her go
      message_and_wait("Prince", "Then go. Return to your precious Accord. Tell them I'm coming for them next.")
      message_and_wait("Lyra", "You've changed. The prince I first followed would never have spoken like that.")
      message_and_wait("Lyra", "Goodbye. When next we meet, it will be as enemies.")
      
      # Guaranteed Accord ambush
      $game_variables[70] = 0 # 0% chance to avoid Accord ambush
    end
    
    # Lyra leaves
    $game_screen.start_fadeout(60)
    $game_system.se_play(RPG::SE.new("Run", 80, 100))
    $game_screen.wait(60)
    $game_screen.start_fadein(60)
    
    # Update game state
    $game_switches[131] = true # Lyra betrayal flag
    
    # Remove Lyra from party
    $game_party.remove_actor(3) # Lyra's actor ID
    
    # Update faction relationships
    if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_CRIMSON_ACCORD, -20)
    end
    
    # Set up ambush encounter
    $game_switches[170] = true # Accord ambush pending
    
    # Restore original BGM
    $game_system.replay_bgm
  end
  
  # Betrayal Scene: "Kairos Unleashed" (Shattered Flame representative)
  # Trigger: Relationship falls below -50 with Kairos
  def self.kairos_betrayal_scene
    # Set up cutscene
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Chaotic Flames", 100, 100))
    
    # Tint screen to deep red
    $game_screen.start_tone_change(Tone.new(40, -20, -20, 0), 30)
    $game_screen.wait(30)
    
    # Display dialogue
    message_and_wait("Kairos", "I thought you understood. I thought you could see the beauty in destruction.")
    message_and_wait("Kairos", "But you're just like the others. Afraid to embrace true power.")
    
    # Show animation: Flame Eruption
    $game_player.animation_id = 108 # Flame Eruption animation ID
    $game_player.wait(60)
    
    # Show Kairos transforming (picture)
    $game_screen.pictures[3].show("Cutscene_KairosUnleashed", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.wait(60)
    
    message_and_wait("Kairos", "The Shattered Flame was right. The world must burn so something new can rise from the ashes.")
    message_and_wait("Kairos", "And I will be the one to light the pyre!")
    
    # Screen shake and flash
    $game_screen.start_shake(power: 8, speed: 8, duration: 60)
    $game_screen.start_flash(Color.new(255, 0, 0, 180), 60)
    $game_screen.wait(60)
    
    # Present choice to player
    result = $game_message.choice("Try to reason with him", "Prepare to fight")
    
    if result == 0 # Try to reason
      message_and_wait("Prince", "Kairos, stop! This isn't you. The flame is controlling you!")
      message_and_wait("Kairos", "No... for the first time, I am in control. I see clearly now.")
      message_and_wait("Kairos", "I'll spare you this once, for the journey we shared. But cross my path again, and I will not be so merciful.")
      
      # Kairos leaves without immediate combat
      $game_switches[171] = true # Kairos leaves peacefully
    else # Prepare to fight
      message_and_wait("Prince", "If you've chosen this path, then I'll stop you here and now.")
      message_and_wait("Kairos", "You can try. But the flame cannot be extinguished so easily.")
      
      # Immediate combat with Kairos
      $game_switches[172] = true # Kairos boss battle
    end
    
    # Update game state
    $game_switches[132] = true # Kairos betrayal flag
    
    # Remove Kairos from party
    $game_party.remove_actor(4) # Kairos's actor ID
    
    # Update faction relationships
    if defined?(FactionSystem)
      FactionSystem.change_reputation(FactionSystem::FACTION_SHATTERED_FLAME, -20)
    end
    
    # Fade out cutscene
    $game_screen.start_fadeout(60)
    $game_screen.wait(60)
    
    # Restore original settings
    $game_screen.start_fadein(60)
    $game_screen.start_tone_change(Tone.new(0, 0, 0, 0), 60)
    $game_system.replay_bgm
  end
  
  #==============================================================================
  # ** Personal Vision/Flashback Cutscenes
  #==============================================================================
  
  # Flashback: "Valen's Last Stand" (Dawnsworn representative)
  # Trigger: Camp with Valen after completing his personal quest
  def self.valen_flashback_scene
    # Store current screen settings
    original_tone = $game_screen.tone.clone
    
    # Set up flashback atmosphere
    $game_system.save_bgm
    $game_system.bgm_play(RPG::BGM.new("Fallen Kingdom", 85, 100))
    
    # Tint screen to memory blue
    $game_screen.start_tone_change(Tone.new(-20, -20, 20, 0), 60)
    $game_screen.wait(60)
    
    # Display text messages
    message_and_wait("Valen", "I still see it in my dreams. The night Valebryn fell.")
    
    # Show burning castle (picture)
    $game_screen.pictures[3].show("Flashback_BurningCastle", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(-20, -20, 20, 0), 1) # Match blue tone
    $game_screen.wait(60)
    
    message_and_wait("Valen", "I was stationed at the eastern outpost. By the time I returned, the castle was already burning.")
    message_and_wait("Valen", "I fought my way to the throne room, but I was too late. Your father...")
    
    # Show fallen king (picture change)
    $game_screen.pictures[3].show("Flashback_FallenKing", 0, 400, 300, 100, 100, 255, 0)
    $game_screen.pictures[3].start_tone_change(Tone.new(-20, -20, 20, 0), 1) # Match blue tone
    $game_screen.wait(60)
    
    message_and_wait("Valen", "With his dying breath, he told me to find you. To protect you. That you were the kingdom's last hope.")
    message_and_wait("Valen", "I've carried that burden ever since. The guilt of arriving too late.")
    
    # Present choice to player
    result = $game_message.choice("Absolve him of guilt", "Ask who led the attack")
    
    if result == 0 # Absolve of guilt
      message_and_wait("Prince", "You have nothing to feel guilty for, Valen. You've been loyal beyond measure.")
      message_and_wait("Prince", "My father would be proud of how you've protected me all these years.")
      message_and_wait("Valen", "Thank you, my friend. Those words mean more than you know.")
      
      # Update companion relationship
      if defined?(CompanionSystem)
        CompanionSystem.change_relationship(CompanionSystem::COMPANION_VALEN, 10)
      end
    else # Ask about attack
      message_and_wait("Prince", "Who led the attack? Did you see them?")
      message_and_wait("Valen", "Yes. It was Commander Drayven of the Crimson Accord. I saw him standing over your father.")
      message_and_wait("Valen", "But there was someone else too. A figure in a black cloak, whispering to him. I couldn't see their face.")
      
      # Update lore journal
      if defined?(LoreJournal)
        LoreJournal.discover_lore(220) # Valebryn Fall