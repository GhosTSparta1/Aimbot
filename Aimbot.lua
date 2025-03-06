--[[
    Merged Aimbot com UI Customizada
    Combina funcionalidades avançadas (FOV, configurações, etc.) do Merged Aimbot com uma interface
    baseada na UI que você enviou, que possui uma sidebar com abas laterais.
    Personalize as configurações e integrações conforme necessário.
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
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

------------------------------------------------------------
-- Configurações do Merged Aimbot
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
-- Função Auxiliar: Tornar uma Frame Arrastável
------------------------------------------------------------
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

------------------------------------------------------------
-- Criação da Interface Customizada (UI)
------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MergedAimbotUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui
MergedAimbot.ScreenGui = screenGui

-- Container Principal
local mainContainer = Instance.new("Frame")
mainContainer.Name = "MainContainer"
mainContainer.Size = UDim2.new(0.6, 0, 0.7, 0)        -- 60% da largura e 70% da altura da tela
mainContainer.Position = UDim2.new(0.2, 0, 0.15, 0)     -- Centralizado
mainContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui
makeDraggable(mainContainer)

-- Sidebar (abas laterais)
local sideBar = Instance.new("Frame")
sideBar.Name = "SideBar"
sideBar.Size = UDim2.new(0.2, 0, 1, 0)              -- 20% da largura do container principal
sideBar.Position = UDim2.new(0, 0, 0, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sideBar.BorderSizePixel = 0
sideBar.Parent = mainContainer

-- Área de Conteúdo (páginas)
local contentContainer = Instance.new("Frame")
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(0.8, 0, 1, 0)         -- 80% do container principal
contentContainer.Position = UDim2.new(0.2, 0, 0, 0)
contentContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
contentContainer.BorderSizePixel = 0
contentContainer.Parent = mainContainer

-- Criação das Abas e Páginas
local tabs = {"Aimbot", "ESP", "Config", "Misc"}
local pages = {}
local currentPage = nil
local tabButtonHeight = 40  -- Altura fixa de cada aba em pixels
local tabSpacing = 5        -- Espaçamento entre as abas

for i, tabName in ipairs(tabs) do
    -- Botão da aba
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

    -- Página correspondente no contentContainer
    local page = Instance.new("Frame")
    page.Name = "Page_" .. tabName
    page.Size = UDim2.new(1, 0, 1, 0)
    page.Position = UDim2.new(0, 0, 0, 0)
    page.BackgroundColor3 = Color3.fromRGB(30, 50, 50)
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = contentContainer
    pages[tabName] = page

    -- Título da página
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

-- Exibe automaticamente a primeira aba
if #tabs > 0 and pages[tabs[1]] then
    pages[tabs[1]].Visible = true
    currentPage = pages[tabs[1]]
end

-- Resize Handle para ajustar a largura da Sidebar
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

-- Botão de Minimizar a UI (alternar visibilidade do container principal)
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
-- Integração dos Controles do Merged Aimbot
-- Nesta seção você pode adicionar os controles (toggles, sliders, botões, etc.)
-- dentro de cada página (por exemplo, na aba "Aimbot") para alterar as configurações.
------------------------------------------------------------

print("Merged Aimbot com UI customizada carregado com sucesso!")

------------------------------------------------------------
-- Função auxiliar para obter o jogador mais próximo (continuação)
------------------------------------------------------------
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
                local distanceSq = (camPos - targetPart.Position).Magnitude^2
                if distanceSq < shortestDistanceSq then
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
    
    if MergedAimbot.ScreenGui then
        MergedAimbot.ScreenGui:Destroy()
    end
    UserInputService.MouseDeltaSensitivity = 1
    self.Settings.Enabled = false
end

getgenv().MergedAimbot = MergedAimbot