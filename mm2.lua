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
-- ROOT  (above everything, including CoreGui)
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
-- LOADING SPLASH SCREEN  (same top-tier parent)
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

        Btn.MouseButton1Click:Connect(function()
            state = not state
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

        return Btn
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
    Win.Main = Main
    table.insert(AllWindows, Main)
    return Win
end

-- ============================================================
-- ROLE HELPERS
-- ============================================================
local RoleColors = {
    Murderer = Color3.new(1, 0, 0),
    Sheriff  = Color3.new(0, 0.5, 1),
    Innocent = Color3.new(0, 1, 0)
}

local function GetToolType(player)
    local bp = player:FindFirstChild("Backpack")
    local ch = player.Character
    if bp then
        if bp:FindFirstChild("Gun") then return "Gun" end
        if bp:FindFirstChild("Knife") then return "Knife" end
    end
    if ch then
        if ch:FindFirstChild("Gun") then return "Gun" end
        if ch:FindFirstChild("Knife") then return "Knife" end
    end
end

local function GetRoleColor(player, roles)
    for id, data in pairs(roles) do
        if data and typeof(data) == "table" then
            if tostring(id) == tostring(player.UserId) or id == player.Name then
                return RoleColors[data.Role] or RoleColors.Innocent
            end
        end
    end
    local t = GetToolType(player)
    if t == "Gun" then return Color3.new(0, 0.5, 1) end
    if t == "Knife" then return Color3.new(1, 0, 0) end
    return Color3.new(0, 1, 0)
end

-- ============================================================
-- ESP CHAMS
-- ============================================================
local function StartESP()
    getgenv().PlayerESPObjects = {}
    getgenv().PlayerESPConnections = {}
    getgenv().PlayerRoles = {}

    local function UpdateColor(plr, esp)
        if not esp then return end
        local c = GetRoleColor(plr, getgenv().PlayerRoles)
        esp.FillColor = c
        esp.OutlineColor = c
    end

    local function CreateESP(plr)
        if plr == LocalPlayer or not plr.Character then return end
        if getgenv().PlayerESPObjects[plr] then getgenv().PlayerESPObjects[plr]:Destroy() end
        local esp = Instance.new("Highlight")
        esp.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        esp.FillTransparency = 0.65
        esp.OutlineTransparency = 0.3
        esp.Parent = plr.Character
        UpdateColor(plr, esp)
        getgenv().PlayerESPObjects[plr] = esp
    end

    local function Setup(plr)
        if plr == LocalPlayer then return end
        if plr.Character then CreateESP(plr) end
        getgenv().PlayerESPConnections[plr] = plr.CharacterAdded:Connect(function()
            task.wait(0.5); CreateESP(plr)
        end)
    end

    getgenv().PlayerESPRemoteConnection = FadeEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then getgenv().PlayerRoles = d end
    end)
    getgenv().PlayerESPDataConnection = DataChangedEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then
            getgenv().PlayerRoles = d
            for p, e in pairs(getgenv().PlayerESPObjects) do UpdateColor(p, e) end
        end
    end)
    getgenv().PlayerESPRoundEndConnection = RoundEndEvent.OnClientEvent:Connect(function()
        getgenv().PlayerRoles = {}
        for _, e in pairs(getgenv().PlayerESPObjects) do
            if e then
                e.FillColor = Color3.new(0, 1, 0)
                e.OutlineColor = Color3.new(0, 1, 0)
            end
        end
    end)

    for _, plr in ipairs(Players:GetPlayers()) do Setup(plr) end
    getgenv().PlayerESPPlayerAdded = Players.PlayerAdded:Connect(Setup)
    getgenv().PlayerESPPlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
        if getgenv().PlayerESPObjects[plr] then
            getgenv().PlayerESPObjects[plr]:Destroy()
            getgenv().PlayerESPObjects[plr] = nil
        end
        if getgenv().PlayerESPConnections[plr] then
            getgenv().PlayerESPConnections[plr]:Disconnect()
            getgenv().PlayerESPConnections[plr] = nil
        end
    end)

    getgenv().PlayerESPRefreshLoop = task.spawn(function()
        while getgenv().PlayerESPActive do
            task.wait(2)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    if not getgenv().PlayerESPObjects[plr] then
                        CreateESP(plr)
                    else
                        UpdateColor(plr, getgenv().PlayerESPObjects[plr])
                    end
                end
            end
        end
    end)
end

