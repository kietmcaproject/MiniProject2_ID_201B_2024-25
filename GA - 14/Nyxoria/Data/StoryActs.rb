# encoding: utf-8
#==============================================================================
# ** Story Acts System
#------------------------------------------------------------------------------
# This script implements Act 3 (Revelation) and Act 4 (Choice) storylines for
# Nyxoria, including new locations, quests, and major decision points.
#==============================================================================

module StoryActs
  # Act IDs
  ACT_1 = 0 # Introduction
  ACT_2 = 1 # Journey
  ACT_3 = 2 # Revelation
  ACT_4 = 3 # Choice
  
  # Act Names
  ACT_NAMES = {
    ACT_1 => "Awakening",
    ACT_2 => "Journey",
    ACT_3 => "Revelation - The Abyss Below",
    ACT_4 => "Choice - Crownless Kings"
  }
  
  # Act Themes
  ACT_THEMES = {
    ACT_1 => "Survival, identity, and loss",
    ACT_2 => "Discovery, allies, and growing power",
    ACT_3 => "Descent, truth, and temptation",
    ACT_4 => "Consequences, war, legacy"
  }
  
  # Act 3 Locations
  ACT_3_LOCATIONS = {
    "The Shattered Spine" => {
      description: "A ruined fortress leading underground, once a bastion of the royal guard. Now it serves as the entrance to the ancient catacombs beneath Echo Vale.",
      map_id: 30,
      region_id: WorldMapSystem::REGION_VALEBRYN,
      lore_id: 310
    },
    "Veins of Silence" => {
      description: "A labyrinth of ancient god-tech buried deep beneath the surface. Strange machinery and forgotten technology pulse with otherworldly energy.",
      map_id: 31,
      region_id: WorldMapSystem::REGION_VALEBRYN,
      lore_id: 311
    },
    "The Stained Sanctum" => {
      description: "A divine echo chamber where the voices of dead gods still resonate. The walls shift and change based on the observer's deepest fears.",
      map_id: 32,
      region_id: WorldMapSystem::REGION_VALEBRYN,
      lore_id: 312
    },
    "The Throne Beneath" => {
      description: "An abyssal reflection of the capital, where reality is distorted. This twisted mirror of Valebryn's royal palace reveals dark truths about the kingdom's fall.",
      map_id: 33,
      region_id: WorldMapSystem::REGION_VALEBRYN,
      lore_id: 313
    }
  }
  
  # Act 4 Locations
  ACT_4_LOCATIONS = {
    "Bastion of Judgment" => {
      description: "Your reclaimed capital city, rebuilt from the ruins of Valebryn. The architecture blends the old with the new, symbolizing the rebirth of the kingdom.",
      map_id: 40,
      region_id: WorldMapSystem::REGION_VALEBRYN,
      lore_id: 320
    },
    "The Gathering Grounds" => {
      description: "A neutral meeting place where representatives from all factions come together to determine the future of Nyxoria. Ancient magic prevents violence within its boundaries.",
      map_id: 41,
      region_id: WorldMapSystem::REGION_CINDRAL,
      lore_id: 321
    },
    "Temple of Mirrors" => {
      description: "The final divine arena where the ultimate choice must be made. The mirrors reflect not just the present, but possible futures based on your decisions.",
      map_id: 42,
      region_id: WorldMapSystem::REGION_CINDRAL,
      lore_id: 322
    }
  }
  
  # Act 3 Quests
  ACT_3_QUESTS = {
    "Descent of Shadows" => {
      id: 301,
      description: "Navigate the ruined catacombs beneath Echo Vale to find the entrance to the Veins of Silence.",
      objectives: [
        "Enter The Shattered Spine",
        "Survive the vision sequence with the masked agent",
        "Solve the broken memory mirror puzzle",
        "Discover the entrance to the Veins of Silence"
      ],
      rewards: {
        lore: [310, 311],
        items: [120] # Memory Shard item ID
      },
      switch_id: 50 # Game switch ID for quest completion
    },
    "The Pact Remembered" => {
      id: 302,
      description: "Experience a flashback to the king's pact with a dying god and find the Sigil Shard sealed within a divine altar.",
      objectives: [
        "Navigate the Veins of Silence",
        "Experience the possession flashback",
        "Reach the divine altar in the Stained Sanctum",
        "Retrieve the Sigil Shard",
        "Confront your sibling, the Abyss's Watcher"
      ],
      rewards: {
        lore: [312, 313, 314],
        items: [121] # Sigil Shard item ID
      },
      switch_id: 51 # Game switch ID for quest completion
    },
    "Shatter or Accept" => {
      id: 303,
      description: "Use the Sigil Shard to survive an ambush by corrupted guardians and make a crucial decision about your destiny.",
      objectives: [
        "Escape the Stained Sanctum",
        "Survive the ambush by corrupted guardians",
        "Make your choice: Fuse, Resist, or Share the Sigil Shard"
      ],
      rewards: {
        lore: [315],
        items: [] # Rewards depend on choice
      },
      switch_id: 52 # Game switch ID for quest completion
    }
  }
  
  # Companion Side Quests (Act 3)
  COMPANION_SIDE_QUESTS = {
    "Kael's Trial" => {
      id: 310,
      companion_id: CompanionSystem::COMPANION_VALEN, # Using Valen as Kael
      title: "The Burning Oath",
      description: "Enter Valen's homeland in ruin and face his traitorous brother who betrayed the royal guard.",
      map_id: 35,
      objectives: [
        "Travel to the ruins of Valen's homeland",
        "Find evidence of his brother's betrayal",
        "Confront his brother in the abandoned guard tower",
        "Choose whether to allow Valen to exact revenge or show mercy"
      ],
      rewards: {
        relationship: 20, # Relationship boost with Valen
        special_skill: 25 # ID of special skill unlocked
      },
      switch_id: 55 # Game switch ID for quest completion
    },
    "Veyra's Tears" => {
      id: 311,
      companion_id: CompanionSystem::COMPANION_THORNE, # Using Thorne as Veyra
      title: "Veil of the Fey",
      description: "Help Thorne heal the Whisper Tree spirit or burn it to free him from his curse.",
      map_id: 36,
      objectives: [
        "Travel to the heart of Seldrinar Glade",
        "Find the corrupted Whisper Tree",
        "Choose to heal the tree (preservation) or burn it (destruction)",
        "Deal with the consequences of your choice"
      ],
      rewards: {
        relationship: 20, # Relationship boost with Thorne
        special_skill: 26 # ID of special skill unlocked
      },
      switch_id: 56 # Game switch ID for quest completion
    },
    "Thorne's Memory" => {
      id: 312,
      companion_id: CompanionSystem::COMPANION_KAIROS, # Using Kairos as Thorne
      title: "Ash of Iron",
      description: "Help Kairos confront the machine that imprisoned his soul and decide his true nature.",
      map_id: 37,
      objectives: [
        "Travel to the ancient forge in Nhar'Zhul Wastes",
        "Find the soul-binding machine",
        "Help Kairos confront his past",
        "Choose whether to embrace or reject his machine nature"
      ],
      rewards: {
        relationship: 20, # Relationship boost with Kairos
        special_skill: 27 # ID of special skill unlocked
      },
      switch_id: 57 # Game switch ID for quest completion
    }
  }
  
  # Act 4 Quests
  ACT_4_QUESTS = {
    "Call the Banners" => {
      id: 401,
      description: "Choose which factions to ally with or suppress as you prepare for the final confrontation.",
      objectives: [
        "Meet with representatives from each faction",
        "Choose your allies: Ashen Guard, Feyborne Pact, or Sunken Fang",
        "Deal with the consequences of your choices"
      ],
      rewards: {
        lore: [320, 321],
        items: [130] # Banner of Unity item ID
      },
      switch_id: 60 # Game switch ID for quest completion
    },
    "Trial of the Crownless" => {
      id: 402,
      description: "Face the ghost of your father in a dream and decide whether to carry his legacy or forge your own path.",
      objectives: [
        "Enter the dream realm",
        "Confront your father's ghost",
        "Make your choice about his legacy"
      ],
      rewards: {
        lore: [322, 323],
        items: [131] # Crown Shard item ID
      },
      switch_id: 61 # Game switch ID for quest completion
    },
    "The Final Echo" => {
      id: 403,
      description: "Confront your sibling one last time before the final battle.",
      objectives: [
        "Meet your sibling at the Temple of Mirrors",
        "Fight or reconcile based on your previous choices",
        "Prepare for the final confrontation"
      ],
      rewards: {
        lore: [324],
        items: [132] # Echo Resonance item ID
      },
      switch_id: 62 # Game switch ID for quest completion
    },
    "The Divine Mirror" => {
      id: 404,
      description: "Face the final boss and make your ultimate choice that will determine the fate of Nyxoria.",
      objectives: [
        "Enter the heart of the Temple of Mirrors",
        "Confront the Divine Mirror",
        "Survive the three phases of the battle",
        "Make your final choice: Path of Flame, Path of Chains, or Path of Ash"
      ],
      rewards: {
        lore: [325, 326, 327],
        items: [] # Rewards depend on final choice
      },
      switch_id: 63 # Game switch ID for quest completion
    }
  }
  
  # Endings
  ENDING_FLAME = 1 # Path of Flame (Destruction)
  ENDING_CHAINS = 2 # Path of Chains (Justice)
  ENDING_ASH = 3 # Path of Ash (Peace)
  
  ENDINGS = {
    ENDING_FLAME => 1,
    ENDING_CHAINS => 2,
    ENDING_ASH => 3
  }
  
  # Ending Descriptions
  ENDING_DESCRIPTIONS = {
    ENDING_FLAME => "You chose the Path of Flame, embracing destruction to forge a new world from the ashes of the old. The capital burns as you ascend to godhood, your power unchallenged but your humanity sacrificed.",
    ENDING_CHAINS => "You chose the Path of Chains, establishing order and justice at any cost. Your rule is firm but fair, and though your empire prospers, it does so under the weight of your unyielding judgment.",
    ENDING_ASH => "You chose the Path of Ash, sacrificing yourself to bring peace to a broken world. Though you are gone, your legacy lives on in the stories told by those you saved, and in the healing of Nyxoria."
  }
  
  # Initialize story acts data
  def self.init_story_acts
    $game_system.story_acts_data ||= {}
    
    # Only initialize if story acts data is empty
    return unless $game_system.story_acts_data.empty?
    
    # Set initial act progress
    $game_system.story_acts_data[:current_act] = ACT_1
    $game_system.story_acts_data[:act_progress] = {
      ACT_1 => 0,
      ACT_2 => 0,
      ACT_3 => 0,
      ACT_4 => 0
    }
    
    # Initialize quest progress
    $game_system.story_acts_data[:quest_progress] = {}
    
    # Initialize choice history
    $game_system.story_acts_data[:act3_choices] = {
      sigil_choice: nil # nil, :fuse, :resist, or :share
    }
    
    $game_system.story_acts_data[:act4_choices] = {
      faction_allies: [], # Array of faction IDs
      legacy_choice: nil, # nil, :reject, :accept, or :transcend
      final_path: nil # nil, :flame, :chains, or :ash
    }
    
    # Initialize companion side quest status
    $game_system.story_acts_data[:companion_quests] = {
      CompanionSystem::COMPANION_VALEN => false,
      CompanionSystem::COMPANION_THORNE => false,
      CompanionSystem::COMPANION_KAIROS => false
    }
    
    # Add Act 3 and 4 lore to LoreJournal if available
    if defined?(LoreJournal)
      add_act_lore
    end
  end
  
  # Add Act 3 and 4 lore to the LoreJournal
  def self.add_act_lore
    # The Abyss
    LoreJournal.instance_eval do
      $game_system.lore_entries << {
        id: 310,
        category: CATEGORY_HISTORY,
        title: "The Abyss Below",
        description: "Beneath Nyxoria lies an ancient power known as the Abyss, a realm of pure potential and chaos. It is said that the royal bloodline of Valebryn made a pact with the Abyss during the first invasion, gaining power at a terrible cost. The Abyss is neither good nor evil, but a mirror that reflects and amplifies the desires of those who commune with it.",
        discovered: false,
        region_id: WorldMapSystem::REGION_VALEBRYN,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 311,
        category: CATEGORY_HISTORY,
        title: "The Veins of Silence",
        description: "A network of ancient tunnels beneath Echo Vale, filled with forgotten technology from a bygone era. The machinery pulses with otherworldly energy, responding to the blood of the royal line. These 'god-tech' artifacts were created by beings who walked Nyxoria long before humans, and their true purpose remains a mystery.",
        discovered: false,
        region_id: WorldMapSystem::REGION_VALEBRYN,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 312,
        category: CATEGORY_HISTORY,
        title: "The Stained Sanctum",
        description: "A divine echo chamber where the voices of dead gods still resonate. The walls shift and change based on the observer's deepest fears and desires. It is here that the king of Valebryn made his fateful pact with a dying god, binding his bloodline to the Abyss in exchange for power to protect his kingdom.",
        discovered: false,
        region_id: WorldMapSystem::REGION_VALEBRYN,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 313,
        category: CATEGORY_HISTORY,
        title: "The Throne Beneath",
        description: "An abyssal reflection of Valebryn's royal palace, where reality is distorted and truth revealed. This twisted mirror of the capital shows what the kingdom might have become had different choices been made. It is said that those who sit upon the Throne Beneath can see all possible futures, but at the cost of their sanity.",
        discovered: false,
        region_id: WorldMapSystem::REGION_VALEBRYN,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 314,
        category: CATEGORY_CHARACTERS,
        title: "The Abyss's Watcher",
        description: "Once the elder sibling of the Exiled Prince, now transformed into the Watcher of the Abyss. When Valebryn fell, they sacrificed themselves to the Abyss to ensure their younger sibling's escape. Now they exist between worlds, guiding and testing the prince on his journey to reclaim his birthright.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 315,
        category: CATEGORY_HISTORY,
        title: "The Sigil Shard",
        description: "A fragment of the original pact between the royal bloodline and the Abyss. The Sigil Shard contains immense power that responds to the bearer's intentions. It can be used to destroy, control, or heal, depending on the wielder's choice. The shard is both a key to unlocking the full potential of the royal bloodline and a test of the bearer's character.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      # Act 4 Lore
      $game_system.lore_entries << {
        id: 320,
        category: CATEGORY_HISTORY,
        title: "The Bastion of Judgment",
        description: "The reclaimed capital of Valebryn, rebuilt from ruins into a symbol of rebirth. The architecture blends the old with the new, honoring the kingdom's history while embracing its future. From here, the Exiled Prince must make decisions that will shape the fate of all Nyxoria.",
        discovered: false,
        region_id: WorldMapSystem::REGION_VALEBRYN,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 321,
        category: CATEGORY_HISTORY,
        title: "The Gathering Grounds",
        description: "A neutral meeting place in the Cindral Expanse where representatives from all factions come together to determine the future of Nyxoria. Ancient magic prevents violence within its boundaries, making it the perfect location for diplomatic negotiations. The decisions made here will echo throughout the land for generations to come.",
        discovered: false,
        region_id: WorldMapSystem::REGION_CINDRAL,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 322,
        category: CATEGORY_HISTORY,
        title: "The Temple of Mirrors",
        description: "The final divine arena where the ultimate choice must be made. The mirrors within reflect not just the present, but possible futures based on one's decisions. It is said that the Temple was built by the first king of Valebryn as a place of reflection and judgment, where rulers would come to see the consequences of their choices before making them.",
        discovered: false,
        region_id: WorldMapSystem::REGION_CINDRAL,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 323,
        category: CATEGORY_CHARACTERS,
        title: "The Ghost King",
        description: "The spirit of the last king of Valebryn, father to the Exiled Prince. Though his physical form perished in the fall of the kingdom, his spirit remains bound to the royal bloodline and the pact with the Abyss. He appears to his child in dreams, demanding that his legacy be carried on—whether for good or ill.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 324,
        category: CATEGORY_HISTORY,
        title: "The Final Echo",
        description: "The last resonance of the pact between the royal bloodline and the Abyss. As the power of the Sigil Shard grows, it creates echoes throughout Nyxoria, calling forth both allies and enemies for a final confrontation. The choices made during this time will determine whether the echo fades into silence or crescendos into a new age.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 325,
        category: CATEGORY_HISTORY,
        title: "The Divine Mirror",
        description: "The manifestation of the god of reflection, awakened by the power of the Sigil Shard. The Divine Mirror forces those who face it to confront their true selves, their deepest desires, and the consequences of their choices. It is both the final test and the ultimate judge, reflecting the fate that the bearer of the royal bloodline has chosen for Nyxoria.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      # Ending Lore (discovered based on player choices)
      $game_system.lore_entries << {
        id: 326,
        category: CATEGORY_HISTORY,
        title: "The Three Paths",
        description: "When facing the Divine Mirror, the bearer of the royal bloodline must choose one of three paths: The Path of Flame (destruction), the Path of Chains (justice), or the Path of Ash (peace). Each path represents a different vision for the future of Nyxoria, and each comes with its own cost and reward.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
      
      $game_system.lore_entries << {
        id: 327,
        category: CATEGORY_HISTORY,
        title: "The New Age",
        description: "With the choice made and the Divine Mirror's judgment rendered, a new age dawns for Nyxoria. The land will never be the same, shaped by the decisions of the one who carried the royal bloodline. Whether in flames, chains, or ash, the legacy of Valebryn continues, for better or worse.",
        discovered: false,
        region_id: nil,
        faction_id: nil,
        character_id: nil
      }
    end
  end
  
  # Progress to the next act
  def self.advance_act
    current = $game_system.story_acts_data[:current_act]
    if current < ACT_4
      $game_system.story_acts_data[:current_act] = current + 1
      return true
    end
    return false
  end
  
  # Get current act
  def self.current_act
    $game_system.story_acts_data[:current_act]
  end
  
  # Set act progress (0-100%)
  def self.set_act_progress(act, progress)
    progress = [[progress, 0].max, 100].min
    $game_system.story_acts_data[:act_progress][act] = progress
  end
  
  # Get act progress
  def self.get_act_progress(act)
    $game_system.story_acts_data[:act_progress][act]
  end

  # Set act progress (0-100%)
  def self.set_act_progress(act, progress)
    return unless $game_system.story_acts_data[:act_progress].key?(act)
    progress = [[progress, 0].max, 100].min
    $game_system.story_acts_data[:act_progress][act] = progress
  end
  
  # Get act name
  def self.get_act_name(act)
    ACT_NAMES[act]
  end
  
  # Get act theme
  def self.get_act_theme(act)
    ACT_THEMES[act]
  end
  
  # Get current act name
  def self.current_act_name
    get_act_name(current_act)
  end
  
  # Get current act theme
  def self.current_act_theme
    get_act_theme(current_act)
  end
  
  # Get current act progress
  def self.current_act_progress
    get_act_progress(current_act)
  end
  
  # Set quest progress
  def self.set_quest_progress(quest_id, progress)
    $game_system.story_acts_data[:quest_progress][quest_id] = progress
  end
  
  # Get quest progress
  def self.get_quest_progress(quest_id)
    $game_system.story_acts_data[:quest_progress][quest_id] || 0
  end
  
  # Set Act 3 choice
  def self.set_act3_choice(choice)
    $game_system.story_acts_data[:act3_choices][:sigil_choice] = choice
  end
  
  # Get Act 3 choice
  def self.get_act3_choice
    $game_system.story_acts_data[:act3_choices][:sigil_choice]
  end
  
  # Add faction ally
  def self.add_faction_ally(faction_id)
    $game_system.story_acts_data[:act4_choices][:faction_allies] << faction_id
  end
  
  # Remove faction ally
  def self.remove_faction_ally(faction_id)
    $game_system.story_acts_data[:act4_choices][:faction_allies].delete(faction_id)
  end
  
  # Set legacy choice
  def self.set_legacy_choice(choice)
    $game_system.story_acts_data[:act4_choices][:legacy_choice] = choice
  end
  
  # Get legacy choice
  def self.get_legacy_choice
    $game_system.story_acts_data[:act4_choices][:legacy_choice]
  end
  
  # Set final path
  def self.set_final_path(path)
    $game_system.story_acts_data[:act4_choices][:final_path] = path
  end
  
  # Get final path
  def self.get_final_path
    $game_system.story_acts_data[:act4_choices][:final_path]
  end
  
  # Set companion quest completion
  def self.complete_companion_quest(companion_id)
    $game_system.story_acts_data[:companion_quests][companion_id] = true
  end
  
  # Check if companion quest is completed
  def self.companion_quest_completed?(companion_id)
    $game_system.story_acts_data[:companion_quests][companion_id]
  end
  
  # Get ending description
  def self.get_ending_description(ending_id)
    ENDING_DESCRIPTIONS[ending_id]
  end
end