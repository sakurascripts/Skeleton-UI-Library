--// Skeleton UI Library (Lazer-Style API)
--// Delta Executor Safe | Mobile + PC | No stacking bugs

local Skeleton = {}
Skeleton.__index = Skeleton

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- Utility
--------------------------------------------------
local function Tween(obj, props, time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

--------------------------------------------------
-- Create Window
--------------------------------------------------
function Skeleton.new(title)
    local self = setmetatable({}, Skeleton)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkeletonUI"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui
    self.Gui = gui

    -- Main Frame
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(600, 450)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.Parent = gui
    main.Active = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
    self.Main = main

    -- Top Bar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 44)
    top.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    top.Parent = main
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.fromOffset(14, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Skeleton UI"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = top

    -- Close Button
    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(36, 36)
    close.Position = UDim2.new(1, -42, 0.5, -18)
    close.Text = "×"
    close.Font = Enum.Font.GothamBold
    close.TextSize = 20
    close.BackgroundTransparency = 1
    close.TextColor3 = Color3.fromRGB(200,200,200)
    close.Parent = top

    close.Activated:Connect(function()
        main.Visible = false
        self.ToggleButton.Visible = true
    end)

    -- Floating Toggle Button (Rayfield-style)
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(50,50)
    toggleBtn.Position = UDim2.fromOffset(20,20)
    toggleBtn.Text = "S"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 20
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.Visible = false
    toggleBtn.Parent = gui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1,0)
    self.ToggleButton = toggleBtn

    toggleBtn.Activated:Connect(function()
        main.Visible = true
        toggleBtn.Visible = false
    end)

    -- Tabs
    local tabsBar = Instance.new("ScrollingFrame")
    tabsBar.Size = UDim2.new(1, -20, 0, 40)
    tabsBar.Position = UDim2.fromOffset(10, 54)
    tabsBar.CanvasSize = UDim2.new(0,0,0,0)
    tabsBar.ScrollBarThickness = 0
    tabsBar.BackgroundTransparency = 1
    tabsBar.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0,8)
    tabLayout.Parent = tabsBar

    tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabsBar.CanvasSize = UDim2.fromOffset(tabLayout.AbsoluteContentSize.X + 10, 0)
    end)

    -- Pages
    local pages = Instance.new("Folder")
    pages.Parent = main
    self.Pages = pages
    self.ActivePage = nil

    self.TabsBar = tabsBar
    self.Tabs = {}

    return self
end

--------------------------------------------------
-- Tabs
--------------------------------------------------
function Skeleton:AddTab(name)
    local tab = {}

    -- Tab Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(120, 36)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Parent = self.TabsBar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    -- Page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -110)
    page.Position = UDim2.fromOffset(10, 100)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = self.Pages

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0,12)
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 10)
    end)

    btn.Activated:Connect(function()
        if self.ActivePage then
            self.ActivePage.Visible = false
        end
        self.ActivePage = page
        page.Visible = true
    end)

    if not self.ActivePage then
        self.ActivePage = page
        page.Visible = true
    end

    tab.Page = page
    tab.Layout = layout

    --------------------------------------------------
    -- Sections
    --------------------------------------------------
    function tab:AddSection(title)
        local section = {}

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, -10, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(30,30,38)
        frame.Parent = page
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -10, 0, 30)
        label.Position = UDim2.fromOffset(10,5)
        label.Text = title
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Color3.new(1,1,1)
        label.BackgroundTransparency = 1
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local content = Instance.new("UIListLayout")
        content.Padding = UDim.new(0,8)
        content.Parent = frame

        content:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.Size = UDim2.new(1, -10, 0, content.AbsoluteContentSize.Y + 40)
        end)

        --------------------------------------------------
        -- Button
        --------------------------------------------------
        function section:AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 0, 36)
            btn.Text = text
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.BackgroundColor3 = Color3.fromRGB(45,45,55)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Parent = frame
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

            btn.Activated:Connect(function()
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(60,60,75)}, 0.1)
                task.wait(0.1)
                Tween(btn, {BackgroundColor3 = Color3.fromRGB(45,45,55)}, 0.1)
                if callback then callback() end
            end)
        end

        return section
    end

    return tab
end

--------------------------------------------------
-- Return Library
--------------------------------------------------
return Skeleton
