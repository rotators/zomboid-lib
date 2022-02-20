--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/Vehicles"

require "rLib.Shared"

rLib.Vehicles = rLib.Vehicles or {}
rLib.Vehicles.Functions =
{
	Create = {},
	Init = {},
	InstallComplete = {},
	UninstallComplete = {}
}

--

function rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
	assert(rLib.arg(part, "VehiclePart"))

	local partItemTypes = part:getItemType()
	for i=0, partItemTypes:size()-1 do
		part:setModelVisible(partItemTypes:get(i), false)
	end

	local inventoryItem = part:getInventoryItem()
	if not inventoryItem then
		return
	end

	part:setModelVisible(inventoryItem:getFullType(), true)
end

--

function rLib.Vehicles.Functions.Create.DefaultWithItemTypeModel(vehicle, part)
	Vehicles.Create.Default(vehicle, part)
	rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
end

function rLib.Vehicles.Functions.Create.RadioWithItemTypeModel(vehicle, part)
	Vehicles.Create.Radio(vehicle, part)
	rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
end

function rLib.Vehicles.Functions.Init.DefaultWithItemTypeModel(vehicle, part)
	-- there is no Vehicles.Init.Default(...) in vanilla scripts --
	rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
end

function rLib.Vehicles.Functions.InstallComplete.DefaultWithItemTypeModel(vehicle, part)
	Vehicles.InstallComplete.Default(vehicle, part)
	rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
end

function rLib.Vehicles.Functions.UninstallComplete.DefaultWithItemTypeModel(vehicle, part, item)
	Vehicles.UninstallComplete.Default(vehicle, part, item)
	rLib.Vehicles.Functions.ShowPartItemTypeModel(part)
end

return rLib.Vehicles.Functions
