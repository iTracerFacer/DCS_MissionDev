---
-- Name: AID-CGO-250 - Helicopter - Front-Line Enforcements
-- Author: FlightControl
-- Date Created: 20 Sep 2018
--
-- Demonstrates the way how front-line enforcements can be setup using helicopter transportations.

local SetCargoInfantry = SET_CARGO:New():FilterTypes( "RU_Infantry" ):FilterStart()
local SetHelicopter = SET_GROUP:New():FilterPrefixes( "RU_Helicopter" ):FilterStart()
local SetPickupZones = SET_ZONE:New():FilterPrefixes( "Pickup" ):FilterStart()
local SetDeployZones = SET_ZONE:New():FilterPrefixes( "CZ" ):_FilterStart()

AICargoDispatcherHelicopter = AI_CARGO_DISPATCHER_HELICOPTER:New( SetHelicopter, SetCargoInfantry, SetPickupZones, SetDeployZones ) 
AICargoDispatcherHelicopter:SetHomeZone( ZONE:FindByName( "Home" ) )


-- Here we setup the spawning of Infantry.
SpawnCargoInfantry = SPAWN
  :New( "RU_Infantry" )
  :InitLimit( 20, 4000 )
  :InitRandomizeZones( { ZONE_POLYGON:NewFromGroupName( "Pickup Location Gazipasa" ) } )
  :OnSpawnGroup(
    function( SpawnGroup )
      -- This will automatically add also the CargoInfantry object to the SetCargoInfantry (in the background through the event system).
      local CargoInfantry = CARGO_GROUP:New( SpawnGroup, "RU_Infantry", SpawnGroup:GetName(), 150 )
    end
  )

  --:SpawnScheduled( 300, 0.5 )
  -- SpawnScheduled broken when using OnSpawnGroup() function. Not sure why. To get around this control spawn via mission editor trigger (when zone is empty, spawn a new group) 
  
  SpawnCargoInfantry:Spawn() -- Spawn the initial one. The rest are spawned via ME trigger. (probably a better way to do that but I'm lazy).

 

-- Now we create 4 zones based on GROUP objects within the battlefield, which form the front line defense points.
--local ZoneDefense1 = ZONE_GROUP:New( "Defense 1", GROUP:FindByName("Defense #001"), 1500 )
--local ZoneDefense2 = ZONE_GROUP:New( "Defense 2", GROUP:FindByName("Defense #002"), 1500 )
--local ZoneDefense3 = ZONE_GROUP:New( "Defense 3", GROUP:FindByName("Defense #003"), 1500 )
--local ZoneDefense4 = ZONE_GROUP:New( "Defense 4", GROUP:FindByName("Defense #004"), 1500 )

  local ZoneDefense1 = ZONE:New("CZ1")
  local ZoneDefense2 = ZONE:New("CZ2")
  local ZoneDefense3 = ZONE:New("CZ3")
  local ZoneDefense4 = ZONE:New("CZ4")
  local ZoneDefense5 = ZONE:New("CZ5")
  local ZoneDefense6 = ZONE:New("CZ6")
  local ZoneDefense7 = ZONE:New("CZ7")
  local ZoneDefense8 = ZONE:New("CZ8")
  local ZoneDefense9 = ZONE:New("CZ9")
  local ZoneDefense10 = ZONE:New("CZ10")
  local ZoneDefense11 = ZONE:New("CZ12")
  local ZoneDefense12 = ZONE:New("CZ13")
  local ZoneDefense13 = ZONE:New("CZ13")
  local ZoneDefense14 = ZONE:New("GAZIPAS")

    
    

-- Here we setup the spawning of Helicopters.



--- Pickup Handler OnAfter for AICargoDispatcherHelicopter.
-- Use this event handler to tailor the event when a CarrierGroup is routed towards a new pickup Coordinate and a specified Speed.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- @param #AICargoDispatcherAirplanes self
-- @param #string From A string that contains the "*from state name*" when the event was fired.
-- @param #string Event A string that contains the "*event name*" when the event was fired.
-- @param #string To A string that contains the "*to state name*" when the event was fired.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Core.Point#COORDINATE Coordinate The coordinate of the pickup location.
-- @param #number Speed The velocity in meters per second on which the CarrierGroup is routed towards the pickup Coordinate.
-- @param #number Height Height in meters to move to the pickup coordinate.
function AICargoDispatcherHelicopter:OnAfterPickup( From, Event, To, CarrierGroup, Coordinate, Speed, Height, PickupZone )

  -- Write here your own code.
--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName().. " is picking up cargo. There are " .. AvailableHelis .. " chopers in the air providing reinforcements! Protect the helos!.", MESSAGE.Type.Information ):ToRed()
  

