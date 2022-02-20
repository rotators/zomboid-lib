--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/ISUI/ISVehicleMenu"

require "rLib.Client"

rLib.ClientAuto = {}

local ISVM_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle

-- required for vehicles which are not using `Base` module --
function rLib.ClientAuto.DebugReloadVehicleTextures(context, vehicle)
	local option = rLib.ContextMenu.GetSubOption(context, "[DEBUG] Vehicle", "Reload Vehicle Textures")

	if option and option.onSelect and option.onSelect == reloadVehicleTextures and option.target then
		option.target = vehicle:getScript():getFullName()
	end
end

if getDebug() then
	function ISVehicleMenu.FillMenuOutsideVehicle(player, context, vehicle, ...)
		ISVM_FillMenuOutsideVehicle(player, context, vehicle, ...)

		rLib.ClientAuto.DebugReloadVehicleTextures(context, vehicle)
	end
end

return rLib.ClientAuto
