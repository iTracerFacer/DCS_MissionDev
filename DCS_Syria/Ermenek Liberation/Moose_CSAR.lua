

   -- Instantiate and start a CSAR for the blue side, with template "Downed Pilot" and alias "Luftrettung"
   local my_csar_blue = CSAR:New(coalition.side.BLUE,"Downed Pilot","Downed Pilot")
   -- options
   my_csar_blue.immortalcrew = true -- downed pilot spawn is immortal
   my_csar_blue.invisiblecrew = false -- downed pilot spawn is visible
   -- start the FSM
   my_csar_blue:__Start(5)
   
------------------------------------------------------------------------------------------
--   CSAR Options   

    my_csar_blue.allowDownedPilotCAcontrol = false -- Set to false if you don\'t want to allow control by Combined Arms.
    my_csar_blue.allowFARPRescue = true -- allows pilots to be rescued by landing at a FARP or Airbase. Else MASH only!
    my_csar_blue.FARPRescueDistance = 1000 -- you need to be this close to a FARP or Airport for the pilot to be rescued.
    my_csar_blue.autosmoke = true -- automatically smoke a downed pilot\'s location when a heli is near.
    my_csar_blue.autosmokedistance = 5000 -- distance for autosmoke
    my_csar_blue.coordtype = 1 -- Use Lat/Long DDM (0), Lat/Long DMS (1), MGRS (2), Bullseye imperial (3) or Bullseye metric (4) for coordinates.
    my_csar_blue.csarOncrash = true -- (WIP) If set to true, will generate a downed pilot when a plane crashes as well.
    my_csar_blue.enableForAI = false -- set to false to disable AI pilots from being rescued.
    my_csar_blue.pilotRuntoExtractPoint = true -- Downed pilot will run to the rescue helicopter up to my_csar_blue.extractDistance in meters. 
    my_csar_blue.extractDistance = 500 -- Distance the downed pilot will start to run to the rescue helicopter.
    my_csar_blue.immortalcrew = true -- Set to true to make wounded crew immortal.
    my_csar_blue.invisiblecrew = false -- Set to true to make wounded crew insvisible.
    my_csar_blue.loadDistance = 75 -- configure distance for pilots to get into helicopter in meters.
    my_csar_blue.mashprefix = {"MASH"} -- prefixes of #GROUP objects used as MASHes.
    my_csar_blue.max_units = 6 -- max number of pilots that can be carried if #CSAR.AircraftType is undefined.
    my_csar_blue.messageTime = 15 -- Time to show messages for in seconds. Doubled for long messages.
    my_csar_blue.radioSound = "beacon.ogg" -- the name of the sound file to use for the pilots\' radio beacons. 
    my_csar_blue.smokecolor = 4 -- Color of smokemarker, 0 is green, 1 is red, 2 is white, 3 is orange and 4 is blue.
    my_csar_blue.useprefix = true  -- Requires CSAR helicopter #GROUP names to have the prefix(es) defined below.
    my_csar_blue.csarPrefix = { "Helicargo", "MEDEVAC"} -- #GROUP name prefixes used for useprefix=true - DO NOT use # in helicopter names in the Mission Editor! 
    my_csar_blue.verbose = 0 -- set to > 1 for stats output for debugging.
    -- (added 0.1.4) limit amount of downed pilots spawned by **ejection** events
    my_csar_blue.limitmaxdownedpilots = true
    my_csar_blue.maxdownedpilots = 10 
    -- (added 0.1.8) - allow to set far/near distance for approach and optionally pilot must open doors
    my_csar_blue.approachdist_far = 5000 -- switch do 10 sec interval approach mode, meters
    my_csar_blue.approachdist_near = 3000 -- switch to 5 sec interval approach mode, meters
    my_csar_blue.pilotmustopendoors = true -- switch to true to enable check of open doors
    -- (added 0.1.9)
    my_csar_blue.suppressmessages = false -- switch off all messaging if you want to do your own
    -- (added 0.1.11)
    my_csar_blue.rescuehoverheight = 20 -- max height for a hovering rescue in meters
    my_csar_blue.rescuehoverdistance = 10 -- max distance for a hovering rescue in meters
    -- (added 0.1.12)
    -- Country codes for spawned pilots
    my_csar_blue.countryblue= country.id.USA
    my_csar_blue.countryred = country.id.RUSSIA
    my_csar_blue.countryneutral = country.id.UN_PEACEKEEPERS
    

    

--Number of successful landings with save pilots and aggregated number of saved pilots is stored in these variables in the object:

--   my_csar_blue.rescues -- number of successful landings *with* saved pilots
--   my_csar_blue.rescuedpilots -- aggregated number of pilots rescued from the field (of *all* players)
   

--4. Events
--The class comes with a number of FSM-based events that missions designers can use to shape their mission. These are:

--4.1. PilotDown.
-- The event is triggered when a new downed pilot is detected. Use e.g. `function my_csar_blue:OnAfterPilotDown(...)` to link into this event:

     function my_csar_blue:OnAfterPilotDown(from, event, to, spawnedgroup, frequency, groupname, coordinates_text)
       
     end
--4.2. Approach.
-- A CSAR helicpoter is closing in on a downed pilot. Use e.g. `function my_csar_blue:OnAfterApproach(...)` to link into this event:

     function my_csar_blue:OnAfterApproach(from, event, to, heliname, groupname)
       
     end
--4.3. Boarded.
-- The pilot has been boarded to the helicopter. Use e.g. `function my_csar_blue:OnAfterBoarded(...)` to link into this event:

     function my_csar_blue:OnAfterBoarded(from, event, to, heliname, groupname)
       
     end
--4.4. Returning.
--  The CSAR helicopter is ready to return to an Airbase, FARP or MASH. Use e.g. `function my_csar_blue:OnAfterReturning(...)` to link into this event:

     function my_csar_blue:OnAfterReturning(from, event, to, heliname, groupname)
       
     end
--4.5. Rescued.
-- The CSAR helicopter has landed close to an Airbase/MASH/FARP and the pilots are safe. Use e.g. `function my_csar_blue:OnAfterRescued(...)` to link into this event:

     function my_csar_blue:OnAfterRescued(from, event, to, heliunit, heliname, pilotssaved)
      
      --Add Scores
      ScoreAddBlue(RescuePoints)
      StatBlueRescued = StatBlueRescued + 1
             
     end     
--5. Spawn downed pilots at location to be picked up.
-- If missions designers want to spawn downed pilots into the field, e.g. at mission begin to give the helicopter guys works, they can do this like so:
--
--   -- Create downed "Pilot Wagner" in #ZONE "CSAR_Start_1" at a random point for the blue coalition
--   my_csar_blue:SpawnCSARAtZone( "CSAR_Start_1", coalition.side.BLUE, "Pilot Wagner", true )
--
--      --Create a casualty and CASEVAC request from a "Point" (VEC2) for the blue coalition --shagrat
--      my_csar_blue:SpawnCASEVAC(Point, coalition.side.BLUE)  