--[[*]]-- RotatorsLib --[[*]]--

require "DebugUIs/ObjectViewer"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISModalDialog"
require "ISUI/ISTextEntryBox"
require "ISUI/PlayerData/ISPlayerData"
require "Vehicles/ISUI/ISVehicleMechanics"
require "Vehicles/ISUI/ISVehicleMenu"

require "rLib.Shared"
require "rLib.Events/Vehicle"

rLib.UI.VehicleOverlayEditor = ISPanel:derive("rLib.UI.VehicleOverlayEditor")

function rLib.UI.VehicleOverlayEditor:new(mechanicsUI)
	local w,h = 300, 300

	local this = ISPanel:new(mechanicsUI:getX() - w, mechanicsUI:getY(), 300, 300)
	setmetatable(this, self)
	self.__index = self

	this.MechanicsUI = mechanicsUI
	this.FailsafeCustomPartImg = "<<<VehicleOverlayEditor-CustomPart-ErrorPrevention>>>" -- see SetPartListData() --

	return this
end

function rLib.UI.VehicleOverlayEditor:createChildren()
	ISPanel.createChildren(self)

	self:noBackground()
	self:setX(self.MechanicsUI.xCarTexOffset)
	self:setY(self.MechanicsUI:titleBarHeight() + 10)
	self:setWidth(self.MechanicsUI:getWidth() - self.MechanicsUI.xCarTexOffset - 10)
	self:setHeight(5 + rLib.UI.FontSize.Medium + rLib.UI.FontSize.Small * (5 + 1))

	local wNum = 30
	local wDel = 40
	local h = rLib.UI.FontSize.Small + 4
	local pad = 5

	self.uiVehiclePrefix = ISTextEntryBox:new("", pad * 2, rLib.UI.FontSize.Medium + 7, --[[wNum * 4 + pad * 3]] 155, h)
	self.uiVehiclePrefix:initialise()
	self.uiVehiclePrefix:instantiate()
	self.uiVehiclePrefix.onCommandEntered = self.OnVehiclePrefix
	self:AddElement(self.uiVehiclePrefix)

	self.uiVehicleX = ISTextEntryBox:new("", self.uiVehiclePrefix:getRight() + pad, self.uiVehiclePrefix:getY(), wNum, h)
	self.uiVehicleX.font = self.uiVehiclePrefix.font
	self.uiVehicleX:initialise()
	self.uiVehicleX:instantiate()
	self.uiVehicleX.onCommandEntered = self.OnVehicleXY
	self.uiVehicleX.Var = "x"
	self:AddElement(self.uiVehicleX)

	self.uiVehicleY = ISTextEntryBox:new("", self.uiVehicleX:getRight() + pad, self.uiVehicleX:getY(), wNum, h)
	self.uiVehicleY.font = self.uiVehiclePrefix.font
	self.uiVehicleY:initialise()
	self.uiVehicleY:instantiate()
	self.uiVehicleY.onCommandEntered = self.OnVehicleXY
	self.uiVehicleY.Var = "y"
	self:AddElement(self.uiVehicleY)

	self.uiVehicleDel = ISButton:new(self.uiVehicleY:getRight() + pad, self.uiVehiclePrefix:getY(), wDel, h, getText("UI_rLib_VehicleOverlayEditor_VehicleDel"), self, self.OnVehicleDel)
	self.uiVehicleDel:initialise()
	self.uiVehicleDel:instantiate()
	self:AddElement(self.uiVehicleDel)

	self.uiVehicleAdd = ISButton:new(self.uiVehiclePrefix:getX(), self.uiVehiclePrefix:getY(), self.uiVehicleDel:getRight() - self.uiVehiclePrefix:getX(), h, getText("UI_rLib_VehicleOverlayEditor_VehicleAdd"), self, self.OnVehicleAdd)
	self.uiVehicleAdd:initialise()
	self.uiVehicleAdd:instantiate()
	self:AddElement(self.uiVehicleAdd)

	self.uiPartTexture = ISTextEntryBox:new("", self.uiVehiclePrefix:getX(), self.uiVehiclePrefix:getBottom() + pad, self.uiVehiclePrefix:getWidth(), h)
	self.uiPartTexture.font = self.uiVehiclePrefix.font
	self.uiPartTexture:initialise()
	self.uiPartTexture:instantiate()
	self.uiPartTexture.onCommandEntered = self.OnPartTextureWrapper
	self:AddElement(self.uiPartTexture)

	self.uiPartTextureInfo = ISLabel:new(-1, self.uiPartTexture:getY(), h, "", 1, 1, 1, 1, UIFont.Small, true)
	self.uiPartTextureInfo:initialise()
	self.uiPartTextureInfo:instantiate()
	self.uiPartTextureInfo.center = true
	--self.uiPartTextureInfo:setWidth(self.uiVehicleY:getRight() - self.uiVehicleX:getX())
	self.uiPartTextureInfo:setX(self.uiVehicleX:getX() + (self.uiVehicleY:getRight() - self.uiVehicleX:getX()) / 2)
	self:AddElement(self.uiPartTextureInfo)

	self.uiPartTextureAdd = ISButton:new(self.uiPartTexture:getX(), self.uiPartTexture:getY(), self.uiVehicleAdd:getWidth(), h, getText("UI_rLib_VehicleOverlayEditor_PartTextureAdd"), self, self.OnPartTextureAdd)
	self.uiPartTextureAdd:initialise()
	self.uiPartTextureAdd:instantiate()
	self:AddElement(self.uiPartTextureAdd)

	self.uiPartTextureDel = ISButton:new(self.uiVehicleDel:getX(), self.uiPartTextureAdd:getY(), wDel, h, getText("UI_rLib_VehicleOverlayEditor_PartTextureDel"), self, self.OnPartTextureDel)
	self.uiPartTextureDel:initialise()
	self.uiPartTextureDel:instantiate()
	self:AddElement(self.uiPartTextureDel)

	self.uiPartSpotX1 = ISTextEntryBox:new("", self.uiVehiclePrefix:getX(), self.uiPartTexture:getBottom() + pad, (self.uiVehiclePrefix:getWidth() - (pad * 3)) / 4, self.uiVehiclePrefix:getHeight())
	self.uiPartSpotX1.font = self.uiVehiclePrefix.font
	self.uiPartSpotX1:initialise()
	self.uiPartSpotX1:instantiate()
	self.uiPartSpotX1.Var = "x"
	self.uiPartSpotX1.onCommandEntered = self.OnPartSpotXY
	self:AddElement(self.uiPartSpotX1)

	self.uiPartSpotY1 = ISTextEntryBox:new("", self.uiPartSpotX1:getRight() + pad, self.uiPartSpotX1:getY(), self.uiPartSpotX1:getWidth(), self.uiVehiclePrefix:getHeight())
	self.uiPartSpotY1.font = self.uiVehiclePrefix.font
	self.uiPartSpotY1:initialise()
	self.uiPartSpotY1:instantiate()
	self.uiPartSpotY1.Var = "y"
	self.uiPartSpotY1.onCommandEntered = self.OnPartSpotXY
	self:AddElement(self.uiPartSpotY1)

	self.uiPartSpotX2 = ISTextEntryBox:new("", self.uiPartSpotY1:getRight() + pad, self.uiPartSpotY1:getY(), self.uiPartSpotY1:getWidth(), self.uiVehiclePrefix:getHeight())
	self.uiPartSpotX2.font = self.uiVehiclePrefix.font
	self.uiPartSpotX2:initialise()
	self.uiPartSpotX2:instantiate()
	self.uiPartSpotX2.Var = "x2"
	self.uiPartSpotX2.onCommandEntered = self.OnPartSpotXY
	self:AddElement(self.uiPartSpotX2)

	self.uiPartSpotY2 = ISTextEntryBox:new("", self.uiPartSpotX2:getRight() + pad, self.uiPartSpotX2:getY(), self.uiPartSpotX2:getWidth(), self.uiVehiclePrefix:getHeight())
	self.uiPartSpotY2.font = self.uiVehiclePrefix.font
	self.uiPartSpotY2:initialise()
	self.uiPartSpotY2:instantiate()
	self.uiPartSpotY2.Var = "y2"
	self.uiPartSpotY2.onCommandEntered = self.OnPartSpotXY
	self:AddElement(self.uiPartSpotY2)

	self.uiPartSpotAdd = ISButton:new(self.uiPartSpotX1:getX(), self.uiPartSpotX1:getY(), self.uiPartTextureAdd:getWidth(), h, getText("UI_rLib_VehicleOverlayEditor_PartSpotAdd"), self, self.OnPartSpotAdd)
	self.uiPartSpotAdd:initialise()
	self.uiPartSpotAdd:instantiate()
	self:AddElement(self.uiPartSpotAdd)

	self.uiPartSpotDel = ISButton:new(self.uiPartTextureDel:getX(), self.uiPartSpotAdd:getY(), wDel, h, getText("UI_rLib_VehicleOverlayEditor_PartSpotDel"), self, self.OnPartSpotDel)
	self.uiPartSpotDel:initialise()
	self.uiPartSpotDel:instantiate()
	self:AddElement(self.uiPartSpotDel)

	self.uiPartSpotInfo = ISLabel:new(-1, self.uiPartSpotX1:getY(), h, "", 1, 1, 1, 1, UIFont.Small, true)
	self.uiPartSpotInfo:initialise()
	self.uiPartSpotInfo:instantiate()
	self.uiPartSpotInfo.center = true
	self.uiPartSpotInfo:setX(self.uiPartTextureInfo:getX())
	--self.uiPartSpotInfo:setWidth(self.uiPartTextureInfo:getWidth())
	self:AddElement(self.uiPartSpotInfo)

	local wDisplay = getTextManager():MeasureStringX(UIFont.Small, "ISCarMechanicsOverlay") + pad * 2
	local wGenerate = getTextManager():MeasureStringX(UIFont.Small, tGenerate) + pad * 2
	local tGenerate = getText("UI_rLib_VehicleOverlayEditor_Generate")

	wGenerate = math.max(wGenerate, wDisplay)
	wDisplay = math.max(wGenerate, wDisplay)

	self.uiDisplay = ISButton:new(self:getWidth() - (pad * 2) - wDisplay, self.uiPartTexture:getY(), wDisplay, h, "ISCarMechanicsOverlay", self, self.OnDisplay)
	self.uiDisplay:initialise()
	self.uiDisplay:instantiate()
	self:AddElement(self.uiDisplay)

	self.uiGenerate = ISButton:new(self:getWidth() - (pad * 2) - wGenerate, self.uiPartSpotX1:getY(), wGenerate, h, tGenerate, self, self.OnGenerate)
	self.uiGenerate:initialise()
	self.uiGenerate:instantiate()
	self:AddElement(self.uiGenerate)
