local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Noclip = Instance.new("ScreenGui")
local BG = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Toggle = Instance.new("TextButton")
local EnlargeButton = Instance.new("TextButton")
local ShrinkButton = Instance.new("TextButton")
local UIScale = Instance.new("UIScale")
local StatusPF = Instance.new("TextLabel")
local Status = Instance.new("TextLabel")
local Plr = Players.LocalPlayer
local Clipon = false
local SteppedConnection = nil
local OriginalCanCollide = setmetatable({}, { __mode = "k" })
local UiScaleStep = 0.1
local MinUiScale = 0.75
local MaxUiScale = 1.5

Noclip.Name = "Noclip"
Noclip.Parent = CoreGui

BG.Name = "BG"
BG.Parent = Noclip
BG.BackgroundColor3 = Color3.new(0.0980392, 0.0980392, 0.0980392)
BG.BorderColor3 = Color3.new(0.0588235, 0.0588235, 0.0588235)
BG.BorderSizePixel = 2
BG.Position = UDim2.new(0.149479166, 0, 0.82087779, 0)
BG.Size = UDim2.new(0, 210, 0, 127)
BG.Active = true
BG.Draggable = true

UIScale.Name = "UIScale"
UIScale.Parent = BG
UIScale.Scale = 1

Title.Name = "Title"
Title.Parent = BG
Title.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
Title.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
Title.BorderSizePixel = 2
Title.Size = UDim2.new(0, 210, 0, 33)
Title.Font = Enum.Font.Highway
Title.Text = "Noclip"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.FontSize = Enum.FontSize.Size32
Title.TextSize = 30
Title.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
Title.TextStrokeTransparency = 0

Toggle.Parent = BG
Toggle.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
Toggle.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
Toggle.BorderSizePixel = 2
Toggle.Position = UDim2.new(0.152380958, 0, 0.374192119, 0)
Toggle.Size = UDim2.new(0, 146, 0, 36)
Toggle.Font = Enum.Font.Highway
Toggle.FontSize = Enum.FontSize.Size28
Toggle.Text = "Toggle"
Toggle.TextColor3 = Color3.new(1, 1, 1)
Toggle.TextSize = 25
Toggle.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
Toggle.TextStrokeTransparency = 0

ShrinkButton.Name = "ShrinkButton"
ShrinkButton.Parent = BG
ShrinkButton.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
ShrinkButton.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
ShrinkButton.BorderSizePixel = 2
ShrinkButton.Position = UDim2.new(1, -58, 0, 4)
ShrinkButton.Size = UDim2.new(0, 24, 0, 24)
ShrinkButton.Font = Enum.Font.Highway
ShrinkButton.FontSize = Enum.FontSize.Size24
ShrinkButton.Text = "-"
ShrinkButton.TextColor3 = Color3.new(1, 1, 1)
ShrinkButton.TextSize = 20
ShrinkButton.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
ShrinkButton.TextStrokeTransparency = 0

EnlargeButton.Name = "EnlargeButton"
EnlargeButton.Parent = BG
EnlargeButton.BackgroundColor3 = Color3.new(0.266667, 0.00392157, 0.627451)
EnlargeButton.BorderColor3 = Color3.new(0.180392, 0, 0.431373)
EnlargeButton.BorderSizePixel = 2
EnlargeButton.Position = UDim2.new(1, -29, 0, 4)
EnlargeButton.Size = UDim2.new(0, 24, 0, 24)
EnlargeButton.Font = Enum.Font.Highway
EnlargeButton.FontSize = Enum.FontSize.Size24
EnlargeButton.Text = "+"
EnlargeButton.TextColor3 = Color3.new(1, 1, 1)
EnlargeButton.TextSize = 20
EnlargeButton.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
EnlargeButton.TextStrokeTransparency = 0

StatusPF.Name = "StatusPF"
StatusPF.Parent = BG
StatusPF.BackgroundColor3 = Color3.new(1, 1, 1)
StatusPF.BackgroundTransparency = 1
StatusPF.Position = UDim2.new(0.314285725, 0, 0.708661377, 0)
StatusPF.Size = UDim2.new(0, 56, 0, 20)
StatusPF.Font = Enum.Font.Highway
StatusPF.FontSize = Enum.FontSize.Size24
StatusPF.Text = "Status:"
StatusPF.TextColor3 = Color3.new(1, 1, 1)
StatusPF.TextSize = 20
StatusPF.TextStrokeColor3 = Color3.new(0.333333, 0.333333, 0.333333)
StatusPF.TextStrokeTransparency = 0
StatusPF.TextWrapped = true

Status.Name = "Status"
Status.Parent = BG
Status.BackgroundColor3 = Color3.new(1, 1, 1)
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0.580952346, 0, 0.708661377, 0)
Status.Size = UDim2.new(0, 56, 0, 20)
Status.Font = Enum.Font.Highway
Status.FontSize = Enum.FontSize.Size14
Status.Text = "off"
Status.TextColor3 = Color3.new(0.666667, 0, 0)
Status.TextScaled = true
Status.TextSize = 14
Status.TextStrokeColor3 = Color3.new(0.180392, 0, 0.431373)
Status.TextWrapped = true
Status.TextXAlignment = Enum.TextXAlignment.Left


local function getCharacter()
    return Plr.Character or Workspace:FindFirstChild(Plr.Name)
end

local function setNoclipCollisions(enabled)
    local character = getCharacter()
    if not character then
        return
    end

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if enabled then
                if OriginalCanCollide[part] == nil then
                    OriginalCanCollide[part] = part.CanCollide
                end
                part.CanCollide = false
            elseif OriginalCanCollide[part] ~= nil then
                part.CanCollide = OriginalCanCollide[part]
                OriginalCanCollide[part] = nil
            end
        end
    end
end

local function stopNoclip()
    Clipon = false

    if SteppedConnection then
        SteppedConnection:Disconnect()
        SteppedConnection = nil
    end

    setNoclipCollisions(false)
end

local function startNoclip()
    Clipon = true

    if SteppedConnection then
        SteppedConnection:Disconnect()
    end

    SteppedConnection = RunService.Stepped:Connect(function()
        if Clipon then
            setNoclipCollisions(true)
        else
            stopNoclip()
        end
    end)
end

local function setUiScale(delta)
    UIScale.Scale = math.clamp(UIScale.Scale + delta, MinUiScale, MaxUiScale)
end

ShrinkButton.MouseButton1Click:Connect(function()
    setUiScale(-UiScaleStep)
end)

EnlargeButton.MouseButton1Click:Connect(function()
    setUiScale(UiScaleStep)
end)

Toggle.MouseButton1Click:Connect(function()
    if Status.Text == "off" then
        startNoclip()
        Status.Text = "on"
        Status.TextColor3 = Color3.fromRGB(0, 185, 0)
    elseif Status.Text == "on" then
        stopNoclip()
        Status.Text = "off"
        Status.TextColor3 = Color3.fromRGB(170, 0, 0)
    end
end)
