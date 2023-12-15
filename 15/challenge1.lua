local lib = require "lib"
local lines_from_file = lib.lines_from_file

local input = lines_from_file("input")[1]

local function hash(init, char)
	local result = init + string.byte(char)
	result = result * 17
	return result % 256
end

local function hash_sequence(sequence)
	local init = 0
	for i = 1, #sequence do
		init = hash(init, sequence:sub(i, i))
	end
	return init
end

local score = 0
for sequence in input:gmatch("[^,]+") do
	score = score + hash_sequence(sequence)
end
print(score)