end

function rLib.UI.VehicleOverlayEditor:prerender()
	ISPanel.prerender(self)
	self:drawRectBorderStatic(0, 0, self:getWidth(), self:getHeight(), self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

	self:UpdateSelectedPart()
end

function rLib.UI.VehicleOverlayEditor:postrender(target, func)
	if self.uiPartSpotX1.Val ~= nil and self.uiPartSpotY1.Val ~= nil and self.uiPartSpotX2.Val ~= nil and self.uiPartSpotY2.Val ~= nil then
		func(target, self.uiPartSpotX1.Val, self.uiPartSpotY1.Val, self.uiPartSpotX2.Val - self.uiPartSpotX1.Val, self.uiPartSpotY2.Val - self.uiPartSpotY1.Val, 0.5, 0, 0.5, 0)
	end
end

function rLib.UI.VehicleOverlayEditor:renderMechanics()
	-- self = ISVehicleMechanics --

	ISCollapsableWindow.render(self)
	if self.isCollapsed then return end

	self:checkEngineFull()
	self:renderCarOverlay()
	self.rLib.VehicleOverlayEditor:postrender(self, self.drawRect)

	local title = self.vehicle:getScript():getFullName()
	if self.rLib.VehicleOverlayEditor.SelectedPart then
		title = title .. " (" .. self.rLib.VehicleOverlayEditor.SelectedPart:getId() .. ")"
	end

	-- TODO convert to editor's label --
	self:drawTextCentre(title, self.xCarTexOffset + 5 + (self.rLib.VehicleOverlayEditor:getWidth() / 2), self:titleBarHeight() + 10 + 5, self.partCatRGB.r, self.partCatRGB.g, self.partCatRGB.b, self.partCatRGB.a, UIFont.Medium)

	if self.drawJoypadFocus and self.leftListHasFocus then
		local ui = self.listbox
		self:drawRectBorder(ui:getX(), ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0)
		self:drawRectBorder(ui:getX()+1, ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0)
	elseif self.drawJoypadFocus then
		local ui = self.bodyworklist
		self:drawRectBorder(ui:getX(), ui:getY(), ui:getWidth(), ui:getHeight(), 0.4, 0.2, 1.0, 1.0)
		self:drawRectBorder(ui:getX()+1, ui:getY()+1, ui:getWidth()-2, ui:getHeight()-2, 0.4, 0.2, 1.0, 1.0)
	end
end

--

function rLib.UI.VehicleOverlayEditor:AddElement(element)
	if element.Type == "ISButton" then
		element.borderColor.a = 0.4
		element.backgroundColor.a = 1
		element.backgroundColorMouseOver.a = 0.7
	elseif element.Type == "ISTextEntryBox" then
		if element.Var then
			element:setOnlyNumbers(true)
			element:setMaxTextLength(4)
		end
	end

	self:addChild(element)
end

function rLib.UI.VehicleOverlayEditor:Show(show)
	if show and type(show) ~= "boolean" then
		show = nil -- required as ISButton pushes itself in front of args --
	end

	if show == nil then
		show = not self:getIsVisible()
	end

	if not self.Vanilla then
		self.Vanilla = {}
		self.Vanilla.render = self.MechanicsUI.render
	end

	self.MechanicsUI.render = show and self.renderMechanics or self.Vanilla.render

	self:DestroyModals()
	self:OnChangeVehicle(self:GetVehicle())
	self:setVisible(show)
end

function rLib.UI.VehicleOverlayEditor:ShowElements(show, enable, ...)
	for _,element in ipairs({...}) do
		if element.Type == "ISButton" then
			element:setEnable(enable)
		else
			element:setEnabled(enable)
		end

		element:setVisible(show)
	end
end

function rLib.UI.VehicleOverlayEditor:ShowMsg(text)
	if self.ModalMsg then
		self.ModalMsg:destroy()
		self.ModalMsg = nil
	end

	self.ModalMsg = ISModalDialog:new(0, 0, 0, 0, text, false)
	self.ModalMsg:initialise()
	self.ModalMsg:setX((getCore():getScreenWidth() / 2) - (self.ModalMsg:getWidth() / 2))
	self.ModalMsg:setY(getCore():getScreenHeight() / 3)
	self.ModalMsg:addToUIManager()
end

function rLib.UI.VehicleOverlayEditor:DestroyModals()
	if self.Modal then
		self.Modal:destroy()
		self.Modal = nil
	end
	if self.ModalMsg then
		self.ModalMsg:destroy()
		self.ModalMsg = nil
	end
end

function rLib.UI.VehicleOverlayEditor:GeneratePartList(codePartial)
	local result = {}
	for part,_ in pairs(codePartial) do
		table.insert(result, part)
	end

	table.sort(result)
	return result
end

function rLib.UI.VehicleOverlayEditor:GenerateSafeAccess(var)
	if string.match(var, "^[A-Za-z0-9_]+$") and not string.match(var, "^[0-9]+") then
		return "." .. var
	end

	return "[\"" .. var .. "\"]"
end

--[[
local ISVM_render = ISVehicleMechanics.render
function ISVehicleMechanics:render()
	ISVM_render(self)

	if self.rLib and self.rLib.VehicleOverlayEditor then
		self.rLib.VehicleOverlayEditor:postrender(self, self.drawRect)
	end
end
]]--

function rLib.UI.VehicleOverlayEditor:GetVehicle()
	assert(instanceof(self.MechanicsUI.vehicle, "BaseVehicle"))

	return self.MechanicsUI.vehicle
end

function rLib.UI.VehicleOverlayEditor:GetVehicleFullName()
	return self:GetVehicle():getScript():getFullName()
end

function rLib.UI.VehicleOverlayEditor:UpdateSelectedPart()
	local selectedPart
	if self.MechanicsUI.listbox.selected > 0 and self.MechanicsUI.listbox.items[self.MechanicsUI.listbox.selected] then
		selectedPart = self.MechanicsUI.listbox.items[self.MechanicsUI.listbox.selected].item.part
	elseif self.MechanicsUI.bodyworklist.selected > 0 and self.MechanicsUI.bodyworklist.items[self.MechanicsUI.bodyworklist.selected] then
		selectedPart = self.MechanicsUI.bodyworklist.items[self.MechanicsUI.bodyworklist.selected].item.part
	end

	if self.SelectedPart ~= selectedPart then
		self.SelectedPart = selectedPart
		self:OnChangeSelectedPart(self.SelectedPart)
	end
end

function rLib.UI.VehicleOverlayEditor:IsCarListOK()
	local vehicleName = self:GetVehicleFullName()

	return ISCarMechanicsOverlay.CarList[vehicleName] ~= nil
end

function rLib.UI.VehicleOverlayEditor:GetCarListData(name)
	assert(rLib.arg(name, "string"))

	local vehicleName = self:GetVehicleFullName()

	if ISCarMechanicsOverlay.CarList[vehicleName] and ISCarMechanicsOverlay.CarList[vehicleName][name] then
		return ISCarMechanicsOverlay.CarList[vehicleName][name]
	end

	return nil
end

function rLib.UI.VehicleOverlayEditor:SetCarListData(name, data)
	assert(rLib.arg(name, "string"))

	local vehicleName = self:GetVehicleFullName()

	ISCarMechanicsOverlay.CarList[vehicleName] =
	ISCarMechanicsOverlay.CarList[vehicleName] or {}

	ISCarMechanicsOverlay.CarList[vehicleName][name] = data

	if data == nil and table.isempty(ISCarMechanicsOverlay.CarList[vehicleName]) then
		ISCarMechanicsOverlay.CarList[vehicleName] = nil
	end
end

function rLib.UI.VehicleOverlayEditor:IsPartListOK(part)
	assert(rLib.arg(part, "VehiclePart"))

	local partId = part:getId()
	local prefix = self:GetCarListData("imgPrefix")
	if not prefix then
		return nil
	end

	return ISCarMechanicsOverlay.PartList[partId] ~= nil and ISCarMechanicsOverlay.PartList[partId].vehicles ~= nil and ISCarMechanicsOverlay.PartList[partId].vehicles[prefix] ~= nil
end

function rLib.UI.VehicleOverlayEditor:GetPartListData(part, name, vanillaFallback)
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(name, "string"))

	local prefix = self:GetCarListData("imgPrefix")
	if not prefix then
		return nil, nil
	end

	local partId = part:getId()

	if name == "img" then
		local vehicleName = self:GetVehicleFullName()

		if ISCarMechanicsOverlay.CarList[vehicleName] and ISCarMechanicsOverlay.CarList[vehicleName].PartList and ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId] and ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId][name] then
			return ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId][name], "vehicle"
		end
	else
		if ISCarMechanicsOverlay.PartList[partId] and ISCarMechanicsOverlay.PartList[partId].vehicles and ISCarMechanicsOverlay.PartList[partId].vehicles[prefix] and ISCarMechanicsOverlay.PartList[partId].vehicles[prefix][name] then
			return ISCarMechanicsOverlay.PartList[partId].vehicles[prefix][name], "part"
		end
	end

	if vanillaFallback then
		local result = self:GetVanillaPartListData(part, name)
		return result, "vanilla"
	end

	return nil, nil
