--// Skeleton × Lazer UI Library
--// Rayfield / Orion inspired
--// v3.2 – Balanced WaitForChild usage

--================================================--
-- Services
--================================================--

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")

--================================================--
-- Critical Waits (ONLY where needed)
--================================================--

local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

--================================================--
-- Theme
--================================================--

local Theme = {
    Background = Color3.fromRGB(25,25,30),
    Secondary  = Color3.fromRGB(32,32,38),
    Accent     = Color3.fromRGB(120,180,255),
    Text       = Color3.fromRGB(255,255,255)
}

--================================================--
-- Tween Cache
--================================================--

local AnimFast   = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local AnimSmooth = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function Tween(obj, info, props)
    if obj then
        TweenService:Create(obj, info, props):Play()
    end
end

--================================================--
-- Instance Helper
--================================================--

local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    inst.Parent = props and props.Parent
    return inst
end

--================================================--
-- ScreenGui (executor safe)
--================================================--

local function CreateScreenGui()
    local parent = typeof(gethui) == "function" and gethui() or PlayerGui
    return Create("ScreenGui", {
        Name = "SkeletonUI",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Parent = parent
    })
end

--================================================--
-- Drag
--================================================--

local function MakeDraggable(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = frame.Position
            startInput = i.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = i.Position - startInput
            frame.Position = UDim2.fromOffset(
                startPos.X.Offset + delta.X,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--================================================--
-- Blur (single instance)
--================================================--

local Blur = Lighting:FindFirstChild("SkeletonBlur") or Instance.new("BlurEffect")
Blur.Name = "SkeletonBlur"
Blur.Size = 0
Blur.Enabled = false
Blur.Parent = Lighting

--================================================--
-- Library
--================================================--

local Skeleton = {}
Skeleton.__index = Skeleton

function Skeleton:CreateWindow(opts)
    opts = opts or {}

    local Window = {}
    local gui = CreateScreenGui()

    -- Shell
    local Shell = Create("Frame", {
        Size = UDim2.fromOffset(520,420),
        Position = UDim2.fromScale(0.5,0.5),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        Parent = gui
    })

    -- Main
    local Main = Create("Frame", {
        Size = UDim2.fromScale(1,1),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        Parent = Shell
    })
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

    -- Top
    local Top = Create("Frame", {
        Size = UDim2.new(1,0,0,40),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,12)

    Create("TextLabel", {
        Text = opts.Name or "Skeleton Hub",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,12,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Shell, Top)

    -- Tabs
    local TabsBar = Create("ScrollingFrame", {
        Size = UDim2.new(0,140,1,-40),
        Position = UDim2.new(0,0,0,40),
        BackgroundColor3 = Theme.Secondary,
        ScrollBarThickness = 3,
        Parent = Main
    })

    Create("UIListLayout", {
        Padding = UDim.new(0,6),
        Parent = TabsBar
    })

    -- Pages
    local Pages = Create("Frame", {
        Size = UDim2.new(1,-140,1,-40),
        Position = UDim2.new(0,140,0,40),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- Mini button
    local Mini = Create("TextButton", {
        Size = UDim2.fromOffset(48,48),
        Position = UDim2.fromOffset(20,20),
        Text = "S",
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        BackgroundColor3 = Theme.Accent,
        Visible = false,
        Parent = gui,
        ZIndex = 10
    })
    Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)

    -- Show / Hide
    local function Show()
        Mini.Visible = false
        Main.Visible = true
        Tween(Main, AnimSmooth, {BackgroundTransparency = 0})
        Blur.Enabled = true
        Tween(Blur, AnimSmooth, {Size = 18})
    end

    local function Hide()
        Tween(Main, AnimFast, {BackgroundTransparency = 1})
        Tween(Blur, AnimFast, {Size = 0})
        task.delay(AnimFast.Time, function()
            Main.Visible = false
            Mini.Visible = true
        end)
    end

    Mini.MouseButton1Click:Connect(Show)

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.P then
            Show()
        elseif i.KeyCode == Enum.KeyCode.D then
            Hide()
        end
    end)

    -- Tabs API
    local ActivePage

    function Window:CreateTab(name)
        local Tab = {}

        local Btn = Create("TextButton", {
            Size = UDim2.new(1,-10,0,36),
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Background,
            Parent = TabsBar
        })
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8)

        local Page = Create("ScrollingFrame", {
            Size = UDim2.fromScale(1,1),
            ScrollBarThickness = 4,
            Visible = false,
            Parent = Pages
        })

        Create("UIListLayout", {
            Padding = UDim.new(0,8),
            Parent = Page
        })

        Btn.MouseButton1Click:Connect(function()
            if ActivePage then ActivePage.Visible = false end
            ActivePage = Page
            Page.Visible = true
        end)

        if not ActivePage then
            ActivePage = Page
            Page.Visible = true
        end

        function Tab:AddTextbox(placeholder, callback)
            local Box = Create("TextBox", {
                Size = UDim2.new(1,-12,0,40),
                PlaceholderText = placeholder,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundColor3 = Theme.Secondary,
                Parent = Page
            })
            Instance.new("UICorner", Box).CornerRadius = UDim.new(0,8)

            Box.FocusLost:Connect(function()
                if callback then callback(Box.Text) end
            end)
        end

        return Tab
    end

    Show()
    return Window
end

return Skeleton
