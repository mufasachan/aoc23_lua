local Node = require("node")

local file = io.open("./input", "r")
if not file then os.exit() end

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

local previous_node_1, previous_node_2 = start_node, start_node
local node_1, node_2 = nodes[1], nodes[2]
local n_steps = 1
while not Node.equal(node_1, node_2) do
	node_1, previous_node_1 = Node.next(node_1, map, previous_node_1), node_1
	node_2, previous_node_2 = Node.next(node_2, map, previous_node_2), node_2

	n_steps = n_steps + 1
end

print(n_steps)
