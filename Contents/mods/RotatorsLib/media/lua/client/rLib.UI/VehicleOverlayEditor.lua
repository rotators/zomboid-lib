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
	self.uiCarX.font = self.uiPrefix.font
	self.uiCarX:initialise()
	self.uiCarX:instantiate()
	self.uiCarX.Var = "x"
	self.uiCarX:setOnlyNumbers(true)
	self.uiCarX.onCommandEntered = self.OnCarXY
	self:addChild(self.uiCarX)

	self.uiCarY = ISTextEntryBox:new(rLib.tostring(self.CarY), self.uiCarX:getRight() + 4, self.uiCarX:getY(), (self.uiPrefix:getWidth() / 2) - 2, self.uiCarX:getHeight())
	self.uiCarY.font = self.uiPrefix.font
	self.uiCarY:initialise()
	self.uiCarY:instantiate()
	self.uiCarY.Var = "y"
	self.uiCarY:setOnlyNumbers(true)
	self.uiCarY.onCommandEntered = self.OnCarXY
	self:addChild(self.uiCarY)

	self.uiPartAdd = ISButton:new(self.uiPrefix:getX(), self.uiCarY:getBottom() + 25, self.uiPrefix:getWidth(), self.uiPrefix:getHeight(), getText("UI_rLib_VehicleOverlayEditor_PartAdd"), self, self.OnPartAdd)
	self.uiPartAdd:initialise()
	self.uiPartAdd.borderColor.a = 0.4
	self.uiPartAdd.backgroundColor.a = 1
	self.uiPartAdd.backgroundColorMouseOver.a = 0.7
	self:addChild(self.uiPartAdd)

	self.uiPartDel = ISButton:new(self.uiPartAdd:getX(), self.uiPartAdd:getY(), self.uiPartAdd:getWidth(), self.uiPartAdd:getHeight(), getText("UI_rLib_VehicleOverlayEditor_PartDel"), self, self.OnPartDel)
	self.uiPartDel:initialise()
	self.uiPartDel.borderColor.a = 0.4
	self.uiPartDel.backgroundColor.a = 1
	self.uiPartDel.backgroundColorMouseOver.a = 0.7
	self:addChild(self.uiPartDel)

	self.uiPartX1 = ISTextEntryBox:new("", self.uiPrefix:getX(), self.uiPartAdd:getBottom() + 5, (self.uiPrefix:getWidth() / 4) - 3, self.uiPrefix:getHeight())
	self.uiPartX1.font = self.uiPrefix.font
	self.uiPartX1:initialise()
	self.uiPartX1:instantiate()
	self.uiPartX1:setOnlyNumbers(true)
	self.uiPartX1.Var = "x"
	self.uiPartX1.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartX1)

	self.uiPartY1 = ISTextEntryBox:new("", self.uiPartX1:getRight() + 4, self.uiPartX1:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartY1.font = self.uiPrefix.font
	self.uiPartY1:initialise()
	self.uiPartY1:instantiate()
	self.uiPartY1:setOnlyNumbers(true)
	self.uiPartY1.Var = "y"
	self.uiPartY1.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartY1)

	self.uiPartX2 = ISTextEntryBox:new("", self.uiPartY1:getRight() + 4, self.uiPartY1:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartX2.font = self.uiPrefix.font
	self.uiPartX2:initialise()
	self.uiPartX2:instantiate()
	self.uiPartX2:setOnlyNumbers(true)
	self.uiPartX2.Var = "x2"
	self.uiPartX2.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartX2)

	self.uiPartY2 = ISTextEntryBox:new("", self.uiPartX2:getRight() + 4, self.uiPartX2:getY(), self.uiPartX1:getWidth(), self.uiPrefix:getHeight())
	self.uiPartY2.font = self.uiPrefix.font
	self.uiPartY2:initialise()
	self.uiPartY2:instantiate()
	self.uiPartY2:setOnlyNumbers(true)
	self.uiPartY2.Var = "y2"
	self.uiPartY2.onCommandEntered = self.OnPartXY
	self:addChild(self.uiPartY2)

	self.uiPartTexture = ISTextEntryBox:new("", self.uiPrefix:getX(), self.uiPartY2:getBottom() + 5, self.uiPrefix:getWidth(), self.uiPrefix:getHeight())
	self.uiPartTexture.font = self.uiPrefix.font
	self.uiPartTexture:initialise()
	self.uiPartTexture:instantiate()
	self.uiPartTexture.onCommandEntered = self.OnPartTexture
	self:addChild(self.uiPartTexture)

	self.uiGenerate = ISButton:new(self.uiPrefix:getX(), self:getHeight() - 20, 50, 10, "Generate", self, self.Generate)
	self.uiGenerate:initialise()
	self.uiGenerate.borderColor.a = 0.4
	self.uiGenerate.backgroundColor.a = 1
	self.uiGenerate.backgroundColorMouseOver.a = 0.7
	self:addChild(self.uiGenerate)

