REGION_MAPPING = {
    ["GR"] = {"@Start Area - Geyser Rock and Sandover Region/Geyser Rock/Orb Bundle",50},
	["SV"] = {"@Start Area - Geyser Rock and Sandover Region/Sandover Village/Orb Bundle",50},
	["SB"] = {"@Start Area - Geyser Rock and Sandover Region/Sentinel Beach/Orb Bundle",150},
	["FJ"] = {"@Start Area - Geyser Rock and Sandover Region/Forbidden Jungle/Orb Bundle",150},
	["MI"] = {"@Misty Island/Misty Island/Orb Bundle",150},
	["FC"] = {"@Fire Canyon/Fire Canyon/Orb Bundle",50},
	["RV"] = {"@Secondary Area - Rock Village Region/Rock Village/Orb Bundle",50},
	["LPC"] = {"@Secondary Area - Rock Village Region/Lost Precursor City/Orb Bundle",200},
	["BS"] = {"@Secondary Area - Rock Village Region/Boggy Swamp/Orb Bundle",200},
	["PB"] = {"@Secondary Area - Rock Village Region/Precursor Basin/Orb Bundle",200},
	["MP"] = {"@Mountain Pass/Mountain Pass/Orb Bundle",50},
	["VC"] = {"@Tertiary Area - Volcanic Crater Region/Volcanic Crater/Orb Bundle",50},
	["SC"] = {"@Tertiary Area - Volcanic Crater Region/Spider Cave/Orb Bundle",200},
	["SM"] = {"@Tertiary Area - Volcanic Crater Region/Snowy Mountain/Orb Bundle",200},
	["LT"] = {"@Lava Tube/Lava Tube/Orb Bundle",50},
	["GMC"] = {"@Gol and Maia's Citadel/Gol and Maia's Citadel/Orb Bundle",200}
}

ORB_REGIONS = {
	"@Orbs/GR/Main",
	"@Orbs/SV/Main",
	"@Orbs/SV/Cache Cliff",
	"@Orbs/SV/Yakow Cliff",
	"@Orbs/SV/Oracle Platform",
	"@Orbs/SB/Main",
	"@Orbs/SB/Green Ridge",
	"@Orbs/SB/Blue Ridge",
	"@Orbs/SB/Cannon Pillars",
	"@Orbs/FJ/Main",
	"@Orbs/FJ/Post Jungle Elevator",
	"@Orbs/FJ/Post Jungle Elevator with Eco",
	"@Orbs/FJ/Post Dark Eco Plant",
	"@Orbs/MI/Main",
	"@Orbs/MI/See Saw Orbs",
	"@Orbs/MI/Orb Cache",
	"@Orbs/MI/Silo Boxes",
	"@Orbs/FC/Main",
	"@Orbs/RV/Main",
	"@Orbs/RV/Orb Cache",
	"@Orbs/RV/Pontoons",
	"@Orbs/RV/Above Pontoons",
	"@Orbs/PB/Main",
	"@Orbs/BS/Main",
	"@Orbs/BS/Flut Flut Orbs",
	"@Orbs/BS/Tether Pillars",
	"@Orbs/LPC/Main",
	"@Orbs/LPC/Orb Cache in First Chamber",
	"@Orbs/MP/Main",
	"@Orbs/VC/Main",
	"@Orbs/SC/Main",
	"@Orbs/SC/Dark Cave",
	"@Orbs/SC/Robot Scaffolding",
	"@Orbs/SM/Main",
	"@Orbs/SM/Precursor Blockers",
	"@Orbs/SM/Yellow Eco Orbs",
	"@Orbs/SM/Flut Flut Orbs",
	"@Orbs/SM/Lurker Infested Cave",
	"@Orbs/SM/Snowy Fort Orbs and Caches",
	"@Orbs/LT/Main",
	"@Orbs/GMC/Main",
	"@Orbs/GMC/Sage Rooms",
	"@Orbs/GMC/Green Sage"
}

-- from https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- dumps a table in a readable string
function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. k .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

function has(item, amount)
	local count = Tracker:ProviderCountForCode(item)
	amount = tonumber(amount)
	if not amount then
		return count > 0
	else
		return count >= amount
	end
