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

local power_games_sum = 0
local power_game, start_idx, end_idx, colour_number, colours_to_max
for line in file:lines() do
	-- -1 flags that no value has been set yet
	colours_to_max = {
		["red"] = -1,
		["green"] = -1,
		["blue"] = -1,
	}

	-- Init 
	start_idx = line:find(":")
	end_idx = line:find(";")

	while start_idx do
		for colour, _ in pairs(colours_to_max) do
			colour_number = find_colour_number(line, colour, start_idx, end_idx)

			if colour_number then
				if colours_to_max[colour] == -1 or colour_number > colours_to_max[colour] then
					colours_to_max[colour] = colour_number
				end
			end
		end

		start_idx = end_idx
		if start_idx then
			end_idx = line:find(";", start_idx + 1)
		end
	end

	power_game = 1
	for _, max_number in pairs(colours_to_max) do
		power_game = power_game * max_number
	end

	power_games_sum = power_games_sum + power_game

end

print(power_games_sum)

file:close()
