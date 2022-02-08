require "rLib.Shared"

rLib.Vehicles = rLib.Vehicles or {}

function rLib.Vehicles.SetPartModelVisibleFromInventoryItemType(part)
	local partItemTypes = part:getItemType()
	for i=0, partItemTypes:size()-1 do
		part:setModelVisible(partItemTypes:get(i), false)
	end

	local inv = part:getInventoryItem()
	if not inv then
		return
	end

	part:setModelVisible(inv:getFullType(), true)
end

return rLib.Vehicles
