-- this is an example/ default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via thier ids
-- it will also load the AP slot data in the global SLOT_DATA, keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
	Tracker:FindObjectForCode('Orb').AcquiredCount = 0
	if slot_data["fire_canyon_cell_count"] then
		Tracker:FindObjectForCode('FC_Cells').AcquiredCount = slot_data["fire_canyon_cell_count"]
	end
	
	if slot_data["mountain_pass_cell_count"] then
		Tracker:FindObjectForCode('MP_Cells').AcquiredCount = slot_data["mountain_pass_cell_count"]
	end
	
	if slot_data["lava_tube_cell_count"] then
		Tracker:FindObjectForCode('LT_Cells').AcquiredCount = slot_data["lava_tube_cell_count"]
	end
	if slot_data["enable_move_randomizer"] then
		Tracker:FindObjectForCode('MoveRando').Active = slot_data["enable_move_randomizer"]
		if slot_data["enable_move_randomizer"] then
			Tracker:AddLayouts("layouts/moves.json")
        end
	end
	if slot_data["citizen_orb_trade_amount"] then
		Tracker:FindObjectForCode('Citizen').AcquiredCount = slot_data["citizen_orb_trade_amount"]
	end
	if slot_data["oracle_orb_trade_amount"] then
		Tracker:FindObjectForCode('Oracle').AcquiredCount = slot_data["oracle_orb_trade_amount"]
	end
    if slot_data["jak_completion_condition"] then
		local Goal = slot_data["jak_completion_condition"]
		local item = Tracker:FindObjectForCode('Goal')
		if Goal == 69 then item.CurrentStage = 2
		elseif Goal == 87 then item.CurrentStage = 4
		elseif Goal == 89 then item.CurrentStage = 5
		elseif Goal == 6 then item.CurrentStage = 1
		elseif Goal == 86 then item.CurrentStage = 3
		elseif Goal == 112 then item.CurrentStage = 7
		elseif Goal == 116 then item.CurrentStage = 6
		end
	end
	
	if slot_data["enable_orbsanity"] then
		local Mode = slot_data["enable_orbsanity"]
        Tracker:FindObjectForCode('Orbsanity_Mode').CurrentStage = Mode + 1
		if Mode == 1 then
			Tracker:FindObjectForCode('BundleSize').AcquiredCount = slot_data["level_orbsanity_bundle_size"]
            local sections = {
                "@Start Area - Geyser Rock and Sandover Region/Geyser Rock/Orb Bundle",
                "@Start Area - Geyser Rock and Sandover Region/Sandover Village/Orb Bundle",
                "@Start Area - Geyser Rock and Sandover Region/Sentinel Beach/Orb Bundle",
                "@Start Area - Geyser Rock and Sandover Region/Forbidden Jungle/Orb Bundle",
                "@Misty Island/Misty Island/Orb Bundle",
                "@Fire Canyon/Fire Canyon/Orb Bundle",
                "@Secondary Area - Rock Village Region/Rock Village/Orb Bundle",
                "@Secondary Area - Rock Village Region/Lost Precursor City/Orb Bundle",
                "@Secondary Area - Rock Village Region/Boggy Swamp/Orb Bundle",
                "@Secondary Area - Rock Village Region/Precursor Basin/Orb Bundle",
                "@Mountain Pass/Mountain Pass/Orb Bundle",
                "@Tertiary Area - Volcanic Crater Region/Volcanic Crater/Orb Bundle",
                "@Tertiary Area - Volcanic Crater Region/Spider Cave/Orb Bundle",
                "@Tertiary Area - Volcanic Crater Region/Snowy Mountain/Orb Bundle",
                "@Lava Tube/Lava Tube/Orb Bundle",
                "@Gol and Maia's Citadel/Gol and Maia's Citadel/Orb Bundle",
            }
            for _,section in ipairs(sections) do
                local LevelOrbs = Tracker:FindObjectForCode(section)
                LevelOrbs.AvailableChestCount = LevelOrbs.AvailableChestCount / Tracker:FindObjectForCode('BundleSize').AcquiredCount
            end
		elseif Mode == 2 then
			Tracker:FindObjectForCode('BundleSize').AcquiredCount = slot_data["global_orbsanity_bundle_size"]     
            local GlobalOrbs = Tracker:FindObjectForCode('@Global Precursor Orb Bundles/Global Precursor Orb Bundles/Orb Bundle')
            GlobalOrbs.AvailableChestCount = GlobalOrbs.AvailableChestCount / Tracker:FindObjectForCode('BundleSize').AcquiredCount
		end


	end

    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    -- manually run snes interface functions after onClear in case we are already ingame
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
	print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
	
    local OrbCheck1 = string.sub(item_name, -4, -1)
    local OrbCheck2 = string.sub(item_name, -3, -1)

    if OrbCheck1 == "Orbs" then
		local BundleSize = Tracker:FindObjectForCode('BundleSize').AcquiredCount
		Tracker:FindObjectForCode('Orb').AcquiredCount = Tracker:FindObjectForCode('Orb').AcquiredCount + BundleSize
	end
    if OrbCheck2 == "Orb" then
		local BundleSize = Tracker:FindObjectForCode('BundleSize').AcquiredCount
		Tracker:FindObjectForCode('Orb').AcquiredCount = Tracker:FindObjectForCode('Orb').AcquiredCount + BundleSize
	end

    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
    end
end	
-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    
    end   
    if not string.find(location_name, "Bundle") == nil then
        local obj = Tracker:FindObjectForCode("force_refresh")
        obj.Active = not obj.Active
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
