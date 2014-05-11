local Game = require 'game'
local Loading = Game:addState('Loading')

local loader = require 'lib/love-loader'
local Quad = require 'subclass/quad'

local percent = 0
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

local function drawLoadingBar()
	local separation = 30;
	local w = screenWidth - 2*separation
	local h = 50;
	local x,y = separation, screenHeight - separation - h;
	love.graphics.rectangle("line", x, y, w, h)

	x, y = x + 3, y + 3
	w, h = w - 6, h - 7

	if loader.loadedCount > 0 then
		w = w * (loader.loadedCount / loader.resourceCount)
	end
	love.graphics.rectangle("fill", x, y, w, h)
end

local function processQuads(ressources)
	for k,v in pairs(ressources.images) do
		if v.quads and type(v.quads) == 'table' then	
			for i,j in pairs(v.quads) do
				media.quads[i] = Quad:new( media.images[ v[1] ], unpack(j))
			end
		else
			media.quads[v[1]] = Quad:new( media.images[ v[1] ])
		end
	end
end

function Loading:enteredState( nextscene, ressources )
	self:log('Entered Loading',nextscene, ressources)

	math.randomseed(os.time())
	
	self.fadein = { alpha = 0 }
	-- Title text
	flux.to(self.fadein, 0.25, { alpha = 1 }):ease("quadin")

	self.ressources = ressources
	
	self:log("adding sources ...")
	if ressources then
		if ressources.images then
			for k,v in pairs(ressources.images) do
				print(k, v[1], v[2])
				loader.newImage(media.images, v[1], v[2])
			end
		end
		if ressources.imagedata then
			for k,v in pairs(ressources.imagedata) do
				print(k, v[1], v[2])
				loader.newImageData(media.images, v[1], v[2])
			end
		end
		if ressources.source then
			for k,v in pairs(ressources.source) do
				print(k, v[1], v[2], v[3])
				loader.newSource(media.sounds, v[1], v[2], v[3])
			end
		end
		if ressources.sounddata then
			for k,v in pairs(ressources.sounddata) do
				print(k, v[1], v[2])
				loader.newSoundData(media.sounds, v[1], v[2])
			end
		end
	end

	self:log("start loading")
	loader.start( function () processQuads(ressources); self:gotoState( nextscene ) end, print)
end

function Loading:exitedState()
	love.graphics.setColor(255, 255, 255, 255)
	self:log('Exiting Loading')
end

function Loading:draw()
	love.graphics.setColor(255, 255, 255, self.fadein.alpha * 255)
	
	drawLoadingBar()
	if loader.resourceCount ~= 0 then percent = loader.loadedCount / loader.resourceCount end
	local percentagestring = ("Loading .. %d%%"):format(percent*100)
    love.graphics.print(percentagestring, screenWidth/2-string.len(percentagestring)*2, screenHeight/2)
end

function Loading:update( dt )
	loader.update()
end

return Loading