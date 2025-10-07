
-- Operation Polar Shield Mission Script using MOOSE 


-- Set Spawn Limits - These limits can be adjusted to change the number of ground units that will spawn for each type.
-- These set max units, not groups. For example, the manpad group in the mission editor is 2 units. So if MAX_RU_MANPADS = 10, then 5 groups of manpads will spawn.
-- So you have to know how many units are in each group to set these limits effectively.

MAX_RU_MANPADS = 10         -- Each group has 2 units, so 10 = 5 groups of 2.
MAX_RU_AAA = 25             -- Each group has 1 units, so 25 = 25 groups of 1. 
MAX_RU_TANK_T90 = 10        -- The rest of these groups have 1 unit each.
MAX_RU_TANK_T55 = 10
MAX_RU_IFV = 35
MAX_RU_IFV_Technicals = 45
MAX_RU_SA08 = 15
MAX_RU_SA19 = 15
MAX_RU_SA15 = 30            -- This is a group of 3 . Sa15 + Shilka + Ammo truck.

MIN_RU_INTERCEPTORS = 1       -- Each group has 2 units, so 2 = 1 group of 2. This is the minimum number of interceptors that will always be present.
MAX_RU_INTERCEPTORS = 500     -- This the total number of interceptors that can be spawned. The script will maintain at least the minimum number above.

-- MAX_RU_ARTY = 10    -- Disabled lower regardless of this setting. Will fix later.


-- Build Command Center and Mission for Blue Coalition
local blueHQ = GROUP:FindByName("BLUEHQ")
if blueHQ then
    US_CC = COMMANDCENTER:New(blueHQ, "USA HQ")
    US_Mission = MISSION:New(US_CC, "Operation Polar Hammer", "Primary", "", coalition.side.BLUE)
    US_Score = SCORING:New("Operation Polar Hammer")
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
    RU_Mission = MISSION:New(RU_CC, "Operation Polar Shield", "Primary", "Destroy the City of Ushuaia and its supporting FARPS", coalition.side.RED)
    --RU_Score = SCORING:New("Operation Polar Shield")
    --RU_Mission:AddScoring(RU_Score)
    RU_Mission:Start()
    env.info("Red Coalition Command Center and Mission started successfully")
else
    env.info("ERROR: REDHQ group not found! Red mission will not start.")
end

