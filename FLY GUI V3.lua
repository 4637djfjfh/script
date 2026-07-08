local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local main = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local up = Instance.new("TextButton")
local down = Instance.new("TextButton")
local onof = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local plus = Instance.new("TextButton")
local speed = Instance.new("TextLabel")
local mine = Instance.new("TextButton")
local speedBox = Instance.new("TextBox")
local closebutton = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local mini2 = Instance.new("TextButton")

main.Name = "main"
main.Parent = player:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

Frame.Name = "Frame"
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
Frame.BorderColor3 = Color3.fromRGB(103, 221, 213)
Frame.Position = UDim2.new(0.100320168, 0, 0.379746825, 0)
Frame.Size = UDim2.new(0, 189, 0, 28)
Frame.Active = true
Frame.Draggable = true

up.Name = "up"
up.Parent = Frame
up.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
up.Position = UDim2.new(0, 0, 0, 0)
up.Size = UDim2.new(0, 44, 0, 28)
up.Font = Enum.Font.SourceSans
up.Text = "UP"
up.TextColor3 = Color3.fromRGB(0, 0, 0)
up.TextSize = 14

plus.Name = "plus"
plus.Parent = Frame
plus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
plus.Position = UDim2.new(0, 44, 0, 0)
plus.Size = UDim2.new(0, 45, 0, 28)
plus.Font = Enum.Font.SourceSans
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(0, 0, 0)
plus.TextScaled = true
plus.TextSize = 14
plus.TextWrapped = true

TextLabel.Name = "Title"
TextLabel.Parent = Frame
TextLabel.BackgroundColor3 = Color3.fromRGB(242, 60, 255)
TextLabel.Position = UDim2.new(0, 89, 0, 0)
TextLabel.Size = UDim2.new(0, 100, 0, 28)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "FLY GUI V3"
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextScaled = true
TextLabel.TextSize = 14
TextLabel.TextWrapped = true

speedBox.Name = "speedBox"
speedBox.Parent = Frame
speedBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
speedBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
speedBox.Position = UDim2.new(0, 89, -1, 0)
speedBox.Size = UDim2.new(0, 100, 0, 28)
speedBox.Font = Enum.Font.SourceSans
speedBox.PlaceholderText = "输入速度"
speedBox.Text = ""
speedBox.TextColor3 = Color3.fromRGB(0, 0, 0)
speedBox.TextSize = 14
speedBox.ClearTextOnFocus = false

speedBox.Focused:Connect(function()
	speedBox.Text = ""
end)

down.Name = "down"
down.Parent = Frame
down.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
down.Position = UDim2.new(0, 0, 1, 0)
down.Size = UDim2.new(0, 44, 0, 28)
down.Font = Enum.Font.SourceSans
down.Text = "DOWN"
down.TextColor3 = Color3.fromRGB(0, 0, 0)
down.TextSize = 14

mine.Name = "mine"
mine.Parent = Frame
mine.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
mine.Position = UDim2.new(0, 44, 1, 0)
mine.Size = UDim2.new(0, 45, 0, 28)
mine.Font = Enum.Font.SourceSans
mine.Text = "-"
mine.TextColor3 = Color3.fromRGB(0, 0, 0)
mine.TextScaled = true
mine.TextSize = 14
mine.TextWrapped = true

speed.Name = "speed"
speed.Parent = Frame
speed.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
speed.Position = UDim2.new(0, 89, 1, 0)
speed.Size = UDim2.new(0, 44, 0, 28)
speed.Font = Enum.Font.SourceSans
speed.Text = "1"
speed.TextColor3 = Color3.fromRGB(0, 0, 0)
speed.TextScaled = true
speed.TextSize = 14
speed.TextWrapped = true

onof.Name = "onof"
onof.Parent = Frame
onof.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
onof.Position = UDim2.new(0, 133, 1, 0)
onof.Size = UDim2.new(0, 56, 0, 28)
onof.Font = Enum.Font.SourceSans
onof.Text = "fly"
onof.TextColor3 = Color3.fromRGB(0, 0, 0)
onof.TextSize = 14

