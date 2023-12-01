local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local sum = 0
for line in file:lines() do

	local numbers = {}
	for number in string.gmatch(line, "%d") do
		table.insert(numbers, tonumber(number))
	end

	sum = sum + numbers[1] * 10 + numbers[#numbers]
end
print(sum)

file:close()

