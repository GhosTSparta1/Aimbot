local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local MergedAimbot = {
	Settings = {
		Enabled = false,
		LockMode = 1,
		LockPart = "Head",
		Sensitivity = 0,
		Sensitivity2 = 3.5,
		TeamCheck = true,
		AliveCheck = true,
		WallCheck = false,
	},
	FOVSettings = {
		Enabled = true,
		Radius = 90,
		Color = Color3.fromRGB(255, 255, 255),
		LockedColor = Color3.fromRGB(255, 150, 150),
		RainbowColor = false,
		RainbowSpeed = 1,
	},
	ESPEnabled = true,
	Target = nil,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = MergedAimbot.FOVSettings.Enabled
FOVCircle.Radius = MergedAimbot.FOVSettings.Radius
FOVCircle.Color = MergedAimbot.FOVSettings.Color
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Filled = false

local function GetRainbowColor()
	local t = tick() % MergedAimbot.FOVSettings.RainbowSpeed / MergedAimbot.FOVSettings.RainbowSpeed
	return Color3.fromHSV(t, 1, 1)
end

local function makeDraggable(frame)
	local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MergedAimbotUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
MergedAimbot.ScreenGui = screenGui

local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0.6, 0, 0.7, 0)
mainContainer.Position = UDim2.new(0.2, 0, 0.15, 0)
mainContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui
makeDraggable(mainContainer)

local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Size = UDim2.new(0.2, 0, 1, 0)
sideBar.Position = UDim2.new(0, 0, 0, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainContainer

local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(0.8, 0, 1, 0)
contentContainer.Position = UDim2.new(0.2, 0, 0, 0)
contentContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainContainer

local tabs = {"Aimbot", "ESP", "Config", "Misc"}
local pages = {}
local currentPage = nil
local tabButtonHeight = 40
local tabSpacing = 5

for i, tabName in ipairs(tabs) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = "Tab_" .. tabName
	tabButton.Size = UDim2.new(1, 0, 0, tabButtonHeight)
	tabButton.Position = UDim2.new(0, 0, 0, (tabButtonHeight + tabSpacing) * (i - 1) + 10)
	tabButton.BackgroundColor3 = Color3.fromRGB(50, 70, 70)
	tabButton.TextColor3 = Color3.fromRGB(210, 230, 230)
	tabButton.Font = Enum.Font.Gotham
	tabButton.TextSize = 16
	tabButton.Text = tabName
	tabButton.Parent = sideBar

	local page = Instance.new("Frame")
	page.Name = "Page_" .. tabName
	page.Size = UDim2.new(1, 0, 1, 0)
	page.Position = UDim2.new(0, 0, 0, 0)
	page.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
	page.BorderSizePixel = 0
	page.Visible = false
	page.Parent = contentContainer
	pages[tabName] = page

	local pageLabel = Instance.new("TextLabel")
	pageLabel.Name = "TitleLabel"
	pageLabel.Size = UDim2.new(1, 0, 0, 30)
	pageLabel.Position = UDim2.new(0, 0, 0, 0)
	pageLabel.BackgroundTransparency = 1
	pageLabel.Text = "Configurações de " .. tabName
	pageLabel.TextColor3 = Color3.new(1, 1, 1)
	pageLabel.Font = Enum.Font.GothamSemibold
	pageLabel.TextSize = 18
	pageLabel.Parent = page

	tabButton.MouseButton1Click:Connect(function()
		if currentPage then
			currentPage.Visible = false
		end
		page.Visible = true
		currentPage = page
	end)
end

if #tabs > 0 and pages[tabs[1]] then
	pages[tabs[1]].Visible = true
	currentPage = pages[tabs[1]]
end

local resizeHandle = Instance.new("Frame")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 5, 1, 0)
resizeHandle.Position = UDim2.new(1, -5, 0, 0)
resizeHandle.BackgroundColor3 = Color3.new(1, 1, 1)
resizeHandle.BackgroundTransparency = 0.5
resizeHandle.ZIndex = 2
resizeHandle.Active = true
resizeHandle.Selectable = true
resizeHandle.Parent = sideBar

local draggingResize = false
local dragStartX, originalWidth

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingResize = true
		dragStartX = input.Position.X
		originalWidth = sideBar.AbsoluteSize.X
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				draggingResize = false
			end
		end)
	end
end)

