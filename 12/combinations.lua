local function list_from_indexes(list, indexes)
	local indexed_list = {}
	for i = 1, #indexes do
		indexed_list[#indexed_list+1] = list[indexes[i]]
	end
	return indexed_list
end

local function combinations(n_choices, n_choosen)
	local indexes = {}
	for i = 1, n_choices do
		indexes[#indexes+1] = i
	end

	local choosen_indexes = {}
	for i = 1, n_choosen do
		choosen_indexes[#choosen_indexes+1] = i
	end

	local _combinations = { list_from_indexes(indexes, choosen_indexes) }

	while true do
		local i_current
		for i = n_choosen, 1, -1 do
			if choosen_indexes[i] ~= i + n_choices - n_choosen then
				i_current = i
				goto next_combination
			end
		end
		do return _combinations end

		::next_combination::
		choosen_indexes[i_current] = choosen_indexes[i_current] + 1
		for j = i_current+1, n_choosen do
			choosen_indexes[j] = choosen_indexes[j-1] + 1
		end

		_combinations[#_combinations+1] =  list_from_indexes(indexes, choosen_indexes)
	end
end

return combinations
