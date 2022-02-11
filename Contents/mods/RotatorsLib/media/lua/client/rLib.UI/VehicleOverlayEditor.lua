--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/ISUI/ISVehicleMechanics.lua"

require "rLib.Shared"
require "rLib.Events/Vehicle"

rLib.UI = rLib.UI or {}
rLib.UI.VehicleOverlayEditor = ISCollapsableWindow:derive("rLib.UI.VehicleOverlayEditor")

function rLib.UI.VehicleOverlayEditor:new(mechanicsUI)
	local w,h = 300, 300

	local this = ISCollapsableWindow:new(mechanicsUI:getX() - w, mechanicsUI:getY(), 300, 300)
	setmetatable(this, self)
	self.__index = self

	this.MechanicsUI = mechanicsUI

	return this
end

function rLib.UI.VehicleOverlayEditor:createChildren()
	ISCollapsableWindow.createChildren(self)

	self:setTitle(getText("UI_rLib_VehicleOverlayEditor"))
	self:setResizable(false)
	self.pinButton:setVisible(false)
	self.collapseButton:setVisible(false)

	self.CarPrefix, self.CarX, self.CarY = self:GetCarListData("imgPrefix") or "", self:GetCarListData("x") or 0, self:GetCarListData("y") or 0

	self.uiPrefix = ISTextEntryBox:new(self.CarPrefix, 10, self:titleBarHeight() + 10, 112, 20)
	self.uiPrefix.font = UIFont.Small
	self.uiPrefix:initialise()
	self.uiPrefix:instantiate()
	self.uiPrefix.onCommandEntered = self.OnCarPrefix
	self:addChild(self.uiPrefix)

	self.uiCarX = ISTextEntryBox:new(rLib.tostring(self.CarX), self.uiPrefix:getX(), self.uiPrefix:getBottom() + 5, (self.uiPrefix:getWidth() / 2) - 2, self.uiPrefix:getHeight())
	self.uiCarX.font = UIFont.Small
	self.uiCarX:initialise()
	self.uiCarX:instantiate()
	self.uiCarX.Var = "x"
	self.uiCarX:setOnlyNumbers(true)
	self.uiCarX.onCommandEntered = self.OnCarXY
	self:addChild(self.uiCarX)

	self.uiCarY = ISTextEntryBox:new(rLib.tostring(self.CarY), self.uiCarX:getRight() + 4, self.uiCarX:getY(), (self.uiPrefix:getWidth() / 2) - 2, self.uiCarX:getHeight())
	self.uiCarY.font = UIFont.Small
	self.uiCarY:initialise()
	self.uiCarY:instantiate()
	self.uiCarY.Var = "y"
	self.uiCarY:setOnlyNumbers(true)
	self.uiCarY.onCommandEntered = self.OnCarXY
	self:addChild(self.uiCarY)

	self.uiPartX1 = ISTextEntryBox:new("", self.uiPrefix:getX(), self.uiCarY:getBottom() + 25, (self.uiPrefix:getWidth() / 4) - 3, self.uiPrefix:getHeight())
	self.uiPartX1.font = UIFont.Small
	self.uiPartX1:initialise()
	self.uiPartX1:instantiate()
	self.uiPartX1:setOnlyNumbers(true)
	self.uiPartX1.Var = "x"
	self.uiPartX1.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartX1)

	self.uiPartY1 = ISTextEntryBox:new("", self.uiPartX1:getRight() + 4, self.uiPartX1:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartY1.font = UIFont.Small
	self.uiPartY1:initialise()
	self.uiPartY1:instantiate()
	self.uiPartY1:setOnlyNumbers(true)
	self.uiPartY1.Var = "y"
	self.uiPartY1.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartY1)

	self.uiPartX2 = ISTextEntryBox:new("", self.uiPartY1:getRight() + 4, self.uiPartY1:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartX2.font = UIFont.Small
	self.uiPartX2:initialise()
	self.uiPartX2:instantiate()
	self.uiPartX2:setOnlyNumbers(true)
	self.uiPartX2.Var = "x2"
	self.uiPartX2.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartX2)

	self.uiPartY2 = ISTextEntryBox:new("", self.uiPartX2:getRight() + 4, self.uiPartX2:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartY2.font = UIFont.Small
	self.uiPartY2:initialise()
	self.uiPartY2:instantiate()
	self.uiPartY2:setOnlyNumbers(true)
	self.uiPartY2.Var = "y2"
	self.uiPartY2.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartY2)

	self.uiButtonGenerate = ISButton:new(self.uiPrefix:getX(), self:getHeight() - 50, 50, 10, "Generate", self, self.Generate)
	self.uiButtonGenerate:initialise()
	self.uiButtonGenerate.borderColor.a = 0.0
	self.uiButtonGenerate.backgroundColor.a = 1
	self.uiButtonGenerate.backgroundColorMouseOver.a = 0.7
	self:addChild(self.uiButtonGenerate)
