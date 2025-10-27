-- Moose RU Attack Script
-- Monitors warehouse destruction and activates capture groups

-- Define warehouse-to-capture-group mappings
-- Add or modify entries here for each base
local warehouseGroups = {
    {
        warehouseName = "Luostari Supply",
        captureGroupName = "RU_Luostari_Capture_Group",
        activated = false
    },
    
    {
        warehouseName = "Ivalo Supply",
        captureGroupName = "RU_Ivalo_Capture_Group",
        activated = false
    },
    {
        warehouseName = "Alakurtti Supply",
        captureGroupName = "RU_Alakurtti_Capture_Group",
        activated = false
    },
}

-- Function to check all warehouses and activate corresponding groups
local function CheckWarehouses()
    for i, baseData in ipairs(warehouseGroups) do
        -- Skip if already activated
        if not baseData.activated then
            local warehouse = STATIC:FindByName(baseData.warehouseName)
            
            -- If warehouse doesn't exist or is destroyed
            if warehouse == nil or not warehouse:IsAlive() then
                MESSAGE:New(baseData.warehouseName .. " has been destroyed! Activating capture group...", 15):ToAll()
                
                -- Activate the late activate group
                local captureGroup = GROUP:FindByName(baseData.captureGroupName)
                if captureGroup then
                    captureGroup:Activate()
                    MESSAGE:New("RU forces are moving to secure " .. baseData.warehouseName .. " location!", 15):ToAll()
                    baseData.activated = true
                else
                    env.info("ERROR: Could not find group: " .. baseData.captureGroupName)
                end
            end
        end
    end
end

-- Start a scheduler to check warehouse status every 5 seconds
SCHEDULER:New(nil, CheckWarehouses, {}, 5, 5)

MESSAGE:New("RU Attack Script loaded. Monitoring " .. #warehouseGroups .. " supply warehouse(s)...", 10):ToAll()
