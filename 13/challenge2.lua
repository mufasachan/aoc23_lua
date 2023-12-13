local file = assert(io.open("./input", "r"))

local function printPattern(pattern)
	local s = ""
	for i = 1, #pattern do
		for j = 1, #pattern[1] do
			s = s .. pattern[i][j]
		end
		s = s .. "\n"
	end
	print(s)
end

local function get_pattern_score_row(pattern, n_row, n_col)
	for row = 1, n_row-1 do
		local smugde = false
		for col = 1, n_col do
			if pattern[row][col] ~= pattern[row+1][col] then
				if smugde then
					goto next_row
				end
				if not smugde then smugde = true end
			end
		end

		local start_row_j = row-1
		local end_row_j = (row <= n_row / 2) and 1 or (2*row + 1 - n_row)

		for row_j = start_row_j, end_row_j, -1 do
			for col = 1, n_col do
				if pattern[row_j][col] ~= pattern[row+1+row-row_j][col] then
					if smugde then goto next_row end

					if not smugde then smugde = true end
				end
			end
		end

		if smugde then
			return row
		end

		::next_row::
	end

	return nil
end

local function get_pattern_score(pattern)
	local n_row, n_col = #pattern, #pattern[1]

	local symetric_pattern = {}
	for col = 1, n_col do
		local row_pattern = {}
		for row = 1, n_row do
			row_pattern[#row_pattern+1] = pattern[row][col]
		end
		symetric_pattern[#symetric_pattern+1] = row_pattern
	end

	local score_row = get_pattern_score_row(pattern, n_row, n_col)
	if score_row then return 100 * score_row end

	local score_col = get_pattern_score_row(symetric_pattern, n_col, n_row)
	return score_col
end

local patterns = {}
local pattern = {}
for line in file:lines() do
	if #line == 0 then
		patterns[#patterns+1] = pattern
		pattern = {}
	else
		local line_pattern = {}
		for n_row = 1, #line do
			line_pattern[#line_pattern+1] = line:sub(n_row, n_row)
		end
		pattern[#pattern+1] = line_pattern
	end
end
patterns[#patterns+1] = pattern

local score = 0
for i = 1, #patterns do
	score = score + get_pattern_score(patterns[i])
end
print(score)

file:close()

