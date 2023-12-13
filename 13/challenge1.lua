local file = assert(io.open("./input", "r"))

local function get_pattern_score(pattern)
	local n_row, n_col = #pattern, #pattern[1]

	for row = 1, n_row-1 do
		local are_equal = true
		for col = 1, n_col do
			if pattern[row][col] ~= pattern[row+1][col] then
				are_equal = false
				break
			end
		end
		if are_equal then
			local are_all_equal = true
			if row <= n_row / 2 then
				for row_j = row-1, 1, -1 do
					for col = 1, n_col do
						if pattern[row_j][col] ~= pattern[row+1+row-row_j][col] then
							are_all_equal = false
							break
						end
					end
				end
			else
				local length = n_row - (row + 1)
				for row_j = row-1, row-length, -1 do
					for col = 1, n_col do
						if pattern[row_j][col] ~= pattern[row+1 + row-row_j][col] then
							are_all_equal = false
							break
						end
					end
				end
			end

			if are_all_equal then return 100 * row end
		end
	end

	for col = 1, n_col-1 do
		local are_equal = true
		for row = 1, n_row do
			if pattern[row][col] ~= pattern[row][col+1] then
				are_equal = false
				break
			end
		end

		if are_equal then
			local are_all_equal = true

			if col <= n_col / 2 then
				for col_j = col-1, 1, -1 do
					for row = 1, n_row do
						if pattern[row][col_j] ~= pattern[row][col+1+col-col_j] then
							are_all_equal = false
							break
						end
					end
				end
			else
				local length = n_col - (col + 1)
				for col_j = col-1, col-length, -1 do
					for row = 1, n_row do
						if pattern[row][col_j] ~= pattern[row][col+1 + col-col_j] then
							are_all_equal = false
							break
						end
					end
				end
			end

			if are_all_equal then return col end
		end
	end
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