end

function rLib.UI.VehicleOverlayEditor:GetVanillaPartListData(part, name)
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(name, "string"))

	local partId = part:getId()

	if ISCarMechanicsOverlay.PartList[partId] and ISCarMechanicsOverlay.PartList[partId][name] then
		return ISCarMechanicsOverlay.PartList[partId][name]
	end

	return nil
end

function rLib.UI.VehicleOverlayEditor:SetPartListData(part, name, data)
	assert(rLib.arg(part, "VehiclePart"))
	assert(rLib.arg(name, "string"))

	local partId = part:getId()
	local vehicleName = self:GetVehicleFullName()
	local dbgCarList = ISCarMechanicsOverlay.CarList[vehicleName]
	local dbgPartList = ISCarMechanicsOverlay.PartList[partId]

	if name == "img" then
		ISCarMechanicsOverlay.CarList[vehicleName].PartList =
		ISCarMechanicsOverlay.CarList[vehicleName].PartList or {}

		ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId] =
		ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId] or {}

		ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId][name] = data

		if data == nil then
			if table.isempty(ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId]) then
				ISCarMechanicsOverlay.CarList[vehicleName].PartList[partId] = nil
			end

			if table.isempty(ISCarMechanicsOverlay.CarList[vehicleName].PartList) then
				ISCarMechanicsOverlay.CarList[vehicleName].PartList = nil
			end

			-- install failsafe to prevents errors when vanilla script renders custom part without PartList entry --
			if not ISCarMechanicsOverlay.PartList[partId] or ISCarMechanicsOverlay.PartList[partId].img == nil then
				ISCarMechanicsOverlay.PartList[partId] =
				ISCarMechanicsOverlay.PartList[partId] or {}

				ISCarMechanicsOverlay.PartList[partId].img = self.FailsafeCustomPartImg
			end
		else
			-- remove failsafe as it's no longer needed when part have texture set --
			if ISCarMechanicsOverlay.PartList[partId] and ISCarMechanicsOverlay.PartList[partId].img == self.FailsafeCustomPartImg then
				ISCarMechanicsOverlay.PartList[partId].img = nil

				if table.isempty(ISCarMechanicsOverlay.PartList[partId]) then
					ISCarMechanicsOverlay.PartList[partId] = nil
				end
			end
		end
	else
		local prefix = self:GetCarListData("imgPrefix")

		ISCarMechanicsOverlay.PartList[partId] =
		ISCarMechanicsOverlay.PartList[partId] or {}

		ISCarMechanicsOverlay.PartList[partId].vehicles =
		ISCarMechanicsOverlay.PartList[partId].vehicles or {}

		ISCarMechanicsOverlay.PartList[partId].vehicles[prefix] =
		ISCarMechanicsOverlay.PartList[partId].vehicles[prefix] or {}

		ISCarMechanicsOverlay.PartList[partId].vehicles[prefix][name] = data

		if data == nil and table.isempty(ISCarMechanicsOverlay.PartList[partId].vehicles[prefix]) then
			ISCarMechanicsOverlay.PartList[partId].vehicles[prefix] = nil

			if table.isempty(ISCarMechanicsOverlay.PartList[partId].vehicles) then
				ISCarMechanicsOverlay.PartList[partId].vehicles = nil
			end

			if table.isempty(ISCarMechanicsOverlay.PartList[partId]) then
				ISCarMechanicsOverlay.PartList[partId] = nil
			end
		end
	end
