wait(2)
if game.PlaceId ~= 142823291 then return end

-- ============================================================
-- BLACKOUT GUI v2 | RED EDITION | TRIPLE PANEL + INTRO + THEME
-- ============================================================

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local Workspace          = game:GetService("Workspace")
local Lighting           = game:GetService("Lighting")
local LocalPlayer        = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay")
local FadeEvent          = Remotes:WaitForChild("Fade")
local DataChangedEvent   = Remotes:WaitForChild("PlayerDataChanged")
local RoundEndEvent      = Remotes:WaitForChild("RoundEndFade")

-- ============================================================
-- THEME TABLE (RED default)
-- ============================================================
local THEMES = {
    RED    = { accent = Color3.fromRGB(230, 30, 45),   dim = Color3.fromRGB(120, 15, 22),   border = Color3.fromRGB(34, 20, 22) },
    PURPLE = { accent = Color3.fromRGB(175, 90, 255),  dim = Color3.fromRGB(80, 40, 120),   border = Color3.fromRGB(40, 24, 55) },
    BLUE   = { accent = Color3.fromRGB(65, 130, 255),  dim = Color3.fromRGB(30, 60, 120),   border = Color3.fromRGB(22, 30, 48) },
    GREEN  = { accent = Color3.fromRGB(65, 220, 125),  dim = Color3.fromRGB(30, 110, 60),   border = Color3.fromRGB(20, 40, 28) },
    ORANGE = { accent = Color3.fromRGB(245, 130, 30),  dim = Color3.fromRGB(120, 60, 15),   border = Color3.fromRGB(45, 28, 15) },
    PINK   = { accent = Color3.fromRGB(255, 90, 180),  dim = Color3.fromRGB(130, 40, 90),   border = Color3.fromRGB(45, 22, 35) },
    WHITE  = { accent = Color3.fromRGB(235, 235, 235), dim = Color3.fromRGB(120, 120, 120), border = Color3.fromRGB(40, 40, 45) },
}
local currentTheme = "RED"

-- ============================================================
-- COLORS (mutable — ApplyTheme updates these)
-- ============================================================
local BG          = Color3.fromRGB(6, 6, 7)
local BG_ITEM     = Color3.fromRGB(13, 13, 15)
local BG_HOVER    = Color3.fromRGB(22, 14, 16)
local BORDER      = THEMES.RED.border
local ACCENT      = THEMES.RED.accent
local ACCENT_DIM  = THEMES.RED.dim
local TEXT        = Color3.fromRGB(255, 255, 255)
local TEXT_DIM    = Color3.fromRGB(170, 170, 178)
local TEXT_ON     = THEMES.RED.accent

local ThemedElements = { windows = {}, toggles = {}, buttons = {}, dropdowns = {}, sections = {} }

-- ============================================================
-- ROLE COLORS
-- ============================================================
local RoleColors = {
    Murderer = Color3.fromRGB(255, 45, 65),
    Sheriff  = Color3.fromRGB(65, 130, 255),
    Innocent = Color3.fromRGB(65, 220, 125),
}

local function GetRoleColor(player)
    local roles = getgenv().BlackoutRoles or {}
    for id, data in pairs(roles) do
        if data and typeof(data) == "table" then
            if tostring(id) == tostring(player.UserId) or id == player.Name then
                return RoleColors[data.Role] or RoleColors.Innocent
            end
        end
    end
    local function hasTool(name)
        local bp = player:FindFirstChild("Backpack")
        local ch = player.Character
        if bp and bp:FindFirstChild(name) then return true end
        if ch and ch:FindFirstChild(name) then return true end
        return false
    end
    if hasTool("Knife") then return RoleColors.Murderer end
    if hasTool("Gun") then return RoleColors.Sheriff end
    return RoleColors.Innocent
end

-- ============================================================
-- ESP / COMBAT STATE
-- ============================================================
local outlineOnlyEnabled = true
local skeletonEnabled = true
local skeletonThickness = 1
local boxEnabled = false
local boxThickness = 1.5
local tracerEnabled = false
local tracerOrigin = "Bottom"
local healthBarEnabled = false
local nameESPEnabled = true

local aimbotEnabled = false
local aimbotSmoothing = 0.2
local aimbotFOV = 150
local aimbotPart = "Head"
local aimbotKey = "Right Click"
local aimbotTarget = "Murderer"  -- "All" or "Murderer"
local aiming = false

local killAuraEnabled = false
local killAuraRange = 15

local fastThrowEnabled = false
local fastThrowConnection = nil
local fastThrowDelay = 0.05

local flingTargetName = ""
local activeFlingTarget = nil

local coinFarmEnabled = false
local coinFarmConnection = nil
local coinFarmSpeed = 1
local coinFarmWarmup = 0.25

-- Silent Aim loop handle
local silentAimLoop = nil
-- Forward references so toggles can control each other
local silentAimToggleRef = nil
local triggerbotToggleRef = nil

-- ============================================================
-- ROOT
-- ============================================================
local guiParent
pcall(function()
    if gethui then guiParent = gethui() end
end)
if not guiParent then
    pcall(function()
        guiParent = game:GetService("CoreGui")
    end)
end
if not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackoutTripleGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 2147483647
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
ScreenGui.Parent = guiParent

-- ============================================================
-- LOADING SPLASH
-- ============================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "BlackoutLoader"
LoadGui.ResetOnSpawn = false
LoadGui.IgnoreGuiInset = true
LoadGui.DisplayOrder = 2147483647
LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
LoadGui.Parent = guiParent

local LoadBG = Instance.new("Frame")
LoadBG.Size = UDim2.new(1, 0, 1, 0)
LoadBG.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LoadBG.BorderSizePixel = 0
LoadBG.BackgroundTransparency = 1
LoadBG.Parent = LoadGui

local LoadCenter = Instance.new("Frame")
LoadCenter.Size = UDim2.new(0, 400, 0, 160)
LoadCenter.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadCenter.AnchorPoint = Vector2.new(0.5, 0.5)
LoadCenter.BackgroundTransparency = 1
LoadCenter.Parent = LoadBG

local LogoLbl = Instance.new("TextLabel")
LogoLbl.Size = UDim2.new(1, 0, 0, 70)
LogoLbl.BackgroundTransparency = 1
LogoLbl.Text = ""
LogoLbl.Font = Enum.Font.Code
LogoLbl.TextSize = 48
LogoLbl.TextColor3 = THEMES.RED.accent
LogoLbl.TextTransparency = 1
LogoLbl.TextStrokeTransparency = 1
LogoLbl.TextStrokeColor3 = Color3.fromRGB(255, 90, 100)
LogoLbl.Parent = LoadCenter

local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1, 0, 0, 20)
SubLbl.Position = UDim2.new(0, 0, 0, 76)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "LOADING // PLEASE WAIT"
SubLbl.Font = Enum.Font.Code
SubLbl.TextSize = 12
SubLbl.TextColor3 = THEMES.RED.dim
SubLbl.TextTransparency = 1
SubLbl.Parent = LoadCenter

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(0, 320, 0, 4)
BarBg.Position = UDim2.new(0.5, -160, 0, 112)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
BarBg.BorderSizePixel = 0
BarBg.BackgroundTransparency = 1
BarBg.Parent = LoadCenter
Instance.new("UICorner", BarBg).CornerRadius = UDim.new(1, 0)

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = THEMES.RED.accent
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

local BarGlow = Instance.new("UIStroke")
BarGlow.Color = Color3.fromRGB(255, 90, 100)
BarGlow.Thickness = 1
BarGlow.Transparency = 0.4
BarGlow.Parent = BarFill

local PctLbl = Instance.new("TextLabel")
PctLbl.Size = UDim2.new(1, 0, 0, 14)
PctLbl.Position = UDim2.new(0, 0, 0, 122)
PctLbl.BackgroundTransparency = 1
PctLbl.Text = "0%"
PctLbl.Font = Enum.Font.Code
PctLbl.TextSize = 10
PctLbl.TextColor3 = TEXT_DIM
PctLbl.TextTransparency = 1
PctLbl.Parent = LoadCenter

local Scanlines = Instance.new("Frame")
Scanlines.Size = UDim2.new(1, 0, 1, 0)
Scanlines.BackgroundTransparency = 1
Scanlines.Parent = LoadBG

for i = 0, 60 do
    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(1, 0, 0, 1)
    Line.Position = UDim2.new(0, 0, 0, i * 14)
    Line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Line.BackgroundTransparency = 0.97
    Line.BorderSizePixel = 0
    Line.Parent = Scanlines
end

