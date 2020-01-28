local canvas = love.graphics.newCanvas()

local color = {
	{1, 1, 1},
	{0, 0, 0},
	{1, 0, 0},
	{0, 1, 0},
	{0, 0, 1},
	i = 1
}

local width = {
	1, 2, 3, 4, 5,
	i = 1
}

function love.mousepressed(x, y, key)
	if key == 2 then
		width.i = width.i + 1
		width.i = width.i > #width and 1 or width.i
		love.graphics.setLineWidth(width[width.i])
	end
end

function love.wheelmoved(vx, vy)
	color.i = color.i - vy
	color.i = color.i < 1 and #color or color.i > #color and 1 or color.i
end

local ffi = require("ffi")

pcall(ffi.cdef, [[
typedef struct ImageData_Pixel
{
    uint8_t r, g, b, a;
} ImageData_Pixel;
]])
local pixelptr = ffi.typeof("ImageData_Pixel *")

local mx, my

function fillFromPoint(x, y)
    local imgdata = canvas:newImageData()
    local pointer = ffi.cast(pixelptr, imgdata:getPointer())
    for i = 1, 100 do
        for j = 1, 100 do
            pointer[i + j * 100].r = 1
            pointer[i + j * 100].g = 1
            pointer[i + j * 100].b = 1
            pointer[i + j * 100].r = 1
        end
    end
    local newImage = love.graphics.newImage(imgdata)
    imgdata:encode("png", "canvas.png")
    love.graphics.setCanvas(canvas)
    love.graphics.setColor{1, 1, 1}
    love.graphics.rectangle("fill", 10, 10, 1000, 1000)
    love.graphics.draw(newImage, 0, 0)
    love.graphics.setCanvas()
    print("filled")
end

function love.update()
	if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        if love.keyboard.isDown("lshift") then
            fillFromPoint(x, y)
        end
		
		love.graphics.setCanvas(canvas)
		love.graphics.setColor(color[color.i])
		if not mx and not my then
			love.graphics.points(x, y)
		else
			love.graphics.line(mx, my, x, y)
		end
		mx, my = x, y
		love.graphics.setCanvas()
	else
		mx, my = nil, nil
	end

end

function love.keypressed(key)
	if key == 'space' then
		love.graphics.setCanvas(canvas)
		love.graphics.clear(color[color.i])
		love.graphics.setCanvas()
	end
end

function love.draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(canvas)

	love.graphics.print('Colors: ')
	for i, v in ipairs(color) do
		love.graphics.setColor(v)
		love.graphics.rectangle('fill', 40 + i * 12, 3, 10, 10)
		if i == color.i then 
			love.graphics.setColor(.5, .5, .5)
			local w = width[width.i]
			love.graphics.rectangle('fill', 42 + i * 12, 5, w, w)
		end
	end
end
