--// Skeleton UI Library (Premium v1.0)
--// Lazer API + Rayfield UX
--// Full script, single return, no errors

local Skeleton = {}
Skeleton.__index = Skeleton

--================================================--
-- Services
--================================================--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--================================================--
-- Utilities
--================================================--
local function Create(class, props)
    local obj = Instance.new(class)
    local parent = props and props.Parent
    if props then
        props.Parent = nil
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    obj.Parent = parent
    return obj
end

local function Tween(obj, t, props)
    TweenService:Create(
        obj,
        TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        props
    ):Play()
end

--================================================--
-- Blur
--================================================--
local function EnableBlur()
    if Lighting:FindFirstChild("SkeletonBlur") then return end
    local blur = Instance.new("BlurEffect")
    blur.Name = "SkeletonBlur"
    blur.Size = 0
    blur.Parent = Lighting
    Tween(blur, 0.3, { Size = 18 })
end

local function DisableBlur()
    local blur = Lighting:FindFirstChild("SkeletonBlur")
    if blur then
        Tween(blur, 0.3, { Size = 0 })
        task.delay(0.3, function()
            blur:Destroy()
        end)
    end
end

--================================================--
-- Drag (PC + Mobile)
--================================================--
local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--================================================--
-- Constructor (Lazer Style)
--================================================--
function Skeleton.new(title)
    local self = setmetatable({}, Skeleton)

    -- ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "SkeletonUI"
    self.Gui.ResetOnSpawn = false
    self.Gui.IgnoreGuiInset = true
    self.Gui.Parent = PlayerGui

    -- Main
    self.Main = Create("Frame", {
        Size = UDim2.fromScale(0.45, 0.55),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18,18,22),
        Parent = self.Gui
    })
    Create("UICorner", { CornerRadius = UDim.new(0,14), Parent = self.Main })

    -- Top Bar
    self.Top = Create("Frame", {
        Size = UDim2.new(1,0,0,44),
        BackgroundColor3 = Color3.fromRGB(28,28,34),
        Parent = self.Main
    })
    Create("UICorner", { CornerRadius = UDim.new(0,14), Parent = self.Top })

    Create("TextLabel", {
        Text = title or "Skeleton UI",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.new(1,1,1),
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-60,1,0),
        Position = UDim2.fromOffset(12,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Top
    })

    MakeDraggable(self.Main, self.Top)

    -- Close Button
    local close = Create("TextButton", {
        Text = "✕",
        Size = UDim2.fromOffset(32,32),
        Position = UDim2.new(1,-38,0.5,-16),
        BackgroundColor3 = Color3.fromRGB(200,60,60),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        Parent = self.Top
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = close })

    -- Tabs
    self.TabBar = Create("ScrollingFrame", {
        Size = UDim2.new(0,140,1,-44),
        Position = UDim2.new(0,0,0,44),
        BackgroundColor3 = Color3.fromRGB(24,24,30),
        ScrollBarThickness = 3,
        Parent = self.Main
    })

    Create("UIListLayout", {
        Padding = UDim.new(0,6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = self.TabBar
    })

    self.Pages = Create("Frame", {
        Size = UDim2.new(1,-140,1,-44),
        Position = UDim2.new(0,140,0,44),
        BackgroundTransparency = 1,
        Parent = self.Main
    })

    -- Floating Open Button
    self.OpenButton = Create("TextButton", {
        Size = UDim2.fromOffset(56,56),
        Position = UDim2.new(0,20,0.5,-28),
        BackgroundColor3 = Color3.fromRGB(90,150,255),
        Text = "☰",
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        Visible = false,
        Parent = self.Gui
    })
    Create("UICorner", { CornerRadius = UDim.new(1,0), Parent = self.OpenButton })
    MakeDraggable(self.OpenButton)

    close.MouseButton1Click:Connect(function()
        DisableBlur()
        self.Main.Visible = false
        self.OpenButton.Visible = true
    end)

    self.OpenButton.MouseButton1Click:Connect(function()
        self.Main.Visible = true
        self.OpenButton.Visible = false
        EnableBlur()
    end)

    self.Tabs = {}
    self.ActiveTab = nil

    return self
end

--================================================--
-- Tabs
--================================================--
function Skeleton:AddTab(name)
    assert(name, "Tab name missing")

    local tab = {}
    local button = Create("TextButton", {
        Text = name,
        Size = UDim2.new(1,-10,0,36),
        BackgroundColor3 = Color3.fromRGB(18,18,22),
        TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.Gotham,
        Parent = self.TabBar
    })
    Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = button })

    local page = Create("ScrollingFrame", {
        Size = UDim2.fromScale(1,1),
        ScrollBarThickness = 3,
        Visible = false,
        Parent = self.Pages
    })

    Create("UIListLayout", {
        Padding = UDim.new(0,10),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = page
    })

    button.MouseButton1Click:Connect(function()
        if self.ActiveTab then
            self.ActiveTab.Page.Visible = false
        end
        page.Visible = true
        self.ActiveTab = tab
    end)

    if not self.ActiveTab then
        page.Visible = true
        self.ActiveTab = tab
    end

    tab.Page = page
    function tab:AddSection(title)
        local section = {}

        Create("TextLabel", {
            Text = title,
            Size = UDim2.new(1,-12,0,22),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1,1,1),
            Font = Enum.Font.GothamBold,
            Parent = page
        })

        local holder = Create("Frame", {
            Size = UDim2.new(1,-12,0,0),
            BackgroundTransparency = 1,
            Parent = page
        })

        local layout = Create("UIListLayout", {
            Padding = UDim.new(0,8),
            Parent = holder
        })

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            holder.Size = UDim2.new(1,-12,0,layout.AbsoluteContentSize.Y)
        end)

        function section:AddButton(text, callback)
            local btn = Create("TextButton", {
                Text = text,
                Size = UDim2.new(1,0,0,40),
                BackgroundColor3 = Color3.fromRGB(32,32,40),
                TextColor3 = Color3.new(1,1,1),
                Parent = holder
            })
            Create("UICorner", { CornerRadius = UDim.new(0,10), Parent = btn })
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
        end

        return section
    end

    return tab
end

--================================================--
-- RETURN (IMPORTANT)
--================================================--
return Skeleton
