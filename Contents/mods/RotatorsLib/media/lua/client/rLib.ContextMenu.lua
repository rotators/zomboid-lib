--[[*]]-- RotatorsLib --[[*]]--

require "rLib.Shared"

rLib.ContextMenu = {}

function rLib.ContextMenu.GetSub(context, submenuName)
	assert(rLib.arg(submenuName, "string"))

	local var = context:getOptionFromName(submenuName)
	if not var or not var.subOption then
		return nil
	end

	var = var.subOption

	if not context.instanceMap or context.instanceMap[var] == nil then
		return nil
	end

	return context.instanceMap[var]
end

function rLib.ContextMenu.GetSubOption(context, submenuName, optionName)
	assert(rLib.arg(submenuName, "string"))
	assert(rLib.arg(optionName, "string"))

	local submenu = rLib.ContextMenu.GetSub(context, submenuName)
	if not submenu then
		return nil
	end

	return submenu:getOptionFromName(optionName)
end

return rLib.ContextMenu