end

function rLib.UI.VehicleOverlayEditor:Generate(button)
	local code = {}

	local vehicle = self:GetVehicle()
	local carList = string.format("ISCarMechanicsOverlay.CarList[\"%s\"]", vehicle:getScript():getFullName())
	local prefix = self:GetCarListData("imgPrefix")
	local func = string.format( "%sMechanicsOverlay", self:GetVehicle():getScript():getFullName():gsub("%.", ""))
	local parts, partsLine = {}, 0

	table.insert(code, "--[[*]]-- Generated automagically by RotatorsLib --[[*]]--")
	table.insert(code, "")
	table.insert(code, "require \"Vehicles/ISUI/ISCarMechanicsOverlay\"")
	table.insert(code, "")
	table.insert(code, string.format("local function %s()", func))

	if self:IsCarListOK() then
		table.insert(code, string.format("\t%s = { imgPrefix = \"%s\", x = %d, y = %d}", carList, prefix, self:GetCarListData("x"), self:GetCarListData("y")))
		table.insert(code, "")
		table.insert(code, "\t--PLACEHOLDER--")
		partsLine = #code
		table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name] = ISCarMechanicsOverlay.PartList[name] or {}")
		table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name].vehicles = ISCarMechanicsOverlay.PartList[name].vehicles or {}")
		table.insert(code, "\tend")
		table.insert(code, "")

		for p=0,vehicle:getPartCount()-1 do
			local part = vehicle:getPartByIndex(p)
			local partId = part:getId()

			if self:IsPartListOK(part) then
				local x1 = self:GetPartListData(part, "x")
				local y1 = self:GetPartListData(part, "y")
				local x2 = self:GetPartListData(part, "x2")
				local y2 = self:GetPartListData(part, "y2")
				if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
					table.insert(parts, partId)
					table.insert(code, string.format("\tISCarMechanicsOverlay.PartList[\"%s\"].vehicles[\"%s\"] = { x = %d, y = %d, x2 = %d, y2 = %d }", partId, prefix, x1, y1, x2, y2))
				end
			end
		end
	end
	if #parts > 0 then
		code[partsLine] = "\tfor _,name in ipairs({ \"" .. table.concat(parts, "\", \"") .. "\" }) do"
	else
		code[partsLine] = "\tfor _,name in ipairs({}) do" -- damage control --
	end
	table.insert(code, "end")
	table.insert(code, "")
	table.insert(code, string.format("Events.OnInitWorld.Add(%s)", func))

	Clipboard.setClipboard(table.concat(code, "\n") .. "\n")
end

