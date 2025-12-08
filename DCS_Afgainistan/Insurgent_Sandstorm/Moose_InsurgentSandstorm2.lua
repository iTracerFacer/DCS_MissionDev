-- Disable MOOSE's automatic F10 menus
_SETTINGS:SetPlayerMenuOff()  -- Disables the "Settings" F10 menu
-- Note: MOOSE does not add scoring menus by default unless SCORING objects are created

local ENABLE_SAMS = true -- used for testing purposes. Set to true to enable SAMs, false to disable.

-- Build Command Center and Mission for Blue Coalition
local blueHQ = GROUP:FindByName("BLUEHQ")
if blueHQ then
    US_CC = COMMANDCENTER:New(blueHQ, "USA HQ")
    US_Mission = MISSION:New(US_CC, "Insurgent Sandstorm", "Primary", "", coalition.side.BLUE)
    US_Mission:GetCommandCenter():SetMenu()  -- Disable mission F10 menu
    --US_Score = SCORING:New("Operation Polar Hammer")  -- Commented out to prevent Scoring F10 menu
    --US_Mission:AddScoring(US_Score)
    --US_Mission:Start()
    env.info("Blue Coalition Command Center and Mission started successfully")
else
    env.info("ERROR: BLUEHQ group not found! Blue mission will not start.")
end

--Build Command Center and Mission Red
local redHQ = GROUP:FindByName("REDHQ")
if redHQ then
    RU_CC = COMMANDCENTER:New(redHQ, "Russia HQ")
    RU_Mission = MISSION:New(RU_CC, "Insurgent Sandstorm", "Primary", "Hold what we have, take what we don't.", coalition.side.RED)
    RU_Mission:GetCommandCenter():SetMenu()  -- Disable mission F10 menu
    --RU_Score = SCORING:New("Operation Polar Shield")  -- Commented out to prevent Scoring F10 menu
    --RU_Mission:AddScoring(RU_Score)
    RU_Mission:Start()
    env.info("Red Coalition Command Center and Mission started successfully")
else
    env.info("ERROR: REDHQ group not found! Red mission will not start.")
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup SAM Systems
------------------------------------------------------------------------------------------------------------------------------------------------------

local RED_AA_ZONES = {
  ZONE:New("RED-AA-1"),
  ZONE:New("RED-AA-2"),
  ZONE:New("RED-AA-3"),
  ZONE:New("RED-AA-4"),
  ZONE:New("RED-AA-5"),
  ZONE:New("RED-AA-6"),
  ZONE:New("RED-AA-7"),
  ZONE:New("RED-AA-8"),
  ZONE:New("RED-AA-9"),
  ZONE:New("RED-AA-10"),
  ZONE:New("RED-AA-11"),
  ZONE:New("RED-AA-12"),
  ZONE:New("RED-AA-13"),
  ZONE:New("RED-AA-14"),
  ZONE:New("RED-AA-15"),
  ZONE:New("RED-AA-16"),
  ZONE:New("RED-AA-17"),
  ZONE:New("RED-AA-18"),
  ZONE:New("RED-AA-19"),
  ZONE:New("RED-AA-20"),
  ZONE:New("RED-AA-21"),
  ZONE:New("RED-AA-22"),
  ZONE:New("RED-AA-23"),
  ZONE:New("RED-AA-24"),
  ZONE:New("RED-AA-25"),
  ZONE:New("RED-AA-26"),
  ZONE:New("RED-AA-27"),
  ZONE:New("RED-AA-28"),
  ZONE:New("RED-AA-29"),
  ZONE:New("RED-AA-30"),
  ZONE:New("RED-AA-31"),
  ZONE:New("RED-AA-32"),
  ZONE:New("RED-AA-33"),
  ZONE:New("RED-AA-34"),
  ZONE:New("RED-AA-35"),
  ZONE:New("RED-AA-36"),
  ZONE:New("RED-AA-37"),
  ZONE:New("RED-AA-38"),
  ZONE:New("RED-AA-39"),
  ZONE:New("RED-AA-40"),
  ZONE:New("RED-AA-41"),
  ZONE:New("RED-AA-42"),
  ZONE:New("RED-AA-43"),
  ZONE:New("RED-AA-44"),
  ZONE:New("RED-AA-45"),
  ZONE:New("RED-AA-46"),
  ZONE:New("RED-AA-47"),
  ZONE:New("RED-AA-48"),
  ZONE:New("RED-AA-49"),
  ZONE:New("RED-AA-50"),
  ZONE:New("RED-AA-51"),
  ZONE:New("RED-AA-52"),
  ZONE:New("RED-AA-53"),
  ZONE:New("RED-AA-54"),
  ZONE:New("RED-AA-55"),
  ZONE:New("RED-AA-56"),
  ZONE:New("RED-AA-57"),
  ZONE:New("RED-AA-58"),
  ZONE:New("RED-AA-59"),
  ZONE:New("RED-AA-60"),
  ZONE:New("RED-AA-61"),
  ZONE:New("RED-AA-62"),
  ZONE:New("RED-AA-63"),
  ZONE:New("RED-AA-64"),
  ZONE:New("RED-AA-65"),
  ZONE:New("RED-AA-66"),
  ZONE:New("RED-AA-67"),
  ZONE:New("RED-AA-68"),
  ZONE:New("RED-AA-69"),
  ZONE:New("RED-AA-70"),
  ZONE:New("RED-AA-71"),
  ZONE:New("RED-AA-72"),
  ZONE:New("RED-AA-73"),
  ZONE:New("RED-AA-74"),
  ZONE:New("RED-AA-75"),
  ZONE:New("RED-AA-76"),
  ZONE:New("RED-AA-77"),
  ZONE:New("RED-AA-78"),
  ZONE:New("RED-AA-79"),
  ZONE:New("RED-AA-80"),
  ZONE:New("RED-AA-81"),
  ZONE:New("RED-AA-82"),
  ZONE:New("RED-AA-83"),
  ZONE:New("RED-AA-84"),
  ZONE:New("RED-AA-85"),
  ZONE:New("RED-AA-86"),
  ZONE:New("RED-AA-87"),
  ZONE:New("RED-AA-88"),
  ZONE:New("RED-AA-89"),
  ZONE:New("RED-AA-90"),
  ZONE:New("RED-AA-91"),
  ZONE:New("RED-AA-92"),
  ZONE:New("RED-AA-93"),
  ZONE:New("RED-AA-94"),
  ZONE:New("RED-AA-95"),
  ZONE:New("RED-AA-96"),
  ZONE:New("RED-AA-97"),
  ZONE:New("RED-AA-98"),
  ZONE:New("RED-AA-99"),
  ZONE:New("RED-AA-100"),
  ZONE:New("RED-AA-101"),
  ZONE:New("RED-AA-102"),
  ZONE:New("RED-AA-103"),
  ZONE:New("RED-AA-104"),
  ZONE:New("RED-AA-105"),
  ZONE:New("RED-AA-106"),
  ZONE:New("RED-AA-107"),
  ZONE:New("RED-AA-108"),
  ZONE:New("RED-AA-109"),
  ZONE:New("RED-AA-110"),
  ZONE:New("RED-AA-111"),
  ZONE:New("RED-AA-112"),
  ZONE:New("RED-AA-113"),
  ZONE:New("RED-AA-114"),
  ZONE:New("RED-AA-115"),
  ZONE:New("RED-AA-116"),
  ZONE:New("RED-AA-117"),
  ZONE:New("RED-AA-118"),
  ZONE:New("RED-AA-119"),
  ZONE:New("RED-AA-120"),
  ZONE:New("RED-AA-121"),
  ZONE:New("RED-AA-122"),
  ZONE:New("RED-AA-123"),
  ZONE:New("RED-AA-124"),
  ZONE:New("RED-AA-125"),
  ZONE:New("RED-AA-126"),
  ZONE:New("RED-AA-127"),
  ZONE:New("RED-AA-128"),
  ZONE:New("RED-AA-129"),
  ZONE:New("RED-AA-130"),
  ZONE:New("RED-AA-131"),
  ZONE:New("RED-AA-132"),
  ZONE:New("RED-AA-133"),
  ZONE:New("RED-AA-134"),
  ZONE:New("RED-AA-135"),
  ZONE:New("RED-AA-136"),
  ZONE:New("RED-AA-137"),
  ZONE:New("RED-AA-138"),
  ZONE:New("RED-AA-139"),
}

