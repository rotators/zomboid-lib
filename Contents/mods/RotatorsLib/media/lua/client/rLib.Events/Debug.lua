--[[*]]-- RotatorsLib --[[*]]--

require "DebugUIs/LuaDebugger"

local Vanilla =
{
	DoLuaDebugger = DoLuaDebugger
}

--[[LuaDebugger.lua v41.65]] rLib.Events.Add("Debug.BeforeDebugger")
--[[LuaDebugger.lua v41.65]] rLib.Events.Add("Debug.AfterDebugger")

function DoLuaDebugger(file, line)
	rLib.Events.Run("Debug.BeforeDebugger", file, line)

	Vanilla.DoLuaDebugger(file, line)

	rLib.Events.Run("Debug.AfterDebugger", file, line)
end
