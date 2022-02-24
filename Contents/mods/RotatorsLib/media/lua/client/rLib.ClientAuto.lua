--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/ISUI/ISVehicleMenu"

require "rLib.Client"

rLib.ClientAuto = {}

local ISVM_FillMenuOutsideVehicle = ISVehicleMenu.FillMenuOutsideVehicle

local function gTableSafeGet(...)
	local var = _G
	for _,val in ipairs({...}) do
		if var[val] == nil then
			return nil
		end
		var = var[val]
	end

	return var
end

local function gTableSafeSet(...)
	local path = {...}
	assert(#path >= 3)

	local tbl = _G
	local val = table.remove(path)
	local var = table.remove(path)

	for _,t in ipairs(path) do
		tbl[t] = tbl[t] or {}
		tbl = tbl[t]
	end
	tbl[var] = val

	return tbl
end

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

-- required for vehicles which are badly configured --
function rLib.ClientAuto.MechanicsOverlayMissingImg(ui, visible)
	local vehicleName = ui.vehicle:getScript():getFullName()

	for p=0, ui.vehicle:getPartCount()-1 do
		local part = ui.vehicle:getPartByIndex(p)
		local partId = part:getId()
		local crappyConfig = "<<<RotatorsLib-ISCarMechanicsOverlay-BadlyConfiguredVehicle>>>"
		if visible then
			if ISCarMechanicsOverlay.PartList[partId] and ISCarMechanicsOverlay.PartList[partId].img == nil and gTableSafeGet("ISCarMechanicsOverlay", "CarList", vehicleName, "PartList", partId, "img") == nil then
				rLib.dprint("[rLib] ISCarMechanicsOverlay texture hotfix add : %s", partId)
				gTableSafeSet("ISCarMechanicsOverlay", "CarList", vehicleName, "PartList", partId, "img", crappyConfig)
			end
		else
			if gTableSafeGet("ISCarMechanicsOverlay", "CarList", vehicleName, "PartList", partId, "img") == crappyConfig then
				rLib.dprint("[rLib] ISCarMechanicsOverlay texture hotfix del : %s", partId)
				ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId].img = nil

				if table.isempty(ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId]) then
					ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId] = nil
				end

				if table.isempty(ISCarMechanicsOverlay.CarList[vehicleName].PartList) then
					ISCarMechanicsOverlay.CarList[vehicleName].PartList = nil
				end
			end
		end
	end
end

rLib.Events.On("Vehicle.MechanicsSetVisible", rLib.ClientAuto.MechanicsOverlayMissingImg)

return rLib.ClientAuto
