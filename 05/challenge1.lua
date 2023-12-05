local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

-- [
-- Parameters:
-- line (string) map line with 3 numbers
--
-- Returns:
-- (table) {start_range_destination, start_range_source, length}
-- ]
local function get_line_map(line)
	local map = {}
	local count = 1
	for match in line:gmatch("%d+") do
		if count == 1 then
			map.destination_start = tonumber(match)
		elseif count == 2 then
			map.source_start = tonumber(match)
		elseif count == 3 then
			map.length = tonumber(match)
		end

		count = count + 1
	end

	return map
end

local function pass_seed_through_map(seed, maps)
	for i_map = 1, #maps do
		local relative_seed = seed - maps[i_map].source_start
		if  relative_seed >= 0 and relative_seed < maps[i_map].length then
			return maps[i_map].destination_start + relative_seed
		end
	end

	return seed
end

local count_map_category = 0
local count_map = 0
local is_first_line = true
local maps_arrays = {}
local seeds = {}
local result
-- Create maps
for line in file:lines() do

	-- Seed line
	if is_first_line then
		for seed in line:gmatch("%d+") do
			seeds[#seeds+1] = tonumber(seed)
		end

		is_first_line = false
		goto new_line
	end

	-- Do nothing on empty line
	if #line == 0 then
		goto new_line
	end

	-- New map category
	result = line:match(":")
	if result then
		-- Set up next array of maps
		count_map_category = count_map_category + 1
		maps_arrays[count_map_category] = {}
		-- Rest count map for the new array
		count_map = 1
		goto new_line
	end

	-- Add map to its array
	maps_arrays[count_map_category][count_map] = get_line_map(line)
	count_map = count_map + 1

	::new_line::
end

local min_seed = 999999999999
-- Pass each seed through maps and keep minimum
for i_seed = 1, #seeds do
	local seed = seeds[i_seed]

	for i_map_category = 1, #maps_arrays do
		-- Get next seed number
		seed = pass_seed_through_map(seed, maps_arrays[i_map_category])
	end

	if seed < min_seed then
		min_seed = seed
	end
end

print(min_seed)
file:close()
