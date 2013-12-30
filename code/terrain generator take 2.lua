require 'perlin_noise'
require 'islandGenerator'

local noise_w = 80
local noise_h = 80
local noise_f = 1
local noise_o = 16

local map_w = 80
local map_h = 80

local world = islandGenerator.generate_island(noise_w, noise_h, noise_f, noise_o, map_h, map_w)
io.write("Write To File")
--output filled tiles to a file
local file = io.open("output2.dat", "w")
for i=1,map_w do 
	file:write("  ")
	for j=1,map_h do
		file:write(tostring(world[i][j])..",")
	end
	file:write("\n")
end
file:close()