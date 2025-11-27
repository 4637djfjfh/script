local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "ModeGui"
local TextLabel = Instance.new("TextLabel", ScreenGui)
TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
TextLabel.Position = UDim2.new(0.5,0,0.85,0)
TextLabel.Size = UDim2.new(0,400,0,80)
TextLabel.BackgroundTransparency = 1
TextLabel.TextScaled = true
TextLabel.TextColor3 = Color3.new(1,1,1)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextTransparency = 1

local mode = 1
local effects = {}
local currentConnection = nil
local currentTrack = nil

local function clearEffects()
	for _, v in pairs(effects) do
		v:Destroy()
	end
	effects = {}
	if currentConnection then
		currentConnection:Disconnect()
		currentConnection = nil
	end
	if currentTrack then
		currentTrack:Stop()
		currentTrack = nil
	end
end

local function showText(text, color)
	TextLabel.Text = text
	TextLabel.TextColor3 = color
	local tweenIn = TweenService:Create(TextLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency=0})
	local tweenOut = TweenService:Create(TextLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency=1})
	tweenIn:Play()
	tweenIn.Completed:Connect(function()
		task.delay(0.8, function() -- non-blocking wait
			tweenOut:Play()
		end)
	end)
end

local function playAnim(id)
	if currentTrack then
		currentTrack:Stop()
	end
	local anim = Instance.new("Animation")
	anim.AnimationId = "rbxassetid://"..id
	local track = humanoid:LoadAnimation(anim)
	track:Play()
	currentTrack = track
	return track
end

local function modeExotic()
	clearEffects()
	showText("EXOTIC", Color3.fromRGB(255,255,255))
	playAnim("125722696765151")
	local attach1 = Instance.new("Attachment", hrp)
	local attach2 = Instance.new("Attachment", hrp)
	attach1.Position = Vector3.new(2,0,-1)
	attach2.Position = Vector3.new(-2,0,-1)
	for _, wing in pairs({attach1, attach2}) do
		local p = Instance.new("ParticleEmitter", wing)
		p.Texture = "rbxassetid://241837157"
		p.Lifetime = NumberRange.new(1)
		p.Rate = 40
		p.Speed = NumberRange.new(2,5)
		p.Size = NumberSequence.new(1.5)
		p.LightEmission = 1
		p.Rotation = NumberRange.new(0,360)
		p.RotSpeed = NumberRange.new(-90,90)
		p.Transparency = NumberSequence.new(0,1)
		p.Color = ColorSequence.new(Color3.fromRGB(255,255,255))
	end
	table.insert(effects, attach1)
	table.insert(effects, attach2)
end

local function modeChromatic()
	clearEffects()
	showText("CHROMATIC", Color3.fromRGB(255,50,50))
	playAnim("87449122230956")
	local auraAttach = Instance.new("Attachment", hrp)
	local aura = Instance.new("ParticleEmitter", auraAttach)
	aura.Texture = "rbxassetid://243098098"
	aura.Lifetime = NumberRange.new(0.6)
	aura.Rate = 120
	aura.Speed = NumberRange.new(1,2)
	aura.Size = NumberSequence.new(2)
	aura.Transparency = NumberSequence.new(0,1)
	aura.LightEmission = 1
	aura.Color = ColorSequence.new(Color3.fromRGB(255,0,0))
	table.insert(effects, auraAttach)
end

local function modeAura()
	clearEffects()
	showText("AURA", Color3.fromRGB(255,60,60))
	playAnim("123127694191310")
	local outline = Instance.new("SelectionBox")
	outline.LineThickness = 0.05
	outline.Color3 = Color3.fromRGB(255,0,0)
	outline.Adornee = character
	outline.Parent = character
	table.insert(effects, outline)
	local fireAttach = Instance.new("Attachment", hrp)
	local fire = Instance.new("ParticleEmitter", fireAttach)
	fire.Texture = "rbxassetid://241837157"
	fire.Lifetime = NumberRange.new(0.3,0.8)
	fire.Rate = 100
	fire.Speed = NumberRange.new(3,7)
	fire.Size = NumberSequence.new({NumberSequenceKeypoint.new(0,3),NumberSequenceKeypoint.new(1,0)})
	fire.LightEmission = 1
	fire.Color = ColorSequence.new(Color3.fromRGB(50,100,255))
	table.insert(effects, fireAttach)
end

