require 'perlin_noise'

islandGenerator = {}

function islandGenerator.generate_island(noise_width, noise_height, noise_frequency, noise_octaves, map_height, map_width)
		local map = perlinAlgo.generateNoise(noise_width, noise_height, noise_frequency, noise_octaves)
		
		local particle_map = {}

		for i=0,map_height do
			local row = {}
			for j=0,map_width do
				table.insert(row,0)
			end
			table.insert(particle_map,row)
		end

		for i=0,math.floor(map_width*map_height*0.85) do
			local x = math.random(15, map_width-16)
			local y = math.random(15, map_height-16)

			for j=0,math.floor(map_width*map_height*0.05) do
				particle_map[y][x] = particle_map[y][x] + 7
				if particle_map[y][x] >= 255 then
					particle_map[y][x] = 255
				end
				local current_value = particle_map[y][x]
				local choices = {}
				if x-1 > 0 then
					if particle_map[y][x-1] <= current_value then
						table.insert(choices, "left")
					end
				end
				if x+1 < map_width-1 then
					if particle_map[y][x+1] <= current_value then
						table.insert(choices, "right")
					end
				end
				if y-1 > 0 then
					if particle_map[y-1][x] <= current_value then
						table.insert(choices, "up")
					end
				end
				if y+1 < map_height-1 then
					if particle_map[y+1][x] <= current_value then
						table.insert(choices, "down")
					end
				end

				if next(choices) == nil then break end

				local new = choices[math.random(#choices)]
				if new == "left" then
					x = x - 1
				elseif new == "right" then
					x = x + 1
				elseif new == "up" then
					y = y - 1
				elseif new == "down" then
					y = y + 1
				end
			end
		end

		for y=0,map_height do
			for x=0,map_width do
				map[y+1][x+1] = map[y+1][x+1] * ((particle_map[y+1][x+1]) / 255.0 )
			end
		end
		io.write("begin smoothing")
		map = islandGenerator.smoothen(map, map_height, map_width)
		io.write("returning map")
		return map
end

function islandGenerator.smoothen (map, height, width)
	for y=1,height + 1 do
		for x=1,width + 1 do
			local average = 0.0
			local times = 0.0

			if x-1 >= 1 then
				average = average + map[y][x-1]
				times = times + 1
			end
			if x+1 < width then
				average = average + map[y][x+1]
				times = times + 1
			end
			if y-1 >= 1 then
				average = average + map[y-1][x]
				times = times + 1
			end
			if y+1 < height then
				average = average + map[y+1][x]
				times = times + 1
			end

			if x-1 >= 1 and y-1 >= 1 then
				average = average + map[y-1][x-1]
				times = times + 1
			end
			if x+1 < width and y-1 >= 1 then
				average = average + map[y-1][x+1]
				times = times + 1
			end
			if x-1 >= 1 and y+1 < height then
				average = average + map[y+1][x-1]
				times = times + 1
			end
			if x+1 < width and y+1 < height then
				average = average + map[y+1][x+1]
				times = times + 1
			end

			average = average + map[y][x]
			times = times + 1

			average = average / times

			map[y][x] = average
		end
	end
	return map
end