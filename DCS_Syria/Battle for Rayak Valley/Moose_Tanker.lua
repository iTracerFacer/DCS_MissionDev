-- Create the Blue TANKER 130 spawn object
Blue_Tanker_130 = SPAWN:New("TANKER 130")
    :InitLimit(1, 99)

-- Function to spawn the TANKER 130
function SpawnTanker130()
    Blue_Tanker_130:Spawn()
end


-- Create the Blue TANKER spawn objects
Blue_Tanker = SPAWN:New("TANKER 135")
  :InitLimit(1, 99)

Blue_Tanker_MPRS = SPAWN:New("TANKER 135 MPRS")
  :InitLimit(1, 99)
  

-- Function to spawn the tankers
function SpawnTanker()
  Blue_Tanker:Spawn()
end

function SpawnTankerMPRS()
  Blue_Tanker_MPRS:Spawn()
end

-- Create a mission menu for requesting the tankers


MenuCoalitionBlue = MENU_COALITION:New(coalition.side.BLUE, "Request TANKER", missionMenu)
MenuCoalitionBlueTanker = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch TANKER 135", MenuCoalitionBlue, SpawnTanker)
MenuCoalitionBlueTankerMPRS = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch TANKER 135 MPRS", MenuCoalitionBlue, SpawnTankerMPRS)
MenuCoalitionBlueTanker130 = MENU_COALITION_COMMAND:New(coalition.side.BLUE, "Launch TANKER 130", MenuCoalitionBlue, SpawnTanker130)
