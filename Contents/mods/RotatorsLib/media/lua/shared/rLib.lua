require "ISBaseObject"

rLib = ISBaseObject:derive("rLib")

function rLib.dprint(text)
	if getDebug() then
		rLib.printf(text)
	end
end

function rLib.dprintf(text, ...)
	if getDebug() then
		rLib.printf(text, ...)
	end
end

function rLib.printf(text, ...)
	if type(name) ~= "string" then
		return
	end

	print(string.format(text, ...))
end

function rLib.IsMod(name)
	if type(name) ~= "string" then
		return false
	end

	return ActiveMods.getById("currentGame"):isModActive(name)
end

return rLib
