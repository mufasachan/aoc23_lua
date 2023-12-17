-- TODO Implement a queue to manage the loop
-- Consume a queue and copy the new reference to the queue
-- Each iteration can give zero, one or two elements (do not return array)
local Beam = require "beam"

---@alias tile_status { tile: Tile, is_visited: boolean }
---@alias tiles_map tile_status[][]

---Build a Tile table based on the char in the map
---@param tiles_map tiles_map
---@return Contraptor
local function _builder(tiles_map)
	return {
		tiles_map = tiles_map,
		width = #tiles_map,
		height = #tiles_map[1],
	}
end

---@class Contraptor
---@field tiles_map tiles_map
---@field width number
---@field height number
local Contraptor = {}

---Create a new contraptor
---@param tiles_map tile_status[][]
---@return Contraptor
function Contraptor:new(tiles_map)
	local _contraptor = _builder(tiles_map)

	self.__index = self
	setmetatable(_contraptor, self)

	return _contraptor
end

---Check if a beam is out of bound of the map
---@param beam Beam
---@return boolean
function Contraptor:beam_is_in(beam)
	local is_in = (
		beam.row <= self.width and
		beam.col <= self.height and
		beam.row > 0 and
		beam.col > 0
	)

	if is_in then
		self.tiles_map[beam.row][beam.col].is_visited = true
	end

	return is_in
end

---Contrapt one beam
---Based on the internal maps of tiles, update the beam.
---The beam can continue, be deleted or double.
---The beam state is updated in place.
---The only return value is one there is a new beam.
---@param beam Beam
---@return number # Number of new beams
---@return Beam  ...
function Contraptor:contrapt_one_beam(beam)
	local row, col = beam.row, beam.col
	local tile_status = self.tiles_map[row][col]

	local count_direction, direction_1, direction_2 = tile_status.tile:next_direction(beam.direction)

	---@type Beam|nil
	local new_beam
	if count_direction == 2 then
		new_beam = Beam:copy(beam):update(direction_2)
	end
	beam:update(direction_1)

	if new_beam and self:beam_is_in(new_beam) and self:beam_is_in(beam) then
		return 2, beam, new_beam
	end

	if new_beam and self:beam_is_in(new_beam) then
		return 1, new_beam
	end

	if self:beam_is_in(beam) then
		return 1, beam
	end

	return 0
end

---Contrapt an array of beams.
---Return the new valid beam
---@param beams Beam[]
---@return Beam[] new_beams
function Contraptor:one_step(beams)
	local new_beams = {}

	for i = 1, #beams do
		local count_beams, beam_1, beam_2 = self:contrapt_one_beam(beams[i])

		if count_beams >= 1 then
			new_beams[#new_beams + 1] = beam_1
			if count_beams == 2 then
				new_beams[#new_beams + 1] = beam_2
			end
		end
	end

	return new_beams
end

return Contraptor