end

function rLib.UI.VehicleOverlayEditor:GeneratePartList(codePartial)
	local result = {}
	for part,_ in pairs(codePartial) do
		table.insert(result, part)
	end

	table.sort(result)
	return result
end

function rLib.UI.VehicleOverlayEditor:GenerateSafeAccess(str)
	if string.match(str, "^[A-Za-z0-9_]+$") then
		return "." .. str
	end

	return "[\" .. string .. \"]"
end

function rLib.UI.VehicleOverlayEditor:Generate(button)
	local code, codeImg, codeCoord, parts = {}, {}, {}

	local vehicle = self:GetVehicle()
	local vehicleName = vehicle:getScript():getFullName()
	local carList = string.format("ISCarMechanicsOverlay.CarList[\"%s\"]", vehicleName)
	local prefix = self:GetCarListData("imgPrefix")
	local func = string.format( "%sMechanicsOverlay", vehicleName:gsub("%.", ""))

	table.insert(code, "--[[*]]-- Generated automagically by RotatorsLib --[[*]]--")
	table.insert(code, "")
	table.insert(code, "require \"Vehicles/ISUI/ISCarMechanicsOverlay\"")
	table.insert(code, "")
	table.insert(code, string.format("local function %s()", func))

	if self:IsCarListOK() then
		table.insert(code, string.format("\t%s = { imgPrefix = \"%s\", x = %d, y = %d }", carList, prefix, self:GetCarListData("x"), self:GetCarListData("y")))

		for p=0,vehicle:getPartCount()-1 do
			local part = vehicle:getPartByIndex(p)
			local partId = part:getId()

			local img = self:GetPartListData(part, "img")
			if img then
				local multi, quote = "", ""

				if type(img) == "table" then
					multi = "multipleImg = true, "
				elseif type(img) == "string" then
					quote = "\""
				else
					error("[rLib] Unknown part image type, PANIK")
				end

				codeImg[partId] = string.format("\tISCarMechanicsOverlay.CarList[\"%s\"].PartList%s = { %simg = %s%s%s }", vehicleName, self:GenerateSafeAccess(partId), multi, quote, rLib.tostring(img), quote)
			end

			if self:IsPartListOK(part) then
				local x1 = self:GetPartListData(part, "x")
				local y1 = self:GetPartListData(part, "y")
				local x2 = self:GetPartListData(part, "x2")
				local y2 = self:GetPartListData(part, "y2")
				if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
					codeCoord[partId] = string.format("\tISCarMechanicsOverlay.PartList%s.vehicles%s = { x = %d, y = %d, x2 = %d, y2 = %d }", self:GenerateSafeAccess(partId), self:GenerateSafeAccess(prefix), x1, y1, x2, y2)
				end
			end
		end

		if not table.isempty(codeImg) then
			parts = self:GeneratePartList(codeImg)
			table.insert(code, "")
			table.insert(code, string.format("\tISCarMechanicsOverlay.CarList[\"%s\"].PartList = {}", vehicleName))
			for _,id in ipairs(parts) do
				table.insert(code, codeImg[id])
			end
		end

		if not table.isempty(codeCoord) then
			parts = self:GeneratePartList(codeCoord)
			table.insert(code, "")
			table.insert(code, "\tfor _,name in ipairs({ \"" .. table.concat(parts, "\", \"") .. "\" }) do")
			table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name] = ISCarMechanicsOverlay.PartList[name] or {}")
			table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name].vehicles = ISCarMechanicsOverlay.PartList[name].vehicles or {}")
			table.insert(code, "\tend")
			table.insert(code, "")
			for _,id in ipairs(parts) do
				table.insert(code, codeCoord[id])
			end
		end
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

	if name == "img" then
		local vehicle = self:GetVehicle():getScript():getFullName()

		if ISCarMechanicsOverlay.CarList[vehicle] and ISCarMechanicsOverlay.CarList[vehicle].PartList and ISCarMechanicsOverlay.CarList[vehicle].PartList[part] and ISCarMechanicsOverlay.CarList[vehicle].PartList[part][name] then
			return ISCarMechanicsOverlay.CarList[vehicle].PartList[part][name]
		end
	else
		if ISCarMechanicsOverlay.PartList[part] and ISCarMechanicsOverlay.PartList[part].vehicles and ISCarMechanicsOverlay.PartList[part].vehicles[prefix] and ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name] then
			return ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name]
		end
	end

	return nil
end

