-- Frame For Widgets
-- Need Mega Drawing Sistem to work.

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
            BorderRadius = 0,
            BorderColor = {0, 0, 0, 0},
        }

    }, buttons)
    table.insert(buttons, button)
    module.updateZindex()
    return button
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
    local position = self.position
    local size = self.size
    local color = self.color
    if nameClicked == self.name then
        color = self.clickedColor
    end
    ds.draw.rectangle(position.x, position.y, size.w, size.h, color, nil, nil, self.Border.BorderRadius, self.Border.BorderColor, self.Border.Active)
    ds.draw.text(position.x, position.y, self.Z, {0, 0, 0, 255})
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