local function RunLoadingSequence()
    TweenService:Create(LoadBG, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
    task.wait(0.1)
    local text = "BLACKOUT"
    LogoLbl.Text = ""
    TweenService:Create(LogoLbl, TweenInfo.new(0.3), {TextTransparency = 0, TextStrokeTransparency = 0.4}):Play()
    TweenService:Create(SubLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    TweenService:Create(BarBg,  TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    TweenService:Create(PctLbl, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    for i = 1, #text do
        LogoLbl.Text = string.sub(text, 1, i)
        task.wait(0.04)
    end
    for _ = 1, 3 do
        LogoLbl.TextColor3 = Color3.fromRGB(255, 200, 200)
        task.wait(0.05)
        LogoLbl.TextColor3 = THEMES.RED.accent
        task.wait(0.05)
    end
    local steps = 40
    for i = 0, steps do
        local pct = i / steps
        BarFill.Size = UDim2.new(pct, 0, 1, 0)
        PctLbl.Text = math.floor(pct * 100) .. "%"
        task.wait(1.0 / steps)
    end
    task.wait(0.15)
    local fadeInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(LogoLbl, fadeInfo, {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    TweenService:Create(SubLbl, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarBg,  fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(PctLbl, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarGlow, fadeInfo, {Transparency = 1}):Play()
    local bgTween = TweenService:Create(LoadBG, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    bgTween:Play()
    bgTween.Completed:Wait()
    task.wait(0.05)
    LoadGui:Destroy()
end

-- ============================================================
-- DROPDOWN SYSTEM
-- ============================================================
local DropdownLayer = Instance.new("Frame")
DropdownLayer.Size = UDim2.fromScale(1, 1)
DropdownLayer.BackgroundTransparency = 1
DropdownLayer.BorderSizePixel = 0
DropdownLayer.Visible = false
DropdownLayer.ZIndex = 5000
DropdownLayer.Parent = ScreenGui

local DropdownMenu = Instance.new("Frame")
DropdownMenu.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
DropdownMenu.BorderSizePixel = 0
DropdownMenu.Visible = false
DropdownMenu.ZIndex = 5001
DropdownMenu.Parent = DropdownLayer
Instance.new("UICorner", DropdownMenu).CornerRadius = UDim.new(0, 5)
local DStroke = Instance.new("UIStroke", DropdownMenu)
DStroke.Color = ACCENT_DIM
DStroke.Thickness = 1

local DropdownScroll = Instance.new("ScrollingFrame")
DropdownScroll.Position = UDim2.fromOffset(4, 4)
DropdownScroll.Size = UDim2.new(1, -8, 1, -8)
DropdownScroll.BackgroundTransparency = 1
DropdownScroll.BorderSizePixel = 0
DropdownScroll.ScrollBarThickness = 3
DropdownScroll.ScrollBarImageColor3 = ACCENT
DropdownScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DropdownScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownScroll.ZIndex = 5002
DropdownScroll.Parent = DropdownMenu

local DropdownList = Instance.new("UIListLayout")
DropdownList.Padding = UDim.new(0, 3)
DropdownList.SortOrder = Enum.SortOrder.LayoutOrder
DropdownList.Parent = DropdownScroll

local activeDropdown = nil

local function closeDropdown()
    activeDropdown = nil
    DropdownMenu.Visible = false
    DropdownLayer.Visible = false
    for _, child in ipairs(DropdownScroll:GetChildren()) do
        if child:IsA("GuiObject") then child:Destroy() end
    end
end

DropdownLayer.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        closeDropdown()
    end
end)

-- ============================================================
-- THEME APPLIER
-- ============================================================
local ApplyTheme
ApplyTheme = function(name)
    local t = THEMES[name]
    if not t then return end
    currentTheme = name
    ACCENT     = t.accent
    ACCENT_DIM = t.dim
    BORDER     = t.border
    TEXT_ON    = t.accent

    for _, w in ipairs(ThemedElements.windows) do
        if w.mainStroke then w.mainStroke.Color = BORDER end
        if w.glow then w.glow.BackgroundColor3 = ACCENT end
        if w.divider then w.divider.BackgroundColor3 = BORDER end
        if w.titleDot then w.titleDot.BackgroundColor3 = ACCENT end
        if w.scroll then w.scroll.ScrollBarImageColor3 = ACCENT_DIM end
    end

    for _, tog in ipairs(ThemedElements.toggles) do
        if tog.render then pcall(tog.render) end
    end

    for _, b in ipairs(ThemedElements.buttons) do
        if b.stroke then b.stroke.Color = BORDER end
        if b.bar then b.bar.BackgroundColor3 = BORDER end
        if b.label then b.label.TextColor3 = TEXT end
    end

    for _, d in ipairs(ThemedElements.dropdowns) do
        if d.stroke then d.stroke.Color = BORDER end
        if d.bar then d.bar.BackgroundColor3 = BORDER end
        if d.valueTxt then d.valueTxt.TextColor3 = TEXT_ON end
    end

    for _, s in ipairs(ThemedElements.sections) do
        if s then s.TextColor3 = ACCENT_DIM end
    end

    if DStroke then DStroke.Color = ACCENT_DIM end
    if DropdownScroll then DropdownScroll.ScrollBarImageColor3 = ACCENT end
end

-- ============================================================
-- WINDOW BUILDER
-- ============================================================
local AllWindows = {}

local function CreateWindow(title, posX, posY)
    local Win = {}
    local WIDTH = 230

    local Main = Instance.new("Frame")
    Main.Name = title
    Main.Size = UDim2.new(0, WIDTH, 0, 0)
    Main.Position = UDim2.new(0, posX, 0, posY)
    Main.BackgroundColor3 = BG
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = BORDER
    MainStroke.Thickness = 1
    MainStroke.Parent = Main

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 1)
    Glow.BackgroundColor3 = ACCENT
    Glow.BorderSizePixel = 0
    Glow.Parent = Main
    local GlowGrad = Instance.new("UIGradient")
    GlowGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    GlowGrad.Parent = Glow

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = BG
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.BorderSizePixel = 0
    Header.Parent = Main

    local TitleDot = Instance.new("Frame")
    TitleDot.Size = UDim2.new(0, 5, 0, 5)
    TitleDot.Position = UDim2.new(0, 11, 0.5, -2)
    TitleDot.BackgroundColor3 = ACCENT
    TitleDot.BorderSizePixel = 0
    TitleDot.Parent = Header
    Instance.new("UICorner", TitleDot).CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -50, 1, 0)
    TitleLbl.Position = UDim2.new(0, 22, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = TEXT
    TitleLbl.Font = Enum.Font.Code
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Header

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
    MinimizeBtn.Position = UDim2.new(1, -28, 0.5, -11)
    MinimizeBtn.BackgroundColor3 = BG_ITEM
    MinimizeBtn.Text = "–"
    MinimizeBtn.TextColor3 = TEXT_DIM
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.TextSize = 14
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.BorderSizePixel = 0
    MinimizeBtn.Parent = Header
    Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 3)

    MinimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = ACCENT}):Play()
    end)
    MinimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = TEXT_DIM}):Play()
    end)

    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -16, 0, 1)
    Divider.Position = UDim2.new(0, 8, 0, 30)
    Divider.BackgroundColor3 = BORDER
    Divider.BorderSizePixel = 0
    Divider.Parent = Main

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = "Scroll"
    Scroll.Size = UDim2.new(1, 0, 0, 0)
    Scroll.Position = UDim2.new(0, 0, 0, 31)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 3
    Scroll.ScrollBarImageColor3 = ACCENT_DIM
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    Scroll.Parent = Main

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 3)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 6)
    Pad.PaddingBottom = UDim.new(0, 8)
    Pad.PaddingLeft = UDim.new(0, 7)
    Pad.PaddingRight = UDim.new(0, 7)
    Pad.Parent = Scroll

    table.insert(ThemedElements.windows, {
        main = Main, mainStroke = MainStroke, glow = Glow,
        divider = Divider, titleDot = TitleDot, scroll = Scroll,
    })

    local function CreateSection(text)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, 0, 0, 16)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = "── " .. string.upper(text)
        Lbl.TextColor3 = ACCENT_DIM
        Lbl.Font = Enum.Font.Code
        Lbl.TextSize = 9
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Scroll
        table.insert(ThemedElements.sections, Lbl)
        return Lbl
    end

    local function CreateToggle(name, defaultState, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local StatusTxt = Instance.new("TextLabel")
        StatusTxt.Size = UDim2.new(0, 30, 1, 0)
        StatusTxt.Position = UDim2.new(1, -36, 0, 0)
        StatusTxt.BackgroundTransparency = 1
        StatusTxt.Text = "OFF"
        StatusTxt.TextColor3 = TEXT_DIM
        StatusTxt.Font = Enum.Font.Code
        StatusTxt.TextSize = 10
        StatusTxt.TextXAlignment = Enum.TextXAlignment.Right
        StatusTxt.Parent = Btn

        local state = defaultState or false

        local function Render(animate)
            local tColor  = state and ACCENT or BORDER
            local tText   = state and TEXT_ON or TEXT
            local tStatus = state and "ON" or "OFF"
            local tStatC  = state and ACCENT or TEXT_DIM
            local tBg     = state and Color3.fromRGB(20, 10, 12) or BG_ITEM
            if animate then
                TweenService:Create(Bar,   TweenInfo.new(0.15), {BackgroundColor3 = tColor}):Play()
                TweenService:Create(Stroke,TweenInfo.new(0.15), {Color = tColor}):Play()
                TweenService:Create(Label, TweenInfo.new(0.15), {TextColor3 = tText}):Play()
                TweenService:Create(Btn,   TweenInfo.new(0.15), {BackgroundColor3 = tBg}):Play()
            else
                Bar.BackgroundColor3  = tColor
                Stroke.Color          = tColor
                Label.TextColor3      = tText
                Btn.BackgroundColor3  = tBg
            end
            StatusTxt.Text = tStatus
            StatusTxt.TextColor3 = tStatC
        end

        Render(false)

        Btn.MouseEnter:Connect(function()
            if not state then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
            end
        end)
        Btn.MouseLeave:Connect(function()
            if not state then
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
            end
        end)

        local function SetState(newState, fireCallback)
            if state == newState then return end
            state = newState
            Render(true)
            if fireCallback and callback then
                local ok, err = pcall(callback, state)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end

        Btn.MouseButton1Click:Connect(function()
            local newState = not state
            state = newState
            Render(true)
            if callback then
                local ok, err = pcall(callback, state)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)

        table.insert(ThemedElements.toggles, {
            btn = Btn, stroke = Stroke, bar = Bar, label = Label, statusTxt = StatusTxt,
            render = function() Render(false) end,
        })

        return {
            Button = Btn,
            SetState = function(v) SetState(v, true) end,
            SetStateSilent = function(v) SetState(v, false) end,
            GetState = function() return state end,
        }
    end

    local function CreateButton(name, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(name)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = ACCENT}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = ACCENT}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
            TweenService:Create(Stroke, TweenInfo.new(0.1), {Color = BORDER}):Play()
            TweenService:Create(Bar, TweenInfo.new(0.1), {BackgroundColor3 = BORDER}):Play()
        end)

        Btn.MouseButton1Click:Connect(function()
            Bar.BackgroundColor3 = TEXT_ON
            Label.TextColor3 = TEXT_ON
            task.delay(0.15, function()
                Bar.BackgroundColor3 = ACCENT
                Label.TextColor3 = TEXT
            end)
            if callback then
                local ok, err = pcall(callback)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)

        table.insert(ThemedElements.buttons, { btn = Btn, stroke = Stroke, bar = Bar, label = Label })

        return Btn
    end

    local function CreateDropdown(label, value, options, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.5, 0, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(label)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local ValueTxt = Instance.new("TextLabel")
        ValueTxt.Size = UDim2.new(0.4, 0, 1, 0)
        ValueTxt.Position = UDim2.new(0.55, 0, 0, 0)
        ValueTxt.BackgroundTransparency = 1
        ValueTxt.Text = tostring(value)
        ValueTxt.TextColor3 = TEXT_ON
        ValueTxt.Font = Enum.Font.Code
        ValueTxt.TextSize = 10
        ValueTxt.TextXAlignment = Enum.TextXAlignment.Right
        ValueTxt.Parent = Btn

        local currentValue = value

        local function updateValue(v)
            currentValue = v
            ValueTxt.Text = tostring(v)
            if callback then
                local ok, err = pcall(callback, v)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end

        local function openMenu()
            closeDropdown()
            activeDropdown = Btn
            DropdownLayer.Visible = true
            local absPos = Btn.AbsolutePosition
            local absSize = Btn.AbsoluteSize
            local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local menuWidth = math.max(absSize.X, 180)
            local rowHeight = 26
            local menuHeight = math.min(#options, 7) * rowHeight + 10
            local x = absPos.X
            if x + menuWidth > viewport.X - 8 then x = viewport.X - menuWidth - 8 end
            local y = absPos.Y + absSize.Y + 5
            if y + menuHeight > viewport.Y - 8 then y = absPos.Y - menuHeight - 5 end
            if y < 8 then y = 8 end
            DropdownMenu.Position = UDim2.fromOffset(x, y)
            DropdownMenu.Size = UDim2.fromOffset(menuWidth, menuHeight)
            DropdownMenu.Visible = true
            for i, opt in ipairs(options) do
                local o = Instance.new("TextButton")
                o.Size = UDim2.new(1, -2, 0, 23)
                o.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
                o.BorderSizePixel = 0
                o.AutoButtonColor = false
                o.Text = "  " .. tostring(opt)
                o.TextColor3 = (opt == currentValue) and ACCENT or TEXT
                o.Font = Enum.Font.Code
                o.TextSize = 10
                o.TextXAlignment = Enum.TextXAlignment.Left
                o.LayoutOrder = i
                o.ZIndex = 5003
                o.Parent = DropdownScroll
                Instance.new("UICorner", o).CornerRadius = UDim.new(0, 3)
                o.MouseEnter:Connect(function()
                    TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
                end)
                o.MouseLeave:Connect(function()
                    TweenService:Create(o, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(16, 16, 20)}):Play()
                end)
                o.MouseButton1Click:Connect(function()
                    updateValue(opt)
                    closeDropdown()
                end)
            end
        end

        Btn.MouseButton1Click:Connect(openMenu)
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_HOVER}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = BG_ITEM}):Play()
        end)

        table.insert(ThemedElements.dropdowns, { btn = Btn, stroke = Stroke, bar = Bar, label = Label, valueTxt = ValueTxt })

        return {
            Button = Btn,
            SetValue = function(v) currentValue = v; ValueTxt.Text = tostring(v) end,
            GetValue = function() return currentValue end,
            SetVisible = function(v) Btn.Visible = v end
        }
    end

    local function CreateInput(label, placeholder, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 24)
        Btn.BackgroundColor3 = BG_ITEM
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.BorderSizePixel = 0
        Btn.Parent = Scroll
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 3)

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = BORDER
        Stroke.Thickness = 1
        Stroke.Parent = Btn

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 2, 0, 12)
        Bar.Position = UDim2.new(0, 0, 0.5, -6)
        Bar.BackgroundColor3 = BORDER
        Bar.BorderSizePixel = 0
        Bar.Parent = Btn
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.4, 0, 1, 0)
        Label.Position = UDim2.new(0, 13, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = string.upper(label)
        Label.TextColor3 = TEXT
        Label.Font = Enum.Font.Code
        Label.TextSize = 10
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        local InputBox = Instance.new("TextBox")
        InputBox.Size = UDim2.new(0.5, 0, 0, 18)
        InputBox.Position = UDim2.new(0.45, 0, 0.5, -9)
        InputBox.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
        InputBox.BorderSizePixel = 0
        InputBox.Text = ""
        InputBox.PlaceholderText = placeholder
        InputBox.TextColor3 = TEXT
        InputBox.PlaceholderColor3 = TEXT_DIM
        InputBox.Font = Enum.Font.Code
        InputBox.TextSize = 10
        InputBox.ClearTextOnFocus = false
        InputBox.Parent = Btn
        Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 3)

        InputBox.FocusLost:Connect(function(enterPressed)
            if enterPressed and callback then
                local ok, err = pcall(callback, InputBox.Text)
                if not ok then warn("[Blackout] " .. tostring(err)) end
            end
        end)

        table.insert(ThemedElements.dropdowns, { btn = Btn, stroke = Stroke, bar = Bar, label = Label })

        return {
            Button = Btn,
            GetValue = function() return InputBox.Text end,
            SetValue = function(v) InputBox.Text = v end,
        }
    end

    do
        local dragging, startPos, startInput
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                startInput = input.Position
                startPos = Main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
                local d = input.Position - startInput
                Main.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
                if activeDropdown then closeDropdown() end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local minimized = false
    local MAX_CONTENT_HEIGHT = 340

    local function UpdateSize()
        local targetHeight
        if minimized then
            targetHeight = 31
        else
            local contentH = Layout.AbsoluteContentSize.Y + 16
            if contentH > MAX_CONTENT_HEIGHT then contentH = MAX_CONTENT_HEIGHT end
            targetHeight = 31 + contentH
            Scroll.Size = UDim2.new(1, 0, 0, contentH)
            Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 16)
        end
        TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(0, WIDTH, 0, targetHeight)}):Play()
    end

    MinimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MinimizeBtn.Text = minimized and "+" or "–"
        UpdateSize()
    end)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not minimized then UpdateSize() end
    end)

    task.defer(function()
        task.wait(0.05)
        UpdateSize()
    end)

    Win.CreateSection = CreateSection
    Win.CreateToggle = CreateToggle
    Win.CreateButton = CreateButton
    Win.CreateDropdown = CreateDropdown
    Win.CreateInput = CreateInput
    Win.Main = Main
    table.insert(AllWindows, Main)
    return Win
