local file = io.open("./input", "r")
if not file then os.exit(1) end

local t1 = os.clock()

local function all(list)
	for i = 1, #list do
		if not list[i] then
			return false
		end
	end

	return true
end

local instructions = {}
local maps = {}
local nodes = {}
local are_reached = {}
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

local all_complete = false
local i_instruction = 1
local score = 0
while not all_complete do
	score = score + 1

	local direction = instructions:sub(i_instruction, i_instruction)

	local are_complete = {}
	for i_node = 1, #nodes do
		local node = nodes[i_node]

		nodes[i_node].current = maps[node.current][direction]

		if node.current:sub(3,3) == 'Z' then
			if not node.z_node then node.z_node = score
			elseif not node.length then node.length = score - node.z_node end
		end

		are_complete[#are_complete+1] = node.length ~= nil
	end

	all_complete = all(are_complete)

	if i_instruction >= #instructions then
		i_instruction = 1
	else
		i_instruction = i_instruction + 1
	end
end

local congruences = {}
for i = 1, #nodes do
	local node = nodes[i]
	local congruence = {
		rest = (score - node.z_node) % node.length,
		modulo = node.length,
	}
  congruences[#congruences+1] = congruence
end

-- Check conditons generalized chinese theorem
-- local all_ok = {}
-- for i = 1, #nodes do
-- 	local congruence_i = congruences[i]
-- 	for j = 1, #nodes do
-- 		if i < j then
-- 			local congruence_j = congruences[j]
-- 			local diff = congruence_i.rest - congruence_j.rest
-- 			local div = gcd(congruence_i.modulo, congruence_j.modulo)
-- 			all_ok[#all_ok+1] = (diff % div) == 0
-- 		end
-- 	end
-- end
-- if not all(all_ok) then
-- 	print("Generalized chinese theorem conditions are not met")
-- 	print(
-- 		"There is no solution because the congruences will need " ..
-- 		"never \"catch\" each other."
-- 	)
-- 	os.exit()
-- end

local function extended_euclid(r1, u1, v1, r2, u2, v2)
	if r2 == 0 then return r1, u1, v1
	else
		local q = math.floor(r1 / r2)
		return extended_euclid(
			r2,
			u2,
			v2,
			r1 - q * r2,
			u1 - q * u2,
			v1 - q * v2
		)
	end
end


local function bezout(modulo1, modulo2)
	local r1 = modulo1
	local r2 = modulo2
	local u1 = 1
	local v1 = 0
	local u2 = 0
	local v2 = 1


	return extended_euclid(r1, u1, v1, r2, u2, v2)
end

for i = 1, #congruences do
	print(congruences[i].modulo)
end

local g, u, v = bezout(12, 45)
print(g, u, v)
os.exit()
-- \[ x \equiv a \cdot v \cdot n + b \cdot u \cdot m \mod mn \]
-- x = 1 [12]
-- x = 20 [45]
-- 1. (1 + 12j) = 20 [45]
-- 2. 12j = 19 [45]
-- 3. j = 4 * 19 [45]
-- 4. j = 31 + 45k
-- 5. 32 = 20 [45] WRONG
-- c'est-à-dire 24j ≡ 18 mod 45. D'après l'exemple de la section précédente, les solutions sont j = –3 + 15k donc x = 1 + 12(–3 + 15k), soit
-- x = –35 + 180k (avec k entier).

local function step_chinese_general_theorem(congruence1, congruence2)
	-- m1, m2 are the modulo
	-- r1, r2 are the rest
	local m1 = congruence1.modulo
	local r1 = congruence1.rest
	local m2 = congruence2.modulo
	local r2 = congruence2.rest

	local gcd, u, v = bezout(m1, m2)
	-- r = r1 * m2 + r2 * m1 [lcm]
	local lcm = m1 * m2 / gcd_number
end



local t2 = os.clock()
print((t2 - t1) * 1000 .. " ms")

local congruence = congruences[1]
for i = 2, #congruences do
	congruence = step_chinese_general_theorem(
		congruence, congruences[i]
	)
end

file:close()