end


--- Load Handler OnAfter for AICargoDispatcherHelicopter.
-- Use this event handler to tailor the event when a CarrierGroup has initiated the loading or boarding of cargo within reporting or near range.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- @param #AICargoDispatcherHelicopter self
-- @param #string From A string that contains the "*from state name*" when the event was fired.
-- @param #string Event A string that contains the "*event name*" when the event was fired.
-- @param #string To A string that contains the "*to state name*" when the event was fired.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
function AICargoDispatcherHelicopter:OnAfterLoad( From, Event, To, CarrierGroup )
-- SpawnCargoInfantry:Spawn()
  -- Write here your own code.
--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName().. " is loading cargo.", MESSAGE.Type.Information ):ToAll()
  
end


--- Loaded event handler OnAfter for AICargoDispatcherHelicopter.
-- Use this event handler to tailor the event when a CarrierUnit of a CarrierGroup has loaded a cargo object.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- Note that if more cargo objects were loading or boarding into the CarrierUnit, then this event can be triggered multiple times for each different Cargo/CarrierUnit.
-- A CarrierUnit can be part of the larger CarrierGroup.
-- @param #AICargoDispatcherHelicopter self
-- @param #string From A string that contains the "*from state name*" when the event was triggered.
-- @param #string Event A string that contains the "*event name*" when the event was triggered.
-- @param #string To A string that contains the "*to state name*" when the event was triggered.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Cargo.Cargo#CARGO Cargo The cargo object.
-- @param Wrapper.Unit#UNIT CarrierUnit The carrier unit that is executing the cargo loading operation.
-- @param Core.Zone#ZONE_AIRBASE PickupZone (optional) The zone from where the cargo is picked up. Note that the zone is optional and may not be provided, but for AI_CARGO_DISPATCHER_AIRBASE there will always be a PickupZone, as the pickup location is an airbase zone.
function AICargoDispatcherHelicopter:OnAfterLoaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, PickupZone )

  -- Write here your own code.
--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName().. " has loaded cargo " .. Cargo:GetName(), MESSAGE.Type.Information ):ToAll()

end

--- Deploy Handler OnAfter for AI_CARGO_DISPATCHER.
-- Use this event handler to tailor the event when a CarrierGroup is routed to a deploy coordinate, to Unload all cargo objects in each CarrierUnit.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- @function OnAfterPickedUp
-- @param self
-- @param #string From A string that contains the "*from state name*" when the event was fired.
-- @param #string Event A string that contains the "*event name*" when the event was fired.
-- @param #string To A string that contains the "*to state name*" when the event was fired.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Core.Point#COORDINATE Coordinate The deploy coordinate.
-- @param #number Speed The velocity in meters per second on which the CarrierGroup is routed towards the deploy Coordinate.
-- @param #number Height Height in meters to move to the deploy coordinate.
-- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
function AICargoDispatcherHelicopter:OnAfterDeploy( From, Event, To, CarrierGroup, Coordinate, Speed, Height, DeployZone )

--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName().. " is starting deployment of all cargo in zone " .. DeployZone:GetName(), MESSAGE.Type.Information ):ToAll()

end


