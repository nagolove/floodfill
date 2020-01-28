local canvas = love.graphics.newCanvas()
local inspect = require "inspect"

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
    local fillColor = color[color.i]
    local borderColor = color[color.i]
    local imgdata = canvas:newImageData()
    local pointer = ffi.cast(pixelptr, imgdata:getPointer())
    local w, h = imgdata:getDimensions()
    print("w", w, "h", h)

    function getPixel(px, py)
        if px >= 1 and px <= w and py >= 1 and py <= h then
            return {
            pointer[py * w + px].r / 255,
            pointer[py * w + px].g / 255,
            pointer[py * w + px].b / 255,
            pointer[py * w + px].a / 255,
        }
        end
    end

    print("color under cursor", inspect(getPixel(x, y)))

    function putPixel(px, py, color)
        if px >= 1 and px <= w and py >= 1 and py <= h then
            pointer[py * w + px].r = color[1] * 255
            pointer[py * w + px].g = color[2] * 255
            pointer[py * w + px].b = color[3] * 255
            pointer[py * w + px].a = 255
        end
    end

    function fillPixel(px, py)
        if px >= 1 and px <= w and py >= 1 and py <= h then
            local c = getPixel(px, py)
            if c[1] == 0 and c[2] == 0 and c[3] == 0 and
                c[1] ~= fillColor[1] and c[2] ~= fillColor[2] and 
                c[3] ~= fillColor[3] then
                putPixel(px, py, fillColor)

                print("ok")
                fillPixel(px + 1, py)
                fillPixel(px - 1, py)
                fillPixel(px, py + 1)
                fillPixel(px, py - 1)
            end
        end
    end

    fillPixel(x, y)
    --fillPixel(x + 1, y + 1)
    --fillPixel(x + 1, y - 1)
    --fillPixel(x - 1, y + 1)
    --fillPixel(x - 1, y - 1)

    local newImage = love.graphics.newImage(imgdata)
    imgdata:encode("png", "canvas.png")
    love.graphics.setCanvas(canvas)
    love.graphics.setColor{1, 1, 1}
    --love.graphics.rectangle("fill", 10, 10, 1000, 1000)
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
