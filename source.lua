--// Skeleton → Lazer Style UI Library (Delta Safe)

local Library = {}
Library.__index = Library

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Create Library
function Library.new(title)
    local self = setmetatable({}, Library)

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeletonUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui
    self.ScreenGui = ScreenGui

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 420)
    Main.Position = UDim2.new(0.5, -260, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
    Main.Parent = ScreenGui
    Main.Active = true
    Main.ZIndex = 2
    self.Main = Main

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = title or "Skeleton UI"
    Title.TextColor3 = Color3.new(1,1,1)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.TextXAlignment = Left
    Title.Parent = Main

    -- Tab Buttons
    local TabsHolder = Instance.new("ScrollingFrame")
    TabsHolder.Position = UDim2.new(0, 10, 0, 60)
    TabsHolder.Size = UDim2.new(0, 120, 1, -70)
    TabsHolder.CanvasSize = UDim2.new()
    TabsHolder.ScrollBarThickness = 4
    TabsHolder.BackgroundTransparency = 1
    TabsHolder.Parent = Main

    local TabLayout = Instance.new("UIListLayout", TabsHolder)
    TabLayout.Padding = UDim.new(0, 6)

    -- Content Area
    local Pages = Instance.new("Frame")
    Pages.Position = UDim2.new(0, 140, 0, 60)
    Pages.Size = UDim2.new(1, -150, 1, -70)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Main

    self.Tabs = {}
    self.Pages = Pages
    self.ActiveTab = nil

    -- Drag
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    return self
end

--// Add Tab
function Library:AddTab(name)
    local Tab = {}

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -4, 0, 36)
    Button.Text = name
    Button.BackgroundColor3 = Color3.fromRGB(30,30,35)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 14
    Button.Parent = self.Main.ScrollingFrame or self.Main:FindFirstChildWhichIsA("ScrollingFrame")

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.CanvasSize = UDim2.new()
    Page.ScrollBarThickness = 5
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.Parent = self.Pages

    local Layout = Instance.new("UIListLayout", Page)
    Layout.Padding = UDim.new(0, 8)

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
    end)

    Button.Activated:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.Page.Visible = false
        end
        Page.Visible = true
        self.ActiveTab = {Page = Page}
    end)

    if not self.ActiveTab then
        Page.Visible = true
        self.ActiveTab = {Page = Page}
    end

    function Tab:AddSection(title)
        local Section = {}

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -6, 0, 40)
        Frame.BackgroundColor3 = Color3.fromRGB(25,25,30)
        Frame.Parent = Page

        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -12, 0, 30)
        Label.Position = UDim2.new(0, 6, 0, 6)
        Label.BackgroundTransparency = 1
        Label.Text = title
        Label.TextColor3 = Color3.new(1,1,1)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.Parent = Frame

        local Layout = Instance.new("UIListLayout", Frame)
        Layout.Padding = UDim.new(0, 6)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Frame.Size = UDim2.new(1, -6, 0, Layout.AbsoluteContentSize.Y + 10)
        end)

        function Section:AddButton(text, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, -12, 0, 36)
            Btn.Text = text
            Btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
            Btn.TextColor3 = Color3.new(1,1,1)
            Btn.Font = Enum.Font.Gotham
            Btn.TextSize = 14
            Btn.Parent = Frame

            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

            Btn.Activated:Connect(function()
                if callback then callback() end
            end)
        end

        return Section
    end

    return Tab
end

return Library
