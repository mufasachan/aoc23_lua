local Queue = require("queue")

local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local t1 = os.clock()

local function create_seed_range(head, tail)
	if head > tail then
		os.exit()
	end
	local seed_range = {
		head = head,
		tail = tail,
	}
	seed_range.length = seed_range.tail - seed_range.head + 1

	return seed_range
end

-- [
-- Parameters:
-- line (string) map line with 3 numbers
--
-- Returns:
-- (table) {destination_start, source_start, length}
-- ]
local function get_line_map(line)
	local map = {}
	local count = 1
	for match in line:gmatch("%d+") do
		if count == 1 then
			map.destination_head = tonumber(match)
		elseif count == 2 then
			map.source_head = tonumber(match)
		elseif count == 3 then
			map.length = tonumber(match)
			map.destination_tail = map.destination_head + map.length - 1
			map.source_tail = map.source_head + map.length - 1
		end

		count = count + 1
	end

	return map
end

local count_map_category = 0
local count_map = 0
local is_first_line = true
local maps_arrays = {}
local seed_ranges = Queue.new()
local result
-- Create maps
for line in file:lines() do

	-- Seed line
	if is_first_line then
		for seed_range in line:gmatch("%d+ %d+") do
			local start_range = nil
			for seed in seed_range:gmatch("%d+") do
				if not start_range then
					start_range = tonumber(seed)
				else
					Queue.push(
						seed_ranges,
						create_seed_range(start_range, start_range + tonumber(seed) - 1)
					)
				end
			end
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


-- Pass seed ranges
for i_category = 1, #maps_arrays do
	local maps = maps_arrays[i_category]
	local new_seed_ranges = Queue.new()

	while not Queue.is_empty(seed_ranges) do
		-- We will get one seed range and pass it through the category's maps
		local seed_range = Queue.pull(seed_ranges)

		for i_map = 1, #maps do
			local map = maps[i_map]

			-- Case 0: seed range exactly fits the source map
			if (
				seed_range.head == map.source_head and
				seed_range.tail == map.source_tail
			) then
				Queue.push(
					new_seed_ranges,
					create_seed_range(map.destination_head, map.destination_tail)
				)
			end
			-- Case 1: the map is inside the seed range
			-- Solution:
			-- 	We map the overlapping seeds based on the map
			-- 	The left, right part is queued
			-- 	We go to next seed
			-- 	                |  MAP  |
			--                |    SEED   |
			if (
				seed_range.head < map.source_head and
				map.source_tail < seed_range.tail
			) then
				Queue.push(
					new_seed_ranges,
					create_seed_range(
						map.destination_head,
						map.destination_tail
					)
				)

				-- Left part
				Queue.push(
					seed_ranges,
					create_seed_range(
						seed_range.head,
						map.source_head - 1
					)
				)

				-- Right part
				Queue.push(
					seed_ranges,
					create_seed_range(
						map.source_tail + 1,
						seed_range.tail
					)
				)
				goto next_seed_range
			end

			-- 	  | | <- left_offset
			--    |     MAP     |
			-- 	    |  SEED |
			-- 	            |   | <- right_offset
			-- Case 2: the seed range is inside the map range
			-- Solution:
			-- 	We map the whole seed range with the map
			-- 	We go to next seed
			if (
				map.source_head < seed_range.head and
				seed_range.tail < map.source_tail
			) then
				local left_offset = seed_range.head - map.source_head
				local right_offset = map.source_tail - seed_range.tail

				Queue.push(
					new_seed_ranges,
					create_seed_range(
						map.destination_head + left_offset,
						map.destination_tail - right_offset
					)
				)
				goto next_seed_range
			end


			-- Case 3: the seed range head is included in the map range
			-- Solution:
			-- 	We map the shared seeds 
			-- 	We queue the seed range outside the map
			-- 	We go to next seed
			-- |  MAP  |
			--      | SEED |
			--      |  | <- right_overlap
			local right_overlap = map.source_tail - seed_range.head
			if (
				map.source_head <= seed_range.head and
				map.source_tail <= seed_range.tail and
				right_overlap > 0
			) then
				Queue.push(
					new_seed_ranges,
					create_seed_range(
						map.destination_tail - right_overlap,
						map.destination_tail
					)
				)

				-- No remaining, go to next seed
				if right_overlap == seed_range.length - 1 then
					goto next_seed_range
				end

				Queue.push(
					seed_ranges,
					create_seed_range(
						map.source_tail + 1,
						seed_range.tail
					)
				)
				goto next_seed_range
			end

			-- Case 4: the seed range tail is included in the map range
			-- Solution:
			-- 	We map the shared seeds 
			-- 	We queue the seed range outside the map
			-- 	We go to next seed
			--     |  MAP  |
			--  | SEED |
			--     |    | <- left_overlap
			local left_overlap = seed_range.tail - map.source_head
			if (
				seed_range.head <= map.source_head and
				seed_range.tail <= map.source_tail and
				left_overlap > 0
			) then
				Queue.push(
					new_seed_ranges,
					create_seed_range(
						map.destination_head,
						map.destination_head + left_overlap
					)
				)

				-- No remaining, go to next seed
				if left_overlap == seed_range.length - 1 then
					goto next_seed_range
				end

				Queue.push(
					seed_ranges,
					create_seed_range(
						seed_range.head,
						map.source_head - 1
					)
				)
				goto next_seed_range
			end
		end

		-- Seed range is not fitting in any map
		Queue.push(new_seed_ranges, seed_range)

		::next_seed_range::
	end

	Queue.delete(seed_ranges)
	seed_ranges = new_seed_ranges
end

local min_seed = 9999999999
while not Queue.is_empty(seed_ranges) do
	local seed_range = Queue.pull(seed_ranges)

	if seed_range.head < min_seed then
		min_seed = seed_range.head
	end
end

local t2 = os.clock()
print("Time: " .. (t2 - t1) * 1000 .. " ms")

print("Score: " .. min_seed)
file:close()