end

-- ============================================================
-- ROLE TRACKING
-- ============================================================
getgenv().BlackoutRoles = {}

local function StartRoleTracking()
    if getgenv().BlackoutRoleConnections then
        for _, c in ipairs(getgenv().BlackoutRoleConnections) do
            if c then pcall(function() c:Disconnect() end) end
        end
    end
    getgenv().BlackoutRoleConnections = {}

    table.insert(getgenv().BlackoutRoleConnections, FadeEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then getgenv().BlackoutRoles = d end
    end))
    table.insert(getgenv().BlackoutRoleConnections, DataChangedEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then getgenv().BlackoutRoles = d end
    end))
    table.insert(getgenv().BlackoutRoleConnections, RoundEndEvent.OnClientEvent:Connect(function()
        getgenv().BlackoutRoles = {}
    end))
end
StartRoleTracking()

-- ============================================================
-- OUTLINE ONLY ESP
-- ============================================================
local function StartOutlineESP()
    getgenv().PlayerOutlineObjects = {}
    getgenv().PlayerOutlineConnections = {}

    local function UpdateColor(plr, esp)
        if not esp then return end
        local c = GetRoleColor(plr)
        esp.FillColor = c
        esp.OutlineColor = c
    end

    local function CreateESP(plr)
        if plr == LocalPlayer or not plr.Character then return end
        if getgenv().PlayerOutlineObjects[plr] then getgenv().PlayerOutlineObjects[plr]:Destroy() end
        local esp = Instance.new("Highlight")
        esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.FillTransparency = 1
        esp.OutlineTransparency = 0.15
        esp.Parent = plr.Character
        UpdateColor(plr, esp)
        getgenv().PlayerOutlineObjects[plr] = esp
    end

    local function Setup(plr)
        if plr == LocalPlayer then return end
        if plr.Character then CreateESP(plr) end
        getgenv().PlayerOutlineConnections[plr] = plr.CharacterAdded:Connect(function()
            task.wait(0.5); CreateESP(plr)
        end)
    end

    for _, plr in ipairs(Players:GetPlayers()) do Setup(plr) end
    getgenv().PlayerOutlinePlayerAdded = Players.PlayerAdded:Connect(Setup)
    getgenv().PlayerOutlinePlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
        if getgenv().PlayerOutlineObjects[plr] then
            getgenv().PlayerOutlineObjects[plr]:Destroy()
            getgenv().PlayerOutlineObjects[plr] = nil
        end
        if getgenv().PlayerOutlineConnections[plr] then
            getgenv().PlayerOutlineConnections[plr]:Disconnect()
            getgenv().PlayerOutlineConnections[plr] = nil
        end
    end)

    getgenv().PlayerOutlineRefreshLoop = task.spawn(function()
        while getgenv().OutlineESPActive do
            task.wait(1)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    if not getgenv().PlayerOutlineObjects[plr] then
                        CreateESP(plr)
                    else
                        UpdateColor(plr, getgenv().PlayerOutlineObjects[plr])
                    end
                end
            end
        end
    end)
