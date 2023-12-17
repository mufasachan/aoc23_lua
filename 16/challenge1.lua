local Tile = require "tile"
local Contraptor = require "contraptor"
local Beam = require "beam"
local lib = require "lib"
local matrix_from_file = lib.matrix_from_file
local mequal = lib.mequal
local mcopy = lib.mcopy

local function tiles_map_score(tiles_map)
	local score = 0

	for i = 1, #tiles_map do
		for j = 1, #tiles_map[i] do
			local tile_status = tiles_map[i][j]
			score = (tile_status.is_visited and score + 1) or score
		end
	end

	return score
end


---t1 == t2
---@param t1 tile_status
---@param t2 tile_status
---@return boolean
local function is_same_tile_status(t1, t2)
	return t1.is_visited == t2.is_visited
end

local function is_known_by_memory(tiles_map, tiles_map_memory)
	for i = 1, #tiles_map_memory do
		if mequal(tiles_map, tiles_map_memory[i], is_same_tile_status) then
			return true
		end
	end

	return false
end

---Copy tile status element
---@param tile_status tile_status
---@return tile_status
local function copy_tile_status(tile_status)
	return { tile = tile_status.tile, is_visited = tile_status.is_visited }
end

local input = matrix_from_file("input")

---@type tile_status[][]
local tiles_map = {}
for i = 1, #input do
	local tiles_status = {}
	for j = 1, #input[1] do
		tiles_status[#tiles_status + 1] = {
			tile = Tile:new(input[i][j]),
			is_visited = false,
		}
	end
	tiles_map[#tiles_map + 1] = tiles_status
end

-- Init initial beam
local init_beam = Beam:new()
tiles_map[init_beam.row][init_beam.col].is_visited = true

local contraptor = Contraptor:new(tiles_map)
local beams = { init_beam }

local tiles_map_memory = {}
local i = 1
local stale_length = 0
local max_state_length = 10
repeat
	beams = contraptor:one_step(beams)

	local is_known = is_known_by_memory(tiles_map, tiles_map_memory)

	if is_known then
		stale_length = stale_length + 1
	else
		tiles_map_memory[#tiles_map_memory + 1] = mcopy(tiles_map, copy_tile_status)
		i = i + 1
		stale_length = 0
	end
until stale_length > max_state_length

local score = tiles_map_score(tiles_map)
print("Score: " .. score)