local function modeLevitation()
	clearEffects()
	showText("LEVITATION", Color3.fromRGB(255,255,100))
	playAnim("88138077358201")
	local stars = {}
	local numStars = 10
	local radius = 3
	for i=1,numStars do
		local part = Instance.new("Part")
		part.Size = Vector3.new(0.2,0.2,0.2)
		part.Anchored = true
		part.CanCollide = false
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255,255,255)
		part.Parent = workspace
		table.insert(stars, part)
		table.insert(effects, part)
	end
	local angle = 0
	currentConnection = RunService.RenderStepped:Connect(function()
		if #stars == 0 then return end
		angle = angle + 0.02
		for i, star in ipairs(stars) do
			local offsetAngle = (i/numStars)*math.pi*2
			local x = math.cos(angle + offsetAngle)*radius
			local z = math.sin(angle + offsetAngle)*radius
			star.Position = hrp.Position + Vector3.new(x,2,z)
		end
	end)
end

local function switchMode()
	mode = mode + 1
	if mode>4 then mode=1 end
	if mode==1 then modeExotic()
	elseif mode==2 then modeChromatic()
	elseif mode==3 then modeAura()
	else modeLevitation()
	end
end

modeExotic()

game:GetService("UserInputService").InputBegan:Connect(function(input,gpe)
	if gpe then return end
	if input.KeyCode==Enum.KeyCode.F then
		switchMode()
	end
end)

task.wait(.1)
getgenv().tilt = true

local rs,plr = game:GetService("RunService"),game:GetService("Players")
local me,chr,hum,hrp = plr.LocalPlayer,nil,nil,nil
local px,py = 0,0

local cfg = {
    ptime = .25,
    smooth = 5,
    pred = .4,
    base = .1,
    dead = .05,
    side = 25,
    sideSmooth = 5
}

local function init()
    chr = me.Character or me.CharacterAdded:Wait()
    hum = chr:WaitForChild("Humanoid")
    hrp = chr:WaitForChild("HumanoidRootPart")
end
init()

rs.RenderStepped:Connect(function(dt)
    if not (chr and hrp) then return end
    local mv = hum.MoveDirection
    local sx,sp = 0,0
    if mv.Magnitude>0 then
        local rel = hrp.CFrame:VectorToObjectSpace(mv)
        sx = -rel.X*cfg.side
        local pos,vel = hrp.Position,hrp.Velocity
        local fut = pos+vel*cfg.ptime
        local dy = fut.Y-pos.Y
        if math.abs(dy)>cfg.dead then
            local flat = Vector3.new(hrp.CFrame.LookVector.X,0,hrp.CFrame.LookVector.Z).Unit
            local dist = (Vector3.new(fut.X,pos.Y,fut.Z)-pos).Magnitude
            sp+=math.atan2(dy,dist)*cfg.pred
        end
        sp+=rel.Z*cfg.base
    end
    py += (sx-py)*math.min(dt*cfg.sideSmooth,1)
    px += (sp-px)*math.clamp(dt*cfg.smooth,0,1)
    local yaw = CFrame.Angles(0,math.rad(hrp.Orientation.Y),0)
    hrp.CFrame = CFrame.new(hrp.Position)*yaw*CFrame.Angles(px,0,math.rad(py))
end)

-- === Mobile "F" Button (Frosted Glass + Pressed + Dynamic Gloss + Drag + Light Follow) ===
local UIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Name = "MobileFButton"
gui.Parent = playerGui

-- 主 F 按钮
local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0,65,0,40)
button.Position = UDim2.new(1,-80,1,-170)
button.AnchorPoint = Vector2.new(0.5,0.5)
button.Text = "F"
button.TextScaled = true
button.TextColor3 = Color3.fromRGB(255,255,255)
button.BackgroundTransparency = 0.6
button.AutoButtonColor = false
button.BorderSizePixel = 0
button.ClipsDescendants = true
button.Visible = UIS.TouchEnabled

-- 圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,12)
corner.Parent = button

-- 磨砂玻璃渐变
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,200,200))
})
gradient.Rotation = 45
gradient.Parent = button

-- 内阴影边框
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0,0,0)
stroke.Transparency = 0.7
stroke.Thickness = 1.5
stroke.Parent = button