end

local function StopOutlineESP()
    for _, n in ipairs({"PlayerOutlinePlayerAdded","PlayerOutlinePlayerRemoving"}) do
        local c = getgenv()[n]
        if c then c:Disconnect(); getgenv()[n] = nil end
    end
    if getgenv().PlayerOutlineRefreshLoop then
        task.cancel(getgenv().PlayerOutlineRefreshLoop)
        getgenv().PlayerOutlineRefreshLoop = nil
    end
    if getgenv().PlayerOutlineConnections then
        for _, c in pairs(getgenv().PlayerOutlineConnections) do if c then c:Disconnect() end end
        getgenv().PlayerOutlineConnections = {}
    end
    if getgenv().PlayerOutlineObjects then
        for _, o in pairs(getgenv().PlayerOutlineObjects) do if o then pcall(function() o:Destroy() end) end end
        getgenv().PlayerOutlineObjects = {}
    end
end

-- ============================================================
-- BOX ESP
-- ============================================================
local boxESPObjects = {}

local function createBoxESP(plr)
    if plr == LocalPlayer then return end
    if boxESPObjects[plr] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = THEMES.RED.accent
    box.Thickness = boxThickness
    box.Transparency = 1
    box.Filled = false
    boxESPObjects[plr] = { box = box }
end

local function removeBoxESP(plr)
    local d = boxESPObjects[plr]
    if d and d.box then pcall(function() d.box:Remove() end) end
    boxESPObjects[plr] = nil
end

local function getCharacterCorners(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return nil end

    local up = Vector3.new(0, 1, 0)
    local look = hrp.CFrame.LookVector
    look = Vector3.new(look.X, 0, look.Z)
    if look.Magnitude < 0.01 then look = Vector3.new(0, 0, 1) end
    look = look.Unit
    local right = look:Cross(up).Unit

    local feetY = hrp.Position.Y - 3
    local topY = head.Position.Y + 0.5
    for _, name in ipairs({"RightFoot", "LeftFoot", "Right Leg", "Left Leg"}) do
        local part = char:FindFirstChild(name)
        if part then feetY = math.min(feetY, part.Position.Y) end
    end
    for _, name in ipairs({"Head"}) do
        local part = char:FindFirstChild(name)
        if part then topY = math.max(topY, part.Position.Y + 0.5) end
    end

    local height = topY - feetY
    local width = 2.5
    local halfW = width / 2
    local halfH = height / 2
    local halfD = 1.25
    local center = Vector3.new(hrp.Position.X, feetY + halfH, hrp.Position.Z)

    local corners = {}
    for _, sx in ipairs({-1, 1}) do
        for _, sy in ipairs({-1, 1}) do
            for _, sz in ipairs({-1, 1}) do
                local offset = right * (halfW * sx) + up * (halfH * sy) + look * (halfD * sz)
                table.insert(corners, center + offset)
            end
        end
    end
    return corners
end

local function updateBoxESP()
    for plr, d in pairs(boxESPObjects) do
        if not boxEnabled then
            d.box.Visible = false
        elseif plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local corners = getCharacterCorners(char)
                if corners then
                    local cam = workspace.CurrentCamera
                    local minX, minY = math.huge, math.huge
                    local maxX, maxY = -math.huge, -math.huge
                    local anyVisible = false
                    for _, worldPos in ipairs(corners) do
                        local sp, onScreen = cam:WorldToViewportPoint(worldPos)
                        if sp.Z > 0 then
                            if onScreen then anyVisible = true end
                            if sp.X < minX then minX = sp.X end
                            if sp.Y < minY then minY = sp.Y end
                            if sp.X > maxX then maxX = sp.X end
                            if sp.Y > maxY then maxY = sp.Y end
                        end
                    end
                    if anyVisible and minX < maxX and minY < maxY then
                        local pad = 2
                        d.box.Size = Vector2.new((maxX - minX) + pad * 2, (maxY - minY) + pad * 2)
                        d.box.Position = Vector2.new(minX - pad, minY - pad)
                        d.box.Color = GetRoleColor(plr)
                        d.box.Thickness = boxThickness
                        d.box.Visible = true
                    else
                        d.box.Visible = false
                    end
                else
                    d.box.Visible = false
                end
            else
                d.box.Visible = false
            end
        else
            d.box.Visible = false
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createBoxESP(plr) end
Players.PlayerAdded:Connect(createBoxESP)
Players.PlayerRemoving:Connect(removeBoxESP)

-- ============================================================
-- HEALTH BAR ESP
-- ============================================================
local healthBarObjects = {}

local function createHealthBarESP(plr)
    if plr == LocalPlayer then return end
    if healthBarObjects[plr] then return end
    local outline = Drawing.new("Square")
    outline.Visible = false
    outline.Filled = false
    outline.Color = Color3.fromRGB(0, 0, 0)
    outline.Thickness = 1
    outline.Transparency = 1

    local fill = Drawing.new("Square")
    fill.Visible = false
    fill.Filled = true
    fill.Color = Color3.fromRGB(0, 255, 0)
    fill.Thickness = 0
    fill.Transparency = 1

    healthBarObjects[plr] = { outline = outline, fill = fill }
end

local function removeHealthBarESP(plr)
    local d = healthBarObjects[plr]
    if d then
        pcall(function() d.outline:Remove() end)
        pcall(function() d.fill:Remove() end)
    end
    healthBarObjects[plr] = nil
end

local function updateHealthBarESP()
    for plr, d in pairs(healthBarObjects) do
        local shouldShow = healthBarEnabled and boxEnabled
        if shouldShow and plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local corners = getCharacterCorners(char)
                if corners then
                    local cam = workspace.CurrentCamera
                    local minX, minY = math.huge, math.huge
                    local maxX, maxY = -math.huge, -math.huge
                    local anyVisible = false
                    for _, worldPos in ipairs(corners) do
                        local sp, onScreen = cam:WorldToViewportPoint(worldPos)
                        if sp.Z > 0 then
                            if onScreen then anyVisible = true end
                            if sp.X < minX then minX = sp.X end
                            if sp.Y < minY then minY = sp.Y end
                            if sp.X > maxX then maxX = sp.X end
                            if sp.Y > maxY then maxY = sp.Y end
                        end
                    end
                    if anyVisible and minX < maxX and minY < maxY then
                        local barWidth = 3
                        local barHeight = (maxY - minY)
                        local barX = maxX + 4
                        local barY = minY
                        local hpFraction = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        d.outline.Size = Vector2.new(barWidth + 2, barHeight + 2)
                        d.outline.Position = Vector2.new(barX - 1, barY - 1)
                        d.outline.Visible = true

                        local fillHeight = barHeight * hpFraction
                        d.fill.Size = Vector2.new(barWidth, fillHeight)
                        d.fill.Position = Vector2.new(barX, barY + (barHeight - fillHeight))
                        if hpFraction > 0.6 then
                            d.fill.Color = Color3.fromRGB(65, 220, 125)
                        elseif hpFraction > 0.3 then
                            d.fill.Color = Color3.fromRGB(245, 205, 55)
                        else
                            d.fill.Color = Color3.fromRGB(255, 45, 65)
                        end
                        d.fill.Visible = true
                    else
                        d.outline.Visible = false
                        d.fill.Visible = false
                    end
                else
                    d.outline.Visible = false
                    d.fill.Visible = false
                end
            else
                d.outline.Visible = false
                d.fill.Visible = false
            end
        else
            d.outline.Visible = false
            d.fill.Visible = false
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createHealthBarESP(plr) end
Players.PlayerAdded:Connect(createHealthBarESP)
Players.PlayerRemoving:Connect(removeHealthBarESP)

-- ============================================================
-- SKELETON ESP
-- ============================================================
local skeletonESPObjects = {}

local SKELETON_BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local SKELETON_BONES_R15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local function createSkeletonESP(plr)
    if plr == LocalPlayer then return end
    if skeletonESPObjects[plr] then return end
    local lines = {}
    for i = 1, 16 do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255, 255, 255)
        line.Thickness = skeletonThickness
        line.Transparency = 1
        lines[i] = line
    end
    skeletonESPObjects[plr] = { lines = lines, bones = nil }
