local utils = {}

function utils.len(key_value_table)
	local count = 0
	for _, _ in pairs(key_value_table) do
		count = count + 1
	end

	return count
end

function utils.printKVTable(table)
	print("{")
	for key, value in pairs(table) do
		print("\t" .. key .. ": " .. value .. ",")
	end
	print("}")
end

return utils
