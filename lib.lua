local lib = {}

---@generic T an element of a list or matrix
---@alias list T[] a 1D continuous 1-indexed
---@alias matrix list[] a 2D continuous 1-indexed

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
		rows[#rows + 1] = lib.lprint(matrix[i_row], separator)
	end

	print(table.concat(rows, row_separator))
end

local function _copy(e)
	return e
end

---Copy every value from `list`.
---@generic T_cpy # type to be copied
---@param list list 1D list, continuous 1-indexed
---@param copy? fun(e: T_cpy):T_cpy Copy element function
---@return list 1D list with the same values as `list`
function lib.lcopy(list, copy)
	copy = copy or _copy

	local _list = {}
	for i = 1, #list do
		_list[#_list + 1] = copy(list[i])
	end
	return _list
end

---Copy every value from `matrix`.
---@generic T_cpy # type to be copied
---@param matrix matrix 2D matrix, continuous 1-indexed
---@param copy? fun(e: T_cpy):T_cpy Copy element function
---@return matrix 2D matrix with the same values as `matrix`
function lib.mcopy(matrix, copy)
	copy = copy or _copy

	local _matrix = {}
	for i = 1, #matrix do
		_matrix[#_matrix + 1] = lib.lcopy(matrix[i], copy)
	end
	return _matrix
end

local function _equal(a, b)
	return a == b
end
---Tests equalities of two lists
---@param list1 list 1D table, continuous 1-D
---@param list2 list 1D table, continuous 1-D
---@param equal? fun(e1, e2): boolean Function equality
---@return boolean #return `true` if `list1` == `list2` (values), else `false`
function lib.lequal(list1, list2, equal)
	equal = equal or _equal

	if #list1 ~= #list2 then
		error("Lists should have the same size to be compared")
	end

	for i = 1, #list1 do
		if not equal(list1[i], list2[i]) then
			return false
		end
	end

	return true
end

---Tests equalities of two matrix
---@param matrix1 matrix 2D table, continuous 2-D
---@param matrix2 matrix 2D table, continuous 2-D
---@param equal? fun(e1, e2): boolean Function equality
---@return boolean #return `true` if `matrix1` == `matrix2` (values), else `false`
function lib.mequal(matrix1, matrix2, equal)
	equal = equal or _equal

	if #matrix1 ~= #matrix2 then
		error("Matrixes should have the same size to be compared")
	end

	for i = 1, #matrix1 do
		local error_code, rows_is_equal = pcall(lib.lequal, matrix1[i], matrix2[i], equal)
		if not error_code then
			error("Matrixes should have the same size to be compared")
		end

		if not rows_is_equal then
			return false
		end
	end

	return true
end

---Get a list from a line of text
---@param line string
---@return list #continuous 1D-indexed table.
function lib.list_from_line(line)
	local list = {}

	for i = 1, #line do
		list[#list + 1] = line:sub(i, i)
	end
	return list
end

---Get the file contents with a list of string
---@param filename string File to be loaded
---@return string[] # lines of the file
function lib.lines_from_file(filename)
	local file = assert(io.open(filename), "r")

	local lines = {}
	for line in file:lines() do
		lines[#lines + 1] = line
	end

	file:close()
	return lines
end

---Create a matrix from a text file.
---@param filename string
---@return matrix # continuous 2D 1-indexed table.
function lib.matrix_from_file(filename)
	local file = assert(io.open(filename, "r"))

	local matrix = {}
	for line in file:lines() do
		matrix[#matrix + 1] = lib.list_from_line(line)
	end

	file:close()
	return matrix
end

---Sum elements of `list`.
---Elements should be convertible to `number`.
---@param list list
---@return number # Sum of all elements in `list`
function lib.lsum(list)
	local sum = 0
	for i = 1, #list do
		sum = sum + tonumber(list[i])
	end
	return sum
end

return lib