end

local function removeSkeletonESP(plr)
    local d = skeletonESPObjects[plr]
    if d then
        for _, line in ipairs(d.lines) do
            pcall(function() line:Remove() end)
        end
    end
    skeletonESPObjects[plr] = nil
end

local function resolveBones(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    local pairsList = hum and hum.RigType == Enum.HumanoidRigType.R15 and SKELETON_BONES_R15 or SKELETON_BONES_R6
    local bones = {}
    for _, pair in ipairs(pairsList) do
        local a, b = char:FindFirstChild(pair[1]), char:FindFirstChild(pair[2])
        if a and b then
            table.insert(bones, {a, b})
        end
    end
    return bones
end

local function updateSkeletonESP()
    for plr, d in pairs(skeletonESPObjects) do
        if not skeletonEnabled then
            for _, line in ipairs(d.lines) do line.Visible = false end
        elseif plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                if not d.bones or d.bonesChar ~= char then
                    d.bones = resolveBones(char)
                    d.bonesChar = char
                end
                local cam = workspace.CurrentCamera
                local color = GetRoleColor(plr)
                for i, line in ipairs(d.lines) do
                    local bone = d.bones[i]
                    if bone then
                        local a, b = bone[1], bone[2]
                        local pa, oa = cam:WorldToViewportPoint(a.Position)
                        local pb, ob = cam:WorldToViewportPoint(b.Position)
                        if oa and ob and pa.Z > 0 and pb.Z > 0 then
                            line.From = Vector2.new(pa.X, pa.Y)
                            line.To = Vector2.new(pb.X, pb.Y)
                            line.Color = color
                            line.Thickness = skeletonThickness
                            line.Visible = true
                        else
                            line.Visible = false
                        end
                    else
                        line.Visible = false
                    end
                end
            else
                for _, line in ipairs(d.lines) do line.Visible = false end
            end
        else
            for _, line in ipairs(d.lines) do line.Visible = false end
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createSkeletonESP(plr) end
Players.PlayerAdded:Connect(createSkeletonESP)
Players.PlayerRemoving:Connect(removeSkeletonESP)

-- ============================================================
-- TRACER ESP
-- ============================================================
local tracerESPObjects = {}

local function createTracerESP(plr)
    if plr == LocalPlayer then return end
    if tracerESPObjects[plr] then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = THEMES.RED.accent
    line.Thickness = 1
    line.Transparency = 1
    tracerESPObjects[plr] = { line = line }
end

local function removeTracerESP(plr)
    local d = tracerESPObjects[plr]
    if d and d.line then pcall(function() d.line:Remove() end) end
    tracerESPObjects[plr] = nil
end

local function updateTracerESP()
    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    for plr, d in pairs(tracerESPObjects) do
        if not tracerEnabled then
            d.line.Visible = false
        elseif plr.Character then
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
                local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen and screenPos.Z > 0 then
                    local origin
                    if tracerOrigin == "Bottom" then
                        origin = Vector2.new(viewport.X / 2, viewport.Y)
                    elseif tracerOrigin == "Top" then
                        origin = Vector2.new(viewport.X / 2, 0)
                    else
                        local m = UserInputService:GetMouseLocation()
                        origin = Vector2.new(m.X, m.Y)
                    end
                    d.line.From = origin
                    d.line.To = Vector2.new(screenPos.X, screenPos.Y)
                    d.line.Color = GetRoleColor(plr)
                    d.line.Visible = true
                else
                    d.line.Visible = false
                end
            else
                d.line.Visible = false
            end
        else
            d.line.Visible = false
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createTracerESP(plr) end
Players.PlayerAdded:Connect(createTracerESP)
Players.PlayerRemoving:Connect(removeTracerESP)

-- ============================================================
-- NAME ESP
-- ============================================================
local nameESPObjects = {}

local function createNameESP(plr)
    if plr == LocalPlayer then return end
    if nameESPObjects[plr] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 40)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = ScreenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0
    label.TextSize = 14
    label.Font = Enum.Font.ArialBold
    label.Text = plr.Name
    label.Parent = billboard

    nameESPObjects[plr] = { gui = billboard, label = label }
end

local function removeNameESP(plr)
    local d = nameESPObjects[plr]
    if d and d.gui then d.gui:Destroy() end
    nameESPObjects[plr] = nil
end

local function updateNameESP()
    for plr, d in pairs(nameESPObjects) do
        if not nameESPEnabled then
            d.gui.Enabled = false
        elseif plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                d.gui.Adornee = head
                d.gui.Enabled = true
                d.label.Text = plr.DisplayName or plr.Name
                d.label.TextColor3 = GetRoleColor(plr)
            else
                d.gui.Enabled = false
            end
        else
            d.gui.Enabled = false
        end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do createNameESP(plr) end
Players.PlayerAdded:Connect(createNameESP)
Players.PlayerRemoving:Connect(removeNameESP)

