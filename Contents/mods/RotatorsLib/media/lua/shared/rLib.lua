--[[*]]-- RotatorsLib --[[*]]--

require "ISBaseObject"

rLib = ISBaseObject:derive("rLib")

--

function rLib.nop()
end

-- log --

function rLib.dprint(text, ...)
	if getDebug() then
		rLib.print(text, ...)
	else
		rLib.dprint = rLib.nop
	end
end

function rLib.print(text, arg, ...)
	assert(rLib.arg(text, "string"))

	if arg ~= nil then
		text = string.format(text, arg, ...)
	end

	print(text)
end

-- spam --

function rLib.dhalo(player, text, ...)
	if getDebug() then
		rLib.halo(player, text, ...)
	else
		rLib.dhalo = rLib.nop
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

-- util --

function rLib.tostring(arg)
	local result = ""

	if type(arg) == "table" then
		result = "{"
		local comma = ""
		for var,val in pairs(arg) do
			result = result .. comma .. " " .. var .. " = " .. rLib.tostring(val)
			comma = ","
		end
		result = result .. " }"
	else
		result = tostring(arg)
	end

	return result
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

function rLib.mod(name)
	assert(rLib.arg(name, "string"))

	return ActiveMods.getById("currentGame"):isModActive(name)
end

function rLib.modinfo(name, info, multi)
	assert(rLib.arg(name, "string"))
	assert(rLib.arg(info, "string"))
	assert(rLib.arg(multi, "boolean", "nil"))

	if type(multi) == "nil" then
		multi = false
	end

	local result = multi and {} or nil

	if not rLib.mod(name) then
		return result
	end

	local file = getModFileReader(name, "mod.info", false)
	if file then
		result = rLib.modinfoget(file, info, multi)
		file:close()
	end

	return result
end

--[[ wip/unreliable
function rLib.modinfoself(info, multi)
	assert(rLib.arg(info, "string"))
	assert(rLib.arg(multi, "boolean", "nil"))

	local coro = getCurrentCoroutine()
	local func = getCoroutineCallframeStack(coro, 1)
	local file = getFilenameOfCallframe(func)
	local path = string.split(file, "/")

	if type(multi) == "nil" then
		multi = false
	end

	local result = multi and {} or nil

	local modinfo = nil
	while #path > 0 do
		table.remove(path)
		local filename = table.concat(path, "/") .. "/mod.info"
		if fileExists(filename) then
			modinfo = filename
			break
		end
	end

	if modinfo then
		file = getGameFilesInput(modinfo)
		if file then
			result = rLib.modinfoget(file, info, multi)
			file:close()
			endFileInput()
		end
	end

	return result
end
]]--

function rLib.modinfoget(file, info, multi)
	assert(rLib.arg(file, "BufferedReader", "DataInputStream"))
	assert(rLib.arg(info, "string"))
	assert(rLib.arg(multi, "boolean"))

	local result = multi and {} or nil

	local line = ""
	while line do
		local sline = string.split(line, "=")

		if #sline >= 2 then
			if string.lower(sline[1]) == string.lower(info) then
				local text = string.sub(line, string.find(line, "=") + 1)
				if multi then
					table.insert(result, text)
				else
					result = text
					break
				end
			end
		end

		line = file:readLine()
	end

	return result
end

function rLib.modversion(name)
	assert(rLib.arg(name, "string"))

	local result = nil
	local text = rLib.modinfo(name, "modversion", false)
	if text then
		result = tonumber(text)
	end

	return result
end

-- debug --

function rLib.arg(obj, ...)
	local varargs = {...}
	for _,t in ipairs(varargs) do
		if type(t) == "string" and (type(obj) == t or instanceof(obj, t)) then
			return true
		end
	end

	return false, "[rLib] Invalid argument : expected '" .. table.concat(varargs, "' or '") .. "'"
end

function rLib.g(obj)
	if getDebug() then
		local zombie = zombie
		local java = java
		local g = _G
		rLib.breakpoint()
		rLib.nop()
	else
		rLib.g = rLib.nop
	end
end

function rLib.callstack()
	local result = {}

	local coro = getCurrentCoroutine()
	for f=1, getCallframeTop(coro)-1 do
		local func = getCoroutineCallframeStack(coro, f)
		if func then
			local file = getFilenameOfCallframe(func) or "(unknown)"

			table.insert(result, {func = func, file = file ~= "(unknown)" and getShortenedFilename(file) or file, line = getLineNumber(func)})
		end
	end

	return result
end

function rLib.dumpstack()
	local callstack = rLib.callstack()
	for _,f in ipairs(callstack) do
		rLib.dprint(rLib.tostring(f))
	end
end

function rLib.breakpoint()
	local coro = getCurrentCoroutine()
	local func = getCoroutineCallframeStack(coro, 1)
	local file = getFilenameOfCallframe(func)
	local line = getLineNumber(func)
	local what = "attempt "

	if getDebug() and rLib.Events.Exists("Debug.BeforeDebugger") then
		what = "add "
		toggleBreakpoint(file, line)
		rLib.Events.On("Debug.BeforeDebugger", rLib.clearpoint)
	end
	rLib.print("[rLib] Breakpoint %s: %s:%d", what, getShortenedFilename(file), line)
end

function rLib.clearpoint(file, line)
	if not rLib.Events.Current then
		return
	end

	toggleBreakpoint(file, line)
	rLib.Events.Off("Debug.BeforeDebugger", rLib.clearpoint)
	rLib.print("[rLib] Breakpoint del: %s:%d", getShortenedFilename(file), line)
end

--

return rLib