end

--

function rLib.UI.VehicleOverlayEditor:GetPrefixTextureName(name)
	name = "media/ui/vehicles/mechanic overlay/" .. name .. "base.png"

	return name, getTexture(name) ~= nil
end

function rLib.UI.VehicleOverlayEditor:GetPartTextureName(name)
	local prefix = self:GetCarListData("imgPrefix")
	if not prefix then
		return nil, false
	end

	name = "media/ui/vehicles/mechanic overlay/" .. prefix .. name .. ".png"

	return name, getTexture(name) ~= nil
end

--

function rLib.UI.VehicleOverlayEditor:OnChangeVehicle(vehicle)
	assert(rLib.arg(vehicle, "BaseVehicle"))

	local prefix = self:GetCarListData("imgPrefix")
	local x = self:GetCarListData("x")
	local y = self:GetCarListData("y")

	local valid = prefix ~= nil and x ~= nil and y ~= nil

	if valid then
		self.uiVehiclePrefix:setText(prefix)
		self.uiVehiclePrefix.Previous = prefix
		self.uiVehicleX:setText(tostring(x))
		self.uiVehicleY:setText(tostring(y))
	end

	self:ShowElements(not valid, not valid, self.uiVehicleAdd)
	self:ShowElements(valid, valid, self.uiVehicleDel, self.uiVehiclePrefix, self.uiVehicleX, self.uiVehicleY, self.uiGenerate)

	self.SelectedPart = "invalidate"
	self:UpdateSelectedPart()
