local find_colour_number = require("common").find_colour_number


local function run()
	local file = io.open("./input", "r")

	if not file then
		os.exit(1)
	end

	local t1 = os.clock()

	local colours_to_max = {
		["red"] = 12,
		["green"] = 13,
		["blue"] = 14,
	}

	local game_ids_sum = 0
	for line in file:lines() do
		-- Find the id and init indices
		local _, start_idx, game_id = line:find("Game (%d+):")
		local end_idx = line:find(";", start_idx)

		while start_idx do
			for colour, max_value in pairs(colours_to_max) do
				local colour_number = find_colour_number(line, colour, start_idx, end_idx)

				if colour_number and colour_number > max_value then
					goto next_line
				end
			end

			start_idx = end_idx

			if not end_idx then
				goto last_set
			end

			end_idx = line:find(";", start_idx + 1)

			::last_set::
		end

		game_ids_sum = game_ids_sum + game_id

		::next_line::
	end

	local t2 = os.clock()
	file:close()
	return t2 - t1


end

local mean = 0
local iter = 500
for _ = 1, iter do
	mean = mean + run()
end
print(mean / iter * 1000 .. " ms")
