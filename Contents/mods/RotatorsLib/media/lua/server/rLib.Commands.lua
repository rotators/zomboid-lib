require "rLib.Shared"

rLib.Commands = rLib.Commands or {}

function rLib.Commands.Server_TEST_SynchTrailerHeadlights(player, args)
	assert(type(args.vehicleId) == "number")

	local vehicle = getVehicleById(args.vehicleId)
	if not vehicle then
		return
	end

	local vehicleTowed = vehicle:getVehicleTowing()
	if not vehicleTowed then
		return
	end

	vehicleTowed:setHeadlightsOn(vehicle:getHeadlightsOn())

	--[[
	local enable = vehicle:getHeadlightsOn()

	for p=0, vehicleTowed:getPartCount()-1 do
		local part = vehicleTowed:getPartByIndex(p)
		if part and part:getInventoryItem() and part:getLight() then
			rLib.dprint("%s = %s", part:getId(), tostring(enable))
			part:setLightActive(enable)
		end
	end
	]]--
end

function rLib.Commands.SendToClient(cmd, args, dbg)
	assert(type(cmd) == "string")
	assert(type(args) == "table")

	if type(dbg) == "boolean" and dbg then
		rLib.dprint("[rLib.Commands] -> %s : %s", cmd, rLib.tostring(args))
		args._dbg_ = true
	end

	sendServerCommand("rLib", cmd, args)
end

function rLib.Commands.OnClientCommand(module, cmd, player, args)
	--assert(type(module) == "string")

	if module ~= "rLib" then
		return
	end

	assert(type(cmd) == "string")
	assert(instanceof(player, "IsoPlayer"))
	assert(type(args) == "table")

	if args._dbg_ then
		args._dbg_ = nil
		rLib.dprint("[rLib.Commands] <- %s %s", cmd, tostring(args))
	end

	local func = "Server_" .. cmd

	if rLib.Commands[func] ~= nil then
		rLib.Commands[func](player, args)
	else
		rLib.dprint("[rLib.Commands] Unknown command '%s'", cmd)

		local r = rLib
		assert(not getDebug(), "!")
	end
end

Events.OnClientCommand.Add(rLib.Commands.OnClientCommand)