closebutton.Name = "Close"
closebutton.Parent = Frame
closebutton.BackgroundColor3 = Color3.fromRGB(225, 25, 0)
closebutton.Font = Enum.Font.SourceSans
closebutton.Size = UDim2.new(0, 45, 0, 28)
closebutton.Text = "X"
closebutton.TextSize = 30
closebutton.Position = UDim2.new(0, 0, -2, 28)

mini.Name = "minimize"
mini.Parent = Frame
mini.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini.Font = Enum.Font.SourceSans
mini.Size = UDim2.new(0, 45, 0, 28)
mini.Text = "-"
mini.TextSize = 40
mini.Position = UDim2.new(0, 44, -2, 28)

mini2.Name = "minimize2"
mini2.Parent = Frame
mini2.BackgroundColor3 = Color3.fromRGB(192, 150, 230)
mini2.Font = Enum.Font.SourceSans
mini2.Size = UDim2.new(0, 45, 0, 28)
mini2.Text = "+"
mini2.TextSize = 40
mini2.Position = UDim2.new(0, 44, -1, 28)
mini2.Visible = false

local speeds = 1
local flyingEnabled = false
local tpwalking = false
local flyConnection = nil
local bodyGyro = nil
local bodyVelocity = nil
local upHolding = false
local downHolding = false
local upLoopRunning = false
local downLoopRunning = false

pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "FLY GUI V3",
		Text = "Speed input added",
		Icon = "rbxthumb://type=Asset&id=5107182114&w=150&h=150",
		Duration = 5
	})
end)

local function getCharacter()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHumanoid()
	local character = getCharacter()
	return character:FindFirstChildWhichIsA("Humanoid")
end

local function getRootPart()
	local character = getCharacter()
	return character:FindFirstChild("HumanoidRootPart")
end

local function updateSpeedText()
	speed.Text = tostring(speeds)
end

local function setHumanoidStates(enabled)
	local humanoid = getHumanoid()
	if not humanoid then return end

	local states = {
		Enum.HumanoidStateType.Climbing,
		Enum.HumanoidStateType.FallingDown,
		Enum.HumanoidStateType.Flying,
		Enum.HumanoidStateType.Freefall,
		Enum.HumanoidStateType.GettingUp,
		Enum.HumanoidStateType.Jumping,
		Enum.HumanoidStateType.Landed,
		Enum.HumanoidStateType.Physics,
		Enum.HumanoidStateType.PlatformStanding,
		Enum.HumanoidStateType.Ragdoll,
		Enum.HumanoidStateType.Running,
		Enum.HumanoidStateType.RunningNoPhysics,
		Enum.HumanoidStateType.Seated,
		Enum.HumanoidStateType.StrafingNoPhysics,
		Enum.HumanoidStateType.Swimming
	}

	for _, state in ipairs(states) do
		pcall(function()
			humanoid:SetStateEnabled(state, enabled)
		end)
	end
end

local function startTPWalk()
	tpwalking = true

	task.spawn(function()
		local character = getCharacter()
		local humanoid = getHumanoid()

		while tpwalking and character and humanoid and humanoid.Parent do
			RunService.Heartbeat:Wait()

			if humanoid.MoveDirection.Magnitude > 0 then
				character:TranslateBy(humanoid.MoveDirection * speeds)
			end
		end
	end)
end

local function stopTPWalk()
	tpwalking = false
end

local function stopVerticalMovement()
	upHolding = false
	downHolding = false
end

local function startFly()
	local character = getCharacter()
	local humanoid = getHumanoid()
	local rootPart = getRootPart()

	if not character or not humanoid or not rootPart then return end

	flyingEnabled = true
	onof.Text = "unfly"

	startTPWalk()

	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = true
	end

	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(0)
	end

	setHumanoidStates(false)
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	humanoid.PlatformStand = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 9e4
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.new(0, 0.1, 0)
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Parent = rootPart

	local currentSpeed = 0
	local maxSpeed = 50

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flyingEnabled or not character.Parent or humanoid.Health <= 0 then
			return
		end

		local moveDirection = humanoid.MoveDirection

		if moveDirection.Magnitude > 0 then
			currentSpeed = math.min(currentSpeed + 0.5 + currentSpeed / maxSpeed, maxSpeed)
			bodyVelocity.Velocity = moveDirection * currentSpeed * speeds
		else
			currentSpeed = math.max(currentSpeed - 1, 0)
			bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		end

		if workspace.CurrentCamera then
			bodyGyro.CFrame = workspace.CurrentCamera.CFrame
		end
	end)