end

function rLib.UI.VehicleOverlayEditor:OnChangeSelectedPart(part)
	assert(rLib.arg(part, "VehiclePart", "nil"))

	local prefix = self:GetCarListData("imgPrefix")

	-- texture --

	local texture

	if not part then
		self:ShowElements(false, false, self.uiPartTextureAdd, self.uiPartTextureDel, self.uiPartTexture, self.uiPartTextureInfo)
	elseif part and prefix then
		local textureSource
		texture, textureSource = self:GetPartListData(part, "img", true)
		if textureSource == "vanilla" and texture == self.FailsafeCustomPartImg then -- see SetPartListData() --
			texture, textureSource = nil, nil
		end
		if texture ~= nil and textureSource ~= nil then
			self.uiPartTexture:setText(texture)
			self.uiPartTexture.Previous = texture

			self.uiPartTextureInfo.name = textureSource == "vanilla" and getText("UI_rLib_VehicleOverlayEditor_default") or getText("UI_rLib_VehicleOverlayEditor_custom")
			self:ShowElements(true, textureSource ~= "vanilla", self.uiPartTextureDel)
			self:ShowElements(true, true, self.uiPartTexture, self.uiPartTextureInfo)
			self:ShowElements(false, false, self.uiPartTextureAdd, self.uiPartTextureAddCheck)
			texture = true
		else
			self:ShowElements(true, true, self.uiPartTextureAdd)
			self:ShowElements(false, false, self.uiPartTextureDel, self.uiPartTexture, self.uiPartTextureInfo)
			texture = false
		end
	else
		self:ShowElements(true, false, self.uiPartTextureAdd)
		self:ShowElements(false, false, self.uiPartTextureAddCheck, self.uiPartTextureDel, self.uiPartTexture, self.uiPartTextureInfo)
	end

	-- hotspot --

	local spot = false

	for _,ui in ipairs({ self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2 }) do
		ui.Val = nil
	end

	if not part then
		self:ShowElements(false, false, self.uiPartSpotAdd, self.uiPartSpotDel, self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2, self.uiPartSpotInfo)
	elseif texture then
		local x1, x1Source = self:GetPartListData(part, "x", true)
		local y1, y1Source = self:GetPartListData(part, "y", true)
		local x2, x2Source = self:GetPartListData(part, "x2", true)
		local y2, y2Source = self:GetPartListData(part, "y2", true)
		local sameSource = x1Source == y1Source and y1Source == x2Source and x2Source == y2Source
		spot = x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil
		if spot and sameSource then
			for _,ui in ipairs({ self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2 }) do
				ui.Val = self:GetPartListData(part, ui.Var, true)
				ui:setText(tostring(ui.Val))
			end

			self.uiPartSpotInfo.name = x1Source == "vanilla" and getText("UI_rLib_VehicleOverlayEditor_default") or getText("UI_rLib_VehicleOverlayEditor_custom")
			self:ShowElements(false, false, self.uiPartSpotAdd)
			self:ShowElements(true, x1Source ~= "vanilla", self.uiPartSpotDel)
			self:ShowElements(true, true, self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2, self.uiPartSpotInfo)
			spot = true
		else
			self:ShowElements(true, true, self.uiPartSpotAdd)
			self:ShowElements(false, false, self.uiPartSpotDel, self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2, self.uiPartSpotInfo)
			spot = false
		end
	else
		self:ShowElements(true, false, self.uiPartSpotAdd)
		self:ShowElements(false, false, self.uiPartSpotDel, self.uiPartSpotX1, self.uiPartSpotY1, self.uiPartSpotX2, self.uiPartSpotY2, self.uiPartSpotInfo)
	end
