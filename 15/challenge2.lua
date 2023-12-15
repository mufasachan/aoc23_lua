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

local boxes = {}
local n_boxes = 256
for _ = 1, n_boxes do
	boxes[#boxes+1] = {}
end

for sequence in input:gmatch("[^,]+") do
	local letters = sequence:match("%w+")
	local i_box = hash_sequence(letters) + 1
	local box = boxes[i_box]

	if sequence:sub(#sequence, #sequence) == '-' then
		if not box or #box == 0 then goto next_sequence end

		for i, lens in pairs(box) do
			if lens.name == letters then
				table.remove(boxes[i_box], i)
			end
		end
		-- for i_lens = 1, #box do
		-- end
	else
		local number = sequence:match("%d")
		box = box or {}

		for i_lens = 1, #box do
			if box[i_lens].name == letters then
				box[i_lens].number = number
				goto next_sequence
			end
		end

		box[#box+1] = { name = letters, number = number }
	end

	::next_sequence::
end

local score = 0
for i = 1, #boxes do
	if #boxes[i] == 0 then goto next_box end
	for j = 1, #boxes[i] do
		score = score + i * j * boxes[i][j].number
	end
	::next_box::
end
print(score)
