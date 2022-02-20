--[[*]]-- RotatorsLib --[[*]]--

require "rLib.Shared"

rLib.Commands = rLib.Commands or {}

function rLib.Commands.SendToServer(player, cmd, args, dbg)
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(cmd, "string"))
	assert(rLib.arg(args, "table"))

	if dbg then
		rLib.dprint("[rLib.Commands] -> %s : %s", cmd, rLib.tostring(args))
		args._dbg_ = true
	end

	sendClientCommand(player, "rLib", cmd, args)
end

function rLib.Commands.OnServerCommand(module, cmd, player, args)
	--assert(type(module) == "string")

	if module ~= "rLib" then
		return
	end

	assert(rLib.arg(cmd, "string"))
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(args, "table"))

	if args._dbg_ then
		args._dbg_ = nil
		rLib.dprint("[rLib.Commands] <- %s : %s", cmd, rLib.tostring(args))
	end

	local func = "Client_" .. cmd

	if rLib.Commands[func] ~= nil then
		rLib.Commands[func](player, args)
	else
		rLib.dprint("[rLib.Commands] Unknown : " .. cmd)

		assert(not getDebug())
	end
end

Events.OnServerCommand.Add(rLib.Commands.OnServerCommand)

return rLib.Commands