function rLib.UI.VehicleOverlayEditor:SetPartListData(part, name, data)
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(name, "string"))

	part = part:getId()

	if name == "img" then
		local vehicle = self:GetVehicle():getScript():getFullName()

		ISCarMechanicsOverlay.CarList[vehicle].PartList =
		ISCarMechanicsOverlay.CarList[vehicle].PartList or {}

		ISCarMechanicsOverlay.CarList[vehicle].PartList[part] =
		ISCarMechanicsOverlay.CarList[vehicle].PartList[part] or {}

		ISCarMechanicsOverlay.CarList[vehicle].PartList[part].img = data

		local carListDebug = ISCarMechanicsOverlay.CarList[vehicle]
		if data == nil then
			if #ISCarMechanicsOverlay.CarList[vehicle].PartList[part] == 0 then
				ISCarMechanicsOverlay.CarList[vehicle].PartList[part] = nil
			end

			if #ISCarMechanicsOverlay.CarList[vehicle].PartList == 0 then
				ISCarMechanicsOverlay.CarList[vehicle].PartList = nil
			end
		end
		rLib.breakpoint()
		rLib.nop()
	else
		local prefix = self:GetCarListData("imgPrefix")

		ISCarMechanicsOverlay.PartList[part] =
		ISCarMechanicsOverlay.PartList[part] or {}

		ISCarMechanicsOverlay.PartList[part].vehicles =
		ISCarMechanicsOverlay.PartList[part].vehicles or {}

		ISCarMechanicsOverlay.PartList[part].vehicles[prefix] =
		ISCarMechanicsOverlay.PartList[part].vehicles[prefix] or {}

		if data then
			for _,var in ipairs({"x", "y", "x2", "y2"}) do
				ISCarMechanicsOverlay.PartList[part].vehicles[prefix][var] =
				ISCarMechanicsOverlay.PartList[part].vehicles[prefix][var] or 0
			end
		else
				ISCarMechanicsOverlay.PartList[part].vehicles[prefix][var] = nil
		end

		ISCarMechanicsOverlay.PartList[part].vehicles[prefix][name] = data

		if not data and table.isempty(ISCarMechanicsOverlay.PartList[part].vehicles[prefix]) then
			ISCarMechanicsOverlay.PartList[part].vehicles[prefix] = nil
		end
	end
end

function rLib.UI.VehicleOverlayEditor:OnSelectedPartChange(part)
	assert(rLib.arg(part, "VehiclePart", "nil"))

	local valid = part ~= nil

	if valid then
		for _,ui in ipairs({ self.uiPartX1, self.uiPartY1, self.uiPartX2, self.uiPartY2 }) do
			local partVal = ""
			ui.Val = nil
			ui.Val = self:GetPartListData(part, ui.Var)
			partVal = tostring(ui.Val)
			if ui.Val == nil then
				valid = false
			end
			ui:setText(partVal)
			ui:setEditable(true)
		end
		self.uiPartTexture:setText(self:GetPartListData(part, "img") or "")
	end

	for _,ui in ipairs({ self.uiPartDel, self.uiPartX1, self.uiPartY1, self.uiPartX2, self.uiPartY2, self.uiPartTexture}) do
		ui:setVisible(part ~= nil and valid)
	end
	for _,ui in ipairs({ self.uiPartAdd }) do
		ui:setVisible(part ~= nil and not valid)
	end
end

--

function rLib.UI.VehicleOverlayEditor:GetPrefixTextureName(name)
	name = "media/ui/vehicles/mechanic overlay/" .. name .. "base.png"
	if not getTexture(name) then
		return name, false
	end

	return name, true
end

function rLib.UI.VehicleOverlayEditor:OnCarPrefix()
	local name, valid = self:getParent():GetPrefixTextureName(self:getText())

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

function rLib.UI.VehicleOverlayEditor:OnPartAdd(button)
	if not self.SelectedPart then
		return
	end

	for _,name in ipairs({ "x", "y", "x2", "y2" }) do
		self:SetPartListData(self.SelectedPart, name, 0)
	end
	self:OnSelectedPartChange(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartDel(button)
	if not self.SelectedPart then
		return
	end

	for _,name in ipairs({ "x", "y", "x2", "y2" }) do
		self:SetPartListData(self.SelectedPart, name, nil)
	end
	self:OnSelectedPartChange(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartXY()
	local selectedPart = self:getParent().SelectedPart

	if not selectedPart then
		return
	end

	self.Val = tonumber(self:getText())
	self:getParent():SetPartListData(selectedPart, self.Var, self.Val)
end

function rLib.UI.VehicleOverlayEditor:OnPartTexture()
	local selectedPart = self:getParent().SelectedPart

	if not selectedPart then
		return
	end

	local data = self:getText()
	if data == "" then
		data = nil
	end

	self:getParent():SetPartListData(selectedPart, "img", data)
end

---

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
