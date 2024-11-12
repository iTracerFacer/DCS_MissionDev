-- ************** ADD-ON AAA SPAWNABLE CRATES ******************
-- Weights must be unique as we use the weight to change the cargo to the correct unit
-- when we unpack
--
do
    local _addCrates = {
        ["AA Crates"] = {
            { weight = 421, desc = "AAA Vulcan", unit = "Vulcan", side = 2, cratesRequired = 1 },
            { weight = 422, desc = "AAA Gepard", unit = "Gepard", side = 2, cratesRequired = 2 },
            { weight = 423, desc = "AAA ZU-23", unit = "Ural-375 ZU-23", side = 1, cratesRequired = 1 },
            { weight = 424, desc = "AAA ZSU-23-4 Shilka", unit = "ZSU-23-4 Shilka", side = 1, cratesRequired = 2 },
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