function rLib.UI.VehicleOverlayEditor:prerender()
	ISCollapsableWindow.prerender(self)

	local selectedPart
	if self.MechanicsUI.listbox.selected > 0 and self.MechanicsUI.listbox.items[self.MechanicsUI.listbox.selected] then
		selectedPart = self.MechanicsUI.listbox.items[self.MechanicsUI.listbox.selected].item.part
	elseif self.MechanicsUI.bodyworklist.selected > 0 and self.MechanicsUI.bodyworklist.items[self.MechanicsUI.bodyworklist.selected] then
		selectedPart = self.MechanicsUI.bodyworklist.items[self.MechanicsUI.bodyworklist.selected].item.part
	end

	if self.SelectedPart ~= selectedPart then
		self.SelectedPart = selectedPart
		self:OnSelectedPartChange(self.SelectedPart)
	end
end

function rLib.UI.VehicleOverlayEditor:postrender(target, func)
	if self.uiPartX1.Val ~= nil and self.uiPartY1.Val ~= nil and self.uiPartX2.Val ~= nil and self.uiPartY2.Val ~= nil then
		func(target, self.uiPartX1.Val, self.uiPartY1.Val, self.uiPartX2.Val - self.uiPartX1.Val, self.uiPartY2.Val - self.uiPartY1.Val, 0.5, 0, 0.5, 0)
	end
end

local ISVM_render = ISVehicleMechanics.render
function ISVehicleMechanics:render()
	ISVM_render(self)

	if self.rLib and self.rLib.VehicleOverlayEditor then
		self.rLib.VehicleOverlayEditor:postrender(self, self.drawRect)
	end
end

function rLib.UI.VehicleOverlayEditor:close()
	ISCollapsableWindow.close(self)
	self.MechanicsUI.rLib.VehicleOverlayEditor = nil
	self:removeFromUIManager()
end

--[[
function rLib.UI.VehicleOverlayEditor:renderCarOverlay()
	ISVehicleMechanics.renderCarOverlay(self)

	self:drawText("CarList", self.bodyworklist:getRight() + 10, self.bodyworklist:getY(), self.partCatRGB.r, self.partCatRGB.g, self.partCatRGB.b, self.partCatRGB.a, UIFont.Medium)
	self:drawText("PartList", self.bodyworklist:getRight() + 10, self.uiCarY:getBottom() + 5, self.partCatRGB.r, self.partCatRGB.g, self.partCatRGB.b, self.partCatRGB.a, UIFont.Medium)

	local selectedPart
	if self.listbox.items[self.listbox.selected] then
		selectedPart = self.listbox.items[self.listbox.selected].item.part
	elseif self.bodyworklist.items[self.bodyworklist.selected] then
		selectedPart = self.bodyworklist.items[self.bodyworklist.selected].item.part
	end

	if ISCarMechanicsOverlay.CarList[self.vehicle:getScriptName()] then
		local props = ISCarMechanicsOverlay.CarList[self.vehicle:getScriptName()]
		local propsString = string.format("ISCarMechanicsOverlay.CarList[%s]", self.vehicle:getScriptName())

		for i=1,self.vehicle:getPartCount() do
			local part = self.vehicle:getPartByIndex(i-1)
			if part == selectedPart then
				if ISCarMechanicsOverlay.PartList[part:getId()] then
					local partProps = ISCarMechanicsOverlay.PartList[part:getId()]
					local partPropsString = string.format("ISCarMechanicsOverlay.PartList[\"%s\"]", part:getId())

					local partPropsORG = partProps
					local partPropsStringORG = partPropsString

					if props.PartList and props.PartList[part:getId()] then
						partProps = props.PartList[part:getId()]
						partPropsString = string.format("%s.PartList[\"%s\"]", propsString, part:getId())
					end

					local x, y, nope = self.bodyworklist:getRight(), self.bodyworklist:getY() + 200, "(???)"
					self:drawText(string.format("%s.imgPrefix = %s", propsString, props.imgPrefix or nope), x, y+0, 1, 1, 1, 1)
					self:drawText(string.format("%s.x = %s", propsString, props.x or nope), x, y+10, 1, 1, 1, 1)
					self:drawText(string.format("%s.y = %s", propsString, props.y or nope), x, y+20, 1, 1, 1, 1)

					self:drawText(string.format("%s.x = %s", partPropsString, partProps.x or nope), x, y+30, 1, 1, 1, 1)
					self:drawText(string.format("%s.y = %s", partPropsString, partProps.y or nope), x, y+40, 1, 1, 1, 1)

					if partPropsORG.vehicles and partPropsORG.vehicles[props.imgPrefix] then
						self:drawText(string.format("%s.vehicles[\"%s\"].x  = %s", partPropsStringORG, props.imgPrefix, partPropsORG.vehicles[props.imgPrefix].x or nope), x, y+50, 1, 1, 1, 1)
						self:drawText(string.format("%s.vehicles[\"%s\"].y  = %s", partPropsStringORG, props.imgPrefix, partPropsORG.vehicles[props.imgPrefix].y or nope), x, y+60, 1, 1, 1, 1)
						self:drawText(string.format("%s.vehicles[\"%s\"].x2 = %s", partPropsStringORG, props.imgPrefix, partPropsORG.vehicles[props.imgPrefix].x2 or nope), x, y+70, 1, 1, 1, 1)
						self:drawText(string.format("%s.vehicles[\"%s\"].y2 = %s", partPropsStringORG, props.imgPrefix, partPropsORG.vehicles[props.imgPrefix].y2 or nope), x, y+80, 1, 1, 1, 1)
					end
				end
			end
		end
	end
end
]]--

