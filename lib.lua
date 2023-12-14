local lib = {}

---@alias list table #1D continuous 1-indexed table.
---@alias matrix table #2D continuous 1-indexed table.

---@param list list The list to be printed
---@param separator? string The seperator between elements
function lib.lprint(list, separator)
	separator = separator or ""

	print(table.concat(list, separator))
end

---Print a 2D table `matrix` with `separator` for string seperator in a row and `row_separator` for string separator between rows.
---@param matrix matrix 2D matrix, continuous 1-indexed
---@param separator? string Seperation between element in a row. Defaults to ""
---@param row_separator? string Seperation between rows. Defaults to "\n"
function lib.mprint(matrix, separator, row_separator)
	separator = separator or ""
	row_separator = row_separator or "\n"

	local rows = {}
	for i_row = 1, #matrix do
		rows[#rows+1] = lib.lprint(matrix[i_row], separator)
	end

	print(table.concat(rows, row_separator))
end

---Copy every value from `list`.
---@param list list 1D list, continuous 1-indexed
---@return list 1D list with the same values as `list`
function lib.lcopy(list)
	local copy = {}
	for i = 1, #list do
		copy[#copy+1] = list[i]
	end
	return copy
end

---Copy every value from `matrix`.
---@param matrix matrix 2D matrix, continuous 1-indexed
---@return matrix 2D matrix with the same values as `matrix`
function lib.mcopy(matrix)
	local copy = {}
	for i = 1, #matrix do
		copy[#copy+1] = lib.lcopy(matrix[i])
	end
	return copy
end

---Tests equalities of two lists
---@param list1 list 1D table, continuous 1-D
---@param list2 list 1D table, continuous 1-D
---@return boolean #return `true` if `list1` == `list2` (values), else `false`
function lib.lequal(list1, list2)
	if #list1 ~= #list2 then
		error("Lists should have the same size to be compared")
	end

	for i = 1, #list1 do
		if list1[i] ~= list2[i] then
			return false
		end
	end

	return true
end

---Tests equalities of two matrix
---@param matrix1 matrix 2D table, continuous 2-D
---@param matrix2 matrix 2D table, continuous 2-D
---@return boolean #return `true` if `matrix1` == `matrix2` (values), else `false`
function lib.mequal(matrix1, matrix2)
	if #matrix1 ~= #matrix2 then
		error("Matrixes should have the same size to be compared")
	end

	for i = 1, #matrix1 do
		local error_code, rows_is_equal = pcall(lib.lequal, matrix1[i], matrix2[i])
		if not error_code then
			error("Matrixes should have the same size to be compared")
		end

		if not rows_is_equal then
			return false
		end
	end

	return true
end

return lib