end

function rLib.UI.VehicleOverlayEditor:OnVehiclePrefix()
	local name, valid = self:getParent():GetPrefixTextureName(self:getText())
	local vehicle = self:getParent():GetVehicle()

	if not vehicle then
		return
	end

	if self:getText() == "" then
		self:getParent():ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameEmpty"))
		self:setText(self.Previous)
		return
	end

	if not valid then
		self:getParent():ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameInvalid", name))
		self:setText(self.Previous)
		return
	end

	self:getParent():SetCarListData("imgPrefix", self:getText())
	self:getParent():OnChangeVehicle(vehicle)
end

function rLib.UI.VehicleOverlayEditor:OnVehicleXY()
	local vehicle = self:getParent():GetVehicle()

	if not vehicle then
		return
	end

	self:getParent():SetCarListData(self.Var, tonumber(self:getText()))
	self:getParent():OnChangeVehicle(vehicle)
end

function rLib.UI.VehicleOverlayEditor:OnVehicleAdd()
	self:DestroyModals()

	self.Modal = ISModalDialog:new(0, 0, 0, 0, getText("UI_rLib_VehicleOverlayEditor_VehiclePrefixNew"), true, self, self.OnVehicleAddCheck)
	self.Modal:initialise()
	self.Modal:setX((getCore():getScreenWidth() / 2) - (self.Modal:getWidth() / 2))
	self.Modal:setY(getCore():getScreenHeight() / 3)

	local pad = self.Modal:getHeight() - self.Modal.yes:getBottom()

	self.Modal.uiVehiclePrefixNew = ISTextEntryBox:new("", pad, self.Modal.yes:getY(), self.Modal:getWidth() - pad * 2, rLib.UI.FontSize.Small + 4)
	self.Modal.uiVehiclePrefixNew:initialise()
	self.Modal.uiVehiclePrefixNew:instantiate()
	self.Modal.uiVehiclePrefixNew.onCommandEntered = self.OnVehicleAddCheck
	self.Modal:addChild(self.Modal.uiVehiclePrefixNew)

	self.Modal.yes:setEnable(false)
	self.Modal.yes:setTitle(getText("UI_btn_accept"))
	self.Modal.no:setTitle(getText("UI_btn_cancel"))
	self.Modal:setHeight(self.Modal.uiVehiclePrefixNew:getBottom() + pad + self.Modal.yes:getHeight() + pad)

	self.Modal.Editor = self
	self.Modal:addToUIManager()
