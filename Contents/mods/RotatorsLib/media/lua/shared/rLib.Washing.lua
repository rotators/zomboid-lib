--[[*]]-- RotatorsLib --[[*]]--

require "rLib"

rLib.Washing = {}

function rLib.Washing.GetBlood(player)
	assert(rLib.arg(player, "IsoPlayer"))

	if not player then
		return 0
	end

	local bodyBlood, visual = 0, 0, player:getHumanVisual()
	for i=0, BloodBodyPartType.MAX:index()-1 do
		local part = BloodBodyPartType.FromIndex(i)
		bodyBlood = bodyBlood + visual:getBlood(part)
	end

	return bodyBlood
end

function rLib.Washing.GetDirt(player)
	assert(rLib.arg(player, "IsoPlayer"))

	if not player then
		return 0
	end

	local bodyDirt, visual = 0, 0, player:getHumanVisual()
	for i=0, BloodBodyPartType.MAX:index()-1 do
		local part = BloodBodyPartType.FromIndex(i)
		bodyDirt = bodyDirt + visual:getDirt(part)
	end

	return bodyDirt
end

function rLib.Washing.GetBloodAndDirt(player)
	assert(rLib.arg(player, "IsoPlayer"))

	if not player then
		return 0
	end

	local bodyBlood, bodyDirt, visual = 0, 0, player:getHumanVisual()
	for i=0, BloodBodyPartType.MAX:index()-1 do
		local part = BloodBodyPartType.FromIndex(i)
		bodyBlood = bodyBlood + visual:getBlood(part)
		bodyDirt = bodyDirt + visual:getDirt(part)
	end

	return bodyBlood + bodyDirt
end

function rLib.Washing.GetSoapItems(player)
	assert(rLib.arg(player, "IsoPlayer"))

	local soapList = {}

	function _addItemType(itemType)
		if not player then
			return
		end

		local list = player:getInventory():getItemsFromType(itemType, true)

		for i = 0, list:size() - 1 do
			local item = list:get(i)
			table.insert(soapList, item)
		end
	end

	_addItemType("Soap2")
	_addItemType("CleaningLiquid2")

	return soapList
end

return rLib.Washing