end
-- gate 1 = FC
-- gate 2 = MP
-- gate 3 = LT
function cell_gate(x)
	local gate = tonumber(x)
	local Cells = Tracker:ProviderCountForCode("PowerCell")
	local FC = Tracker:ProviderCountForCode("FC_Cells") <= Cells
	local MP = Tracker:ProviderCountForCode("MP_Cells") <= Cells
	local LT = Tracker:ProviderCountForCode("LT_Cells") <= Cells
	if gate == 1 and FC then
		return true
	elseif gate == 2 and FC and MP then
		return true
	elseif gate == 3 and FC and MP and LT then
		return true
	end
end
function orb_trades()
	local citizens = Tracker:FindObjectForCode('Citizen').AcquiredCount*9
	local oracles = Tracker:FindObjectForCode('Oracle').AcquiredCount*6
	local trades = citizens + oracles
	if Tracker:FindObjectForCode('Orb').AcquiredCount >= trades then
		return true
	end
	return false
end

function punch_for_klaww()
	return has("Punch") or not has("HasPunchForKlaww")
end

function little_uppies()
	return has("DoubleJump") or (has("Crouch") and has("CrouchJump")) or has("JumpKick")
end

function some_uppies()
	return has("DoubleJump") or has("JumpKick") or (has("Punch") and has ("PunchUppercut"))
end

function any_uppies()
	return has("DoubleJump") or (has("Crouch") and has("CrouchJump")) or (has("Crouch") and has("CrouchUppercut") and has("JumpKick")) or (has("Punch") and has("PunchUppercut"))
end

function over_and_uppies()
	return has("DoubleJump") or (has("Crouch") and has("CrouchJump")) or (has("Crouch") and has("CrouchUppercut") and has("JumpKick"))
end

function stair_uppies()
	return has("DoubleJump") or has("JumpDive") or (has("Crouch") and has("CrouchJump")) or (has("Crouch") and has("CrouchUppercut"))
end

function long_jumps()
	return (has("DoubleJump") and has("JumpKick")) or (has("Roll") and has("RollJump"))
end

function flybox()
	return has("JumpDive") or (has("Crouch") and has("CrouchUppercut"))
end


function no_rando()
	local MoveRando_enabled = Tracker:FindObjectForCode("MoveRando").Active
	return not MoveRando_enabled
end

function level_orbs_accessible(region)
	local bundle_size = Tracker:FindObjectForCode("BundleSize").AcquiredCount
	if bundle_size < 1 then
		return false
	end
	local loc = REGION_MAPPING[region]
	local location = Tracker:FindObjectForCode(loc[1])
	local bundles_acquired = loc[2]/ bundle_size - location.AvailableChestCount
	
	local orbs = 0
	for _,area in ipairs(ORB_REGIONS) do
		if string.find(area,"@Orbs/".. region) == 1 then
			local location = Tracker:FindObjectForCode(area)
			if location.AccessibilityLevel == AccessibilityLevel.Normal then
				orbs = orbs + location.AvailableChestCount
			end
		end
	end
	bundles_reachable = orbs // bundle_size
	return bundles_reachable > bundles_acquired
end

function global_orbs_accessible()
	local bundle_size = Tracker:FindObjectForCode("BundleSize").AcquiredCount
	if bundle_size < 1 then
		return false
	end
	local location = Tracker:FindObjectForCode("@Global Precursor Orb Bundles/Global Precursor Orb Bundles/Orb Bundle")
	local bundles_acquired = 2000 / bundle_size - location.AvailableChestCount

	local orbs = 0
	for _,area in ipairs(ORB_REGIONS) do
		local location = Tracker:FindObjectForCode(area)
		if location.AccessibilityLevel == AccessibilityLevel.Normal then
			orbs = orbs + location.AvailableChestCount
		end
	end
	bundles_reachable = orbs // bundle_size
	return bundles_reachable > bundles_acquired
	
end

function test()
	print(Tracker:FindObjectForCode("@Fire Canyon/Fire Canyon").AccessibilityLevel)
end

function force_refresh()

end