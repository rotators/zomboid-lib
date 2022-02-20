--[[*]]-- RotatorsLib --[[*]]--

require "Vehicles/ISUI/ISVehicleMechanics"
require "Vehicles/ISUI/ISVehicleMenu"
require "Vehicles/TimedActions/ISAttachTrailerToVehicle"
require "Vehicles/TimedActions/ISDetachTrailerFromVehicle"

require "rLib.Shared"

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

--[[ISAttachTrailerToVehicle.lua v41.65]] rLib.Events.Add("Vehicle.AttachVehicle")

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

--[[ISDetachTrailerFromVehicle.lua v41.65]] rLib.Events.Add("Vehicle.DetachVehicle")

function ISDetachTrailerFromVehicle:perform()
	local vehicleB = self.vehicle:getVehicleTowing()

	Vanilla.ISDetachTrailerFromVehicle.perform(self)

	rLib.Events.Run("Vehicle.DetachVehicle", self.character, self.vehicle, vehicleB)
end

--[[ISVehicleMechanics.lua v41.65]] rLib.Events.Add("Vehicle.MechanicsSetVisible")

function ISVehicleMechanics:setVisible(visible, ...)
	Vanilla.ISVehicleMechanics.setVisible(self, visible, ...)

	if instanceof(self.vehicle, "BaseVehicle") then -- skip during player data generation --
		rLib.Events.Run("Vehicle.MechanicsSetVisible", self, visible)
	end
end

--[[ISVehicleMenu v41.65]] rLib.Events.Add("Vehicle.ToggleHeadlights")

function ISVehicleMenu.onToggleHeadlights(player)
	Vanilla.ISVehicleMenu.onToggleHeadlights(player)

	local vehicle = player:getVehicle()
	if not vehicle then
		return
	end

	-- TODO server synch --

	rLib.Events.Run("Vehicle.ToggleHeadlights", player, vehicle)
end