-- Table of Zones to spread red ground forces randomly around.
RandomSpawnZoneTable = {
    ZONE:New("sp-1"), ZONE:New("sp-2"), ZONE:New("sp-3"), ZONE:New("sp-4"), ZONE:New("sp-5"),
    ZONE:New("sp-6"), ZONE:New("sp-7"), ZONE:New("sp-8"), ZONE:New("sp-9"), ZONE:New("sp-10"),
    ZONE:New("sp-11"), ZONE:New("sp-12"), ZONE:New("sp-13"), ZONE:New("sp-14"), ZONE:New("sp-15"),
    ZONE:New("sp-16"), ZONE:New("sp-17"), ZONE:New("sp-18"), ZONE:New("sp-19"), ZONE:New("sp-20"),
    ZONE:New("sp-21"), ZONE:New("sp-22"), ZONE:New("sp-23"), ZONE:New("sp-24"), ZONE:New("sp-25"),
    ZONE:New("sp-26"), ZONE:New("sp-27"), ZONE:New("sp-28"), ZONE:New("sp-29"), ZONE:New("sp-30"),
    ZONE:New("sp-31"), ZONE:New("sp-32"), ZONE:New("sp-33"), ZONE:New("sp-34"), ZONE:New("sp-35"),
    ZONE:New("sp-36"), ZONE:New("sp-37"), ZONE:New("sp-38"), ZONE:New("sp-39"), ZONE:New("sp-40"),
    ZONE:New("sp-41"), ZONE:New("sp-42"), ZONE:New("sp-43"), ZONE:New("sp-44"), ZONE:New("sp-45"),
    ZONE:New("sp-46"), ZONE:New("sp-47"), ZONE:New("sp-48"), ZONE:New("sp-49"), ZONE:New("sp-50"),
    ZONE:New("sp-51"), ZONE:New("sp-52"), ZONE:New("sp-53"), ZONE:New("sp-54"), ZONE:New("sp-55"),
    ZONE:New("sp-56"), ZONE:New("sp-57"), ZONE:New("sp-58"), ZONE:New("sp-59"), ZONE:New("sp-60"),
    ZONE:New("sp-61"), ZONE:New("sp-62"), ZONE:New("sp-63"), ZONE:New("sp-64"), ZONE:New("sp-65"),
    ZONE:New("sp-66"), ZONE:New("sp-67"), ZONE:New("sp-68"), ZONE:New("sp-69"), ZONE:New("sp-70"),
    ZONE:New("sp-71"), ZONE:New("sp-72"), ZONE:New("sp-73"), ZONE:New("sp-74"), ZONE:New("sp-75"),
    ZONE:New("sp-76"), ZONE:New("sp-77"), ZONE:New("sp-78"), ZONE:New("sp-79"), ZONE:New("sp-80"),
    ZONE:New("sp-81"), ZONE:New("sp-82"), ZONE:New("sp-83"), ZONE:New("sp-84"), ZONE:New("sp-85"),
    ZONE:New("sp-86"), ZONE:New("sp-87"), ZONE:New("sp-88"), ZONE:New("sp-89"), ZONE:New("sp-90"),
    ZONE:New("sp-91"), ZONE:New("sp-92"), ZONE:New("sp-93"), ZONE:New("sp-94"), ZONE:New("sp-95"),
    ZONE:New("sp-96"), ZONE:New("sp-97"), ZONE:New("sp-98"), ZONE:New("sp-99"), ZONE:New("sp-100"),
    ZONE:New("sp-101"), ZONE:New("sp-102"), ZONE:New("sp-103"), ZONE:New("sp-104"), ZONE:New("sp-105"),
    ZONE:New("sp-106"), ZONE:New("sp-107"), ZONE:New("sp-108"), ZONE:New("sp-109"), ZONE:New("sp-110"),
    ZONE:New("sp-111"), ZONE:New("sp-112"), ZONE:New("sp-113"), ZONE:New("sp-114"), ZONE:New("sp-115"),
    ZONE:New("sp-116"), ZONE:New("sp-117"), ZONE:New("sp-118"), ZONE:New("sp-119"), ZONE:New("sp-120"),
    ZONE:New("sp-121"), ZONE:New("sp-122"), ZONE:New("sp-123"), ZONE:New("sp-124"), ZONE:New("sp-125"),
    ZONE:New("sp-126"), ZONE:New("sp-127"), ZONE:New("sp-128"), ZONE:New("sp-129"), ZONE:New("sp-130"),
    ZONE:New("sp-131"), ZONE:New("sp-132"), ZONE:New("sp-133"), ZONE:New("sp-134"), ZONE:New("sp-135"),
    ZONE:New("sp-136"), ZONE:New("sp-137"), ZONE:New("sp-138"), ZONE:New("sp-139"), ZONE:New("sp-140"),
    ZONE:New("sp-141"), ZONE:New("sp-142"), ZONE:New("sp-143"), ZONE:New("sp-144"), ZONE:New("sp-145"),
    ZONE:New("sp-146"), ZONE:New("sp-147"), ZONE:New("sp-148"), ZONE:New("sp-149"), ZONE:New("sp-150"),
    ZONE:New("sp-151"), ZONE:New("sp-152"), ZONE:New("sp-153"), ZONE:New("sp-154"), ZONE:New("sp-155"),
    ZONE:New("sp-156"), ZONE:New("sp-157"), ZONE:New("sp-158"), ZONE:New("sp-159"), ZONE:New("sp-160"),
    ZONE:New("sp-161"), ZONE:New("sp-162"), ZONE:New("sp-163"), ZONE:New("sp-164"), ZONE:New("sp-165"),
    ZONE:New("sp-166"), ZONE:New("sp-167"), ZONE:New("sp-168"), ZONE:New("sp-169"), ZONE:New("sp-170"),
    ZONE:New("sp-171"), ZONE:New("sp-172"), ZONE:New("sp-173"), ZONE:New("sp-174"), ZONE:New("sp-175"),
    ZONE:New("sp-176"), ZONE:New("sp-177"), ZONE:New("sp-178"), ZONE:New("sp-179"), ZONE:New("sp-180"),
    ZONE:New("sp-181"), ZONE:New("sp-182"), ZONE:New("sp-183"), ZONE:New("sp-184"), ZONE:New("sp-185"),
    ZONE:New("sp-186"), ZONE:New("sp-187"), ZONE:New("sp-188"), ZONE:New("sp-189"), ZONE:New("sp-190"),
    ZONE:New("sp-191"), ZONE:New("sp-192"), ZONE:New("sp-193"), ZONE:New("sp-194"), ZONE:New("sp-195"),
    ZONE:New("sp-196"), ZONE:New("sp-197"), ZONE:New("sp-198"), ZONE:New("sp-199"), ZONE:New("sp-200"),
    ZONE:New("sp-201"), ZONE:New("sp-202"), ZONE:New("sp-203"), ZONE:New("sp-204"), ZONE:New("sp-205"),
    ZONE:New("sp-206"), ZONE:New("sp-207"), ZONE:New("sp-208"), ZONE:New("sp-209"), ZONE:New("sp-210"),
    ZONE:New("sp-211"), ZONE:New("sp-212"), ZONE:New("sp-213"), ZONE:New("sp-214"), ZONE:New("sp-215"),
    ZONE:New("sp-216"), ZONE:New("sp-217"), ZONE:New("sp-218"), ZONE:New("sp-219"), ZONE:New("sp-220"),
    ZONE:New("sp-221"), ZONE:New("sp-222"), ZONE:New("sp-223"), ZONE:New("sp-224"), ZONE:New("sp-225"),
    ZONE:New("sp-226"), ZONE:New("sp-227"), ZONE:New("sp-228"), ZONE:New("sp-229"), ZONE:New("sp-230"),
    ZONE:New("sp-231"), ZONE:New("sp-232"), ZONE:New("sp-233"), ZONE:New("sp-234"), ZONE:New("sp-235"),
    ZONE:New("sp-236"), ZONE:New("sp-237"), ZONE:New("sp-238"), ZONE:New("sp-239"), ZONE:New("sp-240"),
    ZONE:New("sp-241"), ZONE:New("sp-242"), ZONE:New("sp-243"), ZONE:New("sp-244"), ZONE:New("sp-245"),
    ZONE:New("sp-246"), ZONE:New("sp-247"), ZONE:New("sp-248"), ZONE:New("sp-249"), ZONE:New("sp-250"),
    ZONE:New("sp-251"), ZONE:New("sp-252"), ZONE:New("sp-253"), ZONE:New("sp-254"), ZONE:New("sp-255"),
    ZONE:New("sp-256"), ZONE:New("sp-257"), ZONE:New("sp-258"), ZONE:New("sp-259"), ZONE:New("sp-260"),
    ZONE:New("sp-261"), ZONE:New("sp-262"), ZONE:New("sp-263"), ZONE:New("sp-264"), ZONE:New("sp-265"),
    ZONE:New("sp-266"), ZONE:New("sp-267"), ZONE:New("sp-268"), ZONE:New("sp-269"), ZONE:New("sp-270"),
    ZONE:New("sp-271"), ZONE:New("sp-272"), ZONE:New("sp-273"), ZONE:New("sp-274"), ZONE:New("sp-275"),
    ZONE:New("sp-276"), ZONE:New("sp-277"), ZONE:New("sp-278"), ZONE:New("sp-279"), ZONE:New("sp-280"),
    ZONE:New("sp-281"), ZONE:New("sp-282"), ZONE:New("sp-283"), ZONE:New("sp-284"), ZONE:New("sp-285"),
    ZONE:New("sp-286"), ZONE:New("sp-287"), ZONE:New("sp-288"), ZONE:New("sp-289"), ZONE:New("sp-290"),
    ZONE:New("sp-291"), ZONE:New("sp-292"), ZONE:New("sp-293"), ZONE:New("sp-294"), ZONE:New("sp-295"),
    ZONE:New("sp-296"), ZONE:New("sp-297"), ZONE:New("sp-298"), ZONE:New("sp-299"), ZONE:New("sp-300"),
    ZONE:New("sp-301"), ZONE:New("sp-302"), ZONE:New("sp-303"), ZONE:New("sp-304"), ZONE:New("sp-305"),
    ZONE:New("sp-306"), ZONE:New("sp-307"), ZONE:New("sp-308"), ZONE:New("sp-309"), ZONE:New("sp-310"),
    ZONE:New("sp-311"), ZONE:New("sp-312"), ZONE:New("sp-313"), ZONE:New("sp-314"), ZONE:New("sp-315"),
    ZONE:New("sp-316"), ZONE:New("sp-317"), ZONE:New("sp-318"), ZONE:New("sp-319"), ZONE:New("sp-320"),
    ZONE:New("sp-321"), ZONE:New("sp-322"), ZONE:New("sp-323"), ZONE:New("sp-324"), ZONE:New("sp-325"),
    ZONE:New("sp-326"), ZONE:New("sp-327"), ZONE:New("sp-328"), ZONE:New("sp-329"), ZONE:New("sp-330"),
    ZONE:New("sp-331"), ZONE:New("sp-332"), ZONE:New("sp-333"), ZONE:New("sp-334"), ZONE:New("sp-335"),
    ZONE:New("sp-336"), ZONE:New("sp-337"), ZONE:New("sp-338"), ZONE:New("sp-339"), ZONE:New("sp-340"),
    ZONE:New("sp-341"), ZONE:New("sp-342"), ZONE:New("sp-343"), ZONE:New("sp-344"), ZONE:New("sp-345"),
    ZONE:New("sp-346"), ZONE:New("sp-347"), ZONE:New("sp-348"), ZONE:New("sp-349"), ZONE:New("sp-350"),
    ZONE:New("sp-351"), ZONE:New("sp-352"), ZONE:New("sp-353"), ZONE:New("sp-354"), ZONE:New("sp-355"),
    ZONE:New("sp-356"), ZONE:New("sp-357"), ZONE:New("sp-358"), ZONE:New("sp-359"), ZONE:New("sp-360"),
    ZONE:New("sp-361"), ZONE:New("sp-362"), ZONE:New("sp-363"), ZONE:New("sp-364"), ZONE:New("sp-365"),
    ZONE:New("sp-366"), ZONE:New("sp-367"), ZONE:New("sp-368"), ZONE:New("sp-369"), ZONE:New("sp-370"),
    ZONE:New("sp-371"), ZONE:New("sp-372"), ZONE:New("sp-373"), ZONE:New("sp-374"), ZONE:New("sp-375"),
    ZONE:New("sp-376"), ZONE:New("sp-377"), ZONE:New("sp-378"), ZONE:New("sp-379"), ZONE:New("sp-380"),
    ZONE:New("sp-381"), ZONE:New("sp-382"), ZONE:New("sp-383"), ZONE:New("sp-384"), ZONE:New("sp-385"),
    ZONE:New("sp-386"), ZONE:New("sp-387"), ZONE:New("sp-388"), ZONE:New("sp-389"), ZONE:New("sp-390"),
    ZONE:New("sp-391"), ZONE:New("sp-392"), ZONE:New("sp-393"), ZONE:New("sp-394"), ZONE:New("sp-395"),
    ZONE:New("sp-396"), ZONE:New("sp-397"), ZONE:New("sp-398"), ZONE:New("sp-399"), ZONE:New("sp-400"),
    ZONE:New("sp-401"), ZONE:New("sp-402"), ZONE:New("sp-403"), ZONE:New("sp-404"), ZONE:New("sp-405"),
    ZONE:New("sp-406"), ZONE:New("sp-407"), ZONE:New("sp-408"), ZONE:New("sp-409"), ZONE:New("sp-410"),
    ZONE:New("sp-411"), ZONE:New("sp-412"), ZONE:New("sp-413"), ZONE:New("sp-414"), ZONE:New("sp-415"),
    ZONE:New("sp-416"), ZONE:New("sp-417"), ZONE:New("sp-418"), ZONE:New("sp-419"), ZONE:New("sp-420"),
    ZONE:New("sp-421"), ZONE:New("sp-422"), ZONE:New("sp-423"), ZONE:New("sp-424"), ZONE:New("sp-425"),
    ZONE:New("sp-426"), ZONE:New("sp-427"), ZONE:New("sp-428"), ZONE:New("sp-429"), ZONE:New("sp-430"),
    ZONE:New("sp-431"), ZONE:New("sp-432"), ZONE:New("sp-433"), ZONE:New("sp-434"), ZONE:New("sp-435"),
    ZONE:New("sp-436"), ZONE:New("sp-437"), ZONE:New("sp-438"), ZONE:New("sp-439"), ZONE:New("sp-440"),
    ZONE:New("sp-441"), ZONE:New("sp-442"), ZONE:New("sp-443"), ZONE:New("sp-444"), ZONE:New("sp-445"),
    ZONE:New("sp-446"), ZONE:New("sp-447"), ZONE:New("sp-448"), ZONE:New("sp-449"), ZONE:New("sp-450"),
    ZONE:New("sp-451"), ZONE:New("sp-452"), ZONE:New("sp-453"), ZONE:New("sp-454"), ZONE:New("sp-455"),
    ZONE:New("sp-456"), ZONE:New("sp-457"), ZONE:New("sp-458"), ZONE:New("sp-459"), ZONE:New("sp-460"),
    ZONE:New("sp-461"), ZONE:New("sp-462"), ZONE:New("sp-463"), ZONE:New("sp-464"), ZONE:New("sp-465"),
    ZONE:New("sp-466"), ZONE:New("sp-467"), ZONE:New("sp-468"), ZONE:New("sp-469"), ZONE:New("sp-470"),
    ZONE:New("sp-471"), ZONE:New("sp-472"), ZONE:New("sp-473"), ZONE:New("sp-474"), ZONE:New("sp-475"),
    ZONE:New("sp-476"), ZONE:New("sp-477"), ZONE:New("sp-478"), ZONE:New("sp-479"), ZONE:New("sp-480"),
    ZONE:New("sp-481"), ZONE:New("sp-482"), ZONE:New("sp-483"), ZONE:New("sp-484"), ZONE:New("sp-485"),
    ZONE:New("sp-486"), ZONE:New("sp-487"), ZONE:New("sp-488"), ZONE:New("sp-489"), ZONE:New("sp-490"),
    ZONE:New("sp-491"), ZONE:New("sp-492"), ZONE:New("sp-493"), ZONE:New("sp-494"), ZONE:New("sp-495"),
    ZONE:New("sp-496"), ZONE:New("sp-497"), ZONE:New("sp-498"), ZONE:New("sp-499"), ZONE:New("sp-500"),
    ZONE:New("sp-501"), ZONE:New("sp-502"), ZONE:New("sp-503"), ZONE:New("sp-504"), ZONE:New("sp-505"),
    ZONE:New("sp-506"), ZONE:New("sp-507"), ZONE:New("sp-508"), ZONE:New("sp-509"), ZONE:New("sp-510"),
    ZONE:New("sp-511"), ZONE:New("sp-512"), ZONE:New("sp-513"), ZONE:New("sp-514"), ZONE:New("sp-515"),
    ZONE:New("sp-516"), ZONE:New("sp-517"), ZONE:New("sp-518"), ZONE:New("sp-519"), ZONE:New("sp-520"),
    ZONE:New("sp-521"), ZONE:New("sp-522"), ZONE:New("sp-523"), ZONE:New("sp-524"), ZONE:New("sp-525"),
    ZONE:New("sp-526"), ZONE:New("sp-527"), ZONE:New("sp-528"), ZONE:New("sp-529"), ZONE:New("sp-530"),
    ZONE:New("sp-531"), ZONE:New("sp-532"), ZONE:New("sp-533"), ZONE:New("sp-534"), ZONE:New("sp-535"),
    ZONE:New("sp-536"), ZONE:New("sp-537"), ZONE:New("sp-538"), ZONE:New("sp-539"), ZONE:New("sp-540"),
    ZONE:New("sp-541"), ZONE:New("sp-542"), ZONE:New("sp-543"), ZONE:New("sp-544"), ZONE:New("sp-545"),
    ZONE:New("sp-546"), ZONE:New("sp-547"), ZONE:New("sp-548"), ZONE:New("sp-549"), ZONE:New("sp-550"),
    ZONE:New("sp-551"), ZONE:New("sp-552"), ZONE:New("sp-553"), ZONE:New("sp-554"), ZONE:New("sp-555"),
    ZONE:New("sp-556"), ZONE:New("sp-557"), ZONE:New("sp-558"), ZONE:New("sp-559"), ZONE:New("sp-560"),
    ZONE:New("sp-561"), ZONE:New("sp-562"), ZONE:New("sp-563"), ZONE:New("sp-564"), ZONE:New("sp-565"),
    ZONE:New("sp-566"), ZONE:New("sp-567"), ZONE:New("sp-568"), ZONE:New("sp-569"), ZONE:New("sp-570"),
    ZONE:New("sp-571"), ZONE:New("sp-572"), ZONE:New("sp-573"), ZONE:New("sp-574"), ZONE:New("sp-575"),
    ZONE:New("sp-576"), ZONE:New("sp-577"), ZONE:New("sp-578"), ZONE:New("sp-579"), ZONE:New("sp-580"),
    ZONE:New("sp-581"), ZONE:New("sp-582"), ZONE:New("sp-583"), ZONE:New("sp-584"), ZONE:New("sp-585"),
    ZONE:New("sp-586"), ZONE:New("sp-587"), ZONE:New("sp-588"), ZONE:New("sp-589"), ZONE:New("sp-590"),
    ZONE:New("sp-591"), ZONE:New("sp-592"), ZONE:New("sp-593"), ZONE:New("sp-594"), ZONE:New("sp-595"),
    ZONE:New("sp-596"), ZONE:New("sp-597"), ZONE:New("sp-598"), ZONE:New("sp-599"), ZONE:New("sp-600"),
    ZONE:New("sp-601"), ZONE:New("sp-602"), ZONE:New("sp-603"), ZONE:New("sp-604"), ZONE:New("sp-605"),
    ZONE:New("sp-606"), ZONE:New("sp-607"), ZONE:New("sp-608"), ZONE:New("sp-609"), ZONE:New("sp-610"),
    ZONE:New("sp-611"), ZONE:New("sp-612"), ZONE:New("sp-613"), ZONE:New("sp-614"), ZONE:New("sp-615"),
    ZONE:New("sp-616"), ZONE:New("sp-617"), ZONE:New("sp-618"), ZONE:New("sp-619"), ZONE:New("sp-620"),
    ZONE:New("sp-621"), ZONE:New("sp-622"), ZONE:New("sp-623"), ZONE:New("sp-624"), ZONE:New("sp-625"),
    ZONE:New("sp-626"), ZONE:New("sp-627"), ZONE:New("sp-628"), ZONE:New("sp-629"), ZONE:New("sp-630"),
    ZONE:New("sp-631"), ZONE:New("sp-632"), ZONE:New("sp-633"), ZONE:New("sp-634"), ZONE:New("sp-635"),
    ZONE:New("sp-636"), ZONE:New("sp-637"), ZONE:New("sp-638"), ZONE:New("sp-639"), ZONE:New("sp-640"),
    ZONE:New("sp-641"), ZONE:New("sp-642"), ZONE:New("sp-643"), ZONE:New("sp-644"), ZONE:New("sp-645"),
    ZONE:New("sp-646"), ZONE:New("sp-647"), ZONE:New("sp-648"), ZONE:New("sp-649"), ZONE:New("sp-650"),
    ZONE:New("sp-651"), ZONE:New("sp-652"), ZONE:New("sp-653"), ZONE:New("sp-654"), ZONE:New("sp-655"),
    ZONE:New("sp-656"), ZONE:New("sp-657"), ZONE:New("sp-658"), ZONE:New("sp-659"), ZONE:New("sp-660"),
    ZONE:New("sp-661"), ZONE:New("sp-662"), ZONE:New("sp-663"), ZONE:New("sp-664"), ZONE:New("sp-665"),
    ZONE:New("sp-666"), ZONE:New("sp-667"), ZONE:New("sp-668"), ZONE:New("sp-669"), ZONE:New("sp-670"),
    ZONE:New("sp-671"), ZONE:New("sp-672"), ZONE:New("sp-673"), ZONE:New("sp-674"), ZONE:New("sp-675"),
    ZONE:New("sp-676"), ZONE:New("sp-677"), ZONE:New("sp-678"), ZONE:New("sp-679"), ZONE:New("sp-680"),
    ZONE:New("sp-681"), ZONE:New("sp-682"), ZONE:New("sp-683"), ZONE:New("sp-684"), ZONE:New("sp-685"),
    ZONE:New("sp-686"), ZONE:New("sp-687"), ZONE:New("sp-688"), ZONE:New("sp-689"), ZONE:New("sp-690"),
    ZONE:New("sp-691"), ZONE:New("sp-692"), ZONE:New("sp-693"), ZONE:New("sp-694"), ZONE:New("sp-695"),
    ZONE:New("sp-696"), ZONE:New("sp-697"), ZONE:New("sp-698"), ZONE:New("sp-699"), ZONE:New("sp-700")
}


