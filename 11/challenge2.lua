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

-- Init with regular
local super_universe = {}
for i = 1, #universe do
	local row_super_universe = {}
	for j = 1, #universe[i] do
		row_super_universe[#row_super_universe+1] = {
			is_galaxy = (universe[i][j] == "#" and true) or false,
			i = i,
			j = j,
			x = i,
			y = j,
			x_len = 1,
			y_len = 1,
		}
	end
	super_universe[#super_universe+1] = row_super_universe
end

local MILLION = 1000000
-- Set super space (empty cols and rows)
for i_row = 1, #rows_without_galaxy do
	local i_row_without_galaxy = rows_without_galaxy[i_row]
	local row_without_galaxy = super_universe[i_row_without_galaxy]

	-- Set empty row with a big size
	for i_col = 1, n_columns do
		row_without_galaxy[i_col].x_len = MILLION
	end
end
for i_col = 1, #columns_without_galaxy do
	local i_column_without_galaxy = columns_without_galaxy[i_col]

	for i_row = 1, n_rows do
		super_universe[i_row][i_column_without_galaxy].y_len = MILLION
	end
end

local galaxies = {}
for i = 1, n_rows do
	for j = 1, n_columns do
		local star = super_universe[i][j]
		if star.is_galaxy then
			galaxies[#galaxies+1] = star
		end
	end
end

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

local function distance(start_galaxy, end_galaxy, _super_universe)
	local _distance = 0

	local end_i, end_j = end_galaxy.i, end_galaxy.j
	local galaxy = start_galaxy
	local i, j = galaxy.i, galaxy.j

	while i ~= end_i or j ~= end_j do
		-- Get one step in the good direction
		-- Do the difference and take the furthest direction
		local delta_i, delta_j = end_i - i, end_j - j

		if math.abs(delta_i) > math.abs(delta_j) then
			local step_i = (delta_i < 0) and -1 or 1
			_distance = _distance + galaxy.x_len
			galaxy = _super_universe[galaxy.i + step_i][galaxy.j]
		else
			local step_j = (delta_j < 0) and -1 or 1
			_distance = _distance + galaxy.y_len
			galaxy = _super_universe[galaxy.i][galaxy.j+step_j]
		end

		i, j = galaxy.i, galaxy.j
	end

	return _distance
end

local score = 0
for i = 1, #galaxy_pairs do
	local start_galaxy = galaxy_pairs[i][1]
	local end_galaxy = galaxy_pairs[i][2]

	score = score + distance(start_galaxy, end_galaxy, super_universe)
end

print(score)

file:close()