-- Schedule RED AA spawns using the calculated frequencies
-- Must allow enough room for an entire group to spawn. If the group only has 1 unit and you put 5, 5 will spawn,
-- but if the group has 5 units, and you put 5, only 1 will spawn..if you only put 4, it will never spawn. 
-- If you put 10, 2 of them will spawn, etc etc. 

if ENABLE_SAMS then
  RED_SA08 = SPAWN:New("RED EWR SA08")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(8, 8)
    :SpawnScheduled(1800, 0.5)

  -- There are 18 units in this group. Need space for each one in the numbers. So if I want 3 SA10s i'm just rounding up to 60.
  RED_SA10 = SPAWN:New("RED EWR AA-SA10-1")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(60, 60)
    :SpawnScheduled(1800, 0.5)

  -- There are 12 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 48
  RED_SA11 = SPAWN:New("RED EWR AA SA112-1")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(36, 36)
    :SpawnScheduled(1800, 0.5)

  -- There are 11 units in this group. Need space for each one in the numbers. So if I want 4 SA11s i'm just rounding up to 44
  RED_SA06 = SPAWN:New("RED EWR SA6")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(33, 33)
    :SpawnScheduled(1800, 0.5)

  RED_SA02 = SPAWN:New("RED EWR SA2")
    :InitRandomizeZones(RED_AA_ZONES)
    :InitLimit(60, 60)
    :SpawnScheduled(1800, 0.5)  
end

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Setup Air Dispatchers for RED and BLUE
------------------------------------------------------------------------------------------------------------------------------------------------------
--now handled by TADC system.

------------------------------------------------------------------------------------------------------------------------------------------------------
-- Clean up the airbases of debris and stuck aircraft.
------------------------------------------------------------------------------------------------------------------------------------------------------

CleanUpAirports = CLEANUP_AIRBASE:New( { 
 AIRBASE.Afghanistan.Kandahar, 
 AIRBASE.Afghanistan.Camp_Bastion
 
} )


------------------------------------------------------------------------------------------------------------------------------------------------------
-- Misc Spawns
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Spawn the RED Bunker Buster
Red_Bunker_Buster = SPAWN:New("BUNKER BUSTER")
  :InitLimit(1, 99)
  :SpawnScheduled(900, 0.5)


Red_Bunker_Buster2 = SPAWN:New("BUNKER BUSTER-1")
  :InitLimit(1, 99)
  :SpawnScheduled(1800, 0.5)