-- Spawn Ground Units for Red Coalition

env.info("=== GROUND UNIT SPAWN DEBUG ===")
env.info("MAX_RU_MANPADS: " .. MAX_RU_MANPADS)
env.info("RandomSpawnZoneTable size: " .. #RandomSpawnZoneTable)

-- Check if template groups exist
local templateGroups = {
    "RU_MANPADS-1", "RU_AAA-1", "RU_TANK_T90", "RU_TANK_T55", 
    "RU_IFV-1", "RU_IFV-Technicals", "RU_SA-08", "RU_SA-19", "RU_SA-15"
}

for _, templateName in pairs(templateGroups) do
    local template = GROUP:FindByName(templateName)
    if template then
        env.info("✓ Found template: " .. templateName)
    else
        env.info("✗ Missing template: " .. templateName)
    end
end

-- Check spawn zones
local validZones = 0
for i, zone in pairs(RandomSpawnZoneTable) do
    if zone then
        validZones = validZones + 1
    else
        env.info("✗ Invalid zone at index " .. i)
    end
end
env.info("Valid spawn zones: " .. validZones .. "/" .. #RandomSpawnZoneTable)

-- MANPADS Systems
env.info("Spawning MANPADS...")
RandomSpawns_RU_MANPADS = SPAWN:New( "RU_MANPADS-1" )
:InitLimit( MAX_RU_MANPADS, MAX_RU_MANPADS )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Anti-Aircraft Artillery
env.info("Spawning AAA...")
RandomSpawns_RU_AAA = SPAWN:New( "RU_AAA-1" )
:InitLimit( MAX_RU_AAA, MAX_RU_AAA )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Main Battle Tanks
env.info("Spawning T-90 tanks...")
RandomSpawns_RU_TANK_T90 = SPAWN:New( "RU_TANK_T90" )
:InitLimit( MAX_RU_TANK_T90, MAX_RU_TANK_T90 )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

env.info("Spawning T-55 tanks...")
RandomSpawns_RU_TANK_T55 = SPAWN:New( "RU_TANK_T55" )
:InitLimit( MAX_RU_TANK_T55, MAX_RU_TANK_T55 )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Infantry Fighting Vehicles
env.info("Spawning IFVs...")
RandomSpawns_RU_IFV = SPAWN:New( "RU_IFV-1" )
:InitLimit( MAX_RU_IFV, MAX_RU_IFV )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

env.info("Spawning Technical vehicles...")
RandomSpawns_RU_IFV_Technicals = SPAWN:New( "RU_IFV-Technicals" )
:InitLimit( MAX_RU_IFV_Technicals, MAX_RU_IFV_Technicals )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Short Range SAM Systems
env.info("Spawning SA-08 SAMs...")
RandomSpawns_RU_SA08 = SPAWN:New( "RU_SA-08" )
:InitLimit( MAX_RU_SA08, MAX_RU_SA08 )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Medium Range SAM Systems
env.info("Spawning SA-19 SAMs...")
RandomSpawns_RU_SA19 = SPAWN:New( "RU_SA-19" )
:InitLimit( MAX_RU_SA19, MAX_RU_SA19 )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )

-- Long Range SAM Systems0
env.info("Spawning SA-15 SAMs...")
RandomSpawns_RU_SA15 = SPAWN:New( "RU_SA-15" )
:InitLimit( MAX_RU_SA15, MAX_RU_SA15 )
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )


RU_INTERCEPTOR_SPAWN = SPAWN:New("RU_INTERCEPT-1")
:InitLimit( MIN_RU_INTERCEPTORS, MAX_RU_INTERCEPTORS )    
:SpawnScheduled( 3600, 2600  )  -- Spawns every 2600 seconds which is 43 minutes and 20 seconds

RU_INTERCEPTOR_SPAWN = SPAWN:New("RU_INTERCEPT-2")
:InitLimit( MAX_RU_INTERCEPTORS, MAX_RU_INTERCEPTORS )    
:SpawnScheduled( 15000, 2200  )  -- Spawns every 2200 seconds which is 36 minutes and 40 seconds


-- Artillery Systems
--[[
RandomSpawns_RU_ARTY = SPAWN:New( "RU_ARTY-1" )
:InitLimit( MAX_RU_ARTY, MAX_RU_ARTY )
:InitRandomizeTemplate( RandomSpawnZoneTable ) 
:InitRandomizeZones( RandomSpawnZoneTable )
:SpawnScheduled( .1, .5 )
--]]

env.info("Red Ground Forces Spawned")   

env.info("Blue AWACS Spawned")  
USAWACS_SPAWN = SPAWN:New("BLUE-EWR E-3 Focus Group")
:InitLimit( 1, 500 )
:SpawnScheduled( 1, 15  )


env.info("Blue Forces Spawned")  