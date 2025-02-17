local module = {}

GlobalLayer = 1

nameClicked = nil
nameHold = nil

buttons = {}
buttons.__index = buttons

function buttons.new(name, x, y, w, h, color, text, layer, Zindex, clickedColor) --@string? @number?, @number?, @number?, @number?, @table?, @string?, @number?, @number?, @table?
    color = color or {255, 255, 255, 255}
    clickedColor = clickedColor or {color[1] / 1.5, color[2] / 1.5, color[3] / 1.5, color[4]}
    name = name or "NIL"
    layer = layer or 1
    Zindex = Zindex or 1

    local button = setmetatable({

        name = name,
        position = {x = x, y = y},
        size = {w = w, h = h},
        color = color,
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
        }

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

    if self.hold then
        color = self.clickedColor
    end
    local color1 = self.Gradient.Color1
    local color2 = self.Gradient.Color2

    GradientShader:send("color1", ds.color.normal(color1))
    GradientShader:send("color2", ds.color.normal(color2))
    GradientShader:send("size", {self.size.w, self.size.h})
    GradientShader:send("center", {self.size.w / 2 + self.position.x, self.size.h / 2 + self.position.y})
    GradientShader:send("rotation", math.rad(self.Gradient.Rotation))

    love.graphics.setShader(GradientShader)
    ds.draw.rectangle(self.position.x, self.position.y, self.size.w, self.size.h, nil, nil, nil, self.Border.Radius, self.Border.Color, self.Border.Active)

    ds.draw.text(self.position.x, self.position.y, self.Z)
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
