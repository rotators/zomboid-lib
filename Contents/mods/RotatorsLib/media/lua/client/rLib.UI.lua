require "rLib.SidePanel"

rLib.UI = {}

function rLib.UI.Click()
	rLib.dprint("Click!")
end

function rLib.UI.Init()
	local button = rLib.SidePanel.AddButton("media/ui/rLib/rotators-40x40.png", nil, rLib.UI.Click)
	button:setX(5)
end

if getDebug() then
	--Events.OnGameStart.Add(rLib.UI.Init)
end

return rLib.UI
