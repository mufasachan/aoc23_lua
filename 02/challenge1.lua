local find_colour_number = require("common").find_colour_number

local file = io.open("./input", "r")

if not file then
	os.exit(1)
end


local colours_to_max = {
	["red"] = 12,
	["green"] = 13,
	["blue"] = 14,
}

local game_ids_sum = 0
for line in file:lines() do
	-- Find the id
	local game_id = tonumber(line:match("%d+"))

	-- Init 
	local start_idx = line:find(":")
	local end_idx = line:find(";")

	local line_is_ok = true
	while start_idx and line_is_ok do
		for colour, max_value in pairs(colours_to_max) do
			local colour_number = find_colour_number(line, colour, start_idx, end_idx)

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
