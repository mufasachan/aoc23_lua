local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

-- @line (string) where to look things
-- @colour (string) the colour we are searching for
-- @start_idx (number) where to start to look
-- @max_idx (number | nil) constraints how far the match can be done.
-- Return nil if there is no match for @colour in @line when starting
-- to look at indice @start_idx and not further than @max_idx.
-- Else returns the number of the colour
local function find_colour_number(line, colour, start_idx, max_idx)
	local idx, _, number = line:find("(%d+) " .. colour, start_idx)

	-- Nothing has been found
	if not idx then
		return nil
	end

	-- No constraints on max idx
	if not max_idx then
		return tonumber(number)
	end

	-- Check if constraint is met
	if idx < max_idx then
		return tonumber(number)
	end

	-- Constraint is not met
	return nil
end

local colours_to_max = {
	["red"] = 12,
	["green"] = 13,
	["blue"] = 14,
}

local game_ids_sum = 0
local game_id, start_idx, end_idx, line_is_ok, colour_number
for line in file:lines() do
	-- Find the id
	game_id = tonumber(line:match("%d+"))

	-- Init 
	start_idx = line:find(":")
	end_idx = line:find(";")

	line_is_ok = true
	while start_idx and line_is_ok do
		for colour, max_value in pairs(colours_to_max) do
			colour_number = find_colour_number(line, colour, start_idx, end_idx)

			if colour_number then
				if colour_number > max_value then
					line_is_ok = false
				end
			end
		end

		start_idx = end_idx
		if start_idx then
			end_idx = line:find(";", start_idx + 1)
		end
	end

	if line_is_ok then
		game_ids_sum = game_ids_sum + game_id
	end

end

print(game_ids_sum)

file:close()
