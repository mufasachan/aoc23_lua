local Node = {}

Node.char_to_pipe = {
	["|"] = { up = true, down = true, left = false, right = false },
	["-"] = { up = false, down = false, left = true, right = true },
	["L"] = { up = true, down = false, left = false, right = true },
	["7"] = { up = false, down = true, left = true, right = false },
	["F"] = { up = false, down = true, left = false, right = true },
	["J"] = { up = true, down = false, left = true, right = false },
	["."] = { up = false, down = false, left = false, right = false },
	["S"] = nil,
}

-- J and F have the same direction's update .
-- 7 and J have the same direction's update .
Node._update_direction = {
	["J"] = {
		right = "down",
		down = "right",
		left = "up",
		up = "left",
	},
	["F"] = {
		right = "down",
		down = "right",
		left = "up",
		up = "left",
	},
	["L"] = {
		down = "left",
		left = "down",
		up = "right",
		right = "up",
	},
	["7"] = {
		down = "left",
		left = "down",
		up = "right",
		right = "up",
	}
}

function Node.update_direction(direction, node)
	if node.char == '-' or node.char == '|' then return direction end

	return Node._update_direction[node.char][direction]
end

function Node.get_in_out_positions(node, direction)
	if node.char == 'L' then
		local position_1 = { x = node.x + 1, y = node.y}
		local position_2 = { x = node.x, y = node.y - 1}
		return position_1, position_2
	elseif node.char == '7' then
		local position_1 = { x = node.x - 1, y = node.y}
		local position_2 = { x = node.x, y = node.y + 1}
		return position_1, position_2
	elseif node.char == 'J' then
		local position_1 = { x = node.x + 1, y = node.y}
		local position_2 = { x = node.x, y = node.y + 1}
		return position_1, position_2
	elseif node.char == 'F' then
		local position_1 = { x = node.x - 1, y = node.y}
		local position_2 = { x = node.x, y = node.y - 1}
		return position_1, position_2
	end

	local out_position
	local in_position
	if node.char == '|' then
		if direction == 'right' then
			out_position = { x = node.x, y = node.y + 1}
			in_position = { x = node.x, y = node.y - 1}
		elseif direction == 'left' then
			in_position = { x = node.x, y = node.y + 1}
			out_position = { x = node.x, y = node.y - 1}
		else
			print("Wrong direction with |")
			os.exit()
		end
	end
	if node.char == '-' then
		if direction == 'up' then
			out_position = { x = node.x - 1, y = node.y }
			in_position = { x = node.x + 1, y = node.y }
		elseif direction == 'down' then
			out_position = { x = node.x + 1, y = node.y }
			in_position = { x = node.x - 1, y = node.y }
		else
			print("Wrong direction with -")
			os.exit()
		end
	end

	return out_position, in_position
end

function Node.new(x, y, char)
	local is_start = (char == 'S') and true or false
	local pipe = Node.char_to_pipe[char]

	return {
		char = char,
		x = x,
		y = y,
		pipe = pipe,
		is_start = is_start
	}
end

function Node.equal(node_1, node_2)
	return node_1.x == node_2.x and node_1.y == node_2.y
end

-- In the loop, loop node does not go in dead end
function Node.are_connected(node, map)
	local x, y = node.x, node.y
	local pipe = node.pipe

	local connected_nodes = {}
	if pipe.up then connected_nodes[#connected_nodes+1] = map[x-1][y] end
	if pipe.down then connected_nodes[#connected_nodes+1] = map[x+1][y] end
	if pipe.left then connected_nodes[#connected_nodes+1] = map[x][y-1] end
	if pipe.right then connected_nodes[#connected_nodes+1] = map[x][y+1] end

	if #connected_nodes ~= 2 then
		print("no two connected nodes, should not be the case in the loop")
		print("Connected node: " .. #connected_nodes)
		os.exit()
	end

	return connected_nodes[1], connected_nodes[2]
end

function Node.next(node, map, previous_node)
	local node_1, node_2 = Node.are_connected(node, map)

	if not Node.equal(node_1, previous_node) then
		return node_1
	end

	return node_2
end

return Node
