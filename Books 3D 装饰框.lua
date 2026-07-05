local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local booksPath = workspace
	:WaitForChild("Library")
	:WaitForChild("Books")

local UI_NAME = "TX_BookAdornmentUI"
local BOX_NAME = "TX_AdornmentBox"
local BEAM_NAME = "TX_BookGuideBeam"
local BOOK_ATTACHMENT_NAME = "TX_BookGuideAttachment"
local PLAYER_ATTACHMENT_NAME = "TX_BookGuidePlayerAttachment"
local BLOCK_DRAG_ACTION = "TX_BlockBookUIDragCamera"
local EXTRA_SIZE = Vector3.new(0.08, 0.08, 0.08)
local PANEL_SIZE = Vector2.new(238, 322)
local COLLAPSED_HEIGHT = 42
local SCREEN_PADDING = 4
local COLOR_CYCLE_SPEED = 0.45
local PULSE_SPEED = 6
local MIN_BOX_TRANSPARENCY = 0.08
local MAX_BOX_TRANSPARENCY = 0.38
local BOOK_CATEGORIES = {
	"脑萎缩",
	"魔法",
	"神话",
	"经济",
	"历史",
	"冥想",
}
local UNKNOWN_CATEGORY = "未分类"

local bookGroups = {}
local selectedBooks = {}
local bookButtons = {}
local activeBoxes = {}
local activeBeams = {}
local blockDragInputBound = false
local collapsed = false

local oldGui = playerGui:FindFirstChild(UI_NAME)
if oldGui then
	oldGui:Destroy()
end

local function getBookInfo(name)
	local bookName, numberText = name:match("^(.-)_(%d+)$")
	local number = tonumber(numberText)

	if bookName and bookName ~= "" and number and number >= 1 and number <= 10 then
		return bookName, number
	end

	return nil, nil
end

local function hasBasePart(obj)
	if obj:IsA("BasePart") then
		return true
	end

	for _, descendant in ipairs(obj:GetDescendants()) do
		if descendant:IsA("BasePart") then
			return true
		end
	end

	return false
end

local function isInsideAnotherNumberedBook(obj)
	local parent = obj.Parent

	while parent and parent ~= booksPath do
		local bookName = getBookInfo(parent.Name)

		if bookName then
			return true
		end

		parent = parent.Parent
	end

	return false
end

local function getParts(obj)
	local parts = {}

	if obj:IsA("BasePart") then
		table.insert(parts, obj)
	end

	for _, descendant in ipairs(obj:GetDescendants()) do
		if descendant:IsA("BasePart") then
			table.insert(parts, descendant)
		end
	end

	return parts
end

local function detectBookCategory(bookName, obj)
	for _, category in ipairs(BOOK_CATEGORIES) do
		if bookName:find(category, 1, true) then
			return category
		end
	end

	local current = obj.Parent
	while current and current ~= booksPath do
		for _, category in ipairs(BOOK_CATEGORIES) do
			if current.Name:find(category, 1, true) then
				return category
			end
		end

		current = current.Parent
	end

	return UNKNOWN_CATEGORY
end

local function scanBookGroups()
	local groups = {}

	for _, obj in ipairs(booksPath:GetDescendants()) do
		if not obj:IsA("BoxHandleAdornment") then
			local bookName, number = getBookInfo(obj.Name)

			if bookName and number and hasBasePart(obj) and not isInsideAnotherNumberedBook(obj) then
				local category = detectBookCategory(bookName, obj)

				if not groups[bookName] then
					groups[bookName] = {
						name = bookName,
						category = category,
						objects = {},
						maxNumber = 0,
					}
				elseif groups[bookName].category == UNKNOWN_CATEGORY and category ~= UNKNOWN_CATEGORY then
					groups[bookName].category = category
				end

				table.insert(groups[bookName].objects, obj)
				groups[bookName].maxNumber = math.max(groups[bookName].maxNumber, number)
			end
		end
	end

	return groups
end

local function removeBox(part)
	for _, child in ipairs(part:GetChildren()) do
		if child:IsA("BoxHandleAdornment") and child.Name == BOX_NAME then
			activeBoxes[child] = nil
			child:Destroy()
		end
	end
end

