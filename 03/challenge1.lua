local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local function has_adjacent_symbol(symbol_positions, column_start, column_stop, n_line)
	for _, symbol_position in ipairs(symbol_positions) do
		-- {n_line, n_column} is a symbol_position
		if (
			symbol_position[1] <= n_line + 1 and
			symbol_position[1] >= n_line - 1 and
			symbol_position[2] <= column_stop + 1 and
			symbol_position[2] >= column_start - 1
		) then
			return true
		end
	end

	return false
end

local schematic = {}
for line in file:lines() do
	table.insert(schematic, line)
end

-- Find symbol position
local symbols = { '@', '=', '+', '*', '/', '-', '#', '&', '%', '$' }
local symbol_positions = {}
for n_line, line in ipairs(schematic) do
	for n_column = 1, #line do
		local char = line:sub(n_column, n_column)

		-- Check if char is in symbols table
		for _, symbol in ipairs(symbols) do
			if char == symbol then
				table.insert(symbol_positions, {n_line, n_column})
				goto new_char
			end
		end

		::new_char::
	end
end

local numbers_sum = 0
for n_line, line in ipairs(schematic) do
	local init_column = 1

	-- Fill the number and position table
	while init_column do
		local column_start, column_end, numbers = line:find("(%d+)", init_column)

		-- No more number on the line
		if not column_end then
			goto new_line
		end

		-- Find if it's a valid score or not
		if has_adjacent_symbol(symbol_positions, column_start, column_end, n_line) then
			numbers_sum = numbers_sum + numbers
		end

		-- No number will be found at the next iteration
		if column_end == line:len() then
			goto new_line
		end

		init_column = column_end + 1
	end
	::new_line::
end

print("Score: " .. numbers_sum)
