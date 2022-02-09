require "ISBaseObject"

rLib = ISBaseObject:derive("rLib")

--

function rLib.dprint(text, ...)
	if getDebug() then
		rLib.print(text, ...)
	end
end

function rLib.print(text, arg, ...)
	assert(rLib.arg(text, "string"))

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
	assert(rLib.arg(player, "IsoPlayer"))
	assert(rLib.arg(text, "string"))

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
			result = result .. " " .. var .. "=" .. rLib.tostring(val)
			first = false
		end
		result = result .. " }"
	else
		result = tostring(arg)
	end

	return result
end

function rLib.arg(obj, typeName)
	return type(obj) == typeName or instanceof(obj, typeName), "[rLib] Invalid argument : expected " .. typeName
end

function rLib.lua(funcName, ...)
	assert(rLib.arg(funcName, "string"))

	local func = _G
	local sections = funcName:split("\\.")
	for s=1,#sections do
		func = func[sections[s]]
		if type(func) ~= "function" and type(func) ~= "table" then
			assert(not getDebug(), "[rLib] invalid lua function name : " .. funcName)
			break
		end
	end

	if type(func) == "function" then
		return func(...)
	end
end

--

function rLib.mod(name)
	assert(rLib.arg(name, "string"))

	return ActiveMods.getById("currentGame"):isModActive(name)
end

--

function rLib.breakpoint()
	local coro = getCurrentCoroutine()
	local func = getCoroutineCallframeStack(coro, 1)
	local file = getFilenameOfCallframe(func)
	local line = getLineNumber(func)

	if getDebug() and rLib.Events.Exists("Debugger.BeforeDebugger") then
		toggleBreakpoint(file, line)
		rLib.Events.On("Debug.BeforeDebugger", rLib.clearpoint)
	else
		rLib.print("[rLib] Breakpoint attempt : %s:%d", file, line)
	end
end

function rLib.clearpoint(file, line)
	if not rLib.Events.Current then
		return
	end

	toggleBreakpoint(file, line)
	rLib.Events.Off("Debug.BeforeDebugger", rLib.clearpoint)
end

--

return rLib