local function createBox(part)
	removeBox(part)

	local box = Instance.new("BoxHandleAdornment")
	box.Name = BOX_NAME
	box.Adornee = part
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Color3 = Color3.fromRGB(0, 255, 255)
	box.Transparency = MIN_BOX_TRANSPARENCY
	box.Size = part.Size + EXTRA_SIZE
	box.Parent = part
	activeBoxes[box] = true
end

local function getPlayerRootPart()
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerAttachment()
	local rootPart = getPlayerRootPart()
	if not rootPart then
		return nil
	end

	local attachment = rootPart:FindFirstChild(PLAYER_ATTACHMENT_NAME)
	if not attachment then
		attachment = Instance.new("Attachment")
		attachment.Name = PLAYER_ATTACHMENT_NAME
		attachment.Parent = rootPart
	end

	return attachment
end

local function removeGuideLineFromPart(part)
	for _, child in ipairs(part:GetChildren()) do
		if child.Name == BEAM_NAME or child.Name == BOOK_ATTACHMENT_NAME then
			if child:IsA("Beam") then
				activeBeams[child] = nil
			end

			child:Destroy()
		end
	end
end

local function removeGuideLine(bookObj)
	for _, part in ipairs(getParts(bookObj)) do
		removeGuideLineFromPart(part)
	end
end

local function createGuideLine(bookObj)
	local parts = getParts(bookObj)
	local targetPart = parts[1]
	local playerAttachment = getPlayerAttachment()

	if not targetPart or not playerAttachment then
		return
	end

	removeGuideLine(bookObj)

	local bookAttachment = Instance.new("Attachment")
	bookAttachment.Name = BOOK_ATTACHMENT_NAME
	bookAttachment.Parent = targetPart

	local beam = Instance.new("Beam")
	beam.Name = BEAM_NAME
	beam.Attachment0 = playerAttachment
	beam.Attachment1 = bookAttachment
	beam.FaceCamera = true
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Width0 = 0.08
	beam.Width1 = 0.08
	beam.Transparency = NumberSequence.new(0.08)
	beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 0))
	beam.Parent = targetPart
	activeBeams[beam] = true
end

local function updateAnimatedBoxes()
	if not next(activeBoxes) and not next(activeBeams) then
		return
	end

	local now = os.clock()
	local color = Color3.fromHSV((now * COLOR_CYCLE_SPEED) % 1, 1, 1)
	local pulse = (math.sin(now * PULSE_SPEED) + 1) / 2
	local transparency = MIN_BOX_TRANSPARENCY
		+ (MAX_BOX_TRANSPARENCY - MIN_BOX_TRANSPARENCY) * pulse

	for box in pairs(activeBoxes) do
		if box.Parent then
			box.Color3 = color
			box.Transparency = transparency
		else
			activeBoxes[box] = nil
		end
	end

	if next(activeBeams) then
		local playerAttachment = getPlayerAttachment()
		for beam in pairs(activeBeams) do
			if beam.Parent and beam.Attachment1 and playerAttachment then
				beam.Attachment0 = playerAttachment
				beam.Color = ColorSequence.new(color, Color3.fromRGB(255, 255, 0))
				beam.Transparency = NumberSequence.new(transparency * 0.5)
			else
				activeBeams[beam] = nil
			end
		end
	end
end

RunService.RenderStepped:Connect(updateAnimatedBoxes)

local function clearAllBoxes()
	for _, obj in ipairs(booksPath:GetDescendants()) do
		if obj:IsA("BasePart") then
			removeBox(obj)
			removeGuideLineFromPart(obj)
		end
	end
end

local function makeButtonText(bookName, group)
	local count = group.maxNumber
	local categoryText = "【" .. group.category .. "】"

	if selectedBooks[bookName] then
		return "隐藏 " .. categoryText .. bookName .. " | " .. count .. "本"
	else
		return "显示 " .. categoryText .. bookName .. " | " .. count .. "本"
	end
end

local function bindDragInputBlock()
	if blockDragInputBound then
		return
	end

	blockDragInputBound = true
	ContextActionService:BindActionAtPriority(
		BLOCK_DRAG_ACTION,
		function()
			return Enum.ContextActionResult.Sink
		end,
		false,
		Enum.ContextActionPriority.High.Value,
		Enum.UserInputType.Touch,
		Enum.UserInputType.MouseMovement
	)
end

local function unbindDragInputBlock()
	if not blockDragInputBound then
		return
	end

	blockDragInputBound = false
	ContextActionService:UnbindAction(BLOCK_DRAG_ACTION)
end

