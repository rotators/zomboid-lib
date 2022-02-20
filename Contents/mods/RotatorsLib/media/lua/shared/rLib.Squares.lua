--[[*]]-- RotatorsLib --[[*]]--

require "rLib"

rLib.Squares = {}

function rLib.Squares.GetClosestTo(targetSquare, squares)
	local closest = nil
	local closestDist = 1000000
	for _,square in ipairs(squares) do
		local dist = IsoUtils.DistanceTo(targetSquare:getX(), targetSquare:getY(), square:getX() + 0.5, square:getY() + 0.5)
		if dist < closestDist then
			closest = square
			closestDist = dist
		end
	end

	return closest
end

return rLib.Squares