function rLib.UI.VehicleOverlayEditor:GetVehicle()
	return self.MechanicsUI.vehicle
end

function rLib.UI.VehicleOverlayEditor:IsCarListOK()
	local vehicle = self:GetVehicle():getScript():getFullName()

	return ISCarMechanicsOverlay.CarList[vehicle] ~= nil
end

function rLib.UI.VehicleOverlayEditor:GetCarListData(name)
	assert(rLib.arg(name, "string"))

	local vehicle = self:GetVehicle():getScript():getFullName()

	if ISCarMechanicsOverlay.CarList[vehicle] and ISCarMechanicsOverlay.CarList[vehicle][name] then
		return ISCarMechanicsOverlay.CarList[vehicle][name]
	end

	return nil
end

function rLib.UI.VehicleOverlayEditor:SetCarListData(name, data)
	assert(rLib.arg(name, "string"))

	local vehicle = self:GetVehicle():getScript():getFullName()

	ISCarMechanicsOverlay.CarList[vehicle] =
	ISCarMechanicsOverlay.CarList[vehicle] or {}

	ISCarMechanicsOverlay.CarList[vehicle][name] = data
end

function rLib.UI.VehicleOverlayEditor:IsPartListOK(part)
	assert(rLib.arg(part, "VehiclePart"))

	part = part:getId()
	local prefix = self:GetCarListData("imgPrefix")
	if not prefix then
		return nil
	end

	return ISCarMechanicsOverlay.PartList[part] ~= nil and ISCarMechanicsOverlay.PartList[part].vehicles ~= nil and ISCarMechanicsOverlay.PartList[part].vehicles[prefix] ~= nil
end

function rLib.UI.VehicleOverlayEditor:GetPartListData(part, name)
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(name, "string"))

	part = part:getId()
	local prefix = self:GetCarListData("imgPrefix")
	if not prefix then
		return nil
	end

	if ISCarMechanicsOverlay.PartList[part] and ISCarMechanicsOverlay.PartList[part].vehicles and ISCarMechanicsOverlay.PartList[part].vehicles[prefix] and ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name] then
		return ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name]
	end

	return nil
end

function rLib.UI.VehicleOverlayEditor:SetPartListData(part, name, data)
	local part = part:getId()
	local prefix = self:GetCarListData("imgPrefix")

	ISCarMechanicsOverlay.PartList[part] =
	ISCarMechanicsOverlay.PartList[part] or {}

	ISCarMechanicsOverlay.PartList[part].vehicles =
	ISCarMechanicsOverlay.PartList[part].vehicles or {}

	ISCarMechanicsOverlay.PartList[part].vehicles[prefix] =
	ISCarMechanicsOverlay.PartList[part].vehicles[prefix] or {}

	for _,var in ipairs({"x", "y", "x2", "y2"}) do
		ISCarMechanicsOverlay.PartList[part].vehicles[prefix][var] =
		ISCarMechanicsOverlay.PartList[part].vehicles[prefix][var] or 0
	end

	ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name] = data
