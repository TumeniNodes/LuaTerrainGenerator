perlinAlgo = {}
perlinAlgo.noise = {}
perlinAlgo.noise_width = 0
perlinAlgo.noise_height = 0

function perlinAlgo.generateNoise(width, height, frequency, octaves)
	perlinAlgo.noise_width = width
	perlinAlgo.noise_height = height

	for i=0,perlinAlgo.noise_height do
		local noise_row = {}
		for j=0,perlinAlgo.noise_width do
			local rand = math.random(1000) / 1000
			table.insert(noise_row, rand)
		end
		table.insert(perlinAlgo.noise, noise_row)
	end

	local result = {}

	for i=0,perlinAlgo.noise_height do
		local row = {}
		for j=0,perlinAlgo.noise_width do
			local turb = math.floor(perlinAlgo.turbulence(i*frequency,j*frequency,octaves))
			table.insert(row,turb)
		end
		table.insert(result, row)
	end
	return result
end

function perlinAlgo.turbulence(x, y, size)
	local value = 0.0
	size = size * 1.0
	local initial_size = size

	while size >= 1 do
		value = value + perlinAlgo.smoothNoise(x / size, y / size) * size
		size = size / 2.0
	end

	return 128.0 * value / initial_size
end


function perlinAlgo.smoothNoise(x,y)
	local fractX = x - math.floor(x)
	local fractY = y - math.floor(y)

	local x1 = (math.floor(x) + perlinAlgo.noise_width) % perlinAlgo.noise_width
	local y1 = (math.floor(y) + perlinAlgo.noise_height) % perlinAlgo.noise_height

	local x2 = (x1 + perlinAlgo.noise_width - 1) % perlinAlgo.noise_width
	local y2 = (y1 + perlinAlgo.noise_height - 1) % perlinAlgo.noise_height

	local value = 0.0
	--io.write (x,",",y," - ",y1,",",x1,",",y2,",",x2,"\n")
	value = value + fractX * fractY * perlinAlgo.noise[y1+1][x1+1]
	value = value + fractX * (1 - fractY) * perlinAlgo.noise[y2+1][x1+1]
	value = value + (1 - fractX) * fractY * perlinAlgo.noise[y1+1][x2+1]
	value = value + (1 - fractX) * (1 - fractY) * perlinAlgo.noise[y2+1][x2+1]

	return value
end
