--// Skeleton UI Library (Tabs + Sections) | Delta Safe

local Library = {}
Library.__index = Library

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-----------------------------------------------------
-- Utility
-----------------------------------------------------
local function round(px)
    return UDim.new(0, px)
end

-----------------------------------------------------
-- Create Window
-----------------------------------------------------
function Library.new(title)
    local self = setmetatable({}, Library)

    -- ScreenGui
    local gui = Instance.new("ScreenGui")
    gui.Name = "SkeletonUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    self.Gui = gui

    -- Main
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(560, 440)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(18,18,22)
    main.Active = true
    main.Parent = gui
    self.Main = main

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

    -- Top Bar
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 46)
    top.BackgroundColor3 = Color3.fromRGB(28,28,34)
    top.Parent = main

    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -16, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Skeleton UI"
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Color3.new(1,1,1)
    titleLabel.TextXAlignment = Left
    titleLabel.Parent = top

    -- Tabs Holder
    local tabs = Instance.new("ScrollingFrame")
    tabs.Size = UDim2.new(0, 150, 1, -46)
    tabs.Position = UDim2.new(0, 0, 0, 46)
    tabs.CanvasSize = UDim2.new()
    tabs.ScrollBarThickness = 4
    tabs.ScrollingDirection = Enum.ScrollingDirection.Y
    tabs.BackgroundColor3 = Color3.fromRGB(28,28,34)
    tabs.Parent = main
    self.TabsFrame = tabs

    local tabLayout = Instance.new("UIListLayout", tabs)
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.HorizontalAlignment = Center

    -- Pages Holder
    local pages = Instance.new("Frame")
    pages.Size = UDim2.new(1, -150, 1, -46)
    pages.Position = UDim2.new(0, 150, 0, 46)
    pages.BackgroundTransparency = 1
    pages.Parent = main
    self.Pages = pages

    self.ActivePage = nil

    -------------------------------------------------
    -- Drag (PC + Mobile)
    -------------------------------------------------
    local dragging, startPos, dragStart
    top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    return self
end

-----------------------------------------------------
-- Tab
-----------------------------------------------------
function Library:AddTab(name)
    assert(name, "Tab name missing")

    local Tab = {}

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(18,18,22)
    button.Text = name
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.Gotham
    button.TextSize = 13
    button.Parent = self.TabsFrame

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 10)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.CanvasSize = UDim2.new()
    page.ScrollBarThickness = 5
    page.Visible = false
    page.BackgroundTransparency = 1
    page.Parent = self.Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Center

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 10)
    end)

    button.Activated:Connect(function()
        if self.ActivePage then
            self.ActivePage.Visible = false
        end
        page.Visible = true
        self.ActivePage = page
    end)

    if not self.ActivePage then
        page.Visible = true
        self.ActivePage = page
    end

    -------------------------------------------------
    -- Section
    -------------------------------------------------
    function Tab:AddSection(title)
        assert(title, "Section title missing")

        local Section = {}

        local holder = Instance.new("Frame")
        holder.Size = UDim2.new(1, -12, 0, 0)
        holder.BackgroundTransparency = 1
        holder.Parent = page

        local header = Instance.new("TextLabel")
        header.Size = UDim2.new(1, 0, 0, 28)
        header.BackgroundTransparency = 1
        header.Text = title
        header.Font = Enum.Font.GothamBold
        header.TextSize = 13
        header.TextColor3 = Color3.new(1,1,1)
        header.TextXAlignment = Left
        header.Parent = holder

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 0)
        container.BackgroundTransparency = 1
        container.Parent = holder

        local clayout = Instance.new("UIListLayout", container)
        clayout.Padding = UDim.new(0, 8)
        clayout.HorizontalAlignment = Center

        clayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, clayout.AbsoluteContentSize.Y)
            holder.Size = UDim2.new(1, -12, 0, header.AbsoluteSize.Y + clayout.AbsoluteContentSize.Y + 6)
        end)

        -------------------------------------------------
        -- Button
        -------------------------------------------------
        function Section:AddButton(text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -12, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(28,28,34)
            btn.Text = text
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.Parent = container

            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

            btn.Activated:Connect(function()
                if callback then callback() end
            end)
        end

        return Section
    end

    return Tab
end

return Library