-- 顶部高光层
local highlight = Instance.new("Frame")
highlight.Parent = button
highlight.Size = UDim2.new(1,0,0.3,0)
highlight.Position = UDim2.new(0,0,0,0)
highlight.BackgroundTransparency = 0.7
highlight.BackgroundColor3 = Color3.fromRGB(255,255,255)
highlight.ClipsDescendants = true
highlight.ZIndex = 2
local hlCorner = Instance.new("UICorner")
hlCorner.CornerRadius = UDim.new(0,12)
hlCorner.Parent = highlight

-- 高光渐变（动态光泽）
local gloss = Instance.new("UIGradient")
gloss.Color = ColorSequence.new(Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
gloss.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,0.6),NumberSequenceKeypoint.new(1,1)})
gloss.Rotation = 45
gloss.Parent = highlight

-- 尺寸与透明度
local normalSize = UDim2.new(0,65,0,40)
local pressedSize = UDim2.new(0,58,0,35)
local fadedSize  = UDim2.new(0,48,0,30)
local normalTransparency = 0.6
local pressedTransparency = 0.45
local fadedTransparency  = 0.8

local inactiveTime = 0
local FADE_DELAY = 30
local faded = false

-- 点击动画（凹陷 + 动态光泽）
local function clickAnim()
    local tweenPress = TweenService:Create(button, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
        Size = pressedSize,
        BackgroundTransparency = pressedTransparency
    })
    local tweenHighlight = TweenService:Create(highlight, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.85,
        Position = UDim2.new(0,2,0,2)
    })
    local tweenRelease = TweenService:Create(button, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        Size = normalSize,
        BackgroundTransparency = normalTransparency
    })
    local tweenHighlightBack = TweenService:Create(highlight, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0,0,0,0)
    })
    tweenPress:Play()
    tweenHighlight:Play()
    tweenPress.Completed:Connect(function()
        tweenRelease:Play()
        tweenHighlightBack:Play()
    end)
end

-- 恢复与淡出
local function restoreState()
    if faded then
        faded = false
        TweenService:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Size = normalSize,
            BackgroundTransparency = normalTransparency
        }):Play()
        TweenService:Create(highlight, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.7,
            Position = UDim2.new(0,0,0,0)
        }):Play()
    end
end

local function fadeButton()
    if not faded then
        faded = true
        TweenService:Create(button, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
            Size = fadedSize,
            BackgroundTransparency = fadedTransparency
        }):Play()
        TweenService:Create(highlight, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
            BackgroundTransparency = 0.85,
            Position = UDim2.new(0,0,0,0)
        }):Play()
    end
end

-- 点击 F
button.MouseButton1Click:Connect(function()
    inactiveTime = 0
    restoreState()
    clickAnim()
    switchMode()
end)

-- 自动淡出
task.spawn(function()
    while true do
        task.wait(1)
        inactiveTime += 1
        if inactiveTime >= FADE_DELAY then
            fadeButton()
        end
    end
end)

-- ===== 右上角拖动按钮 + 高光跟随 =====
local dragButton = Instance.new("TextButton")
dragButton.Parent = button
dragButton.Size = UDim2.new(0, math.floor(65/5), 0, math.floor(40/5))
dragButton.Position = UDim2.new(1,0,0,0)
dragButton.AnchorPoint = Vector2.new(0,0)
dragButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
dragButton.BackgroundTransparency = 0.7
dragButton.Text = ""
dragButton.AutoButtonColor = true

local cornerDrag = Instance.new("UICorner")
cornerDrag.CornerRadius = UDim.new(0,6)
cornerDrag.Parent = dragButton

local dragStartTime
local dragging = false
local offset = Vector2.new(0,0)

dragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragStartTime = tick()
        local conn
        conn = UIS.InputChanged:Connect(function(change)
            if not dragging and tick() - dragStartTime >= 2 then
                dragging = true
                offset = Vector2.new(button.Position.X.Offset - change.Position.X, button.Position.Y.Offset - change.Position.Y)
            end
        end)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                dragStartTime = nil
                conn:Disconnect()
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        -- 移动按钮
        button.Position = UDim2.new(0, input.Position.X + offset.X, 0, input.Position.Y + offset.Y)

        -- 高光随手指移动
        local buttonSize = button.AbsoluteSize
        local relX = math.clamp((input.Position.X - button.AbsolutePosition.X)/buttonSize.X, 0, 1)
        local relY = math.clamp((input.Position.Y - button.AbsolutePosition.Y)/buttonSize.Y, 0, 1)
        highlight.Position = UDim2.new(relX*0.6,0,relY*0.6,0)
    end
end)