end

function rLib.UI.VehicleOverlayEditor:OnSelectedPartChange(part)
	assert(rLib.arg(part, "VehiclePart", "nil"))

	for _,ui in ipairs({ self.uiPartX1, self.uiPartY1, self.uiPartX2, self.uiPartY2 }) do
		local partVal = ""
		ui.Val = nil
		if part then
			ui.Val = self:GetPartListData(part, ui.Var)
			partVal = tostring(ui.Val)
		end

		ui:setText(partVal)
		ui:setEditable(partVal ~= "" and true or false)
	end
end

--

function rLib.UI.VehicleOverlayEditor:GetTextureName(name)
	name = "media/ui/vehicles/mechanic overlay/" .. name .. "base.png"
	if not getTexture(name) then
		return name, false
	end

	return name, true
end

function rLib.UI.VehicleOverlayEditor:OnCarPrefix()
	local name, valid = self:getParent():GetTextureName(self:getText())

	self:setValid(valid)
	if not valid then
		rLib.dprint("Invalid texture : %s", name)
		return
	end

	self:getParent():SetCarListData("imgPrefix", self:getText())
end

function rLib.UI.VehicleOverlayEditor:OnCarXY()
	self:getParent():SetCarListData(self.Var, tonumber(self:getText()))
end

function rLib.UI.VehicleOverlayEditor:OnPartXY()
	local selectedPart = self:getParent().SelectedPart

	if not selectedPart then
		return
	end

	self.Val = tonumber(self:getText())
	self:getParent():SetPartListData(selectedPart, self.Var, self.Val)
end

ISVehicleMechanics.rLib = ISVehicleMechanics.rLib or {}
function ISVehicleMechanics.rLib:VehicleOverlayEditorButtonClick(button)
	if self.rLib.VehicleOverlayEditor then
		return
	end

	local editor = rLib.UI.VehicleOverlayEditor:new(self)
	editor:initialise()
	editor:instantiate()
	editor:addToUIManager()

	self.rLib.VehicleOverlayEditor = editor
end

local function OnMechanicsSetVisible(ui, visible)
	if not ui.rLib or not ui.rLib.VehicleOverlayEditorButton then
		local x, h
		if ui.infoButton then
			x = ui.infoButton:getRight()
			h = ui.infoButton:getHeight()
		elseif self.closeButton then
			x = ui.closeButton:getRight()
			h = ui.closeButton:getHeight()
		end
		if x and h then
			x = x + 5
			local text = getText("UI_rLib_VehicleOverlayEditor")
			local textWidth = getTextManager():MeasureStringX(UIFont.Small, text)

			ui.rLib.VehicleOverlayEditorButton = ISButton:new(x, 0, textWidth, h, text, ui, ui.rLib.VehicleOverlayEditorButtonClick)
			ui.rLib.VehicleOverlayEditorButton:initialise()
			ui.rLib.VehicleOverlayEditorButton.borderColor.a = 0.0
			ui.rLib.VehicleOverlayEditorButton.backgroundColor.a = 0.0
			ui.rLib.VehicleOverlayEditorButton.backgroundColorMouseOver.a = 0.7
			ui:addChild(ui.rLib.VehicleOverlayEditorButton)
		end
	end

	ui.rLib.VehicleOverlayEditorButton:setVisible(false)

	if ui.rLib.VehicleOverlayEditor then
		ui.rLib.VehicleOverlayEditor:close()
	end

	UIManager.update()
end

rLib.Events.On("Vehicle.MechanicsSetVisible", OnMechanicsSetVisible)
