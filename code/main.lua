require 'perlin_noise'
require 'islandGenerator'

local noise_w = 100
local noise_h = 100
local noise_f = 2
local noise_o = 18

local map_w = 100
local map_h = 100

local map_offset=6

local world = islandGenerator.generate_island(noise_w, noise_h, noise_f, noise_o, map_h, map_w)

function draw_world()
	for y=0, map_h do
		for x=0,map_w do
			local threshold = world[y+1][x+1]
			threshold = math.floor(threshold)
			love.graphics.setColor(threshold, threshold, threshold)
			love.graphics.rectangle("fill", (x*map_offset)+map_offset, (y*map_offset)+map_offset, map_offset, map_offset)
		end
	end
end

function love.draw()
	draw_world()
end