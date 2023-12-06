local file = io.open("./input", "r")

if not file then
	os.exit(1)
end

local function is_race_won(time_button_held, race_time, race_record)
	local race_distance = time_button_held * (race_time - time_button_held)

	return race_distance > race_record
end

local count_line = 1
local times = {}
local records = {}
for line in file:lines() do
	for number in line:gmatch("%d+") do
		if count_line == 1 then
			times[#times+1] = tonumber(number)
		else
			records[#records+1] = tonumber(number)
		end
	end
	count_line = count_line + 1
end

local races = {}
for i = 1, #times do
	races[#races+1] = { time = times[i], record = records[i]}
end

local score = 1
for i = 1, #races do
	local race = races[i]

	local race_score = 0
	for time_held = 1, race.time  do
		if is_race_won(time_held, race.time, race.record) then
			race_score = race_score + 1
		end
	end

	score = score * race_score
end

print("Score: " .. score)

-- distance = (sec held) * (race_time - sec_held)
