--[[
    TOXIC LIFE HUB – PART 1: CORE
    VERSION = "TOXIC_CORE_1.0"

    This module is completely inert until Part 2 (FEATURES) is
    validated and passed to Core.initialize(features).
    It never creates the GUI or starts any feature by itself.
]]

local Core = {}
Core.VERSION = "TOXIC_CORE_1.0"

function Core.validate()
    return true
end

function Core.verifyFeatures(features)
    if type(features) ~= "table" then
        return false, "features is not a table"
    end
    if features.VERSION ~= "TOXIC_FEATURES_1.0" then
        return false, "features version mismatch (got " .. tostring(features.VERSION) .. ")"
    end
    if type(features.attach) ~= "function" then
        return false, "features missing attach()"
    end
    if type(features.validate) ~= "function" then
        return false, "features missing validate()"
    end
    local ok, reason = features.validate()
    if not ok then
        return false, "features.validate() failed: " .. tostring(reason)
    end
    return true
end

function Core.cleanup()
    local gethui = gethui
    local parent = nil
    if gethui then
        parent = gethui()
    else
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok and cg then parent = cg end
    end
    if parent and parent:FindFirstChild("ToxicHubUI") then
        pcall(function() parent.ToxicHubUI:Destroy() end)
    end
end

function Core.initialize(features)
    -- TOXIC LIFE HUB ✨ - Fully Animated & Modern UI + Gravity Input Box + Source 4 & 5 Features Added

    local Players = game:GetService("Players")

    local RunService = game:GetService("RunService")

    local UserInputService = game:GetService("UserInputService")

    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Workspace = game:GetService("Workspace")

    local TweenService = game:GetService("TweenService")

    local Lighting = game:GetService("Lighting")

    local LocalPlayer = Players.LocalPlayer



    -- Safe Notification

    local function Notify(title, text, duration)

        pcall(function()

            game:GetService("StarterGui"):SetCore("SendNotification", { Title = title, Text = text, Duration = duration or 4 })

        end)

    end



    -- ========================================================= --

    -- INTERNAL NATIVE GAME MODULES HOOKING

    -- ========================================================= --

    local getupval = getupvalue or (debug and debug.getupvalue) or getupvalues

    local DataModule = nil



    pcall(function()

        local Modules = ReplicatedStorage:WaitForChild("Modules", 5)

        local Core = Modules and Modules:WaitForChild("Core", 5)

    

        if Core then

            local DataInst = Core:FindFirstChild("Data")

            if DataInst then DataModule = require(DataInst) end

        end

    end)



    -- Anti-Skid String Obfuscation (Prevents simple Ctrl+F stealing)

    local function GetHubName()

        return string.char(84, 79, 88, 73, 67, 32, 76, 73, 70, 69, 32, 72, 85, 66) .. "✨"

    end

    local function GetCreditName()

        return string.char(109, 97, 100, 101, 32, 98, 121, 32, 84, 79, 88, 73, 67, 32, 40, 83, 84, 82, 95, 84, 79, 88, 73, 67, 56, 41) .. "💥"

    end



    -- Gui Parent Setup with secure fallback

    local GuiParent = nil

    if gethui then 

        GuiParent = gethui() 

    else

        local success, coreGui = pcall(function() return game:GetService("CoreGui") end)

        if success and coreGui then 

            GuiParent = coreGui 

        else 

            GuiParent = LocalPlayer:WaitForChild("PlayerGui") 

        end

    end



    if GuiParent:FindFirstChild("ToxicHubUI") then 

        GuiParent.ToxicHubUI:Destroy() 

    end



    -- State Variables

    local TOXIC_STATE = {

        WalkSpeed = 16,

        JumpHeight = 7.2,

        Gravity = 196.2,

        Float = false,

        AntiSit = false,

        Noclip = false,

        AntiVoid = false,

        AntiFling = false,

        AntiCarFling = false,

        GlitchActive = false,

        SmoothActive = true,

        RGBTool = false,

        JobSpammer = false,

        CarPremiumOnly = false,

        Speed = 90,

        Distance = 25,

        Smoothness = 1,

        SpinActive = false,

        SpinSpeed = 20,

        SavedLocation = nil,

        CrazyTpActive = false,

        CrazyTpOrigin = nil,

        WalkingFling = false,

        OrbitActive = false,

        OrbitTarget = "",

        CachedTarget = nil,

        OrbitSpeed = 300,

        OrbitDistance = 15,

        OrbitHeight = 0,

        OrbitAngle = 0,

        LoopFlingActive = false,

        LoopFlingTarget = "",

        lFlingOldPos = nil,

        _timeElapsed = 0,

        NoclipParts = {},

        OriginalFPDH = Workspace.FallenPartsDestroyHeight

    }



    local WalkingFlingConnection = nil

    local function FetchNetwork() return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("Net")) end



    -- ==========================================

    -- OUTFIT COPIER HELPERS

    -- ==========================================

    local NetModule = nil



    local function GetNetworkFunction()

        if NetModule then return NetModule end

        pcall(function()

            local modulesBase = ReplicatedStorage:FindFirstChild("Modules", true)

            if modulesBase and modulesBase:IsA("ModuleScript") then

                local req = require(modulesBase)

                if type(req) == "table" and req["net"] then NetModule = req["net"] end

            end

        end)

        if not NetModule then

            pcall(function()

                local core = ReplicatedStorage:FindFirstChild("Core", true)

                if core and core:FindFirstChild("Net") then NetModule = require(core.Net) end

            end)

        end

        if not NetModule then

            for _, v in ipairs(ReplicatedStorage:GetDescendants()) do

                if v:IsA("ModuleScript") and v.Name == "Net" then

                    pcall(function() NetModule = require(v) end)

                    if NetModule then break end

                end

            end

        end

        return NetModule

    end



    local function SafeSend(...)

        local net = NetModule or GetNetworkFunction()

        if net then

            if type(net.get) == "function" then

                pcall(net.get, ...)

            elseif type(net.send) == "function" then

                pcall(net.send, ...)

            end

        else

            local ok, network = pcall(FetchNetwork)

            if ok and network and type(network.send) == "function" then

                pcall(network.send, ...)

            end

        end

    end



    local function SendChatMessage(msg)

        pcall(function()

            local TextChatService = game:GetService("TextChatService")

            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then

                TextChatService.TextChannels.RBXGeneral:SendAsync(msg)

            else

                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")

            end

        end)

    end



    -- ==========================================

    -- ANIMATED UI SETUP

    -- ==========================================

    local ScreenGui = Instance.new("ScreenGui")

    ScreenGui.Name = "ToxicHubUI"

    ScreenGui.ResetOnSpawn = false

    ScreenGui.IgnoreGuiInset = true

    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    ScreenGui.Parent = GuiParent



    local MainFrame = Instance.new("Frame")

    MainFrame.Name = "MainFrame"

    MainFrame.Size = UDim2.new(0, 300, 0, 400)

    MainFrame.Position = UDim2.new(0.5, -150, 0.25, 0)

    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 14, 12)

    MainFrame.BackgroundTransparency = 0.18

    MainFrame.BorderSizePixel = 0

    MainFrame.Active = true

    MainFrame.Draggable = true

    MainFrame.Parent = ScreenGui



    local MainCorner = Instance.new("UICorner", MainFrame)

    MainCorner.CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", MainFrame)

    MainStroke.Color = Color3.fromRGB(0, 255, 120)

    MainStroke.Thickness = 2

    MainStroke.Transparency = 0.5



    -- MATRIX RAIN BACKGROUND: dedicated non-interactive layer behind all controls

    MainFrame.ClipsDescendants = true

    local MatrixBackground = Instance.new("Frame")

    MatrixBackground.Name = "MatrixBackground"

    MatrixBackground.Size = UDim2.fromScale(1, 1)

    MatrixBackground.Position = UDim2.fromScale(0, 0)

    MatrixBackground.BackgroundTransparency = 1

    MatrixBackground.BorderSizePixel = 0

    MatrixBackground.Active = false

    MatrixBackground.Selectable = false

    MatrixBackground.ZIndex = 1

    MatrixBackground.Parent = MainFrame



    -- Keep the rain visible through the translucent panel; it never captures input.

    task.spawn(function()

        while MatrixBackground and MatrixBackground.Parent do

            task.wait(0.10)

            if not MatrixBackground or not MatrixBackground.Parent then break end

            local drop = Instance.new("TextLabel")

            drop.Name = "MatrixRainDrop"

            drop.Size = UDim2.fromOffset(20, 20)

            drop.Position = UDim2.new(math.random(2, 98) / 100, 0, 0, -20)

            drop.BackgroundTransparency = 1

            drop.Text = math.random(0, 1) == 1 and "1" or "0"

            drop.TextColor3 = Color3.fromRGB(0, 255, 65)

            drop.TextSize = math.random(12, 16)

            drop.Font = Enum.Font.Code

            drop.TextTransparency = math.random(15, 45) / 100

            drop.Active = false

            drop.Selectable = false

            drop.ZIndex = 1

            drop.Parent = MatrixBackground

            local fallDuration = math.random(25, 45) / 10

            local tween = TweenService:Create(drop, TweenInfo.new(fallDuration, Enum.EasingStyle.Linear), {

                Position = UDim2.new(drop.Position.X.Scale, 0, 1, 20)

            })

            tween:Play()

            tween.Completed:Connect(function()

                if drop and drop.Parent then drop:Destroy() end

            end)

        end

    end)



    local TopBar = Instance.new("Frame")

    TopBar.Name = "TopBar"

    TopBar.Size = UDim2.new(1, 0, 0, 42)

    TopBar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)

    TopBar.BorderSizePixel = 0

    TopBar.ZIndex = 2

    TopBar.Parent = MainFrame

    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)



    -- Animated Glowing Rainbow Line under TopBar

    local GlowBar = Instance.new("Frame")

    GlowBar.Size = UDim2.new(1, 0, 0, 3)

    GlowBar.Position = UDim2.new(0, 0, 1, -3)

    GlowBar.BorderSizePixel = 0

    GlowBar.ZIndex = 3

    GlowBar.Parent = TopBar

    Instance.new("UICorner", GlowBar).CornerRadius = UDim.new(1, 0)



    task.spawn(function()

        while GlowBar and GlowBar.Parent do

            GlowBar.BackgroundColor3 = Color3.fromHSV((tick() % 5) / 5, 1, 1)

            RunService.RenderStepped:Wait()

        end

    end)



    local Title = Instance.new("TextLabel")

    Title.Size = UDim2.new(1, -70, 0.6, 0)

    Title.Position = UDim2.new(0, 15, 0, 5)

    Title.BackgroundTransparency = 1

    Title.Text = ""

    Title.TextColor3 = Color3.fromRGB(0, 255, 120)

    Title.TextSize = 16

    Title.Font = Enum.Font.GothamBlack

    Title.TextXAlignment = Enum.TextXAlignment.Left

    Title.ZIndex = 3

    Title.Parent = TopBar



    -- Glitch / typing title animation from supplied GUI

    task.spawn(function()

        local targetText = "TOXIC LIFE HUB ✨"

        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%"

        while Title and Title.Parent do

            for i = 1, #targetText do

                if not Title or not Title.Parent then break end

                local currentSub = string.sub(targetText, 1, i)

                local glitchIndex = math.random(1, #chars)

                local glitchChar = string.sub(chars, glitchIndex, glitchIndex)

                Title.Text = string.sub(currentSub, 1, -2) .. glitchChar

                task.wait(0.06)

                if Title and Title.Parent then Title.Text = currentSub end

                task.wait(0.08)

            end

            task.wait(3)

        end

    end)



    local SubTitle = Instance.new("TextLabel")

    SubTitle.Size = UDim2.new(1, -70, 0.4, 0)

    SubTitle.Position = UDim2.new(0, 15, 0.6, 0)

    SubTitle.BackgroundTransparency = 1

    SubTitle.Text = "made by TOXIC (STR_TOXIC8) 💥"

    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)

    SubTitle.TextSize = 10

    SubTitle.Font = Enum.Font.Gotham

    SubTitle.TextXAlignment = Enum.TextXAlignment.Left

    SubTitle.ZIndex = 3

    SubTitle.Parent = TopBar



    -- Minimize Button (-)

    local MinimizeBtn = Instance.new("TextButton")

    MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)

    MinimizeBtn.Position = UDim2.new(1, -35, 0.5, -14)

    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

    MinimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 120)

    MinimizeBtn.Text = "-"

    MinimizeBtn.TextSize = 18

    MinimizeBtn.Font = Enum.Font.GothamBold

    MinimizeBtn.ZIndex = 4

    MinimizeBtn.Parent = TopBar

    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

    Instance.new("UIStroke", MinimizeBtn).Color = Color3.fromRGB(0, 150, 80)



    -- Search bar

    local SearchFrame = Instance.new("Frame")

    SearchFrame.Name = "SearchFrame"

    SearchFrame.Size = UDim2.new(1, -16, 0, 32)

    SearchFrame.Position = UDim2.new(0, 8, 0, 46)

    SearchFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 22)

    SearchFrame.BorderSizePixel = 0

    SearchFrame.ZIndex = 5

    SearchFrame.Parent = MainFrame

    Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)

    local SearchStroke = Instance.new("UIStroke", SearchFrame)

    SearchStroke.Color = Color3.fromRGB(0, 180, 100)

    SearchStroke.Thickness = 1



    local SearchBox = Instance.new("TextBox")

    SearchBox.Name = "FeatureSearch"

    SearchBox.Size = UDim2.new(1, -12, 1, -6)

    SearchBox.Position = UDim2.new(0, 6, 0, 3)

    SearchBox.BackgroundTransparency = 1

    SearchBox.PlaceholderText = "🔍 Search features..."

    SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 140, 130)

    SearchBox.Text = ""

    SearchBox.TextColor3 = Color3.fromRGB(0, 255, 120)

    SearchBox.TextSize = 13

    SearchBox.Font = Enum.Font.GothamBold

    SearchBox.TextXAlignment = Enum.TextXAlignment.Left

    SearchBox.ClearTextOnFocus = false

    SearchBox.ZIndex = 6

    SearchBox.Parent = SearchFrame



    local Container = Instance.new("ScrollingFrame")

    Container.Name = "ContainerScroll"

    Container.Size = UDim2.new(1, -16, 1, -86)

    Container.Position = UDim2.new(0, 8, 0, 82)

    Container.BackgroundTransparency = 1

    Container.BorderSizePixel = 0

    Container.ScrollBarThickness = 6

    Container.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)

    Container.CanvasSize = UDim2.new(0, 0, 0, 0)

    Container.ZIndex = 2

    Container.Parent = MainFrame



    local UIListLayout = Instance.new("UIListLayout")

    UIListLayout.Parent = Container

    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    UIListLayout.Padding = UDim.new(0, 8)

    UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()

        Container.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 25)

    end)



    local function applyFeatureSearch(query)

        query = string.lower(tostring(query or ""):gsub("^%s+", ""):gsub("%s+$", ""))

        for _, child in ipairs(Container:GetChildren()) do

            if child:IsA("GuiObject") and child.ClassName ~= "UIListLayout" and child.ClassName ~= "UIPadding" then

                if query == "" then

                    child.Visible = true

                else

                    local blob = ""

                    if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then

                        blob = blob .. " " .. (child.Text or "")

                    end

                    for _, d in ipairs(child:GetDescendants()) do

                        if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then

                            blob = blob .. " " .. (d.Text or "")

                        end

                    end

                    child.Visible = string.find(string.lower(blob), query, 1, true) ~= nil

                end

            end

        end

    end



    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()

        applyFeatureSearch(SearchBox.Text)

    end)



    -- Minimize Toggle Logic

    local isMinimized = false

    MinimizeBtn.MouseButton1Click:Connect(function()

        isMinimized = not isMinimized

        MinimizeBtn.Text = isMinimized and "+" or "-"

        Container.Visible = not isMinimized

        SearchFrame.Visible = not isMinimized

        local targetSize = isMinimized and UDim2.new(0, 300, 0, 42) or UDim2.new(0, 300, 0, 400)

        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {Size = targetSize}):Play()

    end)



    -- Tweening Helpers

    local function AddHoverAnim(obj, defaultColor, hoverColor)

        obj.MouseEnter:Connect(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end)

        obj.MouseLeave:Connect(function() TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play() end)

    end



    -- ==========================================

    -- COMPONENT CREATORS (ANIMATED)

    -- ==========================================

    local function CreateButton(name, callback)

        local Button = Instance.new("TextButton")

        Button.Size = UDim2.new(1, 0, 0, 35)

        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        Button.TextColor3 = Color3.fromRGB(255, 255, 255)

        Button.Text = name

        Button.Font = Enum.Font.GothamBold

        Button.TextSize = 13

        Button.Parent = Container

        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Instance.new("UIStroke", Button).Color = Color3.fromRGB(50, 50, 60)



        AddHoverAnim(Button, Color3.fromRGB(30, 30, 40), Color3.fromRGB(0, 180, 100))

    

        Button.MouseButton1Click:Connect(function()

            local clickAnim = TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 31)})

            clickAnim:Play()

            clickAnim.Completed:Wait()

            TweenService:Create(Button, TweenInfo.new(0.1), {Size = UDim2.new(1, 0, 0, 35)}):Play()

            callback()

        end)

        return Button

    end



    local function CreateLabel(text, color, height)

        local Label = Instance.new("TextLabel")

        Label.Size = UDim2.new(1, 0, 0, height or 40)

        Label.BackgroundTransparency = 1

        Label.Text = text

        Label.TextColor3 = color or Color3.fromRGB(220, 220, 220)

        Label.TextSize = 12

        Label.Font = Enum.Font.GothamBold

        Label.TextWrapped = true

        Label.TextXAlignment = Enum.TextXAlignment.Left

        Label.Parent = Container

        return Label

    end



    local function CreateToggle(name, defaultState, callback)

        local ToggleFrame = Instance.new("Frame")

        ToggleFrame.Size = UDim2.new(1, 0, 0, 35)

        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        ToggleFrame.Parent = Container

        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)



        local ToggleLabel = Instance.new("TextLabel")

        ToggleLabel.Size = UDim2.new(0.8, 0, 1, 0)

        ToggleLabel.Position = UDim2.new(0, 15, 0, 0)

        ToggleLabel.BackgroundTransparency = 1

        ToggleLabel.Text = name

        ToggleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

        ToggleLabel.TextSize = 13

        ToggleLabel.Font = Enum.Font.GothamBold

        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

        ToggleLabel.Parent = ToggleFrame



        local CheckboxBg = Instance.new("Frame")

        CheckboxBg.Size = UDim2.new(0, 40, 0, 20)

        CheckboxBg.Position = UDim2.new(1, -55, 0.5, -10)

        CheckboxBg.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(60, 60, 70)

        CheckboxBg.Parent = ToggleFrame

        Instance.new("UICorner", CheckboxBg).CornerRadius = UDim.new(1, 0)



        local Indicator = Instance.new("Frame")

        Indicator.Size = UDim2.new(0, 16, 0, 16)

        Indicator.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

        Indicator.Parent = CheckboxBg

        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)



        local isEnabled = defaultState

        local ClickBtn = Instance.new("TextButton")

        ClickBtn.Size = UDim2.new(1,0,1,0)

        ClickBtn.BackgroundTransparency = 1

        ClickBtn.Text = ""

        ClickBtn.Parent = ToggleFrame



        ClickBtn.MouseButton1Click:Connect(function()

            isEnabled = not isEnabled

            local gPos = isEnabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)

            local gCol = isEnabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(60, 60, 70)

            TweenService:Create(Indicator, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = gPos}):Play()

            TweenService:Create(CheckboxBg, TweenInfo.new(0.3), {BackgroundColor3 = gCol}):Play()

            callback(isEnabled)

        end)

    end



    local function CreateInputBox(name, defaultVal, isNumber, callback)

        local InputFrame = Instance.new("Frame")

        InputFrame.Size = UDim2.new(1, 0, 0, 35)

        InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        InputFrame.Parent = Container

        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)



        local InputLabel = Instance.new("TextLabel")

        InputLabel.Size = UDim2.new(0.45, 0, 1, 0)

        InputLabel.Position = UDim2.new(0, 15, 0, 0)

        InputLabel.BackgroundTransparency = 1

        InputLabel.Text = name

        InputLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

        InputLabel.TextSize = 13

        InputLabel.Font = Enum.Font.GothamBold

        InputLabel.TextXAlignment = Enum.TextXAlignment.Left

        InputLabel.Parent = InputFrame



        local TextBox = Instance.new("TextBox")

        TextBox.Size = UDim2.new(0.45, 0, 0.7, 0)

        TextBox.Position = UDim2.new(0.5, 0, 0.15, 0)

        TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

        TextBox.TextColor3 = Color3.fromRGB(0, 255, 120)

        TextBox.Text = tostring(defaultVal)

        TextBox.TextSize = 13

        TextBox.Font = Enum.Font.GothamBold

        TextBox.Parent = InputFrame

        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)

        Instance.new("UIStroke", TextBox).Color = Color3.fromRGB(0, 150, 80)



        TextBox.FocusLost:Connect(function()

            if isNumber then

                local val = tonumber(TextBox.Text:match("%-?%d+%.?%d*"))

                if val then callback(val); TextBox.Text = tostring(val)

                else TextBox.Text = tostring(defaultVal) end

            else

                callback(TextBox.Text)

            end

        end)

    end



    local function CreatePlayerDropdown(name, defaultVal, callback)

        local InputFrame = Instance.new("Frame")

        InputFrame.Size = UDim2.new(1, 0, 0, 35)

        InputFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        InputFrame.ClipsDescendants = true

        InputFrame.ZIndex = 2

        InputFrame.Parent = Container

        Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 6)



        local TopBarInner = Instance.new("Frame")

        TopBarInner.Size = UDim2.new(1, 0, 0, 35)

        TopBarInner.BackgroundTransparency = 1

        TopBarInner.ZIndex = 3

        TopBarInner.Parent = InputFrame



        local InputLabel = Instance.new("TextLabel")

        InputLabel.Size = UDim2.new(0.40, 0, 1, 0)

        InputLabel.Position = UDim2.new(0, 15, 0, 0)

        InputLabel.BackgroundTransparency = 1

        InputLabel.Text = name

        InputLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

        InputLabel.TextSize = 13

        InputLabel.Font = Enum.Font.GothamBold

        InputLabel.TextXAlignment = Enum.TextXAlignment.Left

        InputLabel.ZIndex = 4

        InputLabel.Parent = TopBarInner



        local TextBox = Instance.new("TextBox")

        TextBox.Size = UDim2.new(0.45, 0, 0.7, 0)

        TextBox.Position = UDim2.new(0.40, 0, 0.15, 0)

        TextBox.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

        TextBox.TextColor3 = Color3.fromRGB(0, 255, 120)

        TextBox.Text = tostring(defaultVal)

        TextBox.TextSize = 13

        TextBox.Font = Enum.Font.GothamBold

        TextBox.ZIndex = 4

        TextBox.Parent = TopBarInner

        Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 4)



        local DropdownBtn = Instance.new("TextButton")

        DropdownBtn.Size = UDim2.new(0, 25, 0.7, 0)

        DropdownBtn.Position = UDim2.new(0.85, 10, 0.15, 0)

        DropdownBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)

        DropdownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

        DropdownBtn.Text = "▼"

        DropdownBtn.Font = Enum.Font.GothamBold

        DropdownBtn.ZIndex = 4

        DropdownBtn.Parent = TopBarInner

        Instance.new("UICorner", DropdownBtn).CornerRadius = UDim.new(0, 4)



        local DropdownList = Instance.new("ScrollingFrame")

        DropdownList.Size = UDim2.new(0.55, 10, 0, 120)

        DropdownList.Position = UDim2.new(0.40, 0, 0, 35)

        DropdownList.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

        DropdownList.BorderSizePixel = 0

        DropdownList.ScrollBarThickness = 2

        DropdownList.Visible = false

        DropdownList.ZIndex = 5

        DropdownList.Parent = InputFrame



        local ListLayout = Instance.new("UIListLayout")

        ListLayout.Parent = DropdownList

        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder



        local isOpen = false



        DropdownBtn.MouseButton1Click:Connect(function()

            isOpen = not isOpen

            DropdownList.Visible = isOpen

        

            InputFrame.ZIndex = isOpen and 50 or 2

            TopBarInner.ZIndex = isOpen and 51 or 3

            InputLabel.ZIndex = isOpen and 52 or 4

            TextBox.ZIndex = isOpen and 52 or 4

            DropdownBtn.ZIndex = isOpen and 52 or 4

            DropdownList.ZIndex = isOpen and 51 or 5



            TweenService:Create(InputFrame, TweenInfo.new(0.3), {Size = isOpen and UDim2.new(1, 0, 0, 160) or UDim2.new(1, 0, 0, 35)}):Play()

            DropdownBtn.Text = isOpen and "▲" or "▼"



            if isOpen then

                for _, child in ipairs(DropdownList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end

                for _, p in ipairs(Players:GetPlayers()) do

                    if p ~= LocalPlayer then

                        local pBtn = Instance.new("TextButton")

                        pBtn.Size = UDim2.new(1, 0, 0, 25)

                        pBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

                        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

                        pBtn.Text = p.Name

                        pBtn.Font = Enum.Font.Gotham

                        pBtn.TextSize = 12

                        pBtn.ZIndex = 55

                        pBtn.Parent = DropdownList

                    

                        pBtn.MouseButton1Click:Connect(function()

                            TextBox.Text = p.Name

                            callback(p.Name)

                            isOpen = false

                            DropdownList.Visible = false

                        

                            InputFrame.ZIndex = 2

                            TopBarInner.ZIndex = 3

                            InputLabel.ZIndex = 4

                            TextBox.ZIndex = 4

                            DropdownBtn.ZIndex = 4

                            DropdownList.ZIndex = 5

                        

                            TweenService:Create(InputFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 35)}):Play()

                            DropdownBtn.Text = "▼"

                        end)

                    end

                end

                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)

            end

        end)

        TextBox.FocusLost:Connect(function() callback(TextBox.Text) end)

    end



    local function CreateSlider(name, min, max, defaultVal, callback)

        local SliderFrame = Instance.new("Frame")

        SliderFrame.Size = UDim2.new(1, 0, 0, 50)

        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)

        SliderFrame.Parent = Container

        Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)



        local SliderLabel = Instance.new("TextLabel")

        SliderLabel.Size = UDim2.new(0.8, 0, 0, 20)

        SliderLabel.Position = UDim2.new(0, 15, 0, 5)

        SliderLabel.BackgroundTransparency = 1

        SliderLabel.Text = name

        SliderLabel.TextColor3 = Color3.fromRGB(220, 220, 220)

        SliderLabel.TextSize = 13

        SliderLabel.Font = Enum.Font.GothamBold

        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

        SliderLabel.Parent = SliderFrame



        local ValueLabel = Instance.new("TextLabel")

        ValueLabel.Size = UDim2.new(0.2, 0, 0, 20)

        ValueLabel.Position = UDim2.new(0.8, -15, 0, 5)

        ValueLabel.BackgroundTransparency = 1

        ValueLabel.Text = tostring(defaultVal)

        ValueLabel.TextColor3 = Color3.fromRGB(0, 255, 120)

        ValueLabel.TextSize = 13

        ValueLabel.Font = Enum.Font.GothamBold

        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

        ValueLabel.Parent = SliderFrame



        local SliderTrack = Instance.new("TextButton")

        SliderTrack.Size = UDim2.new(1, -30, 0, 6)

        SliderTrack.Position = UDim2.new(0, 15, 0, 32)

        SliderTrack.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

        SliderTrack.Text = ""

        SliderTrack.AutoButtonColor = false

        SliderTrack.Parent = SliderFrame

        Instance.new("UICorner", SliderTrack).CornerRadius = UDim.new(1, 0)



        local SliderFill = Instance.new("Frame")

        local fillPercent = (defaultVal - min) / (max - min)

        SliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)

        SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 120)

        SliderFill.BorderSizePixel = 0

        SliderFill.Parent = SliderTrack

        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)



        local dragging = false

        local function UpdateSlider(input)

            local relativeX = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)

            local percent = relativeX / SliderTrack.AbsoluteSize.X

            local value = math.floor((min + ((max - min) * percent)) * 10) / 10

            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()

            ValueLabel.Text = tostring(value)

            callback(value)

        end



        SliderTrack.InputBegan:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then

                dragging = true; UpdateSlider(input)

            end

        end)

        UserInputService.InputEnded:Connect(function(input)

            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end

        end)

        UserInputService.InputChanged:Connect(function(input)

            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(input) end

        end)

    end



    -- =========================================

    -- SECURE REMOTE CALLER & HELPERS (Source 4)

    -- =========================================

    local RE = ReplicatedStorage:FindFirstChild("RE") or ReplicatedStorage:FindFirstChild("RemoteEvent", true)

    local RF = ReplicatedStorage:FindFirstChild("RF") or ReplicatedStorage:FindFirstChild("RemoteFunction", true)

    local GetRemoteObj = ReplicatedStorage:WaitForChild("Remotes", 5) and ReplicatedStorage.Remotes:WaitForChild("Get", 5)



    local function SendRemote(...)

        local args = {...}

        pcall(function() if RE then RE:FireServer(unpack(args)) end end)

    end



    local function InvokeRF(...)

        local args = {...}

        local result = nil

        pcall(function() if RF then result = RF:InvokeServer(unpack(args)) end end)

        return result

    end



    local function GetPlayerPlot(plr)

        local PlacedModels = workspace:FindFirstChild("PlacedModels")

        if PlacedModels then

            for _, v in pairs(PlacedModels:GetChildren()) do

                if v:IsA("Model") and v:GetAttribute("owner_id") == plr.UserId then return v end

            end

        end

        return nil

    end



    local function OpenWindow(windowTitle)

        local MGFrame = Instance.new("Frame")

        MGFrame.Size = UDim2.new(1, 0, 1, -42)

        MGFrame.Position = UDim2.new(0, 0, 0, 42)

        MGFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

        MGFrame.ZIndex = 10

        MGFrame.Parent = MainFrame



        local MGTitle = Instance.new("TextLabel", MGFrame)

        MGTitle.Size = UDim2.new(1, -40, 0, 30)

        MGTitle.Position = UDim2.new(0, 10, 0, 5)

        MGTitle.BackgroundTransparency = 1

        MGTitle.Text = windowTitle

        MGTitle.TextColor3 = Color3.fromRGB(0, 255, 200)

        MGTitle.Font = Enum.Font.GothamBold

        MGTitle.TextSize = 14

        MGTitle.ZIndex = 11



        local CloseMG = Instance.new("TextButton", MGFrame)

        CloseMG.Size = UDim2.new(0, 25, 0, 25)

        CloseMG.Position = UDim2.new(1, -30, 0, 5)

        CloseMG.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

        CloseMG.Text = "X"

        CloseMG.TextColor3 = Color3.fromRGB(255, 255, 255)

        CloseMG.Font = Enum.Font.GothamBold

        CloseMG.TextSize = 13

        CloseMG.ZIndex = 11

        Instance.new("UICorner", CloseMG).CornerRadius = UDim.new(0, 6)



        CloseMG.MouseButton1Click:Connect(function()

            MGFrame:Destroy()

        end)



        local ContentArea = Instance.new("Frame", MGFrame)

        ContentArea.Size = UDim2.new(1, -20, 1, -40)

        ContentArea.Position = UDim2.new(0, 10, 0, 35)

        ContentArea.BackgroundTransparency = 1

        ContentArea.ZIndex = 11



        return ContentArea

    end



    -- ========================================================= --

    -- 1. FREEPAY LOGIC (Standalone)

    -- ========================================================= --

    local FreePay_Enabled = false

    local FreePay_Originals = {}



    local function ToggleFreePay(state)

        if not DataModule or not DataModule.initiate then

            Notify("Error ❌", "Data module nahi mila!", 4)

            return false

        end

        if not getupval then

            Notify("Error ❌", "Executor 'getupvalue' support nahi karta!", 4)

            return false

        end



        if state then

            if FreePay_Enabled then return true end

        

            local ok, update_datum = pcall(getupval, DataModule.initiate, 2)

            if not ok or type(update_datum) ~= "function" then return false end

            local ok2, u3 = pcall(getupval, update_datum, 2)

            if not ok2 or type(u3) ~= "table" then return false end



            local patches = { is_verified = true, invisible_bought = true, max_outfits = 99 }



            for key, spoof_val in next, patches do

                local current = u3[key]

                if (type(current) == "boolean" and current ~= true) or (type(current) == "number" and current < spoof_val) or (current == nil) then

                    FreePay_Originals[key] = current

                    pcall(update_datum, key, spoof_val)

                end

            end



            for _, v in ipairs(ReplicatedStorage:GetDescendants()) do

                if v:GetAttribute("IsVerifiedOnly") ~= nil and v:GetAttribute("IsVerifiedOnly") ~= false then

                    FreePay_Originals[v] = FreePay_Originals[v] or {}

                    FreePay_Originals[v].IsVerifiedOnly = v:GetAttribute("IsVerifiedOnly")

                    pcall(function() v:SetAttribute("IsVerifiedOnly", false) end)

                end

                if v:GetAttribute("IsAirportRestricted") ~= nil and v:GetAttribute("IsAirportRestricted") ~= false then

                    FreePay_Originals[v] = FreePay_Originals[v] or {}

                    FreePay_Originals[v].IsAirportRestricted = v:GetAttribute("IsAirportRestricted")

                    pcall(function() v:SetAttribute("IsAirportRestricted", false) end)

                end

            end



            pcall(function() LocalPlayer:SetAttribute("is_verified", true) end)

            FreePay_Enabled = true

            Notify("FreePay Enabled 👑", "Premium Vehicles & Airport Unlocked!", 4)

            return true

        else

            if not FreePay_Enabled then return false end

            local ok, update_datum = pcall(getupval, DataModule.initiate, 2)

        

            for key, original_val in next, FreePay_Originals do

                if typeof(key) == "string" then

                    if ok and type(update_datum) == "function" then pcall(update_datum, key, original_val) end

                elseif typeof(key) == "Instance" and key.Parent and type(original_val) == "table" then

                    if original_val.IsVerifiedOnly ~= nil then pcall(function() key:SetAttribute("IsVerifiedOnly", original_val.IsVerifiedOnly) end) end

                    if original_val.IsAirportRestricted ~= nil then pcall(function() key:SetAttribute("IsAirportRestricted", original_val.IsAirportRestricted) end) end

                end

            end



            table.clear(FreePay_Originals)

            FreePay_Enabled = false

            Notify("FreePay Disabled 🔒", "Premium status wapas normal ho gaya.", 4)

            return false

        end

    end



    -- ========================================================= --

    -- 2. ANTI FIRE LOGIC (Client-sided protection)

    -- ========================================================= --

    local AntiFireLoop = false

    local function ToggleAntiFire(state)

        AntiFireLoop = state

        if state then

            Notify("Anti Fire 🧯", "Aag ko auto-destroy kiya ja raha hai!", 3)

            task.spawn(function()

                while AntiFireLoop do

                    task.wait(0.2)

                    for _, v in ipairs(workspace:GetDescendants()) do

                        if v.Name == "Fire" or v:IsA("Fire") then pcall(function() v:Destroy() end) end

                    end

                    if LocalPlayer.Character then

                        for _, v in ipairs(LocalPlayer.Character:GetDescendants()) do

                            if v.Name == "Fire" or v:IsA("Fire") then pcall(function() v:Destroy() end) end

                        end

                    end

                end

            end)

            return true

        else

            Notify("Anti Fire 🧯", "Anti Fire band kar diya gaya hai.", 3)

            return false

        end

    end





    -- ==========================================

    -- POPULATING FEATURES

    -- ==========================================



    -- =========================================================
    -- API object passed to Features
    -- =========================================================
    local api = {
        CreateButton         = CreateButton,
        CreateLabel          = CreateLabel,
        CreateToggle         = CreateToggle,
        CreateInputBox       = CreateInputBox,
        CreatePlayerDropdown = CreatePlayerDropdown,
        CreateSlider         = CreateSlider,
        OpenWindow           = OpenWindow,
        TOXIC_STATE          = TOXIC_STATE,
        Notify               = Notify,
        SafeSend             = SafeSend,
        FetchNetwork         = FetchNetwork,
        SendChatMessage      = SendChatMessage,
        GetNetworkFunction   = GetNetworkFunction,
        ToggleFreePay        = ToggleFreePay,
        ToggleAntiFire       = ToggleAntiFire,
        GetPlayerPlot        = GetPlayerPlot,
        SendRemote           = SendRemote,
        InvokeRF             = InvokeRF,
        GuiParent            = GuiParent,
        ScreenGui            = ScreenGui,
        MainFrame            = MainFrame,
        Container            = Container,
        LocalPlayer          = LocalPlayer,
        Players              = Players,
        RunService           = RunService,
        UserInputService     = UserInputService,
        TweenService         = TweenService,
        Workspace            = Workspace,
        Lighting             = Lighting,
        ReplicatedStorage    = ReplicatedStorage,
        GetRemoteObj         = GetRemoteObj,
        RE                   = RE,
        RF                   = RF,
    }

    -- Hand control to Features – ONLY place features are registered
    features.attach(api)
end

return Core