end

function rLib.UI.VehicleOverlayEditor:OnVehicleAddCheck(button) -- handles text entry and buttons events --
	if button then
		if button.internal == "YES" then
			local editor = button:getParent().Editor
			local vehicle = editor:GetVehicle()

			if not vehicle then
				return
			end

			editor:SetCarListData("imgPrefix", button:getParent().uiVehiclePrefixNew:getText())
			editor:SetCarListData("x", 0)
			editor:SetCarListData("y", 0)
			editor:OnChangeVehicle(vehicle)
			editor:DestroyModals()
		end
		return
	end

	local editor = self:getParent().Editor
	if self:getText() == "" then
		self:getParent().yes:setEnable(false)
		return editor:ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameEmpty"))
	end

	local name, valid = self:getParent().Editor:GetPrefixTextureName(self:getText())
	if not valid then
		self:getParent().yes:setEnable(false)
		return editor:ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameInvalid", name))
	end

	-- TODO UI_rLib_VehicleOverlayEditor_WarningPrefixInUse --

	self:getParent().yes:setEnable(true)
end

function rLib.UI.VehicleOverlayEditor:OnVehicleDel()
	local vehicle = self:GetVehicle()
	if not vehicle then
		return
	end

	for p=0,vehicle:getPartCount()-1 do
		for _,name in ipairs({"x", "y", "x2", "y2", "img"}) do
			self:SetPartListData(vehicle:getPartByIndex(p), name, nil)
		end
	end

	for _,name in ipairs({"imgPrefix", "x", "y"}) do
		self:SetCarListData(name, nil)
	end

	self:OnChangeVehicle(vehicle)
end

--

