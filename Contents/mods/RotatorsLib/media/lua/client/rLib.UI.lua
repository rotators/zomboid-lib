--[[*]]-- RotatorsLib --[[*]]--

require "rLib.SidePanel"

rLib.UI =
{
	FontSize =
	{
		Small = getTextManager():getFontHeight(UIFont.Small),
		Medium = getTextManager():getFontHeight(UIFont.Medium)
	}
}

function rLib.UI.UpdateAndCall(func, ...)
	-- allows to call functions which check radial menu visibility (such as ISVehicleMenu.showRadialMenu()) directly from radial:addSlice(...) --
	UIManager.update()

	func(...)
end

-- WIP --

function rLib.UI.Click()
	rLib.dprint("Click!")
end

local R

function rLib.UI.Init()
	if not R then
		R = rLib.SidePanel.AddButton("media/ui/rLib/rotators-40x40.png", nil, rLib.UI.Click)
		R:setX(5)
	end
end

function rLib.UI.Finish()
	if R then
		rLib.SidePanel.RemoveButton(R)
		R = nil
	end
end

return rLib.UI
