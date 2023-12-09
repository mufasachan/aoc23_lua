local file = io.open("./input", "r")
if not file then os.exit() end

local function printList(list)
	local s = ""
	for i = 1, #list do
		s = s .. list[i] .. " "
	end
	print(s .. "")
end

local function create_array(array)
	local new_array = { array = {}, zeros = 0}

	for i = 1, #array.array-1 do
		local numbers = array.array[i+1] - array.array[i]
		new_array.array[#new_array.array+1] = numbers
		if numbers == 0 then new_array.zeros = new_array.zeros + 1 end
	end
	
	return new_array
end

local function predict_(arrays)
	for i = #arrays-1, 1, -1 do
		local previous_array = arrays[i+1]
		local current_array = arrays[i]
		current_array.array[#current_array.array+1] = (
			current_array.array[#current_array.array]
			+ previous_array.array[#previous_array.array]
		)
	end
end

local score = 0
for line in file:lines() do
	local arrays = {}

	-- Init first array from line
	arrays[1] = { array = {}, zeros = 0}
	for numbers_str in line:gmatch("%-?%d+") do
		local numbers = tonumber(numbers_str)
		arrays[1].array[#arrays[1].array + 1] = numbers
		if numbers == 0 then arrays[1].zeros = arrays[1].zeros + 1 end
	end

	local array = arrays[1]
	while #array.array ~= array.zeros and #array.array > 1 do
		arrays[#arrays+1] = create_array(array)
		array = arrays[#arrays]
	end

	predict_(arrays)
	score = score + arrays[1].array[#arrays[1].array]
end
print(score)

file:close()
