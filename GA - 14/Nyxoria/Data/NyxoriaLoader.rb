# encoding: UTF-8
#==============================================================================
# ** Nyxoria Loader
#------------------------------------------------------------------------------
# This script loads all Nyxoria custom systems and ensures they are initialized
# in the correct order. Place this script at the top of your script list to
# ensure all systems are available throughout the game.
#==============================================================================

# Load order is important to ensure dependencies are met

#==============================================================================
# Load Video Intro System
#==============================================================================
if File.exist?("Data/VideoIntro.rb")
  load "Data/VideoIntro.rb"
  puts "Loaded Video Intro System" if $TEST
else
  puts "WARNING: Could not find Video Intro System!" if $TEST
end

#==============================================================================
# Load Lore Journal System
#==============================================================================
if File.exist?("Data/LoreJournal.rb")
  load "Data/LoreJournal.rb"
  puts "Loaded Lore Journal System" if $TEST
else
  puts "WARNING: Could not find Lore Journal System!" if $TEST
end

#==============================================================================
# Load Faction System
#==============================================================================
if File.exist?("Data/FactionSystem.rb")
  load "Data/FactionSystem.rb"
  puts "Loaded Faction System" if $TEST
else
  puts "WARNING: Could not find Faction System!" if $TEST
end

#==============================================================================
# Load Companion System
#==============================================================================
if File.exist?("Data/CompanionSystem.rb")
  load "Data/CompanionSystem.rb"
  puts "Loaded Companion System" if $TEST
else
  puts "WARNING: Could not find Companion System!" if $TEST
end

#==============================================================================
# Load World Map System
#==============================================================================
if File.exist?("Data/WorldMapSystem.rb")
  load "Data/WorldMapSystem.rb"
  puts "Loaded World Map System" if $TEST
else
  puts "WARNING: Could not find World Map System!" if $TEST
end

#==============================================================================
# Load Region Content System
#==============================================================================
if File.exist?("Data/RegionContentSystem.rb")
  load "Data/RegionContentSystem.rb"
  puts "Loaded Region Content System" if $TEST
else
  puts "WARNING: Could not find Region Content System!" if $TEST
end

#==============================================================================
# Load Story Acts System
#==============================================================================
if File.exist?("Data/StoryActs.rb")
  load "Data/StoryActs.rb"
  puts "Loaded Story Acts System" if $TEST
else
  puts "WARNING: Could not find Story Acts System!" if $TEST
end

#==============================================================================
# Load Nyxoria Core System (must be loaded last)
#==============================================================================
if File.exist?("Data/NyxoriaCore.rb")
  load "Data/NyxoriaCore.rb"
  puts "Loaded Nyxoria Core System" if $TEST
else
  puts "WARNING: Could not find Nyxoria Core System!" if $TEST
end

#==============================================================================
# Nyxoria Initialization
#==============================================================================
# Load Cutscene Scripts
#==============================================================================
if File.exist?("Data/CutsceneScripts.rb")
  load "Data/CutsceneScripts.rb"
  puts "Loaded Cutscene Scripts" if $TEST
else
  puts "WARNING: Could not find Cutscene Scripts!" if $TEST
end

#==============================================================================
# Load Regional Vision Events
#==============================================================================
if File.exist?("Data/RegionalVisionEvents.rb")
  load "Data/RegionalVisionEvents.rb"
  puts "Loaded Regional Vision Events" if $TEST
else
  puts "WARNING: Could not find Regional Vision Events!" if $TEST
end

#==============================================================================
# Load Companion Cutscenes
#==============================================================================
if File.exist?("Data/CompanionCutscenes.rb")
  load "Data/CompanionCutscenes.rb"
  puts "Loaded Companion Cutscenes" if $TEST
else
  puts "WARNING: Could not find Companion Cutscenes!" if $TEST
end

#==============================================================================
# Load Boss Encounter Scripts
#==============================================================================
if File.exist?("Data/BossEncounterScripts.rb")
  load "Data/BossEncounterScripts.rb"
  puts "Loaded Boss Encounter Scripts" if $TEST
else
  puts "WARNING: Could not find Boss Encounter Scripts!" if $TEST
end

#==============================================================================
module NyxoriaLoader
  # Check if all required systems are loaded
  def self.all_systems_loaded?
    defined?(VideoIntro) &&
    defined?(LoreJournal) && 
    defined?(FactionSystem) && 
    defined?(CompanionSystem) && 
    defined?(WorldMapSystem) && 
    defined?(StoryActs) && 
    defined?(RegionContentSystem) && 
    defined?(CutsceneScripts) &&
    defined?(RegionalVisionEvents) &&
    defined?(CompanionCutscenes) &&
    defined?(BossEncounterScripts) &&
    defined?(NyxoriaCore)
  end
  
  # Initialize all systems
  def self.initialize_all_systems
    if all_systems_loaded?
      NyxoriaCore.init_all_systems
      puts "All Nyxoria systems initialized successfully!" if $TEST
      return true
    else
      puts "WARNING: Not all Nyxoria systems were loaded!" if $TEST
      return false
    end
  end
  
  # This will be called when the game starts
  def self.on_game_start
    initialize_all_systems
  end
end

# Hook into game start
class << DataManager
  alias nyxoria_loader_setup_new_game setup_new_game
  def setup_new_game
    nyxoria_loader_setup_new_game
    NyxoriaLoader.on_game_start
  end
  
  alias nyxoria_loader_setup_battle_test setup_battle_test
  def setup_battle_test
    nyxoria_loader_setup_battle_test
    NyxoriaLoader.on_game_start
  end
  
  alias nyxoria_loader_extract_save_contents extract_save_contents
  def extract_save_contents(contents)
    nyxoria_loader_extract_save_contents(contents)
    NyxoriaLoader.on_game_start
  end
end

puts "Nyxoria Loader initialized" if $TEST