-- ============================================================
-- AIMBOT
-- ============================================================
local function getClosestPlayerInFOV()
    local cam = workspace.CurrentCamera
    local viewport = cam.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local best, bestDist = nil, aimbotFOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                -- Target filter
                if aimbotTarget == "Murderer" then
                    local hasKnife = plr.Character:FindFirstChild("Knife") or
                        (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
                    if not hasKnife then continue end
                end
                local part = plr.Character:FindFirstChild(aimbotPart)
                    or plr.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local sp, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen and sp.Z > 0 then
                        local dx, dy = sp.X - center.X, sp.Y - center.Y
                        local d = math.sqrt(dx * dx + dy * dy)
                        if d < bestDist then
                            bestDist = d
                            best = part
                        end
                    end
                end
            end
        end
    end
    return best
end

local function runAimbot()
    if not aimbotEnabled or not aiming then return end
    local target = getClosestPlayerInFOV()
    if not target then return end
    local cam = workspace.CurrentCamera
    local desired = CFrame.new(cam.CFrame.Position, target.Position)
    local alpha = math.clamp(aimbotSmoothing, 0.01, 1)
    cam.CFrame = cam.CFrame:Lerp(desired, alpha)
end

local function isAimInput(input)
    if aimbotKey == "Right Click" then
        return input.UserInputType == Enum.UserInputType.MouseButton2
    elseif aimbotKey == "Left Alt" then
        return input.KeyCode == Enum.KeyCode.LeftAlt
    elseif aimbotKey == "Left Shift" then
        return input.KeyCode == Enum.KeyCode.LeftShift
    elseif aimbotKey == "Q" then
        return input.KeyCode == Enum.KeyCode.Q
    elseif aimbotKey == "F" then
        return input.KeyCode == Enum.KeyCode.F
    elseif aimbotKey == "C" then
        return input.KeyCode == Enum.KeyCode.C
    elseif aimbotKey == "V" then
        return input.KeyCode == Enum.KeyCode.V
    elseif aimbotKey == "X" then
        return input.KeyCode == Enum.KeyCode.X
    elseif aimbotKey == "Z" then
        return input.KeyCode == Enum.KeyCode.Z
    elseif aimbotKey == "E" then
        return input.KeyCode == Enum.KeyCode.E
    end
    return false
end

-- ============================================================
-- KILL AURA
-- ============================================================
local killAuraConnection = nil

local function startKillAura()
    if killAuraConnection then killAuraConnection:Disconnect() end
    killAuraConnection = RunService.RenderStepped:Connect(function()
        if not killAuraEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local tool = char:FindFirstChildOfClass("Tool")
        if not hrp or not tool then return end
        if tool.Name ~= "Knife" then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and (targetHRP.Position - hrp.Position).Magnitude <= killAuraRange then
                    pcall(function() tool:Activate() end)
                end
            end
        end
    end)
end

local function stopKillAura()
    if killAuraConnection then
        killAuraConnection:Disconnect()
        killAuraConnection = nil
    end
end

-- ============================================================
-- FAST THROW
-- ============================================================
local function StartFastThrow()
    if fastThrowConnection then fastThrowConnection:Disconnect() end
    fastThrowConnection = RunService.RenderStepped:Connect(function()
        if not fastThrowEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if not tool then return end
        if tool.Name ~= "Knife" then return end
        pcall(function() tool:Activate() end)
        task.wait(fastThrowDelay)
    end)
end

local function StopFastThrow()
    if fastThrowConnection then
        fastThrowConnection:Disconnect()
        fastThrowConnection = nil
    end
end

-- ============================================================
-- FLING — WeAreDevs spin fling + TP on top + return
-- ============================================================
local flingActive = false
local flingTarget = nil
local flingBV = nil
local flingConn = nil
local flingOrigCF = nil
local flingOriginalCanCollide = {}

local function CleanupFling()
    if flingBV then
        pcall(function() flingBV:Destroy() end)
        flingBV = nil
    end
    if flingConn then
        pcall(function() flingConn:Disconnect() end)
        flingConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function() hum.PlatformStand = false end)
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.GettingUp) end)
        end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Parent then
            pcall(function()
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end)
            if flingOrigCF then
                hrp.CFrame = flingOrigCF
            end
        end
        for part, val in pairs(flingOriginalCanCollide) do
            if part and part.Parent then
                pcall(function() part.CanCollide = val end)
            end
        end
        flingOriginalCanCollide = {}
    end
    flingActive = false
    flingTarget = nil
    flingOrigCF = nil
end

local function StopFling()
    CleanupFling()
end

local function FlingPlayer(targetPlayer)
    if flingActive then
        CleanupFling()
        task.wait(0.05)
    end
    if not targetPlayer or not targetPlayer.Character then return end
    local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flingActive = true
    flingTarget = targetPlayer
    flingOrigCF = hrp.CFrame

    flingOriginalCanCollide = {}
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            flingOriginalCanCollide[v] = v.CanCollide
            v.CanCollide = false
            v.Massless = true
            v.Velocity = Vector3.zero
        end
    end

    pcall(function() hum.PlatformStand = true end)

    hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)

    local bv = Instance.new("BodyAngularVelocity")
    bv.Name = "FlingBV"
    bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bv.P = math.huge
    bv.AngularVelocity = Vector3.new(0, 9e5, 0)
    bv.Parent = hrp
    flingBV = bv

    flingConn = RunService.Stepped:Connect(function()
        if not flingActive then return end
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)

    task.spawn(function()
        local t0 = tick()
        while flingActive and tick() - t0 < 2.5 do
            if flingTarget and flingTarget.Character then
                local tHRP = flingTarget.Character:FindFirstChild("HumanoidRootPart")
                if tHRP and hrp and hrp.Parent then
                    hrp.CFrame = tHRP.CFrame + Vector3.new(0, 3, 0)
                    hrp.AssemblyLinearVelocity = Vector3.zero
                end
            end
            RunService.Heartbeat:Wait()
        end
        CleanupFling()
    end)
end

local function FlingByName(name)
    if not name or name == "" then return end
    local lower = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if plr.Name:lower():find(lower, 1, true) or (plr.DisplayName or ""):lower():find(lower, 1, true) then
                FlingPlayer(plr)
                return
            end
        end
    end
    warn("[Fling] No player found: " .. name)
end

