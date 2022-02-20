--[[*]]-- RotatorsLib --[[*]]--

require "ISUI/ISEquippedItem"

require "rLib.Shared"

rLib.SidePanel = { Buttons = {} }

function rLib.SidePanel.AddButton(texture, onClickTarget, onClickFunc)
	position = position or "normal"

	if not ISEquippedItem or not ISEquippedItem.instance or not ISEquippedItem.instance.invBtn then
		return
	end

	local y = -1

	for _,child in ipairs(ISEquippedItem.instance:getChildren()) do
		if child.rLib then
			y = math.max(y, button:getBottom() + 5)
		end
	end

	if y < 0 then
		if ISEquippedItem.instance.movableBtn then
			y = ISEquippedItem.instance.movableBtn:getBottom() + 5
		end

		if ISEquippedItem.instance.searchBtn then
			y = ISEquippedItem.instance.searchBtn:getBottom() + 5
		end

		if ISEquippedItem.instance.mapBtn then
			y = ISEquippedItem.instance.mapBtn:getBottom() + 5
		end
	end

	local button = ISButton:new(0, 0, 40, 40, "", onClickTarget, onClickFunc)
	button.rLib = {}
	button.rLib.Icon = getTexture(texture);
	button:setImage(button.rLib.Icon)
	button:initialise();
	button:instantiate();
	button:setDisplayBackground(false);
	button:ignoreWidthChange();
	button:ignoreHeightChange();

	button:setX(0)
	button:setY(y)
	button:setWidth(40)
	button:setHeight(40)

	local buttonH = button:getHeight()

	ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() + buttonH + 5)

	rLib.SidePanel.MoveButton(ISEquippedItem.instance.debugBtn, buttonH + 5)
	rLib.SidePanel.MoveButton(ISEquippedItem.instance.clientBtn, buttonH + 5)
	rLib.SidePanel.MoveButton(ISEquippedItem.instance.adminBtn, buttonH + 5)

	ISEquippedItem.instance:addChild(button)

	return button
end

function rLib.SidePanel.MoveButton(button, offset)
	if button then
		button:setY(button:getY() + offset)
	end
end

function rLib.SidePanel.RemoveButton(button, force)
	if not button.rLib and not force then
		return
	end

	local buttonH = button:getHeight()

	rLib.SidePanel.MoveButton(ISEquippedItem.instance.debugBtn, -buttonH - 5)
	rLib.SidePanel.MoveButton(ISEquippedItem.instance.clientBtn, -buttonH - 5)
	rLib.SidePanel.MoveButton(ISEquippedItem.instance.adminBtn, -buttonH - 5)

	ISEquippedItem.instance:setHeight(ISEquippedItem.instance:getHeight() - buttonH - 5)

	ISEquippedItem.instance:removeChild(button)
end

function rLib.SidePanel.RemoveAllButtons()
	for _,child in ipairs(ISEquippedItem.instance:getChildren()) do
		if child.rLib then
			RemoveButton(button)
		end
	end
end

return rLib.SidePanel
