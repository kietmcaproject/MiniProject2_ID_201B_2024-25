#==============================================================================
# ** Video Intro System
#------------------------------------------------------------------------------
# This script handles playing intro videos before the title screen appears.
# It integrates with the Nyxoria system to play the game logo video.
#==============================================================================

module VideoIntro
  # Path to the logo video relative to the game directory
  LOGO_VIDEO_PATH = "GameLogo.mp4"
  
  # Flag to track if the intro video has been played
  @intro_played = false
  
  # Check if the intro has been played
  def self.intro_played?
    @intro_played
  end
  
  # Mark the intro as played
  def self.mark_as_played
    @intro_played = true
  end
  
  # Reset the intro played status (for testing)
  def self.reset
    @intro_played = false
  end
  
  # Play the intro video
  def self.play_intro
    if File.exist?(LOGO_VIDEO_PATH) && !intro_played?
      Graphics.play_movie(LOGO_VIDEO_PATH)
      mark_as_played
      return true
    end
    return false
  end
end

# Modify Scene_Title to play the intro video before showing the title screen
class Scene_Title < Scene_Base
  alias video_intro_start start
  
  def start
    # Play the intro video before starting the title screen
    VideoIntro.play_intro
    # Continue with the original title screen
    video_intro_start
  end
end

puts "Video Intro System initialized" if $TEST