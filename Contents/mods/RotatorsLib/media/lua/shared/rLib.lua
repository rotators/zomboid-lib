require "ISBaseObject"

rLib = ISBaseObject:derive("rLib")

--

function rLib.dprint(text, ...)
	if getDebug() then
		rLib.print(text, ...)
	end
end

function rLib.print(text, arg, ...)
	if type(text) ~= "string" then
		return
	end

	if arg ~= nil then
		text = string.format(text, arg, ...)
	end

	print(text)
end

--

function rLib.dhalo(player, text, ...)
	if getDebug() then
		rLib.halo(player, text, ...)
	end
end

function rLib.halo(player, text, arg, ...)
	if not player or type(text) ~= "string" then
		return
	end

	if arg ~= nil then
		text = string.format(text, arg, ...)
	end

	player:setHaloNote(text)
end

--

function rLib.mod(name)
	if type(name) ~= "string" then
		return false
	end

	return ActiveMods.getById("currentGame"):isModActive(name)
end

--

return rLib
