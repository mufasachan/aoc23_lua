local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local strenghts = {
	A = 12,
	K = 11,
	Q = 10,
	J = 9,
	T = 8,
	['9'] = 7,
	['8'] = 6,
	['7'] = 5,
	['6'] = 4,
	['5'] = 3,
	['4'] = 2,
	['3'] = 1,
	['2'] = 0
}

-- [
-- Compare two hands of cards
--
-- Parameters:
-- hand_1 (string) first hand
-- hand_2 (string) second hand
--
-- Returns:
-- Return true if hand_1 is better, else false
-- ]
local function hand_compare(hand_1, hand_2)
	if hand_1.value > hand_2.value then
		return true
	end

	if hand_1.value < hand_2.value then
		return false
	end

	for i = 1, #hand_1.hand do
		local card_1 = hand_1.hand:sub(i, i)
		local card_2 = hand_2.hand:sub(i, i)
		if card_1 ~= card_2 then
			return strenghts[card_1] > strenghts[card_2]
		end
	end
end

local function get_value(hand)
	local counter = {}
	for i = 1, #hand do
		local card = hand:sub(i, i)

		if counter[card] then
			counter[card] = counter[card] + 1
		else
			counter[card] = 1
		end

	end

	local has_three_cards = false
	local has_two_cards = false
	local has_two_pairs = false
	for _, count in pairs(counter) do
		if count >= 4 then
			return count + 2
		end

		if count == 3 then
			has_three_cards = true
		end

		if count == 2 then
			if has_two_cards then
				has_two_pairs = true
				has_two_cards = false
			else
				has_two_cards = true
			end
		end
	end

	if has_three_cards and has_two_cards then
		return 5
	elseif has_three_cards then
		return 4
	elseif has_two_pairs then
		return 3
	elseif has_two_cards then
		return 2
	end

	return 0
end

local function get_hand(line)
	local _hand = line:sub(1, 5)
	local _bid = line:sub(7, #line)
	local _value = get_value(_hand)

	return { hand = _hand, value = _value, bid = _bid }
end

-- We iterate through lines and build an array of hands
-- This array should be sorted.
-- So the array needs to have the hand and the bid (for score calculations)
local sorted_hands = {}
for line in file:lines() do
	local hand = get_hand(line)

	-- Iterate to current sorted_hands
	if not sorted_hands then
		sorted_hands[#sorted_hands+1] = hand
		goto next_hand
	end

	for i = 1, #sorted_hands do
		local sorted_hand = sorted_hands[i]

		-- hand < sorted_hand
		if not hand_compare(hand, sorted_hand) then
			table.insert(sorted_hands, i, hand)
			goto next_hand
		end
	end

	-- hand is better than any hand
	sorted_hands[#sorted_hands+1] = hand

    ::next_hand::
end

-- Once we did that we can iterate through this array and count score
local score = 0
for rank = 1, #sorted_hands do
	score = score + rank * sorted_hands[rank].bid
end

print(score)

file:close()
