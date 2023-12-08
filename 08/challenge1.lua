local file = io.open("./input", "r")
if not file then os.exit(1) end

local n_line = 1
local instructions = {}
local maps = {}
for line in file:lines() do
	if n_line == 1 then
		instructions = line
	elseif n_line == 2 then
	else
		local node = line:sub(1, 3)
		local left = line:sub(8, 10)
		local right = line:sub(13, 15)
		maps[node] = { L = left, R = right}
	end

	n_line = n_line + 1
end

local is_reached = false
local i_instruction = 1
local node = "AAA"
local score = 0

while not is_reached do
	score = score + 1

	local direction = instructions:sub(i_instruction, i_instruction)
	node = maps[node][direction]

	if node == "ZZZ" then
		is_reached = true
	end

	if i_instruction >= #instructions then
		i_instruction = 1
	else
		i_instruction = i_instruction + 1
	end
end

print("Score: " .. score)

file:close()