local function StopESP()
    for _, n in ipairs({"PlayerESPRemoteConnection","PlayerESPDataConnection","PlayerESPRoundEndConnection","PlayerESPPlayerAdded","PlayerESPPlayerRemoving"}) do
        local c = getgenv()[n]
        if c then c:Disconnect(); getgenv()[n] = nil end
    end
    if getgenv().PlayerESPRefreshLoop then
        task.cancel(getgenv().PlayerESPRefreshLoop)
        getgenv().PlayerESPRefreshLoop = nil
    end
    if getgenv().PlayerESPConnections then
        for _, c in pairs(getgenv().PlayerESPConnections) do if c then c:Disconnect() end end
        getgenv().PlayerESPConnections = {}
    end
    if getgenv().PlayerESPObjects then
        for _, o in pairs(getgenv().PlayerESPObjects) do if o then pcall(function() o:Destroy() end) end end
        getgenv().PlayerESPObjects = {}
    end
    getgenv().PlayerRoles = {}
end

-- ============================================================
-- NAME ESP
-- ============================================================
local function StartNameESP()
    getgenv().NameESPObjects = {}
    getgenv().NameESPConnections = {}
    getgenv().NameRoles = {}

    local function UpdateNameColor(plr, esp)
        if not esp then return end
        local lbl = esp:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.TextColor3 = GetRoleColor(plr, getgenv().NameRoles) end
    end

    local function CreateNameESP(plr)
        if plr == LocalPlayer or not plr.Character then return end
        local head = plr.Character:FindFirstChild("Head")
        if not head then return end
        if getgenv().NameESPObjects[plr] then getgenv().NameESPObjects[plr]:Destroy() end
        local esp = Instance.new("BillboardGui")
        esp.Size = UDim2.new(0, 200, 0, 40)
        esp.AlwaysOnTop = true
        esp.StudsOffset = Vector3.new(0, 2.5, 0)
        esp.Adornee = head
        esp.Parent = head
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0
        label.TextSize = 14
        label.Font = Enum.Font.ArialBold
        label.TextColor3 = GetRoleColor(plr, getgenv().NameRoles)
        local suffix = plr.DisplayName ~= plr.Name and " (" .. plr.DisplayName .. ")" or ""
        label.Text = plr.Name .. suffix
        label.Parent = esp
        getgenv().NameESPObjects[plr] = esp
    end

    local function Setup(plr)
        if plr == LocalPlayer then return end
        if plr.Character then CreateNameESP(plr) end
        getgenv().NameESPConnections[plr] = plr.CharacterAdded:Connect(function()
            task.wait(0.5); CreateNameESP(plr)
        end)
    end

    getgenv().NameESPRemoteConnection = FadeEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then getgenv().NameRoles = d end
    end)
    getgenv().NameESPDataConnection = DataChangedEvent.OnClientEvent:Connect(function(d)
        if typeof(d) == "table" then
            getgenv().NameRoles = d
            for p, e in pairs(getgenv().NameESPObjects) do UpdateNameColor(p, e) end
        end
    end)
    getgenv().NameESPRoundEndConnection = RoundEndEvent.OnClientEvent:Connect(function()
        getgenv().NameRoles = {}
        for _, e in pairs(getgenv().NameESPObjects) do
            local lbl = e and e:FindFirstChildOfClass("TextLabel")
            if lbl then lbl.TextColor3 = Color3.new(0, 1, 0) end
        end
    end)

    for _, plr in ipairs(Players:GetPlayers()) do Setup(plr) end
    getgenv().NameESPPlayerAdded = Players.PlayerAdded:Connect(Setup)
    getgenv().NameESPPlayerRemoving = Players.PlayerRemoving:Connect(function(plr)
        if getgenv().NameESPObjects[plr] then
            getgenv().NameESPObjects[plr]:Destroy()
            getgenv().NameESPObjects[plr] = nil
        end
        if getgenv().NameESPConnections[plr] then
            getgenv().NameESPConnections[plr]:Disconnect()
            getgenv().NameESPConnections[plr] = nil
        end
    end)

    getgenv().NameESPRefreshLoop = task.spawn(function()
        while getgenv().NameESPActive do
            task.wait(2)
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then
                    if not getgenv().NameESPObjects[plr] then
                        CreateNameESP(plr)
                    else
                        UpdateNameColor(plr, getgenv().NameESPObjects[plr])
                    end
                end
            end
        end
    end)
end