function rLib.UI.VehicleOverlayEditor:OnPartTexture(ui)
	if not self.SelectedPart then
		return
	end

	local data = ui:getText()
	if data == "" then
		data = nil
	end

	local img = self:GetVanillaPartListData(self.SelectedPart, "img")

	if not data then
		self:ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameEmpty"))
		ui:setText(ui.Previous)
		return
	else
		local name, valid = self:GetPartTextureName(data)
		if not valid then
			self:ShowMsg(getText("UI_rLib_VehicleOverlayEditor_ErrorTextureNameInvalid", name))
			ui:setText(ui.Previous)
			return
		end

		ui.Previous = data
	end

	if data and data == img then
		data = nil
	end

	self:SetPartListData(self.SelectedPart, "img", data)
	self:OnChangeSelectedPart(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartTextureWrapper()
	self:getParent():OnPartTexture(self)
end

function rLib.UI.VehicleOverlayEditor:OnPartTextureAdd(button)
	if not self.SelectedPart then
		return
	end

	self:SetPartListData(self.SelectedPart, "img", "base")
	self:OnChangeSelectedPart(self.SelectedPart)

	if ISCarMechanicsOverlay.PartList[self.SelectedPart:getId()] == nil then
		self:OnPartSpotAdd(button)
	end
end

function rLib.UI.VehicleOverlayEditor:OnPartTextureDel(button)
	if not self.SelectedPart then
		return
	end

	self:OnPartSpotDel()
	self:SetPartListData(self.SelectedPart, "img", nil)
	self:OnChangeSelectedPart(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartSpotAdd(button)
	if not self.SelectedPart then
		return
	end

	for _,name in ipairs({ "x", "y", "x2", "y2" }) do
		self:SetPartListData(self.SelectedPart, name, 0)
	end
	self:OnChangeSelectedPart(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartSpotDel(button)
	if not self.SelectedPart then
		return
	end

	for _,name in ipairs({ "x", "y", "x2", "y2" }) do
		self:SetPartListData(self.SelectedPart, name, nil)
	end
	self:OnChangeSelectedPart(self.SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnPartSpotXY()
	if not self:getParent().SelectedPart then
		return
	end

	self.Val = tonumber(self:getText())

	-- fully copy coords into vehicle-specific table when editing default coords --
	for _,ui in ipairs({ self:getParent().uiPartSpotX1, self:getParent().uiPartSpotY1, self:getParent().uiPartSpotX2, self:getParent().uiPartSpotY2 }) do
		self:getParent():SetPartListData(self:getParent().SelectedPart, ui.Var, ui.Val)
	end

	self:setText(tostring(self.Val)) -- remove leading zeros --

	self:getParent():OnChangeSelectedPart(self:getParent().SelectedPart)
end

function rLib.UI.VehicleOverlayEditor:OnDisplay(button)
	local raw = ObjectViewer:new(getCore():getScreenWidth() / 2, 0, 600, 400, ISCarMechanicsOverlay)
	raw:initialise()
	raw:addToUIManager()
	raw.objectView.onRightMouseDown = nil
end

function rLib.UI.VehicleOverlayEditor:OnGenerate(button)
	local code, codeImg, codeCoord, parts = {}, {}, {}

	local vehicle = self:GetVehicle()
	local vehicleName = self:GetVehicleFullName()
	local carList = string.format("ISCarMechanicsOverlay.CarList[\"%s\"]", vehicleName)
	local prefix = self:GetCarListData("imgPrefix")
	local func = string.format( "%sMechanicsOverlay", vehicleName:gsub("%.", ""))
	local partList = ""

	table.insert(code, "--[[*]]-- Generated automagically by RotatorsLib --[[*]]--")
	table.insert(code, "")
	table.insert(code, "require \"Vehicles/ISUI/ISCarMechanicsOverlay\"")
	table.insert(code, "")
	table.insert(code, string.format("local function %s()", func))

	if self:IsCarListOK() then
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

				codeImg[partId] = string.format("\t%s.PartList%s = { %simg = %s%s%s }", carList, self:GenerateSafeAccess(partId), multi, quote, rLib.tostring(img), quote)
			end

			if self:IsPartListOK(part) then
				local x1, y1, x2, y2 = self:GetPartListData(part, "x"), self:GetPartListData(part, "y"), self:GetPartListData(part, "x2"), self:GetPartListData(part, "y2")
				if x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
					codeCoord[partId] = string.format("\tISCarMechanicsOverlay.PartList%s.vehicles%s = { x = %d, y = %d, x2 = %d, y2 = %d }", self:GenerateSafeAccess(partId), self:GenerateSafeAccess(prefix), x1, y1, x2, y2)
				end
			end
		end

		if not table.isempty(codeCoord) then
			parts = self:GeneratePartList(codeCoord)
			table.insert(code, "\tfor _,name in ipairs({ \"" .. table.concat(parts, "\", \"") .. "\" }) do")
			table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name] = ISCarMechanicsOverlay.PartList[name] or {}")
			table.insert(code, "\t\tISCarMechanicsOverlay.PartList[name].vehicles = ISCarMechanicsOverlay.PartList[name].vehicles or {}")
			table.insert(code, "\tend")
			table.insert(code, "")
		end

		if not table.isempty(codeImg) then
			partList = ", PartList = {}"
		end

		table.insert(code, string.format("\t%s = { imgPrefix = \"%s\", x = %d, y = %d%s }", carList, prefix, self:GetCarListData("x"), self:GetCarListData("y"), partList))

		if not table.isempty(codeImg) then
			parts = self:GeneratePartList(codeImg)
			for _,id in ipairs(parts) do
				table.insert(code, codeImg[id])
			end
		end

		if not table.isempty(codeCoord) then
			parts = self:GeneratePartList(codeCoord)
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

---

function rLib.UI.VehicleOverlayEditor.Enable(ui) -- called from mods --
	if ui and ui:isVisible() and ui.rLib and ui.rLib.VehicleOverlayEditorButton then
		ui.rLib.VehicleOverlayEditorButton:setVisible(true)
	end
end

function rLib.UI.VehicleOverlayEditor.OnTry(ui, visible)
	if getDebug() and visible then
		rLib.UI.VehicleOverlayEditor.Enable(ui)
		rLib.Events.Off("Vehicle.MechanicsSetVisible", rLib.UI.VehicleOverlayEditor.OnTry)
	end
end

function rLib.UI.VehicleOverlayEditor.Try() -- called from console --
	local player = getPlayer()
	if not player then
		return
	end

	local vehicle = player:getVehicle() or player:getNearVehicle()
	if not vehicle then
		return
	end

	local ui = getPlayerMechanicsUI(player:getPlayerNum())
	if ui:isReallyVisible() then
		ui:close()
	end

	rLib.Events.On("Vehicle.MechanicsSetVisible", rLib.UI.VehicleOverlayEditor.OnTry)
	ISVehicleMenu.onMechanic(player, vehicle)
end

---

local function OnMechanicsSetVisible(ui, visible)
	if not ui.rLib or not ui.rLib.VehicleOverlayEditor then
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

			ui.rLib = ui.rLib or {}

			ui.rLib.VehicleOverlayEditor = rLib.UI.VehicleOverlayEditor:new(ui)
			ui.rLib.VehicleOverlayEditor:initialise()
			ui.rLib.VehicleOverlayEditor:instantiate()
			ui:addChild(ui.rLib.VehicleOverlayEditor)

			ui.rLib.VehicleOverlayEditorButton = ISButton:new(x, 0, textWidth, h, text, ui.rLib.VehicleOverlayEditor, ui.rLib.VehicleOverlayEditor.Show)
			ui.rLib.VehicleOverlayEditorButton:initialise()
			ui.rLib.VehicleOverlayEditorButton.borderColor.a = 0.0
			ui.rLib.VehicleOverlayEditorButton.backgroundColor.a = 0.1
			ui.rLib.VehicleOverlayEditorButton.backgroundColorMouseOver.a = 0.7
			ui:addChild(ui.rLib.VehicleOverlayEditorButton)
		end
	end

	ui.rLib.VehicleOverlayEditor:Show(false)
	ui.rLib.VehicleOverlayEditorButton:setVisible(false)
end

rLib.Events.On("Vehicle.MechanicsSetVisible", OnMechanicsSetVisible)