local function setBookVisible(bookName, visible)
	local group = bookGroups[bookName]
	if not group then
		return
	end

	selectedBooks[bookName] = visible

	for _, bookObj in ipairs(group.objects) do
		for _, part in ipairs(getParts(bookObj)) do
			if visible then
				createBox(part)
			else
				removeBox(part)
			end
		end

		if visible then
			createGuideLine(bookObj)
		else
			removeGuideLine(bookObj)
		end
	end

	local button = bookButtons[bookName]
	if button then
		button.Text = makeButtonText(bookName, group)

		if visible then
			button.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
			button.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
			button.TextColor3 = Color3.fromRGB(240, 240, 250)
		end
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = UI_NAME
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(PANEL_SIZE.X, PANEL_SIZE.Y)
main.Position = UDim2.fromOffset(8, 70)
main.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
main.BackgroundTransparency = 0.05
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1
mainStroke.Color = Color3.fromRGB(120, 120, 150)
mainStroke.Parent = main

local dragBar = Instance.new("Frame")
dragBar.Size = UDim2.new(1, 0, 0, 42)
dragBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
dragBar.Active = true
dragBar.Parent = main

local dragCorner = Instance.new("UICorner")
dragCorner.CornerRadius = UDim.new(0, 10)
dragCorner.Parent = dragBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -68, 0, 22)
title.Position = UDim2.new(0, 6, 0, 3)
title.BackgroundTransparency = 1
title.Text = "Books 3D"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = dragBar

local collapseButton = Instance.new("TextButton")
collapseButton.Size = UDim2.new(0, 52, 0, 26)
collapseButton.Position = UDim2.new(1, -58, 0, 8)
collapseButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
collapseButton.Text = "折叠"
collapseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collapseButton.TextScaled = true
collapseButton.Font = Enum.Font.GothamBold
collapseButton.Parent = dragBar

local collapseCorner = Instance.new("UICorner")
collapseCorner.CornerRadius = UDim.new(0, 7)
collapseCorner.Parent = collapseButton

local dragTip = Instance.new("TextLabel")
dragTip.Size = UDim2.new(1, -12, 0, 14)
dragTip.Position = UDim2.new(0, 6, 0, 25)
dragTip.BackgroundTransparency = 1
dragTip.Text = "拖这里移动，不转视角"
dragTip.TextColor3 = Color3.fromRGB(180, 180, 190)
dragTip.TextScaled = true
dragTip.Font = Enum.Font.Gotham
dragTip.Parent = dragBar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -12, 0, 26)
searchBox.Position = UDim2.new(0, 6, 0, 48)
searchBox.BackgroundColor3 = Color3.fromRGB(42, 42, 54)
searchBox.BorderSizePixel = 0
searchBox.ClearTextOnFocus = false
searchBox.PlaceholderText = "搜索书名/大类..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 175)
searchBox.TextScaled = true
searchBox.Font = Enum.Font.Gotham
searchBox.Parent = main

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 7)
searchCorner.Parent = searchBox

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -12, 1, -126)
scroll.Position = UDim2.new(0, 6, 0, 82)
scroll.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
scroll.BackgroundTransparency = 0.1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.Active = true
scroll.Parent = main

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scroll

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 6)
padding.PaddingBottom = UDim.new(0, 6)
padding.PaddingLeft = UDim.new(0, 6)
padding.PaddingRight = UDim.new(0, 6)
padding.Parent = scroll

list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 18)
end)

local refreshButton = Instance.new("TextButton")
refreshButton.Size = UDim2.new(0.5, -9, 0, 30)
refreshButton.Position = UDim2.new(0, 6, 1, -36)
refreshButton.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
refreshButton.Text = "重新扫描"
refreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshButton.TextScaled = true
refreshButton.Font = Enum.Font.GothamBold
refreshButton.Parent = main

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 7)
refreshCorner.Parent = refreshButton

local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(0.5, -9, 0, 30)
clearButton.Position = UDim2.new(0.5, 3, 1, -36)
clearButton.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
clearButton.Text = "全部隐藏"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
clearButton.Font = Enum.Font.GothamBold
clearButton.Parent = main

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 7)
clearCorner.Parent = clearButton

