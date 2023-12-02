local common = {}
--[[
  find_colour_number - Search a specific colour in a string between 2 indexes.
	Parameters:
	line (string) - The string with colour number
	colour (string) - The colour we are searching for
	start_idx (number) - Begin to look at position start_idx
	max_idx (number | nil) - End to look at position max_idx.
		if nil, look until the rest of the string.

	Returns:
	number | nil - The number assiocated with the colour. If there is no colour,
		returns nil.
]]
function common.find_colour_number(line, colour, start_idx, max_idx)
	local idx, _, number = line:find("(%d+) " .. colour, start_idx)

	-- Nothing has been found
	-- or
	-- number is out of range
	if not idx or (max_idx and idx >= max_idx) then
		return nil
	end

	return tonumber(number)
end

return common
