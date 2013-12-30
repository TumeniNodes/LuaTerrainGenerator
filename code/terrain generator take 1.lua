--[[
Tile with a base of sprite '0', North and West sides are of sprite '1' and South and East Sides are Sprite '0'
i.e: [0,0] = [1,0,0,1,0]

Bases have a % chance to transition to a different base in a NSEW direction if no tile exists in said direction
Dictionary of bases with possible transitions with %ages
[0], [{0,.7}, {1,.2}, {2,.1}] A base of 0 has a 70% chance of staying at base 0, 20% chance of transitioning to base 1, and  a 10% chance of trainsitioning to base 2.


Initialize map size limit [64,64], [19x5], etc
Get initial starting location
i.e. on a size [64,64] map, start at [20,10] with a base of 0
	[20,10] = [0,0,0,0,0]
Move out in each cardinal direction by 1, check surrounding squares for initial bases
	[19,10] = [0,?,?,?,?]
Use surroundings to determine new base (majority rules),
 		[19,10] = [0,?,?,?,0]
Determine if one of sides will transition
		[19,10] = [0,0,1,0,0]
Continue spider-webbing out
--]]
local maxRowNum = 64
local maxColNum = 16
local numTileSets = 4
local tilesFilled = 0
terrainGenerator = {}
local matrix = {}

function terrainGenerator.mode(t)
	--Takes a group of tile bases and determines what is the most common
	local counts = {}
	for k,v in pairs(t) do 
		if counts[v] == nil then
			counts[v] = 1
		else
			counts[v] = counts[v] + 1
		end
	end
	local biggestCount = 0
	for k,v in pairs(counts) do
		if v > biggestCount then
			biggestCount = v
		end
	end
	local temp = {}
	for k,v in pairs(counts) do
		if v == biggestCount then
			table.insert(temp,k)
		end
	end
	return temp
end

function terrainGenerator.GenerateTile( row, col )
	--Validate Surrounding Tiles
	local NSEW = {}
	if row > 0 then
		NSEW[0] = matrix[row-1][col][1]
	else
		NSEW[0] = -1
	end
	if row < maxRowNum - 1 then
		NSEW[1] = matrix[row+1][col][0]
	else
		NSEW[1] = -1
	end
	if col > 0 then
		NSEW[2] = matrix[row][col-1][3]
	else
		NSEW[2] = -1
	end
	if col < maxColNum - 1 then
		NSEW[3] = matrix[row][col+1][2]
	else
		NSEW[3] = -1
	end
	local mode = terrainGenerator.mode(NSEW)
	--Only valid for tiles which haven't been assigned yet
	if matrix[row][col][4] == nil then
		--If all surrounding tiles are empty choose a random number...else choose the most current
		if mode[1] == nil then
			matrix[row][col][4] = math.random(numTileSets)
		elseif mode[1] == -1 then
			local temp_nsew = math.random(4) - 1
			while NSEW[temp_nsew] == -1 or NSEW[temp_nsew] == nil do
				temp_nsew = math.random(4) - 1
			end
			matrix[row][col][4] = NSEW[temp_nsew]
		else
			matrix[row][col][4] = mode[1]
		end
		--Fill in the edges by matching with the edges of other tiles
		for i=0,4 do
			if matrix[row][col][i] == nil then
				if NSEW[i] ~= nil then
					if NSEW[i] ~= -1 then
						matrix[row][col][i] = NSEW[i]
					else
						matrix[row][col][i] = matrix[row][col][4]
					end
				else
					if math.random() < .7 then
						matrix[row][col][i] = matrix[row][col][4]
					else 
						matrix[row][col][i] = math.random(numTileSets)
					end
				end
			end
		end
		tilesFilled = tilesFilled + 1
	end
	--Determine the next tile to go...cannot go over an edge
	local nextDirection = math.random(4) - 1
	while NSEW[nextDirection] == -1 do
		nextDirection = math.random(4) - 1
	end
	return nextDirection
end


for i=0,maxRowNum do 
	matrix[i] = {}
	for j=0,maxColNum do
		matrix[i][j] = {}
	end
end

math.randomseed(os.time())
local col = math.random(maxColNum)
local row = math.random(maxRowNum)

--While there are tiles left to fill keep filling
local randDirection = math.random(4)
while tilesFilled < (maxRowNum * maxColNum) do
	if randDirection == 0 then
		if	row > 0 then
			row = row - 1
		end
	elseif 	randDirection == 1 then
		if row < maxRowNum -1 then
			row = row + 1
		end
	elseif randDirection == 2 then
		if col > 0 then
			col = col - 1
		end
	elseif randDirection == 3 then
		if col < maxColNum - 1 then
			col = col + 1
		end
	end
	randDirection = terrainGenerator.GenerateTile(row, col)
end

--output filled tiles to a file
local file = io.open("output.dat", "w")
for i=0,maxRowNum-1 do 
	file:write("  ")
	for j=0,(maxColNum-1) do
		file:write(tostring(matrix[i][j][0]).."     ")
	end
	file:write("\n")
	for j=0,(maxColNum-1) do
		file:write(tostring(matrix[i][j][2]).." "..tostring(matrix[i][j][4]).." "..tostring(matrix[i][j][3]).." ")
	end
	file:write("\n  ")
	for j=0,(maxColNum-1) do
		file:write(tostring(matrix[i][j][1]).."     ")
	end
	file:write("\n")
end
file:close()