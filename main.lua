local Drop2Shoot = RegisterMod("Drop2Shoot", 1)
Drop2Shoot.version = 1.3
Drop2Shoot.Enabled = false

Isaac.ConsoleOutput('Drop2Shoot v'..Drop2Shoot.version..' - Keye3Tuido\n')


--------------------------------------------------------------------

Drop2Shoot:AddCallback(13,function(self, entity, hook, action, func, util, id)
    if self.Enabled then
        entity=entity and entity:ToPlayer()
        if entity then
            util=function(x)
                return hook>1 and x>0 or hook<2 and x
            end
            id=entity.ControllerIndex
            func=hook>1 and Input.GetActionValue or hook<1 and Input.IsActionPressed or Input.IsActionTriggered
            if action==11 then
                for m=0,3 do
                    if util(func(m,id)) then
                        return hook>1 and 0
                    end
                end
            else
                entity=entity:GetData()
                id,func=util(func(action,id)),func(11,id)
                hook=util(func)
                if action<4 and id and not hook then
                    entity[self]=action+4
                elseif action==(entity[self]or 7)and hook then
                    return func
                end
            end
        end
    end
end)

--------------------------------------------------------------------
local font = Font()
font:Load('font/cjk/lanapixel.fnt')
local renderStr = 'Drop2Shoot'
local strWidth, baseHeight = font:GetStringWidth(renderStr), font:GetBaselineHeight()
local radius = Vector(strWidth/2, baseHeight/2)
local screenWidth, screenHeight, center, renderPos
function Drop2Shoot:Update()
    screenWidth, screenHeight = Isaac.GetScreenWidth(), Isaac.GetScreenHeight()
    center = Vector(screenWidth/2, screenHeight/2)
    renderPos = renderPos or Vector(center.X, screenHeight - baseHeight)
end
function Drop2Shoot:InBounds(pos)
    self:Update()
    return pos.X >= renderPos.X - radius.X and pos.X <= renderPos.X + radius.X
       and pos.Y >= renderPos.Y - radius.Y and pos.Y <= renderPos.Y + radius.Y
end
function Drop2Shoot:FixRenderPos()
    self:Update()
    renderPos = Vector(
        math.min(math.max(renderPos.X, radius.X), Isaac.GetScreenWidth() - radius.X),
        math.min(math.max(renderPos.Y, radius.Y), Isaac.GetScreenHeight() - radius.Y)
    )
end
local leftPressed,rightPressed,dragging = false,false,false
local alpha = 1
Drop2Shoot:AddCallback(ModCallbacks.MC_POST_RENDER, function(self)
    if not Options.MouseControl then
        local pos = Isaac.WorldToScreen(Input.GetMousePosition(true))
        Isaac.RenderText('o',pos.X-2.2,pos.Y-6.4,0,1,1,1)
    end
    local mpos = Isaac.WorldToScreen(Input.GetMousePosition(true))
    local kcolor = self.Enabled and KColor.Green or KColor.Red
    kcolor = KColor(kcolor.Red, kcolor.Green, kcolor.Blue, alpha)
    kcolor.Alpha = alpha
    if self:InBounds(mpos) then
        kcolor.Alpha = math.min(kcolor.Alpha + .01, 1)
        if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_LEFT) then
            if not leftPressed then
                leftPressed = true
            end
        else
            if leftPressed then
                self.Enabled = not self.Enabled
            end
            leftPressed = false
        end
    else
        kcolor.Alpha = math.max(kcolor.Alpha - .01, .3)
        leftPressed = false
    end
    alpha = kcolor.Alpha
    if Input.IsMouseBtnPressed(Mouse.MOUSE_BUTTON_RIGHT) then
        if self:InBounds(mpos) and not rightPressed then
            dragging = true
        end
        rightPressed = true
    else
        rightPressed = false
        dragging = false
    end
    
    if dragging then
        renderPos = mpos
    end
    self:FixRenderPos()
    
    if not Game():GetHUD():IsVisible() then return end
    font:DrawString(renderStr, renderPos.X - strWidth/2, renderPos.Y - baseHeight/2, kcolor, math.floor(.5+strWidth), true)
end)