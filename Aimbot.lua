--[[
  Merged Aimbot Script by ChatGPT
  Combina funcionalidades avançadas (FOV, lock modes, Tween) com uma GUI interativa, ESP e modos de disparo.
  Desenvolvido integrando aspectos dos dois scripts originais.
  
  Atenção: Alguns métodos (como mousemoverel, mouse1click, etc.) podem depender do executor utilizado.
]]

------------------------------------------------------------
-- Serviços e Variáveis Globais
------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------
-- Função Auxiliar: Tornar uma Frame Arrastável
------------------------------------------------------------
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
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

------------------------------------------------------------
-- Configurações Globais do Merged Aimbot
------------------------------------------------------------
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

------------------------------------------------------------
-- Criação do Círculo FOV via Drawing API
------------------------------------------------------------
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

------------------------------------------------------------
-- Criação da Interface (GUI) com Abas Laterais
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MergedAimbotUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

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
    pageLabel.TextColor3 = Color3.new(1, 1, 1)
    pageLabel.Font = Enum.Font.GothamSemibold
    pageLabel.TextSize = 18
    pageLabel.Parent = page

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
    local success = pcall(function()
        GuiService:OpenBrowserWindow(url)
    end)
    if not success then
        setclipboard(url)
    end
end)

youtubeButton.MouseButton1Click:Connect(function()
    local url = "https://youtube.com/@jinx_scripts?si=nt9aWeD2lRY7Ok9N"
    local success = pcall(function()
        GuiService:OpenBrowserWindow(url)
    end)
    if not success then
        setclipboard(url)
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

------------------------------------------------------------
-- Integração dos Controles do Merged Aimbot (GUI Secundária)
------------------------------------------------------------
print("Carregado!")

local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MergedAimbotGUI"
    screenGui.Parent = PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 220, 0, 220)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    mainFrame.Parent = screenGui
    makeDraggable(mainFrame)

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 40)
    toggleButton.Position = UDim2.new(0, 10, 0, 10)
    toggleButton.Text = "Aimbot: OFF"
    toggleButton.BackgroundColor3 = Color3.new(1, 0, 0)
    toggleButton.Parent = mainFrame

    local autoFireButton = Instance.new("TextButton")
    autoFireButton.Name = "AutoFireButton"
    autoFireButton.Size = UDim2.new(0, 200, 0, 30)
    autoFireButton.Position = UDim2.new(0, 10, 0, 60)
    autoFireButton.Text = "Auto Fire: OFF"
    autoFireButton.Parent = mainFrame

    local holdFireButton = Instance.new("TextButton")
    holdFireButton.Name = "HoldFireButton"
    holdFireButton.Size = UDim2.new(0, 200, 0, 30)
    holdFireButton.Position = UDim2.new(0, 10, 0, 100)
    holdFireButton.Text = "Hold Fire: OFF"
    holdFireButton.Parent = mainFrame

    local teamCheckButton = Instance.new("TextButton")
    teamCheckButton.Name = "TeamCheckButton"
    teamCheckButton.Size = UDim2.new(0, 200, 0, 30)
    teamCheckButton.Position = UDim2.new(0, 10, 0, 140)
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

------------------------------------------------------------
-- Funções de Simulação de Clique do Mouse
------------------------------------------------------------
local function mouse1Click()
    pcall(function() mouse1click() end)
end

local function mouse1Press()
    pcall(function() mouse1press() end)
end

local function mouse1Release()
    pcall(function() mouse1release() end)
end

------------------------------------------------------------
-- Funções Auxiliares para Seleção do Alvo
------------------------------------------------------------
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

            local distanceSq = getDistanceSquared(camPos, targetPart.Position)
            local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
            local mousePos = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            local distToMouse = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude

            if distToMouse <= MergedAimbot.FOVSettings.Radius and distanceSq < shortestDistanceSq then
                if MergedAimbot.Settings.WallCheck then
                    if not hasLineOfSight(camPos, targetPart.Position, player.Character) then
                        continue
                    end
                end
                shortestDistanceSq = distanceSq
                nearestPlayer = player
            end
        end
    end
    return nearestPlayer
end

------------------------------------------------------------
-- Loop Principal do Aimbot (RenderStepped)
------------------------------------------------------------
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
                local targetPosition
                if character:FindFirstChildOfClass("Humanoid") and character:FindFirstChildOfClass("Humanoid").MoveDirection.Magnitude > 0 then
                    targetPosition = root.Position
                else
                    targetPosition = head.Position
                end

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

------------------------------------------------------------
-- Loop de Atualização do ESP (Heartbeat)
------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if MergedAimbot.ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local character = player.Character
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local esp = character:FindFirstChild("ESP")
                    if not esp then
                        esp = Instance.new("BillboardGui")
                        esp.Name = "ESP"
                        esp.Parent = character
                        esp.Adornee = hrp
                        esp.Size = UDim2.new(0, 200, 0, 50)
                        esp.StudsOffset = Vector3.new(0, 2, 0)

                        local label = Instance.new("TextLabel", esp)
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = player.TeamColor.Color
                        label.Text = player.Name
                        label.TextScaled = true
                    end
                end
            end
        end
    end
end)

------------------------------------------------------------
-- Função de Desligamento / Limpeza
------------------------------------------------------------
function MergedAimbot:Exit()
    FOVCircle:Remove()
    if gui and gui.screenGui then
        gui.screenGui:Destroy()
    end
    UserInputService.MouseDeltaSensitivity = 1
    self.Settings.Enabled = false
end

getgenv().MergedAimbot = MergedAimbot
