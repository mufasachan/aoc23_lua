local lib = require "lib"

local columns = lib.matrix_from_file("input")

-- Move rocks up
for col = 1, #columns do
	local last_rock = 0
	local last_dead_end = 0
	for row = 1, #columns[col] do
		local element = columns[col][row]
		if element == '#' then
			last_dead_end = row
		elseif element == 'O' then
			local block_location = math.max(last_dead_end, last_rock)
			last_rock = block_location + 1
			columns[col][row] = '.'
			columns[col][last_rock] = 'O'
		end
	end
end

-- Compute score from final state
local score = 0
for col = 1, #columns do
	for row = 1, #columns[col] do
		if columns[col][row] == 'O' then
			score = score + (#columns[col] - row + 1)
		end
	end
end
print(score)
