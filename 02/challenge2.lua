local find_colour_number = require("common").find_colour_number

local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local power_games_sum = 0
for line in file:lines() do
	-- -1 flags that no value has been set yet
	local colours_to_max = {
		["red"] = -1,
		["green"] = -1,
		["blue"] = -1,
	}

	-- Init 
	local start_idx = line:find(":")
	local end_idx = line:find(";")

	while start_idx do
		for colour, _ in pairs(colours_to_max) do
			local colour_number = find_colour_number(line, colour, start_idx, end_idx)

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

	local power_game = 1
	for _, max_number in pairs(colours_to_max) do
		power_game = power_game * max_number
	end

	power_games_sum = power_games_sum + power_game

end

print(power_games_sum)

file:close()
