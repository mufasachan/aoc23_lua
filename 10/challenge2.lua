local Node = require("node")

local file = io.open("./input", "r")
if not file then os.exit() end

local function position_to_id(position, n_col)
	return (position.x - 1) * n_col + position.y
end

local function printState(n_row, n_col, position_id_to_state)
	local string = ""
	for i = 1, n_row do
		for j = 1, n_col do
			local id = position_to_id({ x = i, y = j}, n_col)
			local state = position_id_to_state[id]

			if state == 'out' then state = 'O' end
			if state == 'loop' then state = 'L' end
			if state == 'enclosed' then state = 'I' end
			if not state then state = "x" end
			string = string .. state
		end
		string = string .. "\n"
	end
	print(string)
end
local function is_inside(position, trajectory)
	for i = 1, #trajectory do
		if position.x == trajectory[i].x and position.y == trajectory[i].y then
			return true
		end
	end
	return false
end

local function get_around(position, n_row, n_col)
	local x, y = position.x, position.y

	local arounds = {}
	if x < n_row then
		arounds[#arounds+1] = { x = x + 1, y = y }
	end
	if x > 1 then
		arounds[#arounds+1] = { x = x - 1, y = y }
	end
	if y < n_col then
		arounds[#arounds+1] = { x = x, y = y + 1}
	end
	if y > 1 then
		arounds[#arounds+1] = { x = x, y = y - 1}
	end

	return arounds
end

local function all_done(id_to_unknown, unknown_ids)
	for i = 1, #unknown_ids do
		if id_to_unknown[unknown_ids[i]] then return false end
	end
	return true
end

local map = {}
local i_line = 1
local start_position = { x = nil, y = nil }
for line in file:lines() do
	local row = {}
	for i_col = 1, #line do
		local char = line:sub(i_col, i_col)
		row[#row+1] = Node.new(i_line, i_col, char)

		if char == 'S' then
			start_position.x, start_position.y = i_line, i_col
		end
	end

	map[#map+1] = row
	i_line = i_line + 1
end

local start_node = map[start_position.x][start_position.y]

-- Initialize with node connected to start_node
local nodes = {}
if map[start_node.x][start_node.y+1].pipe.left then
	nodes[#nodes+1] = map[start_node.x][start_node.y+1]
end
if map[start_node.x][start_node.y-1].pipe.right then
	nodes[#nodes+1] = map[start_node.x][start_node.y-1]
end
if map[start_node.x+1][start_node.y].pipe.up then
	nodes[#nodes+1] = map[start_node.x+1][start_node.y]
end
if map[start_node.x-1][start_node.y].pipe.down then
	nodes[#nodes+1] = map[start_node.x-1][start_node.y]
end
if not (#nodes == 2) then os.exit() end

-- Determine S node
local n1, n2 = nodes[1], nodes[2]
local up = (n1.x < start_node.x) or (n2.x < start_node.x)
local down = (n1.x > start_node.x) or (n2.x > start_node.x)
local left = (n1.y < start_node.y) or (n2.y < start_node.y)
local right = (n1.y > start_node.y) or (n2.y > start_node.y)
local start_pipe = { up = up, down = down, right = right, left = left }
start_node.pipe = start_pipe
for char, pipe in pairs(Node.char_to_pipe) do
	if (
		start_pipe.up == pipe.up and
		start_pipe.down == pipe.down and
		start_pipe.left == pipe.left and
		start_pipe.right == pipe.right
	) then
		start_node.char = char
	end
end

local previous_node = start_node
local node = nodes[1]
local n_steps = 1
local loop_nodes = { start_node, node}
while not Node.equal(start_node, node) do
	node, previous_node = Node.next(node, map, previous_node), node

	n_steps = n_steps + 1

	if not Node.equal(start_node, node) then
		loop_nodes[#loop_nodes+1] = node
	end
end

local n_row, n_col = #map, #map[1]

-- position id is computed by position_to_id
-- state is "loop", "out", "enclosed", "unknown"
local position_id_to_state = {}
-- Remplir les positions de la boucle
for i = 1, #loop_nodes do
	local position = { x = loop_nodes[i].x, y = loop_nodes[i].y }
	local id = position_to_id(position, n_col)
	position_id_to_state[id] = "loop"
end

-- Remplir les noeuds de sortie (O)
for i = 1, n_col do
	local position_first_line = { x = 1, y = i}
	local id_first_line = position_to_id(position_first_line, n_col)

	local position_last_line = { x = n_row, y = i}
	local id_last_line = position_to_id(position_last_line, n_col)

	if not position_id_to_state[id_first_line] then
		position_id_to_state[id_first_line] = "out"
	end
	if not position_id_to_state[id_last_line] then
		position_id_to_state[id_last_line] = "out"
	end
end
for i = 2, n_row-1 do
	local position_first_line = { x = i, y = 1 }
	local id_first_line = position_to_id(position_first_line, n_col)
	local position_last_line = { x = i, y = n_col}
	local id_last_line = position_to_id(position_last_line, n_col)

	if not position_id_to_state[id_first_line] then
		position_id_to_state[id_first_line] = "out"
	end
	if not position_id_to_state[id_last_line] then
		position_id_to_state[id_last_line] = "out"
	end
end

-- Find orientation
-- Browse the loop. Try to find a O node which touches a loop node.
-- Once we get this, we can find the orientation of the node in loop.
-- Then we will start a new loop to mark additional O and I node based on the orientation
nodes = { start_node, loop_nodes[2] }
previous_node = start_node
node = nodes[2]
local orientation_out
while not orientation_out do
	node, previous_node = Node.next(node, map, previous_node), node

	local node_position = { x = node.x, y = node.y}
	local around_positions = get_around(node_position, n_row, n_col)

	for i = 1, #around_positions do
		local position = around_positions[i]
		local id = position_to_id(position, n_col)

		-- We want - or | to have a simple init
		local is_valid_outside = (
			position_id_to_state[id] == 'out' and
			(node.char == '|' or node.char == '-')
		)
		if is_valid_outside then
			if position.x < node_position.x then orientation_out = "up" end
			if position.x > node_position.x then orientation_out = "down" end
			if position.y < node_position.y then orientation_out = "left" end
			if position.y > node_position.y then orientation_out = "right" end
			break
		end
	end
end

local start_node_orientation = node
node, previous_node = Node.next(node, map, previous_node), node

while not Node.equal(node, start_node_orientation) do
	node, previous_node = Node.next(node, map, previous_node), node
	orientation_out = Node.update_direction(orientation_out, node)

	if node.char == '-' or node.char == '|' then
		local out_position, in_position = Node.get_in_out_positions(node, orientation_out)

		local out_id = position_to_id(out_position, n_col)
		local in_id = position_to_id(in_position, n_col)

		if not position_id_to_state[out_id] then
			position_id_to_state[out_id] = 'out' end
		if not position_id_to_state[in_id] then
			position_id_to_state[in_id] = 'enclosed'
		end
	else
		local state
		local position_1, position_2 = Node.get_in_out_positions(node, orientation_out)
		if node.char == 'J' then
			if orientation_out == 'right' or orientation_out == 'down' then
				state = 'out'
			else
				state = 'enclosed'
			end
		elseif node.char == '7' then
			if orientation_out == 'up' or orientation_out == 'right' then
				state = 'out'
			else
				state = 'enclosed'
			end
		elseif node.char == 'L' then
			if orientation_out == "left" or orientation_out == "down" then
				state = 'out'
			else
				state = 'enclosed'
			end
		elseif node.char == 'F' then
			if orientation_out == 'left' or orientation_out == 'up' then
				state = 'out'
			else
				state = 'enclosed'
			end
		end

		local id_1 = position_to_id(position_1, n_col)
		local id_2 = position_to_id(position_2, n_col)

		if not position_id_to_state[id_1] then
			position_id_to_state[id_1] = state
		end
		if not position_id_to_state[id_2] then
			position_id_to_state[id_2] = state
		end
	end
end

printState(n_row, n_col, position_id_to_state)

local id_to_unknown = {}
local unknown_ids = {}
for i = 1, n_row do
	for j = 1, n_col do
		local position = { x = i, y = j }
		local id = position_to_id(position, n_col)

		if not position_id_to_state[id] then
			id_to_unknown[id] = position
			unknown_ids[#unknown_ids+1] = id
		end
	end
end

local i_unknown = 1
local n_unknown = #unknown_ids
while not all_done(id_to_unknown, unknown_ids) do
	if id_to_unknown[unknown_ids[i_unknown]] then
		local trajectory = { id_to_unknown[unknown_ids[i_unknown]] }
		local i_trajectory = 1

		local state
		while (i_trajectory <= #trajectory) and (not state) do
			local position = trajectory[i_trajectory]

			local around_positions = get_around(position, n_row, n_col)
			for i_around = 1, #around_positions do
				local around_position = around_positions[i_around]
				local id_around = position_to_id(around_position, n_col)

				local state_around = position_id_to_state[id_around]
				if around_position.x == 4 and around_position.y == 6 then
					print(state_around)
				end
				if state_around == 'enclosed' or state_around == 'out' then
					state = state_around
					break
				end

				-- The position around is also unknown
				if not state_around then
					if not is_inside(around_position, trajectory) then
						trajectory[#trajectory + 1] = around_position
					end
				end
			end

			i_trajectory = i_trajectory + 1
		end

		if not state then
			state = 'enclosed'
		end

		for i = 1, #trajectory do
			local position = trajectory[i]
			local id = position_to_id(position, n_col)

			position_id_to_state[id] = state
			id_to_unknown[id] = nil
		end
	end

	i_unknown = (i_unknown >= n_unknown) and 1 or (i_unknown + 1)
end

local count_enclosed = 0
for i = 1, n_row do
	for j = 1, n_col do
		local id = position_to_id({ x = i, y = j }, n_col)
		if position_id_to_state[id] == 'enclosed' then
			count_enclosed = count_enclosed + 1
		end
	end
end
print("Score: " .. count_enclosed)

local count_loop = 0
local count_out = 0
for i = 1, n_row do
	for j = 1, n_col do
		local id = position_to_id({x = i, y = j }, n_col)

		if position_id_to_state[id] == 'out' then
			count_out = count_out + 1
		end
		if position_id_to_state[id] == 'loop' then
			count_loop = count_loop + 1
		end
	end
end


printState(n_row, n_col, position_id_to_state)
os.exit()

print("Loop node: " .. count_loop)
print("Enclosed node: " .. count_enclosed)
print("Out node: " .. count_out)
print("Sum node: " .. count_enclosed + count_loop + count_out)
print("All node: " .. n_row * n_col)

file:close()
