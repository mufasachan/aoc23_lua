local file = io.open("./input2", "r")

if not file then
	os.exit(1)
end

local function is_race_won(time_button_held, race_time, race_record)
	local race_distance = time_button_held * (race_time - time_button_held)
	return race_distance > race_record
end

local count_line = 1
local race = {}
for line in file:lines() do
	local number = line:match("%d+")

	if count_line == 1 then
		race.time = tonumber(number)
	else
		race.record = tonumber(number)
	end
	count_line = count_line + 1
end

local race_score = 0
for time_held = 1, race.time  do
	if is_race_won(time_held, race.time, race.record) then
		race_score = race_score + 1
	end
end

print("Score: " .. race_score)

-- distance = (sec held) * (race_time - sec_held)
