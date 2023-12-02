local utils = require "utils"
local len = utils.len

local wordToDigit = {
	-- Artificially add the numeric pattern
	["%d"] = 0,
	["one"] = 1,
	["two"] = 2,
	["three"] = 3,
	["four"] = 4,
	["five"] = 5,
	["six"] = 6,
	["seven"] = 7,
	["eight"] = 8,
	["nine"] = 9,
}

local function argmin(pattern_to_start_idx)
	local minPattern
	local minIdx = -1

	for pattern, idx in pairs(pattern_to_start_idx) do
		if idx < minIdx or minIdx == -1 then
			minIdx = idx
			minPattern = pattern
		end
	end

	return minPattern, minIdx
end

local function init_line_patterns(line)
	local line_patterns = {}
	for pattern, _ in pairs(wordToDigit) do
		local start_idx, _ = string.find(line, pattern)

		if start_idx then
			line_patterns[pattern] = start_idx
		end
	end
	return line_patterns
end

local function wordToNumber(word)
	if #word == 1 then
		return tonumber(word)
	end

	return wordToDigit[word]
end


local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local sum = 0
for line in file:lines() do
	-- {pattern: idx}
	local pattern_to_start_idx = init_line_patterns(line)

	-- Find the first digit
	local first_pattern, _ = argmin(pattern_to_start_idx)
	local first_digit = wordToNumber(string.match(line, first_pattern))

	-- Exhaust the line_patterns
	local last_digit
	while len(pattern_to_start_idx) > 0 do
		-- Find closest known match 
		local pattern, old_idx = argmin(pattern_to_start_idx)

		-- Store the match
		last_digit = string.match(line, pattern, old_idx)

		-- Find the next match of the current pattern
		local new_idx, _, _ = string.find(line, pattern, old_idx + 1)

		-- If there is a new occurence
		if new_idx then
			-- Update entry
			pattern_to_start_idx[pattern] = new_idx
		else
			-- Else, delete it
			pattern_to_start_idx[pattern] = nil
		end
	end

	local number = (first_digit * 10) + wordToNumber(last_digit)
	sum = sum + number
end
print(sum)

file:close()
