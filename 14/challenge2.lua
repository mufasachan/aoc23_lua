local function copy(matrix)
	local _matrix = {}
	for i = 1, #matrix do
		local row = {}
		for j = 1, #matrix[i] do
			row[#row+1] = matrix[i][j]
		end
		_matrix[#_matrix+1] = row
	end
	return _matrix
end

local function equal_position(before_columns, after_columns)
	for i = 1, #before_columns do
		for j = 1, #before_columns[i] do
			if before_columns[i][j] ~= after_columns[i][j] then
				return false
			end
		end
	end
	return true
end

local function move_one_direction(rows, columns, direction)
	if direction == "north" then
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
					rows[row][col] = '.'

					columns[col][last_rock] = 'O'
					rows[last_rock][col] = 'O'
				end
			end
		end
	end
	if direction == "south" then
		for col = 1, #columns do
			local last_rock = #columns[col] + 1
			local last_dead_end = #columns[col] + 1

			for row = #columns[col], 1, -1 do
				local element = columns[col][row]
				if element == '#' then
					last_dead_end = row
				elseif element == 'O' then
					local block_location = math.min(last_dead_end, last_rock)
					last_rock = block_location - 1

					columns[col][row] = '.'
					rows[row][col] = '.'

					columns[col][last_rock] = 'O'
					rows[last_rock][col] = 'O'
				end
			end
		end

	end
	if direction == "west" then
		for row = 1, #rows do
			local last_rock = 0
			local last_dead_end = 0
			for col = 1, #rows[row] do
				local element = rows[row][col]
				if element == '#' then
					last_dead_end = col
				elseif element == 'O' then
					local block_location = math.max(last_dead_end, last_rock)
					last_rock = block_location + 1

					columns[col][row] = '.'
					rows[row][col] = '.'

					columns[last_rock][row] = 'O'
					rows[row][last_rock] = 'O'
				end
			end
		end
	end
	if direction == "east" then
		for row = 1, #rows do
			local last_rock = #rows[row] + 1
			local last_dead_end = #rows[row] + 1
			for col = #rows[row], 1, -1 do
				local element = rows[row][col]
				if element == '#' then
					last_dead_end = col
				elseif element == 'O' then
					local block_location = math.min(last_dead_end, last_rock)
					last_rock = block_location - 1

					columns[col][row] = '.'
					rows[row][col] = '.'

					columns[last_rock][row] = 'O'
					rows[row][last_rock] = 'O'
				end
			end
		end
	end
end

local function has_loop(memory)
	local start_loop
	local length_loop
	for i_previous = 1, #memory do
		for i = i_previous+1, #memory do
			if equal_position(memory[i_previous], memory[i]) then
				start_loop = i_previous
				length_loop = i - i_previous
			end
		end
	end

	return start_loop, length_loop
end

local function one_cycle(rows, columns)
	move_one_direction(rows, columns, "north")
	move_one_direction(rows, columns, "west")
	move_one_direction(rows, columns, "south")
	move_one_direction(rows, columns, "east")
end

local file = assert( io.open("input", "r"))

local rows = {}
local columns = {}
local i_row = 1
for line in file:lines() do
	local row = {}
	for col = 1, #line do
		local element = line:sub(col, col)
		columns[col] = columns[col] or {}
		columns[col][i_row] = element
		row[#row+1] = element
	end
	i_row = i_row + 1
	rows[#rows+1] = row
end
file:close()

local t1 = os.clock()

-- Move rocks up
local n_cycles = 1000000000
local start_loop
local length_loop
local memory = {}
for _ = 1, n_cycles do
	one_cycle(rows, columns)

	start_loop, length_loop = has_loop(memory)
	if start_loop then
		start_loop = start_loop + 1
		break
	end

	memory[#memory+1] = copy(columns)
end

local cycles_left = (n_cycles - start_loop) % length_loop

for _ = 1, cycles_left do
	one_cycle(rows, columns)
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

local t2 = os.clock()
local duration = string.format("%.3f", t2 - t1)
print(duration .. " seconds.")

