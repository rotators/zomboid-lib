require "ISBaseObject"

rLib = ISBaseObject:derive("rLib")

--

function rLib.dprint(text, ...)
	if getDebug() then
		rLib.print(text, ...)
	end
end

function rLib.print(text, arg, ...)
	assert(type(text) == "string")

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
	assert(instanceof(player, "IsoPlayer"))
	assert(type(text) == "string")

	if arg ~= nil then
		text = string.format(text, arg, ...)
	end

	player:setHaloNote(text)
end

--

function rLib.tostring(arg)
	local result = ""

	if type(arg) == "table" then
		result = "{"
		for var,val in pairs(arg) do
			result = result .. " " .. var .. "=" .. tostring(val)
			first = false
		end
		result = result .. " }"
	else
		result = tostring(arg)
	end

	return result
end

--

function rLib.mod(name)
	assert(type(name) == "string")

	return ActiveMods.getById("currentGame"):isModActive(name)
end

--

return rLib
