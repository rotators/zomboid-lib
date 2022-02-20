--[[*]]-- RotatorsLib --[[*]]--

require "rLib.Shared"

rLib.Commands = rLib.Commands or {}

function rLib.Commands.Server_SetVehicleBattery(player, args)
	assert(rLib.arg(args.vehicleId, "number"))
	assert(rLib.arg(args.battery, "number"))

	local vehicle = getVehicleById(args.vehicleId)
	if not vehicle then
		return
	end

	local partId = "Battery"
	if rLib.arg(args.partId, "string") then
		partId = args.partId
	end

	local part = vehicle:getPartById(partId)
	if not part then
		return
	end

	local inv = part:getInventoryItem()
	if not inv then
		return
	end

	inv:setUsedDelta(args.battery)
	vehicle:transmitPartUsedDelta(part)
end

function rLib.Commands.Server_SetVehicleHeadlights(player, args)
	assert(rLib.arg(args.vehicleId, "number"))
	assert(rLib.arg(args.set, "boolean"))

	local vehicle = getVehicleById(args.vehicleId)
	if not vehicle then
		return
	end

	vehicle:setHeadlightsOn(args.set)
end

---

function rLib.Commands.SendToClient(cmd, args, dbg)
	assert(rLib.arg(cmd, "string"))
	assert(rLib.arg(args, "table"))

	if type(dbg) == "boolean" and dbg then
		rLib.dprint("[rLib.Commands] => %s : %s", cmd, rLib.tostring(args))
		args._dbg_ = true
	end

	sendServerCommand("rLib", cmd, args)
end

function rLib.Commands.OnClientCommand(module, cmd, player, args)
	--assert(type(module) == "string")

	if module ~= "rLib" then
		return
	end

	assert(rLib.arg(cmd, "string"))
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(args, "table"))

	if args._dbg_ then
		args._dbg_ = nil
		rLib.dprint("[rLib.Commands] <= %s : %s", cmd, rLib.tostring(args))
	end

	local func = "Server_" .. cmd

	if rLib.Commands[func] ~= nil then
		rLib.Commands[func](player, args)
	else
		rLib.dprint("[rLib.Commands] Unknown : " .. cmd)

		assert(not getDebug())
	end
end

Events.OnClientCommand.Add(rLib.Commands.OnClientCommand)