local function clampMainToViewport()
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
	if not viewportSize then
		return
	end

	local maxX = math.max(SCREEN_PADDING, viewportSize.X - main.AbsoluteSize.X - SCREEN_PADDING)
	local maxY = math.max(SCREEN_PADDING, viewportSize.Y - main.AbsoluteSize.Y - SCREEN_PADDING)
	local nextX = math.clamp(main.AbsolutePosition.X, SCREEN_PADDING, maxX)
	local nextY = math.clamp(main.AbsolutePosition.Y, SCREEN_PADDING, maxY)

	main.Position = UDim2.fromOffset(nextX, nextY)
end

local function setCollapsed(nextCollapsed)
	collapsed = nextCollapsed

	main.Size = UDim2.fromOffset(PANEL_SIZE.X, collapsed and COLLAPSED_HEIGHT or PANEL_SIZE.Y)
	searchBox.Visible = not collapsed
	scroll.Visible = not collapsed
	refreshButton.Visible = not collapsed
	clearButton.Visible = not collapsed
	dragTip.Visible = not collapsed
	collapseButton.Text = collapsed and "展开" or "折叠"

	clampMainToViewport()
end

collapseButton.MouseButton1Click:Connect(function()
	setCollapsed(not collapsed)
end)

local function rebuildList()
	for _, child in ipairs(scroll:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	bookButtons = {}

	local names = {}
	local searchText = searchBox.Text:lower()

	for bookName, group in pairs(bookGroups) do
		local category = group.category or UNKNOWN_CATEGORY

		if searchText == ""
			or bookName:lower():find(searchText, 1, true)
			or category:lower():find(searchText, 1, true) then
			table.insert(names, bookName)
		end
	end

	table.sort(names, function(a, b)
		local groupA = bookGroups[a]
		local groupB = bookGroups[b]
		local categoryA = groupA.category or UNKNOWN_CATEGORY
		local categoryB = groupB.category or UNKNOWN_CATEGORY

		if categoryA ~= categoryB then
			return categoryA < categoryB
		end

		return a:lower() < b:lower()
	end)

	for index, bookName in ipairs(names) do
		local group = bookGroups[bookName]

		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 34)
		button.LayoutOrder = index
		button.Text = makeButtonText(bookName, group)
		button.TextScaled = true
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = true
		button.Parent = scroll

		if selectedBooks[bookName] then
			button.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
			button.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			button.BackgroundColor3 = Color3.fromRGB(55, 55, 68)
			button.TextColor3 = Color3.fromRGB(240, 240, 250)
		end

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 7)
		corner.Parent = button

		button.MouseButton1Click:Connect(function()
			setBookVisible(bookName, not selectedBooks[bookName])
		end)

		bookButtons[bookName] = button
	end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	rebuildList()
end)

local function rescan()
	clearAllBoxes()

	bookGroups = scanBookGroups()

	for bookName in pairs(selectedBooks) do
		if not bookGroups[bookName] then
			selectedBooks[bookName] = nil
		end
	end

	rebuildList()

	for bookName, enabled in pairs(selectedBooks) do
		if enabled then
			setBookVisible(bookName, true)
		end
	end
end

refreshButton.MouseButton1Click:Connect(function()
	rescan()
end)

clearButton.MouseButton1Click:Connect(function()
	for bookName in pairs(selectedBooks) do
		selectedBooks[bookName] = false
	end

	clearAllBoxes()
	rebuildList()
end)

local dragging = false
local dragInput = nil
local dragStart = nil
local startAbsPos = nil

local function updateDrag(input)
	if not startAbsPos then
		return
	end

	local delta = input.Position - dragStart
	local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize
	local nextX = startAbsPos.X + delta.X
	local nextY = startAbsPos.Y + delta.Y

	if viewportSize then
		local maxX = math.max(SCREEN_PADDING, viewportSize.X - main.AbsoluteSize.X - SCREEN_PADDING)
		local maxY = math.max(SCREEN_PADDING, viewportSize.Y - main.AbsoluteSize.Y - SCREEN_PADDING)

		nextX = math.clamp(nextX, SCREEN_PADDING, maxX)
		nextY = math.clamp(nextY, SCREEN_PADDING, maxY)
	end

	main.Position = UDim2.fromOffset(nextX, nextY)
end

dragBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startAbsPos = main.AbsolutePosition
		dragInput = input
		bindDragInputBlock()

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				dragInput = nil
				startAbsPos = nil
				unbindDragInputBlock()
			end
		end)
	end
end)

dragBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		updateDrag(input)
	end
end)

rescan()