local function StopNameESP()
    for _, n in ipairs({"NameESPRemoteConnection","NameESPDataConnection","NameESPRoundEndConnection","NameESPPlayerAdded","NameESPPlayerRemoving"}) do
        local c = getgenv()[n]
        if c then c:Disconnect(); getgenv()[n] = nil end
    end
    if getgenv().NameESPRefreshLoop then
        task.cancel(getgenv().NameESPRefreshLoop)
        getgenv().NameESPRefreshLoop = nil
    end
    if getgenv().NameESPConnections then
        for _, c in pairs(getgenv().NameESPConnections) do if c then c:Disconnect() end end
        getgenv().NameESPConnections = {}
    end
    if getgenv().NameESPObjects then
        for _, o in pairs(getgenv().NameESPObjects) do if o then pcall(function() o:Destroy() end) end end
        getgenv().NameESPObjects = {}
    end
    getgenv().NameRoles = {}
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
-- TRIGGERBOT
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

-- ============================================================
-- SILENT AIM
-- ============================================================
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
-- NOCLIP
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
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

-- ============================================================
-- COIN COLLECT
-- ============================================================
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

-- ============================================================
-- FULLBRIGHT
-- ============================================================
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

-- ============================================================
-- PERFORMANCE MODE
-- ============================================================
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

-- ============================================================
-- TELEPORT OPTIONS
-- ============================================================
local function TpToRandomPlayer()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local candidates = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local targetHRP = plr.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                table.insert(candidates, targetHRP)
            end
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

-- ============================================================
-- INFINITE JUMP
-- ============================================================
local function StartInfJump()
    if getgenv().InfJumpConn then getgenv().InfJumpConn:Disconnect() end
    getgenv().InfJumpConn = UserInputService.JumpRequest:Connect(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function StopInfJump()
    if getgenv().InfJumpConn then
        getgenv().InfJumpConn:Disconnect()
        getgenv().InfJumpConn = nil
    end
end

-- ============================================================
-- FLY
-- ============================================================
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

-- ============================================================
-- REMOVE BARRIERS
-- ============================================================
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

-- ============================================================
-- INVISIBLE
-- ============================================================
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
-- RUN LOADER, THEN BUILD PANELS
-- ============================================================
RunLoadingSequence()

-- ============================================================
-- PANEL 1 — VISUALS (left)
-- ============================================================
local MainPanel = CreateWindow("BLACKOUT // VISUALS", 20, 20)

MainPanel.CreateSection("esp")
MainPanel.CreateToggle("ESP Chams", false, function(s)
    getgenv().PlayerESPActive = s
    if s then StartESP() else StopESP() end
end)
MainPanel.CreateToggle("Name ESP", false, function(s)
    getgenv().NameESPActive = s
    if s then StartNameESP() else StopNameESP() end
end)
MainPanel.CreateToggle("Gun Drop ESP", false, function(s)
    if s then StartGunDropESP() else StopGunDropESP() end
end)

MainPanel.CreateSection("misc")
MainPanel.CreateToggle("Coin Collect [C]", false, function(s)
    getgenv().CoinKeybindActive = s
end)

-- ============================================================
-- PANEL 2 — UTILITY (middle)
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

UtilityPanel.CreateSection("utility")
UtilityPanel.CreateToggle("Remove Barriers", false, function(s)
    if s then StartAutoBarriers() else StopAutoBarriers() end
end)
UtilityPanel.CreateToggle("Invisible", false, function(s)
    if s then StartInvisible() else StopInvisible() end
end)

-- ============================================================
-- PANEL 3 — COMBAT (far right, short)
-- ============================================================
local CombatPanel = CreateWindow("BLACKOUT // COMBAT", 500, 20)

CombatPanel.CreateSection("combat")
CombatPanel.CreateToggle("Auto Grab Gun", false, function(s)
    if s then StartAutoGrab() else StopAutoGrab() end
end)
CombatPanel.CreateToggle("Triggerbot", false, function(s)
    if s then StartTriggerbot() else StopTriggerbot() end
end)
CombatPanel.CreateToggle("Silent Aim [E]", false, function(s)
    getgenv().SilentAimActive = s
end)

-- ============================================================
-- PANEL 4 — THEME (far right)
-- ============================================================
local ThemePanel = CreateWindow("BLACKOUT // THEME", 740, 20)

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
-- KEYBINDS
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    elseif input.KeyCode == Enum.KeyCode.E and getgenv().SilentAimActive then
        FireSilentAim()
    elseif input.KeyCode == getgenv().CoinKeybind and getgenv().CoinKeybindActive then
        CollectCoins()
    end
end)

print("[Blackout] Loaded. RightShift = toggle all | E = Silent Aim | C = Coin Collect")
