local module = {
    buttons = {},
    checkBox = {}
}

BUTTON, CHECKBOX = "button", "checkbox"

GlobalLayer = 1

nameClicked = nil
nameHold = nil

click = false

local checkSelectedIMG = love.graphics.newImage(PATH_LIBRARIES .. "check.png")

function love.mousepressed(mx, my, button)
    if button == 1 then
        click = true
    end
end

local objs = {}
objs.__index = objs

local buttons = {}
buttons.__index = buttons
setmetatable(buttons, objs)

local checkBox = {}
checkBox.__index = checkBox
setmetatable(checkBox, objs)

function module.checkBox.new(name, x, y, s, layer, Zindex)
    name = name or "NIL"
    layer = layer or 1
    Zindex = Zindex or 1

    local check = setmetatable({
        name = name,
        position = {x = x, y = y},
        size = {w = s, h = s},
        selected = false,
        layer = layer,
        Z = Zindex,
        tipe = CHECKBOX

    }, checkBox)

    table.insert(objs, check)
    module.updateZindex()
    return check
end

function module.buttons.new(name, x, y, w, h, color, text, textSize, textColor, layer, Zindex, clickedColor) --@string? @number?, @number?, @number?, @number?, @table?, @string?, @number?, @number?, @table?
    color = color or {255, 255, 255, 255}
    clickedColor = clickedColor or {color[1] / 1.5, color[2] / 1.5, color[3] / 1.5, color[4]}
    name = name or "NIL"
    layer = layer or 1
    Zindex = Zindex or 1

    local button = setmetatable({

        name = name,
        text = text,
        position = {x = x, y = y},
        size = {w = w, h = h},
        textSize = textSize or 16,
        color = color,
        textColor = textColor or { 255, 255, 255, 255},
        clickedColor = clickedColor,
        click = false,
        hold = false,
        layer = layer,
        Z = Zindex,
        Border = {
            Active = false,
            Radius = 0,
            Color = {0, 0, 0, 0},
        },
        Gradient = {
            Active = false,
            Color1 = {0, 0, 0, 255},
            Color2 = {255, 255, 255, 255},
            Rotation = 0
        },
        ColorDecrease = 1.5,
        tipe = BUTTON

    }, buttons)

    table.insert(objs, button)
    module.updateZindex()
    return button
end

function buttons:optionals(Border, Gradient)
    local BActive = Border.Active or false
    local BRadius = Border.Radius or 0
    local BColor = Border.Color or {255, 255, 255, 255}

    self.Border.Active = BActive
    self.Border.Radius = BRadius
    self.Border.Color = BColor

    local GActive = Gradient.Active or false
    local GColor1 = Gradient.Color1 or {255, 255, 255, 255}
    local GColor2 = Gradient.Color2 or {255, 255, 255, 255}

    self.Gradient.Active = GActive
    self.Gradient.Color1 = GColor1
    self.Gradient.Color2 = GColor2
end

function buttons:update()
    local position = self.position
    local size = self.size
    local mx, my = MOUSEX, MOUSEY
    self.click = false
    if ds.isPointInBox(mx, my, position.x, position.y, size.w, size.h) then
        if love.mouse.isDown(1) then
            self.click = false
            if not self.hold then
                self.click = true
            end
            self.hold = true
        else
            self.hold = false
        end
    else
        self.hold = false
    end
end

function buttons:draw()
    local color = self.color
    local borderColor =  self.Border.Color
    local textColor =  self.textColor

    local color1 = self.Gradient.Color1
    local color2 = self.Gradient.Color2


    if self.hold then
        color = self.clickedColor
        textColor = {textColor[1] / self.ColorDecrease, textColor[2] / self.ColorDecrease, textColor[3] / self.ColorDecrease, textColor[4]}
        borderColor = {borderColor[1] / self.ColorDecrease, borderColor[2] / self.ColorDecrease, borderColor[3] / self.ColorDecrease, borderColor[4]}
        color1 = {color1[1] / self.ColorDecrease, color1[2] / self.ColorDecrease, color1[3] / self.ColorDecrease, color1[4] / self.ColorDecrease}
        color2 = {color2[1] / self.ColorDecrease, color2[2] / self.ColorDecrease, color2[3] / self.ColorDecrease, color2[4] / self.ColorDecrease}
        textColor = {textColor[1] / self.ColorDecrease, textColor[2] / self.ColorDecrease, textColor[3] / self.ColorDecrease, textColor[4]}
    end

    if self.Gradient.Active then

        GradientShader:send("color1", ds.color.normal(color1))
        GradientShader:send("color2", ds.color.normal(color2))
        GradientShader:send("size", {self.size.w, self.size.h})
        GradientShader:send("center", {self.size.w / 2 + self.position.x, self.size.h / 2 + self.position.y})
        GradientShader:send("rotation", math.rad(self.Gradient.Rotation))
        love.graphics.setShader(GradientShader)
    end

    ds.draw.rectangle(self.position.x, self.position.y, self.size.w, self.size.h, color, nil, nil, self.Border.Radius, borderColor, self.Border.Active)

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(self.text) * (self.textSize / 256) -- Ajustar a escala da fonte
    local textHeight = font:getHeight() * (self.textSize / 256) -- Ajustar a altura

    local x = self.position.x + (self.size.w - textWidth) / 2
    local y = self.position.y + (self.size.h - textHeight) / 2

    --ds.draw.rectangle(x, y + 15, textWidth, textHeight)
    ds.draw.text(x, y, self.text, textColor, textWidth / (#self.text / 2))

end

function checkBox:draw()
    local color = {128, 0, 255, 255}
    local x, y, w, h = self.position.x, self.position.y, self.size.w, self.size.h
    if self.selected then
        color = {0, 255, 255, 255}
        ds.draw.rectangle(x, y, w, h, color, nil, nil, 2, {30, 30, 30, 255}, true)
        ds.draw.image(x, y, w, h, checkSelectedIMG)
    else
        ds.draw.rectangle(x, y, w, h, color, nil, nil, 2, {30, 30, 30, 255}, true)
    end
end

function checkBox:update()
    local x, y, w, h = self.position.x, self.position.y, self.size.w, self.size.h
    local mx, my = MOUSEX, MOUSEY

    if ds.isPointInBox(mx, my, x, y, w, h) then
        if click then
            self.selected = not self.selected
        end
    end
end

function module.drawAll()
    for i = #objs, 1, -1 do
        local obj = objs[i]
        if GlobalLayer == obj.layer then
            obj:draw()
        end
    end
    
end

function module.updateZindex(func)
    func = func or function(a, b) return a.Z > b.Z end
    table.sort(objs, func)
end

function module.updateAll()
    nameClicked = nil
    for i, obj in ipairs(objs) do
        if GlobalLayer == obj.layer then
            obj:update()
            local c = false
            if obj.click then
                nameClicked = obj.name
                c = true
            end
            if obj.hold then
                nameHold = obj.name
                c = true
            end
            if c then
                break
            end
        end
    end
    click = false
end

return module
