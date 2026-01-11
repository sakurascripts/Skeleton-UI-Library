-- Ready For Use

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Skeleton = {}
Skeleton.__index = Skeleton

local function round(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = obj
end

function Skeleton.new(title)
    local self = setmetatable({}, Skeleton)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SkeletonUI"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.fromOffset(52, 52)
    OpenBtn.Position = UDim2.fromOffset(20, 300)
    OpenBtn.Text = "💀"
    OpenBtn.TextScaled = true
    OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
    OpenBtn.TextColor3 = Color3.new(1,1,1)
    OpenBtn.Parent = ScreenGui
    round(OpenBtn, 26)

    local Window = Instance.new("Frame")
    Window.Size = UDim2.fromOffset(420, 320)
    Window.Position = UDim2.fromScale(0.5, 0.5)
    Window.AnchorPoint = Vector2.new(0.5, 0.5)
    Window.BackgroundColor3 = Color3.fromRGB(25,25,30)
    Window.Visible = true
    Window.Parent = ScreenGui
    round(Window, 16)

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, -20, 0, 44)
    Header.Position = UDim2.fromOffset(10, 8)
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.TextYAlignment = Enum.TextYAlignment.Center
    Header.Text = title
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 20
    Header.TextColor3 = Color3.fromRGB(240,240,255)
    Header.BackgroundTransparency = 1
    Header.Parent = Window

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, -20, 0, 40)
    TabBar.Position = UDim2.fromOffset(10, 56)
    TabBar.BackgroundTransparency = 1
    TabBar.Parent = Window

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabBar

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -20, 1, -110)
    Pages.Position = UDim2.fromOffset(10, 104)
    Pages.BackgroundTransparency = 1
    Pages.Parent = Window

    local drag, start, pos
    OpenBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = i.Position
            pos = OpenBtn.Position
        end
    end)

    OpenBtn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            OpenBtn.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)

    OpenBtn.Activated:Connect(function()
        Window.Visible = not Window.Visible
    end)

    self._gui = ScreenGui
    self._window = Window
    self._tabbar = TabBar
    self._pages = Pages
    self._tabs = {}

    return self
end

function Skeleton:AddTab(name)
    local Tab = {}

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.fromOffset(110, 36)
    Button.Text = name
    Button.TextScaled = true
    Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
    Button.TextColor3 = Color3.new(1,1,1)
    Button.Parent = self._tabbar
    round(Button, 10)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.fromScale(1,1)
    Page.CanvasSize = UDim2.fromOffset(0,0)
    Page.ScrollBarImageTransparency = 1
    Page.Visible = false
    Page.Parent = self._pages

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.Parent = Page

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 10)
    end)

    Button.Activated:Connect(function()
        for _, t in pairs(self._tabs) do
            t.page.Visible = false
            t.button.BackgroundColor3 = Color3.fromRGB(40,40,55)
        end
        Page.Visible = true
        Button.BackgroundColor3 = Color3.fromRGB(70,70,100)
    end)

    Tab.page = Page
    Tab.button = Button

    function Tab:AddSection(title)
        local Section = {}

        local Holder = Instance.new("Frame")
        Holder.Size = UDim2.new(1, 0, 0, 40)
        Holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
        Holder.Parent = Page
        round(Holder, 12)

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -20, 0, 28)
        Label.Position = UDim2.fromOffset(10, 6)
        Label.Text = title
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 16
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.TextColor3 = Color3.fromRGB(230,230,240)
        Label.BackgroundTransparency = 1
        Label.Parent = Holder

        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 8)
        List.Parent = Holder

        List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Holder.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 12)
        end)

        function Section:AddButton(text, callback)
            local B = Instance.new("TextButton")
            B.Size = UDim2.new(1, -20, 0, 36)
            B.Text = text
            B.TextScaled = true
            B.BackgroundColor3 = Color3.fromRGB(0,170,255)
            B.TextColor3 = Color3.new(1,1,1)
            B.Parent = Holder
            round(B, 10)
            B.Activated:Connect(callback)
        end

        function Section:AddToggle(text, callback)
            local T = Instance.new("TextButton")
            T.Size = UDim2.new(1, -20, 0, 36)
            T.Text = text
            T.TextScaled = true
            T.BackgroundColor3 = Color3.fromRGB(120,120,120)
            T.TextColor3 = Color3.new(1,1,1)
            T.Parent = Holder
            round(T, 10)

            local state = false
            T.Activated:Connect(function()
                state = not state
                TweenService:Create(T, TweenInfo.new(0.15), {
                    BackgroundColor3 = state and Color3.fromRGB(0,170,120) or Color3.fromRGB(120,120,120)
                }):Play()
                callback(state)
            end)
        end

        return Section
    end

    table.insert(self._tabs, Tab)

    if #self._tabs == 1 then
        Button:Activate()
    end

    return Tab
end

return Skeleton
