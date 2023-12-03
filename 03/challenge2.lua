local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

-- one gear is { gear_id = {n_line, n_column}}
local function has_adjacent_gear(gears, column_start, column_stop, n_line)
	for gear_id, gear_position in pairs(gears) do
		-- {n_line, n_column} is a symbol_position
		if (
			gear_position[1] <= n_line + 1 and
			gear_position[1] >= n_line - 1 and
			gear_position[2] <= column_stop + 1 and
			gear_position[2] >= column_start - 1
		) then
			return gear_id
		end
	end

	return nil
end

local schematic = {}
for line in file:lines() do
	table.insert(schematic, line)
end

-- A gear is represented by an ID
-- { gear_id = { n_line, column}, ...}
local gears = {}
-- { gear_id = {}, ...}
local working_gear_ids = {}
for n_line, line in ipairs(schematic) do
	for n_column = 1, #line do
		local char = line:sub(n_column, n_column)

		-- Check if char is in symbols table
		if char == "*" then
			local gear_id = n_line * 200 + n_column
			gears[gear_id] = {n_line, n_column}
			working_gear_ids[gear_id] = {}
		end
	end
end

-- Find working gear
-- { gear_id = {} | {numbers} | {numbers}}
for n_line, line in ipairs(schematic) do
	local init_column = 1

	-- Fill the number and position table
	while init_column do
		local column_start, column_end, numbers = line:find("(%d+)", init_column)

		-- No more number on the line
		if not column_end then
			goto new_line
		end

		-- Find if there is a gear nearby
		-- If yes, add entry {gear_id, number}
		local gear_id = has_adjacent_gear(gears, column_start, column_end, n_line)
		if gear_id then
			table.insert(working_gear_ids[gear_id], numbers)
		end

		-- No number will be found at the next iteration
		if column_end == line:len() then
			goto new_line
		end

		init_column = column_end + 1
	end
	::new_line::
end

local numbers_sum = 0
for _, numbers_array in pairs(working_gear_ids) do
	if #numbers_array == 2 then
		numbers_sum = numbers_sum + numbers_array[1] * numbers_array[2]
	end
end

print("Score: " .. numbers_sum)

