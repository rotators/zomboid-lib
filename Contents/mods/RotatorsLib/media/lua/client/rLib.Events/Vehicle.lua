--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/ISUI/ISVehicleMechanics"
require "Vehicles/ISUI/ISVehicleMenu"
require "Vehicles/TimedActions/ISAttachTrailerToVehicle"
require "Vehicles/TimedActions/ISDetachTrailerFromVehicle"

require "rLib.Shared"

if rLib.mod("tsarslib") then
	require "CommonTemplates/ISUI/ISCommonMenu"
end

local Vanilla =
{
	ISAttachTrailerToVehicle =
	{
		perform = ISAttachTrailerToVehicle.perform
	},
	ISDetachTrailerFromVehicle =
	{
		perform = ISDetachTrailerFromVehicle.perform
	},
	ISVehicleMechanics =
	{
		setVisible = ISVehicleMechanics.setVisible
	},
	ISVehicleMenu =
	{
		onToggleHeadlights = ISVehicleMenu.onToggleHeadlights
	}
}

local Mods =
{
	-- tsarlib --
	ISCommonMenu =
	{
		onAttachTrailer = nil,
		onDetachTrailer = nil
	}
}

if type(ISCommonMenu) == "table"
	Mods.ISCommonMenu.onAttachTrailer = ISCommonMenu.onAttachTrailer
	Mods.ISCommonMenu.onDetachTrailer = ISCommonMenu.onDetachTrailer
end

--[[ISAttachTrailerToVehicle.lua v41.66]] rLib.Events.Add("Vehicle.AttachVehicle")

function ISAttachTrailerToVehicle:perform()
	local emit = false

	local square = self.vehicleA:getCurrentSquare()
	local vehicleB = ISVehicleTrailerUtils.getTowableVehicleNear(square, self.vehicleA, self.attachmentA, self.attachmentB)
	if vehicleB == self.vehicleB then
		emit = true
	end

	Vanilla.ISAttachTrailerToVehicle.perform(self)

	if emit then
		rLib.Events.Run("Vehicle.AttachVehicle", self.character, self.vehicleA, self.vehicleB)
	end
end

--[[ISDetachTrailerFromVehicle.lua v41.66]] rLib.Events.Add("Vehicle.DetachVehicle")

function ISDetachTrailerFromVehicle:perform()
	local vehicleB = self.vehicle:getVehicleTowing()

	Vanilla.ISDetachTrailerFromVehicle.perform(self)

	rLib.Events.Run("Vehicle.DetachVehicle", self.character, self.vehicle, vehicleB)
end

--[[ISVehicleMechanics.lua v41.66]] rLib.Events.Add("Vehicle.MechanicsSetVisible")

function ISVehicleMechanics:setVisible(visible, ...)
	Vanilla.ISVehicleMechanics.setVisible(self, visible, ...)

	-- skip running event during player data generation --
	if instanceof(self.vehicle, "BaseVehicle") then
		rLib.Events.Run("Vehicle.MechanicsSetVisible", self, visible)
	end
end

--[[ISVehicleMenu v41.66]] rLib.Events.Add("Vehicle.ToggleHeadlights")

function ISVehicleMenu.onToggleHeadlights(player)
	Vanilla.ISVehicleMenu.onToggleHeadlights(player)

	local vehicle = player:getVehicle()
	if not vehicle then
		return
	end

	-- TODO server synch --

	rLib.Events.Run("Vehicle.ToggleHeadlights", player, vehicle)
end

--

function ISCommonMenu.onAttachTrailer(player, vehicleA, vehicleB, ...)
	Mods.ISCommonMenu.onAttachTrailer(player, vehicleA, vehicleB, ...)

	if not vehicleB then
		return
	end

	rLib.Events.Run("Vehicle.AttachVehicle", player, vehicleA, vehicleB)
end

function ISCommonMenu.onDetachTrailer(player, vehicleA, ...)
	ISCM_onDetachTrailer(player, vehicleA, ...)

	rLib.Events.Run("Vehicle.DetachVehicle", player, vehicleA, vehicleA:getVehicleTowing())
end