resizeHandle.InputChanged:Connect(function(input)
	if draggingResize and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position.X - dragStartX
		local newWidth = originalWidth + delta
		local containerWidth = mainContainer.AbsoluteSize.X
		local newScale = newWidth / containerWidth
		newScale = math.clamp(newScale, 0.1, 0.5)
		sideBar.Size = UDim2.new(newScale, 0, 1, 0)
		contentContainer.Position = UDim2.new(newScale, 0, 0, 0)
		contentContainer.Size = UDim2.new(1 - newScale, 0, 1, 0)
	end
end)

local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 50, 0, 25)
minimizeButton.Position = UDim2.new(1, -55, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(50, 70, 70)
minimizeButton.TextColor3 = Color3.fromRGB(210, 230, 230)
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextSize = 18
minimizeButton.Text = "-"
minimizeButton.Parent = mainContainer

local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
	if isMinimized then
		mainContainer.Visible = true
		minimizeButton.Text = "-"
		isMinimized = false
	else
		mainContainer.Visible = false
		isMinimized = true
	end
end)

do
	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(0, 60, 0, 34)
	switchFrame.Position = UDim2.new(0, 10, 0, 50)
	switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	switchFrame.Parent = pages["Aimbot"]
	local uiCornerSwitch = Instance.new("UICorner")
	uiCornerSwitch.CornerRadius = UDim.new(0, 17)
	uiCornerSwitch.Parent = switchFrame

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 30, 0, 30)
	sliderButton.Position = UDim2.new(0, 2, 0, 2)
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.Parent = switchFrame
	local uiCornerSlider = Instance.new("UICorner")
	uiCornerSlider.CornerRadius = UDim.new(0, 15)
	uiCornerSlider.Parent = sliderButton

	local isAimbotEnabled = false

	local function updateSwitch()
		if isAimbotEnabled then
			sliderButton.Position = UDim2.new(0, 32, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			sliderButton.Position = UDim2.new(0, 2, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	sliderButton.MouseButton1Click:Connect(function()
		isAimbotEnabled = not isAimbotEnabled
		updateSwitch()
		MergedAimbot.Settings.Enabled = isAimbotEnabled
	end)

	updateSwitch()
end

do
	local miscPage = pages["Misc"]
	local currentY = 40

	local function createLabel(text, height)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -20, 0, height or 20)
		label.Position = UDim2.new(0, 10, 0, currentY)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.Gotham
		label.TextSize = 16
		label.Parent = miscPage
		currentY = currentY + (height or 20) + 5
	end

	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.new(0, 200, 0, 30)
	discordButton.Position = UDim2.new(0, 10, 0, currentY)
	discordButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	discordButton.TextColor3 = Color3.new(1, 1, 1)
	discordButton.Font = Enum.Font.GothamBold
	discordButton.TextSize = 16
	discordButton.Text = "Discord"
	discordButton.Parent = miscPage
	discordButton.MouseButton1Click:Connect(function()
		local url = "https://discord.gg/tuEawMf34u"
		local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
		if not success then
			setclipboard(url)
		end
	end)
	currentY = currentY + 40

	local youtubeButton = Instance.new("TextButton")
	youtubeButton.Size = UDim2.new(0, 200, 0, 30)
	youtubeButton.Position = UDim2.new(0, 10, 0, currentY)
	youtubeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	youtubeButton.TextColor3 = Color3.new(1, 1, 1)
	youtubeButton.Font = Enum.Font.GothamBold
	youtubeButton.TextSize = 16
	youtubeButton.Text = "YouTube"
	youtubeButton.Parent = miscPage
	youtubeButton.MouseButton1Click:Connect(function()
		local url = "https://youtube.com/@jinx_scripts?si=nt9aWeD2lRY7Ok9N"
		local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
		if not success then
			setclipboard(url)
		end
	end)
	currentY = currentY + 60

	createLabel("DESTRUA-SE ROBLOX", 25)
	createLabel("Jinxscripts", 25)
	createLabel("\"not\" Justadev", 25)
end

do
	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(0, 60, 0, 34)
	switchFrame.Position = UDim2.new(0, 10, 0, 50)
	switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	switchFrame.Parent = pages["ESP"]
	local uiCornerESPFrame = Instance.new("UICorner")
	uiCornerESPFrame.CornerRadius = UDim.new(0, 17)
	uiCornerESPFrame.Parent = switchFrame

	local sliderButton = Instance.new("TextButton")
	sliderButton.Size = UDim2.new(0, 30, 0, 30)
	sliderButton.Position = UDim2.new(0, 2, 0, 2)
	sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	sliderButton.Parent = switchFrame
	local uiCornerESPSlider = Instance.new("UICorner")
	uiCornerESPSlider.CornerRadius = UDim.new(0, 15)
	uiCornerESPSlider.Parent = sliderButton

	local isESPEnabled = MergedAimbot.ESPEnabled

	local function updateSwitch()
		if isESPEnabled then
			sliderButton.Position = UDim2.new(0, 32, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		else
			sliderButton.Position = UDim2.new(0, 2, 0, 2)
			switchFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		end
	end

	sliderButton.MouseButton1Click:Connect(function()
		isESPEnabled = not isESPEnabled
		updateSwitch()
		MergedAimbot.ESPEnabled = isESPEnabled
	end)

	updateSwitch()
end

do
	local configPage = pages["Config"]

	local configControlsFrame = Instance.new("Frame")
	configControlsFrame.Name = "ConfigControls"
	configControlsFrame.Size = UDim2.new(1, -20, 1, -50)
	configControlsFrame.Position = UDim2.new(0, 10, 0, 40)
	configControlsFrame.BackgroundTransparency = 1
	configControlsFrame.Parent = configPage

	local currentY = 0

	local function createLabel(text, parent)
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Font = Enum.Font.Gotham
		label.TextSize = 16
		label.TextColor3 = Color3.new(1, 1, 1)
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(1, 0, 0, 20)
		label.Position = UDim2.new(0, 0, 0, currentY)
		label.Parent = parent
		currentY = currentY + 25
		return label
	end

	do
		createLabel("Exibir FOV", configControlsFrame)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 60, 0, 34)
		toggleFrame.Position = UDim2.new(0, 10, 0, currentY)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = configControlsFrame
		local uiCornerFOVToggle = Instance.new("UICorner")
		uiCornerFOVToggle.CornerRadius = UDim.new(0, 17)
		uiCornerFOVToggle.Parent = toggleFrame

		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 30, 0, 30)
		toggleButton.Position = UDim2.new(0, 2, 0, 2)
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame
		local uiCornerFOVToggleButton = Instance.new("UICorner")
		uiCornerFOVToggleButton.CornerRadius = UDim.new(0, 15)
		uiCornerFOVToggleButton.Parent = toggleButton

		local isFOVEnabled = MergedAimbot.FOVSettings.Enabled

		local function updateToggle()
			if isFOVEnabled then
				toggleButton.Position = UDim2.new(0, 32, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			else
				toggleButton.Position = UDim2.new(0, 2, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		toggleButton.MouseButton1Click:Connect(function()
			isFOVEnabled = not isFOVEnabled
			MergedAimbot.FOVSettings.Enabled = isFOVEnabled
			FOVCircle.Visible = isFOVEnabled
			updateToggle()
		end)
		updateToggle()
		currentY = currentY + 40
	end

	do
		local fovLabel = createLabel("Raio do FOV: " .. MergedAimbot.FOVSettings.Radius, configControlsFrame)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
		sliderFrame.Position = UDim2.new(0, 10, 0, currentY)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		sliderFrame.Parent = configControlsFrame

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 1, 0)
		knob.Position = UDim2.new((MergedAimbot.FOVSettings.Radius / 180), 0, 0, 0)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.Parent = sliderFrame

		local draggingSlider = false
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = true
			end
		end)
		knob.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)
		sliderFrame.InputChanged:Connect(function(input)
			if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
				local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
				local scale = relativeX / sliderFrame.AbsoluteSize.X
				knob.Position = UDim2.new(scale, 0, 0, 0)
				local newFOV = math.floor(scale * 180)
				MergedAimbot.FOVSettings.Radius = newFOV
				fovLabel.Text = "Raio do FOV: " .. newFOV
				FOVCircle.Radius = newFOV
			end
		end)
		currentY = currentY + 30
	end

	do
		createLabel("Cor do FOV", configControlsFrame)
		local colorButton = Instance.new("TextButton")
		colorButton.Size = UDim2.new(0, 100, 0, 30)
		colorButton.Position = UDim2.new(0, 10, 0, currentY)
		colorButton.Text = "Alterar Cor"
		colorButton.BackgroundColor3 = MergedAimbot.FOVSettings.Color
		colorButton.TextColor3 = Color3.new(0, 0, 0)
		colorButton.Parent = configControlsFrame

		local colors = {
			Color3.fromRGB(255, 0, 0),
			Color3.fromRGB(0, 255, 0),
			Color3.fromRGB(0, 0, 255),
			Color3.fromRGB(255, 255, 255),
			Color3.fromRGB(255, 255, 0),
		}
		local colorIndex = 1
		colorButton.MouseButton1Click:Connect(function()
			colorIndex = colorIndex % #colors + 1
			local newColor = colors[colorIndex]
			MergedAimbot.FOVSettings.Color = newColor
			colorButton.BackgroundColor3 = newColor
			if not MergedAimbot.FOVSettings.RainbowColor then
				FOVCircle.Color = newColor
			end
		end)
		currentY = currentY + 40
	end

	do
		createLabel("Efeito Rainbow", configControlsFrame)
		local toggleFrame = Instance.new("Frame")
		toggleFrame.Size = UDim2.new(0, 60, 0, 34)
		toggleFrame.Position = UDim2.new(0, 10, 0, currentY)
		toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		toggleFrame.BorderSizePixel = 0
		toggleFrame.Parent = configControlsFrame

		local toggleButton = Instance.new("TextButton")
		toggleButton.Size = UDim2.new(0, 30, 0, 30)
		toggleButton.Position = UDim2.new(0, 2, 0, 2)
		toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		toggleButton.BorderSizePixel = 0
		toggleButton.Text = ""
		toggleButton.Parent = toggleFrame

		local isRainbow = MergedAimbot.FOVSettings.RainbowColor

		local function updateToggle()
			if isRainbow then
				toggleButton.Position = UDim2.new(0, 32, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			else
				toggleButton.Position = UDim2.new(0, 2, 0, 2)
				toggleFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			end
		end

		toggleButton.MouseButton1Click:Connect(function()
			isRainbow = not isRainbow
			MergedAimbot.FOVSettings.RainbowColor = isRainbow
			updateToggle()
		end)
		updateToggle()
		currentY = currentY + 40
	end

	do
		local rainbowLabel = createLabel("Velocidade Rainbow: " .. MergedAimbot.FOVSettings.RainbowSpeed, configControlsFrame)
		local sliderFrame = Instance.new("Frame")
		sliderFrame.Size = UDim2.new(0.8, 0, 0, 20)
		sliderFrame.Position = UDim2.new(0, 10, 0, currentY)
		sliderFrame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
		sliderFrame.Parent = configControlsFrame

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 10, 1, 0)
		local currentSpeed = MergedAimbot.FOVSettings.RainbowSpeed
		local normalizedSpeed = (currentSpeed - 0.1) / (5 - 0.1)
		knob.Position = UDim2.new(normalizedSpeed, 0, 0, 0)
		knob.BackgroundColor3 = Color3.new(1, 1, 1)
		knob.Parent = sliderFrame

		local draggingSlider = false
		knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = true
			end
		end)
		knob.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				draggingSlider = false
			end
		end)
		sliderFrame.InputChanged:Connect(function(input)
			if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
				local relativeX = math.clamp(input.Position.X - sliderFrame.AbsolutePosition.X, 0, sliderFrame.AbsoluteSize.X)
				local scale = relativeX / sliderFrame.AbsoluteSize.X
				knob.Position = UDim2.new(scale, 0, 0, 0)
				local newSpeed = 0.1 + scale * (5 - 0.1)
				MergedAimbot.FOVSettings.RainbowSpeed = newSpeed
				rainbowLabel.Text = "Velocidade Rainbow: " .. string.format("%.2f", newSpeed)
			end
		end)
		currentY = currentY + 30
	end
end

print("Merged Aimbot com UI customizada carregado com sucesso!")

local function getNearestPlayer()
	local nearestPlayer = nil
	local shortestDistanceSq = math.huge
	local camPos = Camera.CFrame.Position

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if MergedAimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then
				continue
			end
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			if MergedAimbot.Settings.AliveCheck and (humanoid and humanoid.Health <= 0) then
				continue
			end

			local targetPart = player.Character:FindFirstChild(MergedAimbot.Settings.LockPart)
			if not targetPart then
				continue
			end

			local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
			local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
			local distToMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude

			if distToMouse <= MergedAimbot.FOVSettings.Radius then
				local distanceSq 