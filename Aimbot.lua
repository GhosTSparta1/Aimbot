local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local MergedAimbot = {
    Settings = {
        Enabled = false,
        FireMode = "none",
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
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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

local tabs = {"Início", "Aimbot", "ESP", "Config", "Misc"}
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

    -- Usando ScrollingFrame para permitir rolagem se necessário
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_" .. tabName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentContainer
    pages[tabName] = page

    -- Configurações da rolagem
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 8
    page.ScrollingDirection = Enum.ScrollingDirection.Y

    local pageLabel = Instance.new("TextLabel")
    pageLabel.Name = "TitleLabel"
    pageLabel.Size = UDim2.new(1, 0, 0, 30)
    pageLabel.Position = UDim2.new(0, 0, 0, 0)
    pageLabel.BackgroundTransparency = 1
    if tabName == "Início" then
        pageLabel.Text = "DESTRUA-SE ROBLOX"
        local userInfo = Instance.new("TextLabel")
        userInfo.Name = "UserInfo"
        userInfo.Size = UDim2.new(1, 0, 0, 80)
        userInfo.Position = UDim2.new(0, 0, 0, 35)
        userInfo.BackgroundTransparency = 1
        userInfo.TextColor3 = Color3.new(1, 1, 1)
        userInfo.Font = Enum.Font.Gotham
        userInfo.TextSize = 16
        userInfo.TextWrapped = true
        userInfo.Text = "Conta: " .. LocalPlayer.Name .. "\nGame: " .. game.PlaceId .. "\nServidor: " .. game.JobId
        userInfo.Parent = page
    else
        pageLabel.Text = "Configurações de " .. tabName
    end
    pageLabel.Parent = page

    tabButton.MouseButton1Click:Connect(function()
        if currentPage then currentPage.Visible = false end
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
            if input.UserInputState == Enum.UserInputState.End then draggingResize = false end
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

local bottomContainer = Instance.new("Frame")
bottomContainer.Name = "BottomContainer"
bottomContainer.Size = UDim2.new(1, 0, 0, 70)
bottomContainer.Position = UDim2.new(0, 0, 1, -70)
bottomContainer.BackgroundTransparency = 1
bottomContainer.Parent = sideBar

local discordButton = Instance.new("TextButton")
discordButton.Name = "DiscordButton"
discordButton.Size = UDim2.new(1, 0, 0, 30)
discordButton.Position = UDim2.new(0, 0, 0, 0)
discordButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
discordButton.TextColor3 = Color3.new(1, 1, 1)
discordButton.Font = Enum.Font.GothamBold
discordButton.TextSize = 16
discordButton.Text = " Discord"
discordButton.Parent = bottomContainer

local discordIcon = Instance.new("ImageLabel")
discordIcon.Name = "DiscordIcon"
discordIcon.Size = UDim2.new(0, 30, 0, 30)
discordIcon.Position = UDim2.new(0, 5, 0, 0)
discordIcon.BackgroundTransparency = 1
discordIcon.Image = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSGew1wzyPacpck97bVtg_oNcwMkgWr2-SSP_gFPGv37W2DvAeQPY7hPOQ&s=10"
discordIcon.Parent = discordButton

local youtubeButton = Instance.new("TextButton")
youtubeButton.Name = "YouTubeButton"
youtubeButton.Size = UDim2.new(1, 0, 0, 30)
youtubeButton.Position = UDim2.new(0, 0, 0, 35)
youtubeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
youtubeButton.TextColor3 = Color3.new(1, 1, 1)
youtubeButton.Font = Enum.Font.GothamBold
youtubeButton.TextSize = 16
youtubeButton.Text = " YouTube"
youtubeButton.Parent = bottomContainer

local youtubeIcon = Instance.new("ImageLabel")
youtubeIcon.Name = "YouTubeIcon"
youtubeIcon.Size = UDim2.new(0, 30, 0, 30)
youtubeIcon.Position = UDim2.new(0, 5, 0, 0)
youtubeIcon.BackgroundTransparency = 1
youtubeIcon.Image = "https://upload.wikimedia.org/wikipedia/commons/4/42/YouTube_icon_%282013-2017%29.png"
youtubeIcon.Parent = youtubeButton

discordButton.MouseButton1Click:Connect(function()
    local url = "https://discord.gg/tuEawMf34u"
    local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
    if not success then setclipboard(url) end
end)

youtubeButton.MouseButton1Click:Connect(function()
    local url = "https://youtube.com/@jinx_scripts?si=nt9aWeD2lRY7Ok9N"
    local success = pcall(function() GuiService:OpenBrowserWindow(url) end)
    if not success then setclipboard(url) end
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

print("Carregado!")

-- Função para criar a interface gráfica com descrições acima de cada botão
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MergedAimbotGUI"
    screenGui.Parent = PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    -- Aumentamos a altura para acomodar os rótulos
    mainFrame.Size = UDim2.new(0, 220, 0, 280)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.Parent = screenGui
    makeDraggable(mainFrame)

    -- Rótulo e botão para ativar/desativar o Aimbot
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Size = UDim2.new(0, 200, 0, 20)
    toggleLabel.Position = UDim2.new(0, 10, 0, 10)
    toggleLabel.Text = "Toggle Aimbot"
    toggleLabel.TextColor3 = Color3.new(1,1,1)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 16
    toggleLabel.Parent = mainFrame

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 35)
    toggleButton.Text = "Aimbot: OFF"
    toggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
    toggleButton.Font = Enum.Font.Gotham
    toggleButton.TextSize = 18
    toggleButton.Parent = mainFrame

    -- Rótulo e botão para o modo Auto Fire
    local autoFireLabel = Instance.new("TextLabel")
    autoFireLabel.Name = "AutoFireLabel"
    autoFireLabel.Size = UDim2.new(0, 200, 0, 20)
    autoFireLabel.Position = UDim2.new(0, 10, 0, 80)
    autoFireLabel.Text = "Auto Fire Mode"
    autoFireLabel.TextColor3 = Color3.new(1,1,1)
    autoFireLabel.BackgroundTransparency = 1
    autoFireLabel.Font = Enum.Font.Gotham
    autoFireLabel.TextSize = 16
    autoFireLabel.Parent = mainFrame

    local autoFireButton = Instance.new("TextButton")
    autoFireButton.Name = "AutoFireButton"
    autoFireButton.Size = UDim2.new(0, 200, 0, 30)
    autoFireButton.Position = UDim2.new(0, 10, 0, 105)
    autoFireButton.Text = "Auto Fire: OFF"
    autoFireButton.Parent = mainFrame

    -- Rótulo e botão para o modo Hold Fire
    local holdFireLabel = Instance.new("TextLabel")
    holdFireLabel.Name = "HoldFireLabel"
    holdFireLabel.Size = UDim2.new(0, 200, 0, 20)
    holdFireLabel.Position = UDim2.new(0, 10, 0, 145)
    holdFireLabel.Text = "Hold Fire Mode"
    holdFireLabel.TextColor3 = Color3.new(1,1,1)
    holdFireLabel.BackgroundTransparency = 1
    holdFireLabel.Font = Enum.Font.Gotham
    holdFireLabel.TextSize = 16
    holdFireLabel.Parent = mainFrame

    local holdFireButton = Instance.new("TextButton")
    holdFireButton.Name = "HoldFireButton"
    holdFireButton.Size = UDim2.new(0, 200, 0, 30)
    holdFireButton.Position = UDim2.new(0, 10, 0, 170)
    holdFireButton.Text = "Hold Fire: OFF"
    holdFireButton.Parent = mainFrame

    -- Rótulo e botão para Team Check
    local teamCheckLabel = Instance.new("TextLabel")
    teamCheckLabel.Name = "TeamCheckLabel"
    teamCheckLabel.Size = UDim2.new(0, 200, 0, 20)
    teamCheckLabel.Position = UDim2.new(0, 10, 0, 210)
    teamCheckLabel.Text = "Team Check"
    teamCheckLabel.TextColor3 = Color3.new(1,1,1)
    teamCheckLabel.BackgroundTransparency = 1
    teamCheckLabel.Font = Enum.Font.Gotham
    teamCheckLabel.TextSize = 16
    teamCheckLabel.Parent = mainFrame

    local teamCheckButton = Instance.new("TextButton")
    teamCheckButton.Name = "TeamCheckButton"
    teamCheckButton.Size = UDim2.new(0, 200, 0, 30)
    teamCheckButton.Position = UDim2.new(0, 10, 0, 235)
    teamCheckButton.Text = "Team Check: ON"
    teamCheckButton.Parent = mainFrame

    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Text = "X"
    closeButton.Parent = mainFrame

    local miniButton = Instance.new("TextButton")
    miniButton.Name = "MiniButton"
    miniButton.Size = UDim2.new(0, 50, 0, 50)
    miniButton.Position = UDim2.new(0, 50, 0, 50)
    miniButton.Text = "☰"
    miniButton.Visible = false
    miniButton.Parent = screenGui

    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        miniButton.Visible = true
    end)

    miniButton.MouseButton1Click:Connect(function()
        mainFrame.Position = miniButton.Position
        mainFrame.Visible = true
        miniButton.Visible = false
    end)

    return {
        screenGui = screenGui,
        mainFrame = mainFrame,
        toggleButton = toggleButton,
        autoFireButton = autoFireButton,
        holdFireButton = holdFireButton,
        teamCheckButton = teamCheckButton,
        closeButton = closeButton,
        miniButton = miniButton,
    }
end

local gui = createGUI()

local function updateToggleButton()
    gui.toggleButton.Text = MergedAimbot.Settings.Enabled and "Aimbot: ON" or "Aimbot: OFF"
    gui.toggleButton.BackgroundColor3 = MergedAimbot.Settings.Enabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end

local function updateAutoFireButton()
    gui.autoFireButton.Text = "Auto Fire: " .. (MergedAimbot.Settings.FireMode == "auto" and "ON" or "OFF")
end

local function updateHoldFireButton()
    gui.holdFireButton.Text = "Hold Fire: " .. (MergedAimbot.Settings.FireMode == "hold" and "ON" or "OFF")
end

local function updateTeamCheckButton()
    gui.teamCheckButton.Text = "Team Check: " .. (MergedAimbot.Settings.TeamCheck and "ON" or "OFF")
end

local debounce = {toggle = false, autoFire = false, holdFire = false, teamCheck = false}

gui.toggleButton.MouseButton1Click:Connect(function()
    if debounce.toggle then return end
    debounce.toggle = true
    MergedAimbot.Settings.Enabled = not MergedAimbot.Settings.Enabled
    updateToggleButton()
    wait(0.2)
    debounce.toggle = false
end)

gui.autoFireButton.MouseButton1Click:Connect(function()
    if debounce.autoFire then return end
    debounce.autoFire = true
    if MergedAimbot.Settings.FireMode == "auto" then
        MergedAimbot.Settings.FireMode = "none"
    else
        MergedAimbot.Settings.FireMode = "auto"
    end
    updateAutoFireButton()
    updateHoldFireButton()
    wait(0.2)
    debounce.autoFire = false
end)

gui.holdFireButton.MouseButton1Click:Connect(function()
    if debounce.holdFire then return end
    debounce.holdFire = true
    if MergedAimbot.Settings.FireMode == "hold" then
        MergedAimbot.Settings.FireMode = "none"
    else
        MergedAimbot.Settings.FireMode = "hold"
    end
    updateHoldFireButton()
    updateAutoFireButton()
    wait(0.2)
    debounce.holdFire = false
end)

gui.teamCheckButton.MouseButton1Click:Connect(function()
    if debounce.teamCheck then return end
    debounce.teamCheck = true
    MergedAimbot.Settings.TeamCheck = not MergedAimbot.Settings.TeamCheck
    updateTeamCheckButton()
    wait(0.2)
    debounce.teamCheck = false
end)

local function mouse1Click() pcall(function() mouse1click() end) end
local function mouse1Press() pcall(function() mouse1press() end) end
local function mouse1Release() pcall(function() mouse1release() end) end

local function hasLineOfSight(origin, targetPosition, targetCharacter)
    local direction = targetPosition - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    if result then
        return result.Instance:IsDescendantOf(targetCharacter)
    else
        return true
    end
end

local function getDistanceSquared(a, b)
    local diff = a - b
    return diff.X * diff.X + diff.Y * diff.Y + diff.Z * diff.Z
end

local function getNearestPlayer()
    local nearestPlayer = nil
    local shortestDistanceSq = math.huge
    local camPos = Camera.CFrame.Position
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if MergedAimbot.Settings.TeamCheck and player.Team == LocalPlayer.Team then continue end
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if MergedAimbot.Settings.AliveCheck and (humanoid and humanoid.Health <= 0) then continue end
            local targetPart = player.Character:FindFirstChild(MergedAimbot.Settings.LockPart)
            if not targetPart then continue end
            local distanceSq = getDistanceSquared(camPos, targetPart.Position)
            local screenPoint = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            local distToMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
            if distToMouse <= MergedAimbot.FOVSettings.Radius and distanceSq < shortestDistanceSq then
                if MergedAimbot.Settings.WallCheck then
                    if not hasLineOfSight(camPos, targetPart.Position, player.Character) then continue end
                end
                shortestDistanceSq = distanceSq
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

RunService.RenderStepped:Connect(function(deltaTime)
    if MergedAimbot.FOVSettings.Enabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        if MergedAimbot.FOVSettings.RainbowColor then
            FOVCircle.Color = GetRainbowColor()
        else
            FOVCircle.Color = MergedAimbot.FOVSettings.Color
        end
    end
    if MergedAimbot.Settings.Enabled then
        local target = getNearestPlayer()
        MergedAimbot.Target = target
        if target and target.Character then
            local character = target.Character
            local head = character:FindFirstChild("Head")
            local root = character:FindFirstChild("HumanoidRootPart")
            if head and root then
                local targetPosition = (character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0)
                    and root.Position or head.Position
                if MergedAimbot.Settings.LockMode == 2 then
                    local screenPoint = Camera:WorldToViewportPoint(targetPosition)
                    local mousePos = UserInputService:GetMouseLocation()
                    local deltaX = (screenPoint.X - mousePos.X) / MergedAimbot.Settings.Sensitivity2
                    local deltaY = (screenPoint.Y - mousePos.Y) / MergedAimbot.Settings.Sensitivity2
                    mousemoverel(deltaX, deltaY)
                else
                    if MergedAimbot.Settings.Sensitivity > 0 then
                        local tweenInfo = TweenInfo.new(MergedAimbot.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                        local newCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                        local tween = TweenService:Create(Camera, tweenInfo, {CFrame = newCFrame})
                        tween:Play()
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                    end
                    UserInputService.MouseDeltaSensitivity = 0
                end
                if MergedAimbot.Settings.FireMode == "auto" then
                    mouse1Click()
                elseif MergedAimbot.Settings.FireMode == "hold" then
                    if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                        mouse1Press()
                    end
                else
                    mouse1Release()
                end
            end
        else
            UserInputService.MouseDeltaSensitivity = 1
        end
    else
        UserInputService.MouseDeltaSensitivity = 1
        MergedAimbot.Target = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if MergedAimbot.ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local teamColor = (player.Team and player.TeamColor) and player.TeamColor.Color or Color3.new(1,1,1)
                    local highlight = character:FindFirstChild("ESP_Highlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESP_Highlight"
                        highlight.FillTransparency = 1
                        highlight.OutlineTransparency = 0
                        highlight.OutlineColor3 = teamColor
                        highlight.Parent = character
                    else
                        highlight.OutlineColor3 = teamColor
                    end
                else
                    local highlight = character:FindFirstChild("ESP_Highlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

function MergedAimbot:Exit()
    FOVCircle:Remove()
    if MergedAimbot.ScreenGui then MergedAimbot.ScreenGui:Destroy() end
    UserInputService.MouseDeltaSensitivity = 1
    self.Settings.Enabled = false
end

getgenv().MergedAimbot = MergedAimbot

-- Adicionando Toggle Switch para Team Check e Wall Check na aba "Config"
do
    local configPage = pages["Config"]
    local currentY = currentY or 0

    local function createLabel(text, parent)
        local label = Instance.new("TextLabel")
        label.Text = text
        label.Font = Enum.Font.Gotham
        label.TextSize = 16
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1,0,0,20)
        label.Position = UDim2.new(0,0,0,currentY)
        label.Parent = parent
        currentY = currentY + 25
        return label
    end

    do
        createLabel("Team Check", configPage)
        local teamToggleFrame = Instance.new("Frame")
        teamToggleFrame.Size = UDim2.new(0, 60, 0, 34)
        teamToggleFrame.Position = UDim2.new(0, 10, 0, currentY)
        teamToggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)
        teamToggleFrame.BorderSizePixel = 0
        teamToggleFrame.Parent = configPage
        local uiCornerTeam = Instance.new("UICorner")
        uiCornerTeam.CornerRadius = UDim.new(0,17)
        uiCornerTeam.Parent = teamToggleFrame

        local teamToggleButton = Instance.new("TextButton")
        teamToggleButton.Size = UDim2.new(0, 30, 0, 30)
        teamToggleButton.Position = UDim2.new(0, 2, 0, 2)
        teamToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        teamToggleButton.BorderSizePixel = 0
        teamToggleButton.Text = ""
        teamToggleButton.Parent = teamToggleFrame
        local uiCornerTeamButton = Instance.new("UICorner")
        uiCornerTeamButton.CornerRadius = UDim.new(0,15)
        uiCornerTeamButton.Parent = teamToggleButton

        local isTeamCheckEnabled = MergedAimbot.Settings.TeamCheck
        local function updateTeamToggle()
            if isTeamCheckEnabled then
                teamToggleButton.Position = UDim2.new(0,32,0,2)
                teamToggleFrame.BackgroundColor3 = Color3.fromRGB(0,255,0)
            else
                teamToggleButton.Position = UDim2.new(0,2,0,2)
                teamToggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)
            end
        end

        teamToggleButton.MouseButton1Click:Connect(function()
            isTeamCheckEnabled = not isTeamCheckEnabled
            MergedAimbot.Settings.TeamCheck = isTeamCheckEnabled
            updateTeamToggle()
        end)
        updateTeamToggle()
        currentY = currentY + 40
    end

    do
        createLabel("Wall Check", configPage)
        local wallToggleFrame = Instance.new("Frame")
        wallToggleFrame.Size = UDim2.new(0, 60, 0, 34)
        wallToggleFrame.Position = UDim2.new(0, 10, 0, currentY)
        wallToggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)
        wallToggleFrame.BorderSizePixel = 0
        wallToggleFrame.Parent = configPage
        local uiCornerWall = Instance.new("UICorner")
        uiCornerWall.CornerRadius = UDim.new(0,17)
        uiCornerWall.Parent = wallToggleFrame

        local wallToggleButton = Instance.new("TextButton")
        wallToggleButton.Size = UDim2.new(0, 30, 0, 30)
        wallToggleButton.Position = UDim2.new(0, 2, 0, 2)
        wallToggleButton.BackgroundColor3 = Color3.fromRGB(255,255,255)
        wallToggleButton.BorderSizePixel = 0
        wallToggleButton.Text = ""
        wallToggleButton.Parent = wallToggleFrame
        local uiCornerWallButton = Instance.new("UICorner")
        uiCornerWallButton.CornerRadius = UDim.new(0,15)
        uiCornerWallButton.Parent = wallToggleButton

        local isWallCheckEnabled = MergedAimbot.Settings.WallCheck
        local function updateWallToggle()
            if isWallCheckEnabled then
                wallToggleButton.Position = UDim2.new(0,32,0,2)
                wallToggleFrame.BackgroundColor3 = Color3.fromRGB(0,255,0)
            else
                wallToggleButton.Position = UDim2.new(0,2,0,2)
                wallToggleFrame.BackgroundColor3 = Color3.fromRGB(200,200,200)
            end
        end

        wallToggleButton.MouseButton1Click:Connect(function()
            isWallCheckEnabled = not isWallCheckEnabled
            MergedAimbot.Settings.WallCheck = isWallCheckEnabled
            updateWallToggle()
        end)
        updateWallToggle()
        currentY = currentY + 40
    end
end