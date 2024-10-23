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
	return has("DoubleJump") or (has("Crouch") and has("CrouchJump")) or (has("Punch") and has("PunchUppercut") and has("JumpKick"))
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

function level_orbs_accessible()
	local regions = {
		"@Orbs/GR/Main",
		"@Orbs/SV/Main",
		"@Orbs/SV/Cache Cliff"
	}
	
	local orbs = 0
	for _,area in ipairs(regions) do
		orbs = orbs + Tracker:GetObjectForCode(area).AvailableChestCount
	end
	-- do some math with bundle size and return true if orbs accessible >= bundle_size
end

function global_orbs_accessible()
	
end

function test()
	print(Tracker:FindObjectForCode("@Fire Canyon/Fire Canyon").AccessibilityLevel)
end