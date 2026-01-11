--// Skeleton UI Library (Stable Build)
--// Mobile + PC | Autoscale | Draggable | Sections | Tabs

local Skeleton = {}
Skeleton.__index = Skeleton

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--// Helpers
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function getUISize()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(800, 600)

    local w = math.clamp(vp.X * 0.55, 320, 520)
    local h = math.clamp(vp.Y * 0.65, 360, 600)

    return UDim2.fromOffset(w, h)
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, startPos, dragStart

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Window
function Skeleton.new(title)
    local self = setmetatable({}, Skeleton)

    -- ScreenGui
    self.Gui = Create("ScreenGui", {
        Name = "SkeletonUI",
        ResetOnSpawn = false,
        Parent = PlayerGui
    })

    -- Main
    self.Main = Create("Frame", {
        Size = getUISize(),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        Parent = self.Gui
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = self.Main})

    -- Topbar
    self.Top = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = self.Main
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = self.Top})

    self.Title = Create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = title or "Skeleton UI",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Left,
        Parent = self.Top
    })

    -- Tabs bar
    self.TabBar = Create("Frame", {
        Size = UDim2.new(0, 110, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(22, 22, 22),
        BorderSizePixel = 0,
        Parent = self.Main
    })

    self.TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = self.TabBar
    })

    self.Pages = Create("Frame", {
        Size = UDim2.new(1, -110, 1, -42),
        Position = UDim2.new(0, 110, 0, 42),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    makeDraggable(self.Main, self.Top)

    self.Tabs = {}
    self.CurrentTab = nil

    return self
end

--// Tab
function Skeleton:CreateTab(name)
    assert(name, "Tab name missing")

    local Tab = {}

    Tab.Button = Create("TextButton", {
        Size = UDim2.new(1, -12, 0, 36),
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Parent = self.TabBar
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Tab.Button})

    Tab.Page = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Visible = false,
        Parent = self.Pages
    })

    Tab.Layout = Create("UIListLayout", {
        Padding = UDim.new(0, 10),
        Parent = Tab.Page
    })

    Tab.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Tab.Page.CanvasSize = UDim2.fromOffset(0, Tab.Layout.AbsoluteContentSize.Y + 10)
    end)

    Tab.Button.MouseButton1Click:Connect(function()
        if self.CurrentTab then
            self.CurrentTab.Page.Visible = false
        end
        Tab.Page.Visible = true
        self.CurrentTab = Tab
    end)

    if not self.CurrentTab then
        Tab.Page.Visible = true
        self.CurrentTab = Tab
    end

    function Tab:AddSection(title)
        local Section = {}

        Section.Frame = Create("Frame", {
            Size = UDim2.new(1, -12, 0, 40),
            AutomaticSize = Y,
            BackgroundColor3 = Color3.fromRGB(26, 26, 26),
            Parent = Tab.Page
        })

        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Section.Frame})

        Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.new(0, 10, 0, 6),
            BackgroundTransparency = 1,
            Text = title,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255,255,255),
            Parent = Section.Frame
        })

        Section.Layout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = Section.Frame
        })

        Create("UIPadding", {
            PaddingTop = UDim.new(0, 36),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            Parent = Section.Frame
        })

        function Section:AddButton(text, callback)
            local btn = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Text = text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255,255,255),
                Parent = Section.Frame
            })

            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})

            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        return Section
    end

    return Tab
end

return Skeleton