--- Unloaded Handler OnAfter for AI_CARGO_DISPATCHER.
-- Use this event handler to tailor the event when a CarrierUnit of a CarrierGroup has unloaded a cargo object.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- Note that if more cargo objects were unloading or unboarding from the CarrierUnit, then this event can be fired multiple times for each different Cargo/CarrierUnit.
-- A CarrierUnit can be part of the larger CarrierGroup.
-- @function OnAfterUnloaded
-- @param #AICargoDispatcherHelicopter self
-- @param #string From A string that contains the "*from state name*" when the event was fired.
-- @param #string Event A string that contains the "*event name*" when the event was fired.
-- @param #string To A string that contains the "*to state name*" when the event was fired.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Cargo.Cargo#CARGO Cargo The cargo object.
-- @param Wrapper.Unit#UNIT CarrierUnit The carrier unit that is executing the cargo unloading operation.
-- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
function AICargoDispatcherHelicopter:OnAfterUnloaded( From, Event, To, CarrierGroup, Cargo, CarrierUnit, DeployZone )

  local CargoGroup = Cargo:GetObject() -- Wrapper.Group#GROUP
  
  -- Get the name of the DeployZone
  local DeployZoneName = DeployZone:GetName()
  
  local DeployBuildingNames = {
    ["Deploy A"] = "Building A",
    ["Deploy B"] = "Building B",
    ["Deploy C"] = "Building C",
    }
  
  
  -- Now board the infantry into the respective warehouse building.
  if DeployZoneName then
    local Building = STATIC:FindByName( DeployBuildingNames[DeployZoneName] )
    Cargo:__Board( 5, Building, 25 )
  end

--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName() .. ", Unit " .. CarrierUnit:GetName() .. " has unloaded cargo " .. Cargo:GetName() .. " in zone " .. DeployZone:GetName() .. " and cargo is moving to building " .. DeployBuildingNames[DeployZoneName], MESSAGE.Type.Information ):ToAll()


end


--- Deployed Handler OnAfter for AI_CARGO_DISPATCHER.
-- Use this event handler to tailor the event when a carrier has deployed all cargo objects from the CarrierGroup.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- @function OnAfterDeployed
-- @param #AICargoDispatcherHelicopter self
-- @param #string From A string that contains the "*from state name*" when the event was fired.
-- @param #string Event A string that contains the "*event name*" when the event was fired.
-- @param #string To A string that contains the "*to state name*" when the event was fired.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Core.Zone#ZONE DeployZone The zone wherein the cargo is deployed. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
function AICargoDispatcherHelicopter:OnAfterDeployed( From, Event, To, CarrierGroup, DeployZone )

--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName() .. " deployed all cargo in zone " .. DeployZone:GetName(), MESSAGE.Type.Information ):ToAll()

end


--- Home event handler OnAfter for AICargoDispatcherHelicopter.
-- Use this event handler to tailor the event when a CarrierGroup is returning to the HomeZone, after it has deployed all cargo objects from the CarrierGroup.
-- You can use this event handler to post messages to players, or provide status updates etc.
-- If there is no HomeZone is specified, the CarrierGroup will stay at the current location after having deployed all cargo.
-- @param #AICargoDispatcherHelicopter self
-- @param #string From A string that contains the "*from state name*" when the event was triggered.
-- @param #string Event A string that contains the "*event name*" when the event was triggered.
-- @param #string To A string that contains the "*to state name*" when the event was triggered.
-- @param Wrapper.Group#GROUP CarrierGroup The group object that contains the CarrierUnits.
-- @param Core.Point#COORDINATE Coordinate The home coordinate the Carrier will arrive and stop it's activities.
-- @param #number Speed The velocity in meters per second on which the CarrierGroup is routed towards the home Coordinate.
-- @param #number Height Height in meters to move to the home coordinate.
-- @param Core.Zone#ZONE HomeZone The zone wherein the carrier will return when all cargo has been transported. This can be any zone type, like a ZONE, ZONE_GROUP, ZONE_AIRBASE.
function AICargoDispatcherHelicopter:OnAfterHome( From, Event, To, CarrierGroup, Coordinate, Speed, Height, HomeZone )

--  MESSAGE:NewType( "Group " .. CarrierGroup:GetName() .. " deployed all cargo and going home to zone " .. HomeZone:GetName(), MESSAGE.Type.Detailed ):ToAll()

end


AICargoDispatcherHelicopter:SetPickupRadius( 30, 10 )
AICargoDispatcherHelicopter:SetDeployRadius( 5, 2 )
AICargoDispatcherHelicopter:SetPickupSpeed( 300, 200 )
AICargoDispatcherHelicopter:SetDeploySpeed( 300, 200 )
AICargoDispatcherHelicopter:SetPickupHeight( 100, 30 )
AICargoDispatcherHelicopter:SetDeployHeight( 100, 30 )


AICargoDispatcherHelicopter:__Start( 10 )
