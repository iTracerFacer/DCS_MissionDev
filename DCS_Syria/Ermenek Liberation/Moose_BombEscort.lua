  --------------------------------------------------------  
  MaxBombers1 = 20           -- Total number of maximum available bombers-- Attacks runway @ Adana Sakirpasa
  MaxBombers2 = 20          -- Total number of maximum available bombers-- Attacks runway at Incirlik
  MaxBombersAlive = 5       -- Max number of bombers that can be alive at any given time.
  HotOrColdStart = SPAWN.Takeoff.Cold -- Can be set to SPAWN.Takeoff.Cold, SPAWN.Takeoff.Hot, SPAWN.Takeoff.Takeoff
  
  
  ------------------------------------------------------
  -- Don't Change anything below here unless you are me.
  -- Even then it's probably not a good idea as I have no idea what I'm doing. -tf 
  ------------------------------------------------------
  -- Build the Menus
local MenuCoalitionBlue -- Menu#MENU_COALITION
local MenuShowBomberStatus -- Menu#MENU_COALITION_COMMAND
local MenuDeployBomber1 -- Menu#MENU_COALITION_COMMAND
local MenuDeployBomber2 -- Menu#MENU_COALITION_COMMAND

  



  function SpawnBomber1()
    Spawn_USBomber1:Spawn()
   end

  function SpawnBomber2()
    Spawn_USBomber2:Spawn()
  end

  function ShowBomberStatus()
    MESSAGE:New("Bombers Available for Deployment:\n\n" .. 
    "From Larnaca to Adana Sakirpasa: " .. RemainingBombers1 .. "\n" ..
    "From Larnaca to Incirlik: " .. RemainingBombers2, 10, "Bomber Status", false):ToBlue()
    USERSOUND:New("beeps-and-clicks.wav"):ToCoalition(coalition.side.BLUE)
  end


local MenuCoalitionBlue = MENU_COALITION:New( coalition.side.BLUE, "Manage Bombers" )
local MenuShowBomberStatus = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Show Bomber Status", MenuCoalitionBlue, ShowBomberStatus )
local MenuDeployBomber1 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request Bomber to Adana Sakirpasa", MenuCoalitionBlue, SpawnBomber1 )
local MenuDeployBomber2 = MENU_COALITION_COMMAND:New( coalition.side.BLUE, "Request Bomber to Incirlik", MenuCoalitionBlue, SpawnBomber2 )



  -- Setup the bomber objects 
  
  RemainingBombers1 = MaxBombers1
  Spawn_USBomber1 = SPAWN:New("US BOMBER-1") -- Attacks runway @ Adana Sakirpasa
  :InitLimit( MaxBombersAlive, MaxBombers1 )
  :InitAirbase("Larnaca",HotOrColdStart)
  :InitCleanUp(300)
  :OnSpawnGroup(
    function()
      RemainingBombers1 = RemainingBombers1 - 1
      MESSAGE:New("\n\nRequesting Bomber to Adana Sakirpasa..\n\nATTENTION: A B-1B Bomber is cold starting and deploying from Larnaca. Be prepared to escort! Bombers will orbit at their WP1 for 10 mins before proceeding to their targets. Get formed up and defend them!\n\nBombers Remaining: " .. RemainingBombers1, 30, "Bomber Status", false):ToBlue()
      USERSOUND:New("beeps-and-clicks.wav"):ToCoalition(coalition.side.BLUE)
      if RemainingBombers1 == 0 then -- remove the menu
        MenuDeployBomber1:Remove()
      end
      --Get rid of the parent menu if both are empty.
      if RemainingBombers1 == 0 and RemainingBombers2 == 0 then
        MenuCoalitionBlue:Remove()
      end
      
    end )


  RemainingBombers2 = MaxBombers2
  Spawn_USBomber2 = SPAWN:New("US BOMBER-2") -- Attacks runway at Incirlik
  :InitLimit( MaxBombersAlive, MaxBombers2 )
  :InitAirbase("Larnaca",HotOrColdStart)
  :InitCleanUp(300)
  :OnSpawnGroup(
    function() 
      RemainingBombers2 = RemainingBombers2 - 1
      MESSAGE:New("\n\nRequesting Bomber to Incirlik..\n\nATTENTION: A B-1B Bomber is cold starting and deploying from Larnaca. Be prepared to escort! Bombers will orbit at their WP1 for 10 mins before proceeding to their targets. Get formed up and defend them!\n\nBombers Remaining: " .. RemainingBombers2, 30, "Bomber Status", false):ToBlue()
      USERSOUND:New("beeps-and-clicks.wav"):ToCoalition(coalition.side.BLUE)
      if RemainingBombers2 == 0 then -- remove the menu
        MenuDeployBomber2:Remove()        
      end
      
      --Get rid of the parent menu if both are empty.
      if RemainingBombers1 == 0 and RemainingBombers2 == 0 then
        MenuCoalitionBlue:Remove()
      end
    end ) 




