local file = io.open("./input", "r")
if not file then os.exit(1) end

local universe = {}
local count_row = 1
for line in file:lines() do
	local row = {}
	for i = 1, #line do
		local char = line:sub(i, i)
		row[#row+1] = char

	end
	universe[#universe+1] = row
	count_row = count_row + 1
end

local n_rows, n_columns = #universe, #universe[1]

local rows_without_galaxy = {}
local columns_without_galaxy = {}
for i = 1, n_rows do
	local row = universe[i]

	local is_empty = true
	for j = 1, #row do
		if row[j] == '#' then is_empty = false end
	end

	if is_empty then
		rows_without_galaxy[#rows_without_galaxy+1] = i
	end
end

for i = 1, n_columns do
	local is_empty = true
	for j = 1, n_rows do
		if universe[j][i] == '#' then is_empty = false end
	end

	if is_empty then columns_without_galaxy[#columns_without_galaxy+1] = i end
end

local count_expansion = 0
for i = 1, #rows_without_galaxy do
	local row_without_galaxy = rows_without_galaxy[i] + count_expansion
	local new_row = {}
	for j = 1, n_columns do
		new_row[#new_row+1] = universe[row_without_galaxy][j]
	end
	table.insert(universe, row_without_galaxy, new_row)
	count_expansion = count_expansion + 1
end
n_rows = #universe

count_expansion = 0
for i = 1, #columns_without_galaxy do
	local column_without_galaxy = columns_without_galaxy[i]+count_expansion

	for j = 1, n_rows do
		table.insert(universe[j], column_without_galaxy , '.')
	end

	count_expansion = count_expansion + 1
end
n_columns = #universe[1]

local s = ""
local galaxies = {}
for i = 1, n_rows do
	for j = 1, n_columns do
		s = s .. universe[i][j]
		if universe[i][j] == '#' then
			galaxies[#galaxies+1] = { x = i, y = j }
		end
	end
	s = s .. "\n"
end
print(s)

local galaxy_pairs = {}
for i = 1, #galaxies do
	for j = 1, #galaxies do
		if i < j then
			galaxy_pairs[#galaxy_pairs+1] = {
				galaxies[i], galaxies[j]
			}
		end
	end
end

local function distance(start_galaxy, end_galaxy)
	local _distance = 0

	local end_x, end_y = end_galaxy.x, end_galaxy.y
	local x, y = start_galaxy.x, start_galaxy.y

	while x ~= end_x or y ~= end_y do
		-- Get one step in the good direction
		-- Do the difference and take the furthest direction
		local delta_x, delta_y = end_x - x, end_y - y
		if math.abs(delta_x) > math.abs(delta_y) then
			x = (delta_x < 0) and (x - 1) or (x + 1)
		else
			y = (delta_y < 0) and (y - 1) or (y + 1)
		end
		_distance = _distance + 1
	end

	return _distance
end

local score = 0
for i = 1, #galaxy_pairs do
	local start_galaxy = galaxy_pairs[i][1]
	local end_galaxy = galaxy_pairs[i][2]

	score = score + distance(start_galaxy, end_galaxy)
end

print(score)

file:close()
