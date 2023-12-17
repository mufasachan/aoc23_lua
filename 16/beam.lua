---Beam builder
---@param row? number
---@param col? number
---@param direction? direction
---@return Beam
local function _builder(row, col, direction)
	if not row and not col and not direction then
		return { row = 1, col = 1, direction = 'right' }
	end

	return { row = row, col = col, direction = direction }
end

---@class Beam
---@field row number
---@field col number
---@field direction direction
local Beam = {}

---@param row? number
---@param col? number
---@param direction? direction
---@return Beam
function Beam:new(row, col, direction)
	local beam = _builder(row, col, direction)

	self.__index = self
	setmetatable(beam, self)

	return beam
end

---Update the state of the beam with a new direction
---@param direction direction
function Beam:update(direction)
	self.direction = direction

	if direction == 'right' then self.col = self.col + 1 end
	if direction == 'left' then self.col = self.col - 1 end
	if direction == 'down' then self.row = self.row + 1 end
	if direction == 'up' then self.row = self.row - 1 end

	return self
end

---Create a copy of a beam
---@param beam Beam
---@return Beam
function Beam:copy(beam)
	local new_beam = Beam:new(beam.row, beam.col, beam.direction)
	return new_beam
end

function Beam:__tostring()
	return string.format("Beam(%d, %d, %s)", self.row, self.col, self.direction)
end

function Beam:__eq(b2)
	return (
		self.row == b2.col and
		self.col == b2.col and
		self.direction == b2.direction
	)
end

return Beam
