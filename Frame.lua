local module = {}

GlobalLayer = 1

nameClicked = nil
nameHold = nil

buttons = {}
buttons.__index = buttons

function buttons.new(name, x, y, w, h, color, text, textSize, textColor, layer, Zindex, clickedColor) --@string? @number?, @number?, @number?, @number?, @table?, @string?, @number?, @number?, @table?
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
        ColorDecrease = 1.5

    }, buttons)

    table.insert(buttons, button)
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

    local x = self.position.x + self.size.w / 2 - ((#self.text - 1) * self.textSize) / 2
    local y = self.position.y + self.size.h / 2 - self.textSize / 2
    
    --ds.draw.rectangle(x, y + 15, (#self.text - 1) * self.textSize, self.textSize)

    ds.draw.text(x, y, self.text, textColor, self.textSize)


end

function module.drawAll()
    for i = #buttons, 1, -1 do
        local obj = buttons[i]
        if GlobalLayer == obj.layer then
            obj:draw()
        end
    end
    
end

function module.updateZindex(func)
    func = func or function(a, b) return a.Z > b.Z end
    table.sort(buttons, func)
end

function module.updateAll()
    nameClicked = nil
    for _, obj in ipairs(buttons) do
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
end

return module
