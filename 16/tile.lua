-- TODO Get next_direction of the beam
-- 	See how to express direction for input
-- TODO Map interaction in functional manner to trace the beam.
-- 	No need of an object there, right?
-- 	Think of local score increment.

---@alias orientation
---| "."
---| "/"
---| "\\"
---| "|"
---| "-"

---Build a Tile table based on the char in the map
---@param char? orientation
---@return Tile
local function _builder(char)
	if not char then
		return {}
	end

	return {
		state = char
	}
end

---@class  Tile
---@field state orientation
local Tile = _builder()

function Tile:new(char)
	local _tile = _builder(char)

	self.__index = self
	setmetatable(_tile, self)

	return _tile
end

---@alias direction
---| 'right'
---| 'left'
---| 'up'
---| 'down'

---Get out_direction based on the state of the tile and the in
---input direction.
---@param in_direction direction
---@return number count  number of direction returned
---@return direction ...
function Tile:next_direction(in_direction)
	if self.state == '.' then
		return 1, in_direction
	end

	if in_direction == 'right' then
		if self.state == '|' then return 2, 'up', 'down' end
		if self.state == '/' then return 1, 'up' end
		if self.state == '\\' then return 1, 'down' end
		if self.state == '-' then return 1, in_direction end
	end
	if in_direction == 'left' then
		if self.state == '|' then return 2, 'up', 'down' end
		if self.state == '/' then return 1, 'down' end
		if self.state == '\\' then return 1, 'up' end
		if self.state == '-' then return 1, in_direction end
	end
	if in_direction == 'down' then
		if self.state == '|' then return 1, in_direction end
		if self.state == '/' then return 1, 'left' end
		if self.state == '\\' then return 1, 'right' end
		if self.state == '-' then return 2, 'right', 'left' end
	end
	if in_direction == 'up' then
		if self.state == '|' then return 1, in_direction end
		if self.state == '/' then return 1, 'right' end
		if self.state == '\\' then return 1, 'left' end
		if self.state == '-' then return 2, 'right', 'left' end
	end

	error("No mapping found for state " .. self.state .. " and input direction " .. in_direction .. ".")
end

return Tile
