local function pgcd(x, y)
	if y == 0 then return x
	else return pgcd(y, x % y) end
end


local function run()
	local file = io.open("./input", "r")
	if not file then os.exit(1) end

	local t1 = os.clock()

	local instructions = {}
	local maps = {}
	local nodes = {}
	local n_line = 1
	for line in file:lines() do
		if n_line == 1 then
			instructions = line
		elseif n_line == 2 then
		else
			local node = line:sub(1, 3)
			local left = line:sub(8, 10)
			local right = line:sub(13, 15)
			maps[node] = { L = left, R = right}

			if node:sub(3,3) == 'A' then
				nodes[#nodes+1] = {
					current = node,
					z_node = nil,
					length = nil,
				}
			end
		end

		n_line = n_line + 1
	end

	local i_instruction = 1
	local score = 0
	local count_node = 0
	while count_node < #nodes do
		score = score + 1

		local direction = instructions:sub(i_instruction, i_instruction)

		for i_node = 1, #nodes do
			local node = nodes[i_node]

			nodes[i_node].current = maps[node.current][direction]

			if node.current:sub(3,3) == 'Z' and not node.z_node then
				node.z_node = score
				count_node = count_node + 1
			end
		end

		if i_instruction >= #instructions then
			i_instruction = 1
		else
			i_instruction = i_instruction + 1
		end
	end
	local lcm
	lcm = nodes[2].z_node * nodes[1].z_node / pgcd(nodes[2].z_node, nodes[1].z_node)
	for i = 3, #nodes do
		lcm = lcm * nodes[i].z_node / pgcd(nodes[i].z_node, lcm)
	end

	local t2 = os.clock()
	print(lcm)
	return t2 - t1
end

local n_iter = 500
local total_duration = 0
for _ = 1, n_iter do
	total_duration = total_duration + run()
end
print("Duration: " .. total_duration / n_iter * 1000 .. " ms")

file:close()

