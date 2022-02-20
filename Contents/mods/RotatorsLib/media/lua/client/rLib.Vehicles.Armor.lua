--[[*]]-- RotatorsLib --[[*]]--

require "rLib.Shared"

rLib.Vehicles = rLib.Vehicles or {}
rLib.Vehicles.Armor =
{
	Callback = {}
}

--

function rLib.Vehicles.Armor.ProcessCell(player)
	assert(rLib.arg(player, "IsoPlayer"))

	local result = false

	local vehicles = player:getCell():getVehicles()
	for v=0, vehicles:size()-1 do
		if rLib.Vehicles.Armor.ProcessVehicle(player, vehicles:get(v)) then
			result = true
		end
	end

	return result
end

function rLib.Vehicles.Armor.ProcessVehicle(player, vehicle)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(vehicle, "BaseVehicle"))

	local result = false

	for p=0, vehicle:getPartCount()-1 do
		if rLib.Vehicles.Armor.ProcessPart(player, vehicle, vehicle:getPartByIndex(p)) then
			result = true
		end
	end

	return result
end

function rLib.Vehicles.Armor.ProcessPart(player, vehicle, part)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(vehicle, "BaseVehicle"))
	assert(rLib.arg(part, "VehiclePart"))
	assert(vehicle == part:getVehicle())

	local armor = part:getTable("armor")
	if type(armor) ~= "table" then
		return false
	end

	-- in case someone wants to use `table armor` for their own armor implementation --
	if not armor.logic or (armor.logic ~= "RotatorsLib" and armor.logic ~= "rLib") then
		return false
	end

	local luaTable = armor.lua and type(armor.lua) == "table"

	local check = part:getInventoryItem()

	if luaTable and armor.lua.check then
		check = rLib.lua(armor.lua.check, player, vehicle, part, armor, "check")
	end

	if not check then
		return false
	end

	if armor.needs and type(armor.needs) == "table" then
		if armor.needs.part then
			local guard = vehicle:getPartById(armor.needs.part)

			if not guard or not guard:getInventoryItem() then
				return false
			end

			if armor.needs.condition then
				local condition = tonumber(armor.needs.condition)
				if not condition or guard:getCondition() < condition then
					return false
				end
			end
		end
	end

	local result = false

	if armor.condition then
		local partCondition = tonumber(armor.condition)
		if not partCondition then
			return false
		elseif part:getCondition() < partCondition then
			local repair = true

			if luaTable and armor.lua.repair then
				repair = rLib.lua(armor.lua.repair, player, vehicle, part, armor, "repair")
			end

			if repair then
				--rLib.dprint("[rLib.Vehicles.Armor.ProcessPart] repair %d:%s : %d -> %d", vehicle:getId(), part:getId(), part:getCondition(), partCondition)
				sendClientCommand(player, "vehicle", "setPartCondition", { vehicle = vehicle:getId(), part = part:getId(), condition = partCondition })
			end

			result = true
		end
	end

	return result
end

--

function rLib.Vehicles.Armor.Callback.TrueOnEngine(player, vehicle, part, armor, action)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(vehicle, "BaseVehicle"))
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(armor, "table"))
	assert(rLib.arg(action, "string"))

	return part:getId() == "Engine"
end

function rLib.Vehicles.Armor.Callback.TrueOnZero(player, vehicle, part, armor, action)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(vehicle, "BaseVehicle"))
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(armor, "table"))
	assert(rLib.arg(action, "string"))

	return part:getCondition() <= 0
end

function rLib.Vehicles.Armor.Callback.FalseOnZero(player, vehicle, part, armor, action)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(vehicle, "BaseVehicle"))
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(armor, "table"))
	assert(rLib.arg(action, "string"))

	return part:getCondition() > 0
end

--

local tick = 0

function rLib.Vehicles.Armor.OnPlayerUpdate(player)
	if tick < 250 then
		tick = tick + 1
	else
		tick = 0
	end

	local vehicle = player:getVehicle() or player:getNearVehicle()
	if (vehicle and rLib.Vehicles.Armor.ProcessVehicle(player, vehicle)) or (tick == 0) then
		rLib.Vehicles.Armor.ProcessCell(player)
	end
end

Events.OnPlayerUpdate.Add(rLib.Vehicles.Armor.OnPlayerUpdate)
