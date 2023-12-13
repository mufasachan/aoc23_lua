local combinations = require "combinations"

local function printList(list)
	local s = ""
	for i = 1, #list do
		s = s .. list[i] .. " "
	end
	print(s)
end

local function create_ashes_counts(line, i_space)
	local ashes = {}
	local known_positions = {}
	local unknown_positions = {}
	for i = 1, i_space-1 do
		local char = line:sub(i, i)

		if char == '#' then
			known_positions[#known_positions+1] = i
		elseif char == '?' then
			unknown_positions[#unknown_positions+1] = i
		end

		ashes[#ashes+1] = char
	end

	return ashes, known_positions, unknown_positions
end

local function create_line_targets(line, i_space)
	local targets = {}

	for number in line:gmatch("%d+", i_space) do
		targets[#targets+1] = tonumber(number)
	end

	return targets
end

local function sum(list)
	local _sum = 0
	for i = 1, #list do
		_sum = _sum + list[i]
	end
	return _sum
end

local function get_result(known_positions, unknown_positions, candidates_indices)
	local result_positions = {}
	for i = 1, #candidates_indices do
		result_positions[#result_positions+1] = unknown_positions[candidates_indices[i]]
	end
	for i = 1, #known_positions do
		result_positions[#result_positions+1] = known_positions[i]
	end

	table.sort(result_positions)

	-- Pack continuous number
	local result = {}
	local number = 1
	for i = 2, #result_positions do
		local delta = result_positions[i] - result_positions[i-1]
		if delta > 1 then
			result[#result+1] = number
			number = 1
		else
			number = number + 1
		end

		if i == #result_positions then result[#result+1] = number end
	end

	return result
end

local function check_candidate(result, targets)
	if #result ~= #targets then
		return false
	end

	for i = 1, #targets do
		if result[i] ~= targets[i] then return false end
	end

	return true
end

local file = assert( io.open("input", "r"))

local t1 = os.clock()

local score = 0
local i_l = 1
for line in file:lines() do
	local i_space = line:find(" ")

	local ashes, known_positions, unknown_positions = create_ashes_counts(line, i_space)

	local targets = create_line_targets(line, i_space)
	local goal = sum(targets)

	-- Early stop
	if #ashes == goal + #targets - 1 then
		score = score + 1
		i_l = i_l + 1
		goto next_line
	end

	local n_needed_unknown = goal - #known_positions

	local candidates_indices = combinations(#unknown_positions, n_needed_unknown)
	for i = 1, #candidates_indices do
		local result = get_result(known_positions, unknown_positions, candidates_indices[i])
		local is_ok_candidate = check_candidate(result, targets)
		score = (is_ok_candidate and (score + 1)) or score
	end
	i_l = i_l + 1
	::next_line::
end
local t2 = os.clock()
print(score)
print((t2 - t1) .. " ms")

file:close()