local function FlingMurderer()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasKnife = plr.Character:FindFirstChild("Knife") or
                (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                FlingPlayer(plr)
                return
            end
        end
    end
    warn("[Fling] No murderer in round")
end

local function FlingSheriff()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasGun = plr.Character:FindFirstChild("Gun") or
                (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
            if hasGun then
                FlingPlayer(plr)
                return
            end
        end
    end
    warn("[Fling] No sheriff in round")
end

-- ============================================================
-- COIN FARM
-- ============================================================
local function startCoinFarm()
    if coinFarmConnection then coinFarmConnection:Disconnect() end
    coinFarmConnection = task.spawn(function()
        local collected = {}
        while coinFarmEnabled do
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local nearest = nil
                    local nearestDist = math.huge
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
                            if not collected[obj] and obj.Parent then
                                local d = (obj.Position - hrp.Position).Magnitude
                                if d < nearestDist and d < 500 then
                                    nearestDist = d
                                    nearest = obj
                                end
                            end
                        end
                    end
                    if nearest then
                        collected[nearest] = true
                        task.wait(coinFarmWarmup)
                        hrp.CFrame = CFrame.new(nearest.Position)
                        task.wait(coinFarmSpeed)
                    else
                        collected = {}
                        task.wait(0.5)
                    end
                else
                    task.wait(0.4)
                end
            else
                task.wait(0.5)
            end
        end
    end)
end

local function stopCoinFarm()
    coinFarmEnabled = false
    if coinFarmConnection then
        task.cancel(coinFarmConnection)
        coinFarmConnection = nil
    end
end

-- ============================================================
-- GUN DROP ESP
-- ============================================================
local function StartGunDropESP()
    local GunDropColor = Color3.fromRGB(255, 60, 60)
    local currentHighlight
    local function OnAdded(obj)
        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
            if currentHighlight then currentHighlight:Destroy() end
            currentHighlight = Instance.new("Highlight")
            currentHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            currentHighlight.FillTransparency = 0.5
            currentHighlight.OutlineTransparency = 1
            currentHighlight.FillColor = GunDropColor
            currentHighlight.OutlineColor = GunDropColor
            currentHighlight.Parent = obj
            obj.Destroying:Connect(function()
                if currentHighlight then
                    currentHighlight:Destroy()
                    currentHighlight = nil
                end
            end)
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "GunDrop" and obj:IsA("BasePart") then
            OnAdded(obj); break
        end
    end
    getgenv().GunDropConnection = Workspace.DescendantAdded:Connect(OnAdded)
    getgenv().GunDropHighlight = currentHighlight
end

local function StopGunDropESP()
    if getgenv().GunDropConnection then
        getgenv().GunDropConnection:Disconnect()
        getgenv().GunDropConnection = nil
    end
    if getgenv().GunDropHighlight then
        getgenv().GunDropHighlight:Destroy()
        getgenv().GunDropHighlight = nil
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "GunDrop" then
            local h = obj:FindFirstChildOfClass("Highlight")
            if h then h:Destroy() end
        end
    end
end

-- ============================================================
-- AUTO GRAB GUN
-- ============================================================
local function StartAutoGrab()
    getgenv().AutoGrabGunConnection = Workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "GunDrop" then
            for _, item in pairs(LocalPlayer.Character:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find("knife") then return end
            end
            task.wait(0.1)
            for _, part in pairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part.Name:lower():find("fire") or part.Name:lower():find("flame") then
                    part:Destroy()
                end
            end
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then obj:PivotTo(hrp.CFrame) end
        end
    end)
end

local function StopAutoGrab()
    if getgenv().AutoGrabGunConnection then
        getgenv().AutoGrabGunConnection:Disconnect()
        getgenv().AutoGrabGunConnection = nil
    end
end

-- ============================================================
-- TRIGGERBOT / SILENT AIM
-- ============================================================
local function StartTriggerbot()
    getgenv().TriggerbotActive = true
    task.spawn(function()
        while getgenv().TriggerbotActive do
            local char = LocalPlayer.Character
            if not char then task.wait() continue end
            local gun = char:FindFirstChild("Gun") or char:FindFirstChild("Revolver")
            if not gun then task.wait() continue end
            local originCF
            local gs = gun:FindFirstChild("GunServer")
            if gs then
                local att = gs:FindFirstChild("GunRaycastAttachment1") or gs:FindFirstChild("RaycastAttachment")
                if att then originCF = att.WorldCFrame end
            end
            if not originCF then
                local h = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
                if h and h:IsA("BasePart") then originCF = h.CFrame end
            end
            if not originCF then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then task.wait() continue end
                originCF = hrp.CFrame
            end
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Target
            if not target then task.wait() continue end
            local targetModel = target:FindFirstAncestorOfClass("Model")
            if not targetModel then task.wait() continue end
            local targetPlayer = Players:GetPlayerFromCharacter(targetModel)
            if not targetPlayer or targetPlayer == LocalPlayer then task.wait() continue end
            local hasKnife = targetModel:FindFirstChild("Knife") or
                (targetPlayer.Backpack and targetPlayer.Backpack:FindFirstChild("Knife"))
            if not hasKnife then task.wait() continue end
            local targetHRP = targetModel:FindFirstChild("HumanoidRootPart")
            if not targetHRP then task.wait() continue end
            local rp = RaycastParams.new()
            rp.FilterType = Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances = {char}
            local dir = (targetHRP.Position - originCF.Position).Unit * 1000
            local res = workspace:Raycast(originCF.Position, dir, rp)
            if not res or not res.Instance:IsDescendantOf(targetModel) then task.wait() continue end
            local remote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
            if not remote then task.wait() continue end
            remote:FireServer(
                CFrame.new(originCF.Position, targetHRP.Position),
                CFrame.new(targetHRP.Position)
            )
            task.wait(0.05)
        end
    end)
end

local function StopTriggerbot()
    getgenv().TriggerbotActive = false
end

getgenv().SilentAimActive = false

local function FireSilentAim()
    local char = LocalPlayer.Character
    if not char then return end
    local gun = char:FindFirstChild("Gun")
    if not gun then return end
    local originCF
    local gunServer = gun:FindFirstChild("GunServer")
    if gunServer then
        local att = gunServer:FindFirstChild("GunRaycastAttachment1") or gunServer:FindFirstChild("RaycastAttachment")
        if att then originCF = att.WorldCFrame end
    end
    if not originCF then
        local handle = gun:FindFirstChild("Handle") or gun:FindFirstChild("Gun")
        if handle and handle:IsA("BasePart") then originCF = handle.CFrame end
    end
    if not originCF then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        originCF = hrp.CFrame
    end
    local targetPlayer, targetHRP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasKnife = plr.Character:FindFirstChild("Knife") or
                (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then targetPlayer = plr; targetHRP = hrp; break end
            end
        end
    end
    if not targetPlayer then return end
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Exclude
    rp.FilterDescendantsInstances = {char}
    local res = workspace:Raycast(originCF.Position, (targetHRP.Position - originCF.Position).Unit * 1000, rp)
    if not res or not res.Instance:IsDescendantOf(targetPlayer.Character) then return end
    local shootRemote = gun:FindFirstChild("Shoot") or gun:FindFirstChild("Fire")
    if shootRemote then
        shootRemote:FireServer(
            CFrame.new(originCF.Position, targetHRP.Position),
            CFrame.new(targetHRP.Position)
        )
    end
end

-- ============================================================
-- MOVEMENT / UTILITY
-- ============================================================
local function StartNoclip()
    if getgenv().NoclipConnection then getgenv().NoclipConnection:Disconnect() end
    getgenv().NoclipConnection = RunService.RenderStepped:Connect(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function StopNoclip()
    if getgenv().NoclipConnection then
        getgenv().NoclipConnection:Disconnect()
        getgenv().NoclipConnection = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end

getgenv().CoinKeybind = Enum.KeyCode.C

local function CollectCoins()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name == "Coin_Server" and obj:IsA("BasePart") then
            obj.CFrame = hrp.CFrame
        end
    end
end

local function StartFullbright()
    getgenv().FB_Ambient = Lighting.Ambient
    getgenv().FB_Outdoor = Lighting.OutdoorAmbient
    getgenv().FB_Clock = Lighting.ClockTime
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.ClockTime = 12
end

local function StopFullbright()
    Lighting.Ambient = getgenv().FB_Ambient or Color3.fromRGB(70, 70, 70)
    Lighting.OutdoorAmbient = getgenv().FB_Outdoor or Color3.fromRGB(70, 70, 70)
    Lighting.ClockTime = getgenv().FB_Clock or 14
end

local function StartPerfMode()
    getgenv().Perf_Shadows = Lighting.GlobalShadows
    Lighting.GlobalShadows = false
    for _, d in pairs(Workspace:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire")
        or d:IsA("Smoke") or d:IsA("Sparkles") then
            d.Enabled = false
        end
    end
end

local function StopPerfMode()
    Lighting.GlobalShadows = getgenv().Perf_Shadows ~= false
    for _, d in pairs(Workspace:GetDescendants()) do
        if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire")
        or d:IsA("Smoke") or d:IsA("Sparkles") then
            d.Enabled = true
        end
    end
end

local function TpToRandomPlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then table.insert(candidates, targetHRP) end
        end
    end
    if #candidates == 0 then return end
    local target = candidates[math.random(1, #candidates)]
    hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
end

local function TpToSheriff()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasGun = plr.Character:FindFirstChild("Gun") or
                (plr.Backpack and plr.Backpack:FindFirstChild("Gun"))
            if hasGun then
                local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end
end

local function TpToMurderer()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hasKnife = plr.Character:FindFirstChild("Knife") or
                (plr.Backpack and plr.Backpack:FindFirstChild("Knife"))
            if hasKnife then
                local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    hrp.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
                    return
                end
            end
        end
    end
end

local function StartInfJump()
    if getgenv().InfJumpConn then getgenv().InfJumpConn:Disconnect() end
    getgenv().InfJumpConn = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end

local function StopInfJump()
    if getgenv().InfJumpConn then
        getgenv().InfJumpConn:Disconnect()
        getgenv().InfJumpConn = nil
    end
end

getgenv().FlySpeed = 50

local function StartFly()
    if getgenv().FlyConn then getgenv().FlyConn:Disconnect() end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1, 1, 1) * 1e6
    bv.Parent = char.HumanoidRootPart
    getgenv().FlyBV = bv
    getgenv().FlyConn = RunService.RenderStepped:Connect(function()
        local move = Vector3.zero
        local cam = workspace.CurrentCamera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
        bv.Velocity = move * getgenv().FlySpeed
    end)
end

local function StopFly()
    if getgenv().FlyConn then
        getgenv().FlyConn:Disconnect()
        getgenv().FlyConn = nil
    end
    if getgenv().FlyBV then
        getgenv().FlyBV:Destroy()
        getgenv().FlyBV = nil
    end
end

local function StartAutoBarriers()
    if getgenv().BarrierAutoConn then getgenv().BarrierAutoConn:Disconnect() end
    local function Process(obj)
        if obj:IsA("BasePart") and not obj:IsA("TrussPart") then
            if obj.Name == "GlitchProof" then
                obj.CanCollide = false
                return
            end
            if obj.Transparency == 1 and math.abs(obj.CFrame.UpVector.Y) < 0.5 then
                obj.CanCollide = false
            end
        end
    end
    for _, obj in pairs(Workspace:GetDescendants()) do Process(obj) end
    getgenv().BarrierAutoConn = Workspace.DescendantAdded:Connect(Process)
end

local function StopAutoBarriers()
    if getgenv().BarrierAutoConn then
        getgenv().BarrierAutoConn:Disconnect()
        getgenv().BarrierAutoConn = nil
    end
end

local function StartInvisible()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = 1
        end
    end
    getgenv().InvisConn = char.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") then
            d.LocalTransparencyModifier = 1
        end
    end)
end

local function StopInvisible()
    if getgenv().InvisConn then
        getgenv().InvisConn:Disconnect()
        getgenv().InvisConn = nil
    end
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end

-- ============================================================
-- SILENT AIM LOOP CONTROL
-- ============================================================
local function StartSilentAimLoop()
    if silentAimLoop then task.cancel(silentAimLoop) end
    silentAimLoop = task.spawn(function()
        while getgenv().SilentAimActive do
            pcall(FireSilentAim)
            task.wait(0.15)
        end
        silentAimLoop = nil
    end)
end

local function StopSilentAimLoop()
    getgenv().SilentAimActive = false
    if silentAimLoop then
        task.cancel(silentAimLoop)
        silentAimLoop = nil
    end
end

-- ============================================================
-- RUN LOADER, THEN BUILD PANELS
-- ============================================================
RunLoadingSequence()

-- ============================================================
-- PANEL 1 — VISUALS
-- ============================================================
local MainPanel = CreateWindow("BLACKOUT // VISUALS", 20, 20)

MainPanel.CreateSection("esp")
MainPanel.CreateToggle("Outline Only", true, function(s)
    getgenv().OutlineESPActive = s
    if s then StartOutlineESP() else StopOutlineESP() end
end)
MainPanel.CreateToggle("Name ESP", true, function(s)
    nameESPEnabled = s
end)
MainPanel.CreateToggle("Gun Drop ESP", false, function(s)
    if s then StartGunDropESP() else StopGunDropESP() end
end)

MainPanel.CreateSection("esp options")
MainPanel.CreateToggle("Skeleton ESP", true, function(s)
    skeletonEnabled = s
end)
MainPanel.CreateToggle("Box ESP", false, function(s)
    boxEnabled = s
end)
MainPanel.CreateToggle("Tracers", false, function(s)
    tracerEnabled = s
end)
MainPanel.CreateToggle("Health Bar", false, function(s)
    healthBarEnabled = s
end)

MainPanel.CreateSection("esp tweaks")
MainPanel.CreateDropdown("BOX THICKNESS", 1.5,
    {1, 1.5, 2, 2.5, 3, 4}, function(v)
    boxThickness = tonumber(v) or boxThickness
end)
MainPanel.CreateDropdown("SKELETON THICKNESS", 1,
    {1, 1.5, 2, 2.5, 3}, function(v)
    skeletonThickness = tonumber(v) or skeletonThickness
end)
MainPanel.CreateDropdown("TRACER ORIGIN", "Bottom",
    {"Bottom", "Top", "Mouse"}, function(v)
    tracerOrigin = v
end)

MainPanel.CreateSection("misc")
MainPanel.CreateToggle("Coin Collect [C]", false, function(s)
    getgenv().CoinKeybindActive = s
end)

-- ============================================================
-- PANEL 2 — UTILITY
-- ============================================================
local UtilityPanel = CreateWindow("BLACKOUT // UTILITY", 260, 20)

UtilityPanel.CreateSection("lighting")
UtilityPanel.CreateToggle("Fullbright", false, function(s)
    if s then StartFullbright() else StopFullbright() end
end)
UtilityPanel.CreateToggle("Performance Mode", false, function(s)
    if s then StartPerfMode() else StopPerfMode() end
end)

UtilityPanel.CreateSection("movement")
UtilityPanel.CreateToggle("Noclip", false, function(s)
    if s then StartNoclip() else StopNoclip() end
end)
UtilityPanel.CreateToggle("Infinite Jump", false, function(s)
    if s then StartInfJump() else StopInfJump() end
end)
UtilityPanel.CreateToggle("Fly", false, function(s)
    if s then StartFly() else StopFly() end
end)
UtilityPanel.CreateButton("TP to Random Player", function()
    TpToRandomPlayer()
end)
UtilityPanel.CreateButton("TP to Sheriff", function()
    TpToSheriff()
end)
UtilityPanel.CreateButton("TP to Murderer", function()
    TpToMurderer()
end)

UtilityPanel.CreateSection("utility")
UtilityPanel.CreateToggle("Remove Barriers", false, function(s)
    if s then StartAutoBarriers() else StopAutoBarriers() end
end)
UtilityPanel.CreateToggle("Invisible", false, function(s)
    if s then StartInvisible() else StopInvisible() end
end)

-- ============================================================
-- PANEL 3 — COMBAT
-- ============================================================
local CombatPanel = CreateWindow("BLACKOUT // COMBAT", 500, 20)

CombatPanel.CreateSection("combat")
CombatPanel.CreateToggle("Auto Grab Gun", false, function(s)
    if s then StartAutoGrab() else StopAutoGrab() end
end)

triggerbotToggleRef = CombatPanel.CreateToggle("Triggerbot", false, function(s)
    if s then
        if getgenv().SilentAimActive then
            if silentAimToggleRef then
                silentAimToggleRef.SetStateSilent(false)
            end
            StopSilentAimLoop()
        end
        StartTriggerbot()
    else
        StopTriggerbot()
    end
end)

silentAimToggleRef = CombatPanel.CreateToggle("Silent Aim", false, function(s)
    if s then
        if getgenv().TriggerbotActive then
            if triggerbotToggleRef then
                triggerbotToggleRef.SetStateSilent(false)
            end
            StopTriggerbot()
        end
        getgenv().SilentAimActive = true
        StartSilentAimLoop()
    else
        StopSilentAimLoop()
    end
end)

CombatPanel.CreateToggle("Kill Aura", false, function(s)
    killAuraEnabled = s
    if s then startKillAura() else stopKillAura() end
end)
CombatPanel.CreateDropdown("AURA RANGE", 15,
    {8, 10, 12, 15, 18, 20, 25, 30}, function(v)
    killAuraRange = tonumber(v) or killAuraRange
end)

CombatPanel.CreateSection("fast throw")
CombatPanel.CreateToggle("Fast Throw", false, function(s)
    fastThrowEnabled = s
    if s then StartFastThrow() else StopFastThrow() end
end)
CombatPanel.CreateDropdown("THROW SPEED", 0.05,
    {0.01, 0.02, 0.03, 0.05, 0.08, 0.1, 0.15}, function(v)
    fastThrowDelay = tonumber(v) or fastThrowDelay
end)

CombatPanel.CreateSection("fling")
CombatPanel.CreateInput("FLING TARGET", "username", function(v)
    flingTargetName = v
end)
CombatPanel.CreateButton("Fling Target", function()
    FlingByName(flingTargetName)
end)
CombatPanel.CreateButton("Fling Murderer", function()
    FlingMurderer()
end)
CombatPanel.CreateButton("Fling Sheriff", function()
    FlingSheriff()
end)
CombatPanel.CreateButton("Stop Fling", function()
    StopFling()
end)

CombatPanel.CreateSection("aimbot")
CombatPanel.CreateToggle("Aimbot", false, function(s)
    aimbotEnabled = s
    if not s then aiming = false end
end)
CombatPanel.CreateDropdown("AIM KEY", "Right Click",
    {"Right Click", "Left Alt", "Left Shift", "Q", "F", "C", "V", "X", "Z", "E"}, function(v)
    aimbotKey = v
    aiming = false
end)
CombatPanel.CreateDropdown("AIM PART", "Head",
    {"Head", "UpperTorso", "HumanoidRootPart"}, function(v)
    aimbotPart = v
end)
CombatPanel.CreateDropdown("AIM TARGET", "Murderer",
    {"All", "Murderer"}, function(v)
    aimbotTarget = v
end)
CombatPanel.CreateDropdown("AIM SMOOTHING", 0.2,
    {0.05, 0.1, 0.15, 0.2, 0.3, 0.5, 0.75, 1}, function(v)
    aimbotSmoothing = tonumber(v) or aimbotSmoothing
end)
CombatPanel.CreateDropdown("AIM FOV", 150,
    {50, 75, 100, 125, 150, 200, 250, 350}, function(v)
    aimbotFOV = tonumber(v) or aimbotFOV
end)

-- ============================================================
-- PANEL 4 — FARMING
-- ============================================================
local FarmPanel = CreateWindow("BLACKOUT // FARMING", 740, 20)

FarmPanel.CreateSection("coin farm")
FarmPanel.CreateToggle("Auto Coin Farm", false, function(s)
    coinFarmEnabled = s
    if s then startCoinFarm() else stopCoinFarm() end
end)
FarmPanel.CreateDropdown("FARM SPEED", 1,
    {1, 2}, function(v)
    coinFarmSpeed = tonumber(v) or coinFarmSpeed
end)
FarmPanel.CreateDropdown("WARMUP DELAY", 0.25,
    {0.1, 0.15, 0.2, 0.25, 0.3, 0.4, 0.5}, function(v)
    coinFarmWarmup = tonumber(v) or coinFarmWarmup
end)

FarmPanel.CreateButton("Teleport to Lobby", function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local spawns = Workspace:FindFirstChild("Spawns")
    if spawns then
        for _, obj in ipairs(spawns:GetDescendants()) do
            if obj:IsA("SpawnLocation") then
                hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                return
            end
        end
    end
end)

FarmPanel.CreateButton("Teleport to Map", function()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local spawns = Workspace:FindFirstChild("Spawns")
    if spawns then
        for _, obj in ipairs(spawns:GetDescendants()) do
            if obj.Name == "Spawn" and obj:IsA("BasePart") and not obj:IsA("SpawnLocation") then
                hrp.CFrame = obj.CFrame + Vector3.new(0, 5, 0)
                return
            end
        end
    end
end)

-- ============================================================
-- PANEL 5 — THEME
-- ============================================================
local ThemePanel = CreateWindow("BLACKOUT // THEME", 980, 20)

ThemePanel.CreateSection("theme")
ThemePanel.CreateDropdown("THEME COLOR", "RED",
    {"RED", "PURPLE", "BLUE", "GREEN", "ORANGE", "PINK", "WHITE"}, function(v)
    ApplyTheme(v)
end)

ApplyTheme("RED")

-- ============================================================
-- OPEN BY DEFAULT
-- ============================================================
ScreenGui.Enabled = true

-- ============================================================
-- START DEFAULT ESP
-- ============================================================
getgenv().OutlineESPActive = true
StartOutlineESP()

-- ============================================================
-- ESP RENDER LOOP
-- ============================================================
RunService.RenderStepped:Connect(function()
    updateBoxESP()
    updateHealthBarESP()
    updateSkeletonESP()
    updateTracerESP()
    updateNameESP()
    runAimbot()
end)

-- ============================================================
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == getgenv().CoinKeybind and getgenv().CoinKeybindActive then
        CollectCoins()
    elseif isAimInput(input) and aimbotEnabled then
        aiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if isAimInput(input) then
        aiming = false
    end
end)

print("[Blackout] Loaded. RightShift = toggle all | C = Coin Collect | Aim Key = configurable")
