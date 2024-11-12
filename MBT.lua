-- ************** ADD-ON AAA SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
do
    local _addCrates = {
        ["Ground Forces"] = {
            { weight = 300, desc = "MBT M1A2 Abrams", unit = "M-1 Abrams", side = 2 },
			{ weight = 305, desc = "MBT T-72B", unit = "T-72B", side = 1 },
        },
    }

    -- add extra crate options
    for _subMenuName, _crates in pairs(_addCrates) do

        for _, _crate in pairs(_crates) do
            -- add crate to the menu table
            table.insert(ctld.spawnableCrates[_subMenuName], _crate)
            -- add crate to the lookup table
            ctld.crateLookupTable[tostring(_crate.weight)] = _crate
        end
    end
end