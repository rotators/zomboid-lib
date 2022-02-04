require "rLib.Shared"

rLib.Commands = rLib.Commands or {}

function rLib.Commands.Server_TEST_SetVehicleHeadlights(player, args)
	assert(type(args.vehicleId) == "number")
	assert(type(args.set) == "boolean")

	local vehicle = getVehicleById(args.vehicleId)
	if not vehicle then
		return
	end

	vehicle:setHeadlightsOn(args.set)
end

---

function rLib.Commands.SendToClient(cmd, args, dbg)
	assert(type(cmd) == "string")
	assert(type(args) == "table")

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

	assert(type(cmd) == "string")
	assert(instanceof(player, "IsoPlayer"))
	assert(type(args) == "table")

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
