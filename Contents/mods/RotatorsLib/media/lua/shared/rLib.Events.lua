--[[*]]-- RotatorsLib --[[*]]--

require "rLib"

rLib.Events = {}

function rLib.Events.Exists(name)
	assert(rLib.arg(name, "string"))

	return Events["rLib." .. name] ~= nil
end

function rLib.Events.Add(name)
	assert(not rLib.Events.Exists(name), "[rLib.Events.Add] Already registered : " .. name)

	LuaEventManager.AddEvent("rLib." .. name)
	rLib.dprint( "[rLib.Events.Add] Registered : " .. name)

	return true
end

function rLib.Events.Run(name, ...)
	assert(rLib.Events.Exists(name), "[rLib.Events.Run] Unknown : " .. name)

	rLib.Events.Current = name
	triggerEvent("rLib." .. name, ...)
	rLib.Events.Current = nil
end

function rLib.Events.On(name, func)
	assert(rLib.Events.Exists(name), "[rLib.Event.On] : Unknown : " .. name)
	assert(rLib.arg(func, "function"))

	Events["rLib." .. name].Add(func)
end

function rLib.Events.Off(name, func)
	assert(rLib.Events.Exists(name), "[rLib.Event.Off] : Unknown : " .. name)
	assert(rLib.arg(func, "function"))

	Events["rLib." .. name].Remove(func)
end
