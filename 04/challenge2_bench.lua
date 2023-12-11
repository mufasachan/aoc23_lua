local function is_inside(list, x)
	for i = 1, #list do
		if x == list[i] then
			return true
		end
	end

	return false
end

local function run()
	local file = io.open("./input", "r")

	if not file then
		os.exit(1)
	end

	local t1 = os.clock()

	local number_winning_numbers_one_line = 10
	local number_player_numbers_one_line = 25

	local start_winning_number_idx = 11
	local start_player_number_idx = 43

	local nb_cards_by_line = {}
	local nb_cards = 214
	for i = 1, nb_cards do
		nb_cards_by_line[i] = 1
	end

	local card_number = 1
	for line in file:lines() do
		-- Extract winning numbers
		local winning_numbers = {}
		for i = 1, number_winning_numbers_one_line do
			winning_numbers[#winning_numbers+1] = tonumber(
				line:sub(
					start_winning_number_idx + (i-1) * 3,
					start_winning_number_idx + (i-1) * 3 + 2
				)
			)
		end

		local count_correct_number = 0
		-- Get player number and check if they are in winning numbers
		for i = 1, number_player_numbers_one_line do
			local player_number = tonumber(
				line:sub(
					start_player_number_idx + (i-1) * 3,
					start_player_number_idx + (i-1) * 3 + 2
			)
			)

			if is_inside(winning_numbers, player_number) then
				count_correct_number = count_correct_number + 1
			end
		end

		if count_correct_number == 0 then
			goto next_line
		end

		-- Add copies
		for i = 1, count_correct_number do
			nb_cards_by_line[card_number + i] = nb_cards_by_line[card_number + i] + nb_cards_by_line[card_number]
		end

		::next_line::
		card_number = card_number + 1
	end

	local all_cards = 0
	for nb_card = 1, nb_cards do
		all_cards = all_cards + nb_cards_by_line[nb_card]
	end

	local t2 = os.clock()

	file:close()

	return t2 - t1
end

local nb_runs = 500
local total_duration = 0
for _ = 1, 500 do
	total_duration = total_duration + run()
end
print("Duration " .. total_duration / nb_runs *1000 .. " ms")