end

local function stopFly()
	local character = getCharacter()
	local humanoid = getHumanoid()

	flyingEnabled = false
	onof.Text = "fly"

	stopTPWalk()

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end

	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end

	if humanoid then
		setHumanoidStates(true)
		humanoid.PlatformStand = false
		humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
	end

	if character then
		local animate = character:FindFirstChild("Animate")
		if animate then
			animate.Disabled = false
		end
	end
end

onof.MouseButton1Click:Connect(function()
	if flyingEnabled then
		stopFly()
	else
		startFly()
	end
end)

plus.MouseButton1Click:Connect(function()
	speeds += 1
	updateSpeedText()
	speedBox.Text = tostring(speeds)
end)

mine.MouseButton1Click:Connect(function()
	if speeds <= 1 then
		speed.Text = "min 1"
		task.wait(1)
		updateSpeedText()
	else
		speeds -= 1
		updateSpeedText()
		speedBox.Text = tostring(speeds)
	end
end)

speedBox.FocusLost:Connect(function()
	local value = tonumber(speedBox.Text)

	if value and value >= 1 then
		speeds = math.floor(value)
		updateSpeedText()
		speedBox.Text = tostring(speeds)
	else
		speedBox.Text = ""
		speed.Text = "无效"
		task.wait(1)
		updateSpeedText()
	end
end)

up.MouseButton1Down:Connect(function()
	upHolding = true

	if upLoopRunning then return end
	upLoopRunning = true

	task.spawn(function()
		while upHolding and main.Parent do
			task.wait()
			local rootPart = getRootPart()
			if rootPart then
				rootPart.CFrame = rootPart.CFrame * CFrame.new(0, 1, 0)
			end
		end

		upLoopRunning = false
	end)
end)

up.MouseButton1Up:Connect(function()
	upHolding = false
end)

up.MouseLeave:Connect(function()
	upHolding = false
end)

down.MouseButton1Down:Connect(function()
	downHolding = true

	if downLoopRunning then return end
	downLoopRunning = true

	task.spawn(function()
		while downHolding and main.Parent do
			task.wait()
			local rootPart = getRootPart()
			if rootPart then
				rootPart.CFrame = rootPart.CFrame * CFrame.new(0, -1, 0)
			end
		end

		downLoopRunning = false
	end)
end)

down.MouseButton1Up:Connect(function()
	downHolding = false
end)

down.MouseLeave:Connect(function()
	downHolding = false
end)

player.CharacterAdded:Connect(function()
	task.wait(0.7)

	stopVerticalMovement()
	stopTPWalk()

	local character = getCharacter()
	local humanoid = getHumanoid()

	if humanoid then
		humanoid.PlatformStand = false
	end

	local animate = character:FindFirstChild("Animate")
	if animate then
		animate.Disabled = false
	end

	if flyingEnabled then
		stopFly()
	end
end)

closebutton.MouseButton1Click:Connect(function()
	stopVerticalMovement()
	stopFly()
	main:Destroy()
end)

mini.MouseButton1Click:Connect(function()
	up.Visible = false
	down.Visible = false
	onof.Visible = false
	plus.Visible = false
	speed.Visible = false
	speedBox.Visible = false
	mine.Visible = false
	TextLabel.Visible = false
	mini.Visible = false
	mini2.Visible = true

	Frame.BackgroundTransparency = 1
	closebutton.Position = UDim2.new(0, 0, -1, 28)
end)

mini2.MouseButton1Click:Connect(function()
	up.Visible = true
	down.Visible = true
	onof.Visible = true
	plus.Visible = true
	speed.Visible = true
	speedBox.Visible = true
	mine.Visible = true
	TextLabel.Visible = true
	mini.Visible = true
	mini2.Visible = false

	Frame.BackgroundTransparency = 0
	closebutton.Position = UDim2.new(0, 0, -2, 28)
end)
