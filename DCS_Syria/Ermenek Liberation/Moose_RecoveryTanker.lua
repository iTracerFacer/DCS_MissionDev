-- RECOVERYTANKER:
-- Simple Recovery tanker script using some customized settings.
-- Tanker will be spawned on the CVN-72 Amraham Lincoln and go on station overhead at angels 6 with 274 knots TAS (~250 KIAS).
-- Radio frequencies, callsign are set below and overrule the settings of the late activated template group.


-- S-3B at USS Stennis spawning on deck.
local tankerLincoln=RECOVERYTANKER:New("CVN-72 Amraham Lincoln", "Texaco Group")

-- Custom settings for radio frequency, TACAN, callsign and modex.
tankerLincoln:SetRadio(261)
tankerLincoln:SetTACAN(37, "SHL")
tankerLincoln:SetCallsign(CALLSIGN.Tanker.Arco, 3)
tankerLincoln:SetModex(0)  -- "Triple nuts"

-- Start recovery tanker.
-- NOTE: If you spawn on deck, it seems prudent to delay the spawn a bit after the mission starts.

