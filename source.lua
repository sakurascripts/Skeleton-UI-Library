--// Skeleton UI Library v2.0
--// Clean Rewrite | Closure-Based | Mobile + PC | Executor Safe

local Skeleton = {}

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Theme
local Theme = {
    Background = Color3.fromRGB(18,18,20),
    Secondary  = Color3.fromRGB(28,28,32),
    Accent     = Color3.fromRGB(120,180,255),
    Text       = Color3.fromRGB(235,235,235)
}

--// Safe ScreenGui creator (ALL executors)
local function CreateScreenGui(name)
    local parent

    if gethui then
        parent = gethui()
    elseif syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        parent = sg
    else
        parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = name or "SkeletonUI"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = parent

    return gui
end

--// Utility
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function Tween(obj, time, props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        props
    )
    t:Play()
end

local function MakeDraggable(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function AutoScale(frame)
    local scale = math.clamp(Camera.ViewportSize.X / 900, 0.75, 1)
    frame.Size = UDim2.fromOffset(540 * scale, 420 * scale)
end

--// Create Window
function Skeleton:CreateWindow(options)
    options = options or {}
    local Window = {}

    local isMobile = UIS.TouchEnabled
    local visible = isMobile

    local Gui = CreateScreenGui("SkeletonUI")

    local Main = Create("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundColor3 = Theme.Background,
        Visible = visible,
        Parent = Gui
    })
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)
    AutoScale(Main)

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        AutoScale(Main)
    end)

    local Top = Create("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,14)

    Create("TextLabel", {
        Text = tostring(options.Name or "Skeleton UI"),
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,12,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Main, Top)

    local Tabs = Create("Frame", {
        Size = UDim2.new(0,150,1,-48),
        Position = UDim2.new(0,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local Pages = Create("Frame", {
        Size = UDim2.new(1,-150,1,-48),
        Position = UDim2.new(0,150,0,48),
        BackgroundTransparency = 1,
        Parent = Main
    })

    local function ToggleUI()
        visible = not visible
        Main.Visible = visible
    end

    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.UserInputType == Enum.UserInputType.Keyboard
        and i.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            ToggleUI()
        end
    end)

    if isMobile then
        local btn = Create("TextButton", {
            Size = UDim2.fromOffset(50,50),
            Position = UDim2.new(0,20,0.7,0),
            Text = "☠",
            Font = Enum.Font.GothamBold,
            TextSize = 22,
            BackgroundColor3 = Theme.Secondary,
            TextColor3 = Theme.Text,
            Parent = Gui
        })
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
        btn.MouseButton1Click:Connect(ToggleUI)
        MakeDraggable(btn, btn)
    end

    -- Tabs
    function Window:CreateTab(name)
        local Tab = {}

        local Button = Create("TextButton", {
            Text = tostring(name),
            Size = UDim2.new(1,-12,0,38),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = Tabs
        })
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(),
            ScrollBarImageTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,12)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
        end)

        Button.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    p.Visible = false
                end
            end
            Page.Visible = true
        end)

        -- Sections
        function Tab:AddSection(title)
            local Section = {}

            Create("TextLabel", {
                Text = tostring(title),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,-12,0,20),
                Parent = Page
            })

            local Container = Create("Frame", {
                Size = UDim2.new(1,-12,0,0),
                BackgroundTransparency = 1,
                Parent = Page
            })

            local CLayout = Instance.new("UIListLayout", Container)
            CLayout.Padding = UDim.new(0,8)

            CLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1,0,0,CLayout.AbsoluteContentSize.Y)
            end)

            function Section:AddButton(opt)
                opt = opt or {}
                local b = Create("TextButton", {
                    Text = tostring(opt.Name or "Button"),
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
                b.MouseButton1Click:Connect(function()
                    if typeof(opt.Callback) == "function" then
                        opt.Callback()
                    end
                end)
            end

            function Section:AddToggle(opt)
                opt = opt or {}
                local state = opt.Default or false

                local t = Create("TextButton", {
                    Text = (opt.Name or "Toggle") .. ": " .. (state and "ON" or "OFF"),
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", t).CornerRadius = UDim.new(0,10)

                t.MouseButton1Click:Connect(function()
                    state = not state
                    t.Text = (opt.Name or "Toggle") .. ": " .. (state and "ON" or "OFF")
                    if typeof(opt.Callback) == "function" then
                        opt.Callback(state)
                    end
                end)
            end

            function Section:AddTextbox(opt)
                opt = opt or {}
                local box = Create("TextBox", {
                    PlaceholderText = opt.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

                box.FocusLost:Connect(function()
                    if typeof(opt.Callback) == "function" then
                        opt.Callback(box.Text)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeletond
    return obj
end

local function Tween(obj, t, props)
    local ok, tween = pcall(function()
        return TweenService:Create(
            obj,
            TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
            props
        )
    end)

    if ok and tween then
        tween:Play()
    else
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
end

local function MakeDraggable(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function AutoScale(frame)
    local size = Camera.ViewportSize
    local scale = math.clamp(size.X / 900, 0.75, 1)
    frame.Size = UDim2.new(0, 540 * scale, 0, 420 * scale)
end

----------------------------------------------------------------
--// Theme
----------------------------------------------------------------
local Theme = {
    Background = Color3.fromRGB(18,18,20),
    Secondary  = Color3.fromRGB(28,28,32),
    Accent     = Color3.fromRGB(120,180,255),
    Text       = Color3.fromRGB(235,235,235),
}

----------------------------------------------------------------
--// Window
----------------------------------------------------------------
function Skeleton:CreateWindow(options)
    options = options or {}
    local Window = {}

    local isMobile = UIS.TouchEnabled
    local isVisible = isMobile
    local toggling = false

    -- ScreenGui
    local Gui = CreateScreenGui("SkeletonUI")

    -- Shadow
    local Shadow = Create("ImageLabel", {
        Image = "rbxassetid://1316045217",
        BackgroundTransparency = 1,
        ImageTransparency = 0.75,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10,10,118,118),
        Parent = Gui
    })

    -- Main Frame
    local Main = Create("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundColor3 = Theme.Background,
        Visible = isVisible,
        Parent = Gui
    })
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

    AutoScale(Main)
    Shadow.Size = Main.Size + UDim2.fromOffset(24,24)
    Shadow.Position = Main.Position - UDim2.fromOffset(12,12)
    Shadow.Visible = isVisible

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        AutoScale(Main)
        Shadow.Size = Main.Size + UDim2.fromOffset(24,24)
    end)

    -- Topbar
    local Top = Create("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,14)

    Create("TextLabel", {
        Text = typeof(options.Name) == "string" and options.Name or "Skeleton UI",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,12,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Main, Top)

    ----------------------------------------------------------------
    -- Toggle
    ----------------------------------------------------------------
    local function ToggleUI()
        if toggling then return end
        toggling = true
        isVisible = not isVisible

        if isVisible then
            Main.Visible = true
            Shadow.Visible = true
            Tween(Main, 0.25, {BackgroundTransparency = 0})
        else
            Tween(Main, 0.25, {BackgroundTransparency = 1})
            task.delay(0.25, function()
                Main.Visible = false
                Shadow.Visible = false
            end)
        end

        task.delay(0.25, function()
            toggling = false
        end)
    end

    -- Keyboard Toggle
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            ToggleUI()
        end
    end)

    -- Mobile Toggle Button
    local MobileBtn = Create("TextButton", {
        Size = UDim2.new(0,50,0,50),
        Position = UDim2.new(0,20,0.7,0),
        Text = "☠",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundColor3 = Theme.Secondary,
        TextColor3 = Theme.Text,
        ZIndex = 999,
        Parent = Gui,
        Visible = isMobile
    })
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1,0)
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    MakeDraggable(MobileBtn, MobileBtn)

    ----------------------------------------------------------------
    -- Tabs / Pages
    ----------------------------------------------------------------
    local Tabs = Create("Frame", {
        Size = UDim2.new(0,150,1,-48),
        Position = UDim2.new(0,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local Pages = Create("Frame", {
        Size = UDim2.new(1,-150,1,-48),
        Position = UDim2.new(0,150,0,48),
        BackgroundTransparency = 1,
        Parent = Main
    })

    ----------------------------------------------------------------
    -- Create Tab
    ----------------------------------------------------------------
    function Window:CreateTab(name)
        local Tab = {}

        local Button = Create("TextButton", {
            Text = name,
            Size = UDim2.new(1,-12,0,38),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = Tabs
        })
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(),
            Visible = false,
            Parent = Pages
        })

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,12)

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
        end)

        Button.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    p.Visible = false
                end
            end
            Page.Visible = true
        end)

        ----------------------------------------------------------------
        -- Section
        ----------------------------------------------------------------
        function Tab:AddSection(title)
            local Section = {}

            local Holder = Create("Frame", {
                Size = UDim2.new(1,-12,0,30),
                BackgroundTransparency = 1,
                Parent = Page
            })

            Create("TextLabel", {
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,20),
                Parent = Holder
            })

            local Container = Create("Frame", {
                Position = UDim2.new(0,0,0,24),
                BackgroundTransparency = 1,
                Parent = Holder
            })

            local List = Instance.new("UIListLayout", Container)
            List.Padding = UDim.new(0,8)

            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y)
                Holder.Size = UDim2.new(1,-12,0,List.AbsoluteContentSize.Y + 30)
            end)

            function Section:AddButton(opt)
                if typeof(opt.Callback) ~= "function" then return end
                local b = Create("TextButton", {
                    Text = opt.Name or "Button",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
                b.MouseButton1Click:Connect(opt.Callback)
            end

            function Section:AddToggle(opt)
                local state = opt.Default or false
                if typeof(opt.Callback) ~= "function" then return end

                local t = Create("TextButton", {
                    Text = opt.Name .. ": " .. (state and "ON" or "OFF"),
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", t).CornerRadius = UDim.new(0,10)

                t.MouseButton1Click:Connect(function()
                    state = not state
                    t.Text = opt.Name .. ": " .. (state and "ON" or "OFF")
                    opt.Callback(state)
                end)
            end

            function Section:AddTextbox(opt)
                if typeof(opt.Callback) ~= "function" then return end

                local box = Create("TextBox", {
                    PlaceholderText = opt.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

                box.FocusLost:Connect(function()
                    opt.Callback(box.Text)
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton}

--// Tween helper
local function Tween(obj,time,props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
        props
    )
    t:Play()
end

--// Drag (mouse + touch)
local function MakeDraggable(frame, handle)
    local drag, startPos, startInput

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startInput = i.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

--// Auto scale
local function AutoScale(frame)
    local scale = math.clamp(Camera.ViewportSize.X / 900, 0.75, 1)
    frame.Size = UDim2.new(0, 540 * scale, 0, 420 * scale)
end

--// Window
function Skeleton:CreateWindow(options)
    options = options or {}
    local Window = {}

    local Gui = CreateScreenGui("SkeletonUI")
    local Visible = UIS.TouchEnabled

    local Main = Instance.new("Frame", Gui)
    Main.AnchorPoint = Vector2.new(0.5,0.5)
    Main.Position = UDim2.fromScale(0.5,0.5)
    Main.BackgroundColor3 = Theme.Background
    Main.Visible = Visible
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)
    AutoScale(Main)

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        AutoScale(Main)
    end)

    -- Topbar
    local Top = Instance.new("Frame", Main)
    Top.Size = UDim2.new(1,0,0,46)
    Top.BackgroundColor3 = Theme.Secondary
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,14)

    local Title = Instance.new("TextLabel", Top)
    Title.Text = options.Name or "Skeleton UI"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextColor3 = Theme.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1,-20,1,0)
    Title.Position = UDim2.new(0,10,0,0)
    Title.TextXAlignment = Left

    MakeDraggable(Main, Top)

    -- Tabs
    local Tabs = Instance.new("Frame", Main)
    Tabs.Position = UDim2.new(0,0,0,46)
    Tabs.Size = UDim2.new(0,150,1,-46)
    Tabs.BackgroundColor3 = Theme.Secondary

    local Pages = Instance.new("Frame", Main)
    Pages.Position = UDim2.new(0,150,0,46)
    Pages.Size = UDim2.new(1,-150,1,-46)
    Pages.BackgroundTransparency = 1

    -- Toggle UI
    local function Toggle()
        Visible = not Visible
        Main.Visible = Visible
    end

    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            Toggle()
        end
    end)

    if UIS.TouchEnabled then
        local Mobile = Instance.new("TextButton", Gui)
        Mobile.Size = UDim2.new(0,48,0,48)
        Mobile.Position = UDim2.new(0,20,0.6,0)
        Mobile.Text = "☠"
        Mobile.Font = Enum.Font.GothamBold
        Mobile.TextSize = 22
        Mobile.BackgroundColor3 = Theme.Secondary
        Mobile.TextColor3 = Theme.Text
        Instance.new("UICorner", Mobile).CornerRadius = UDim.new(1,0)
        Mobile.MouseButton1Click:Connect(Toggle)
        MakeDraggable(Mobile, Mobile)
    end

    -- Create Tab
    function Window:CreateTab(name)
        local Tab = {}

        local Btn = Instance.new("TextButton", Tabs)
        Btn.Size = UDim2.new(1,-12,0,36)
        Btn.Text = name
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 13
        Btn.TextColor3 = Theme.Text
        Btn.BackgroundColor3 = Theme.Background
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1,0,1,0)
        Page.ScrollBarImageTransparency = 1
        Page.Visible = false
        Page.CanvasSize = UDim2.new()

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,12)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            Page.Visible = true
        end)

        function Tab:AddSection(title)
            local Section = {}

            local Holder = Instance.new("Frame", Page)
            Holder.BackgroundTransparency = 1
            Holder.Size = UDim2.new(1,-12,0,30)

            local Label = Instance.new("TextLabel", Holder)
            Label.Text = title
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.BackgroundTransparency = 1
            Label.Size = UDim2.new(1,0,0,20)

            local Container = Instance.new("Frame", Holder)
            Container.Position = UDim2.new(0,0,0,24)
            Container.BackgroundTransparency = 1

            local CL = Instance.new("UIListLayout", Container)
            CL.Padding = UDim.new(0,8)

            CL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1,0,0,CL.AbsoluteContentSize.Y)
                Holder.Size = UDim2.new(1,-12,0,CL.AbsoluteContentSize.Y + 30)
                Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
            end)

            function Section:AddButton(o)
                local b = Instance.new("TextButton", Container)
                b.Size = UDim2.new(1,0,0,40)
                b.Text = o.Name
                b.Font = Enum.Font.Gotham
                b.TextSize = 13
                b.TextColor3 = Theme.Text
                b.BackgroundColor3 = Theme.Secondary
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
                b.MouseButton1Click:Connect(function()
                    if o.Callback then o.Callback() end
                end)
            end

            function Section:AddToggle(o)
                local state = o.Default or false
                local t = Instance.new("TextButton", Container)
                t.Size = UDim2.new(1,0,0,40)
                t.Font = Enum.Font.Gotham
                t.TextSize = 13
                t.BackgroundColor3 = Theme.Secondary
                t.TextColor3 = Theme.Text
                Instance.new("UICorner", t).CornerRadius = UDim.new(0,8)

                local function Refresh()
                    t.Text = o.Name .. ": " .. (state and "ON" or "OFF")
                end

                Refresh()
                t.MouseButton1Click:Connect(function()
                    state = not state
                    Refresh()
                    if o.Callback then o.Callback(state) end
                end)
            end

            function Section:AddTextbox(o)
                local box = Instance.new("TextBox", Container)
                box.Size = UDim2.new(1,0,0,40)
                box.PlaceholderText = o.Placeholder
                box.ClearTextOnFocus = false
                box.Font = Enum.Font.Gotham
                box.TextSize = 13
                box.TextColor3 = Theme.Text
                box.BackgroundColor3 = Theme.Secondary
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)
                box.FocusLost:Connect(function()
                    if o.Callback then o.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeletonstate and "ON" or "OFF")
                    if opt.Callback then opt.Callback(state) end
                end)
            end

            function Section:AddTextbox(opt)
                local box = Create("TextBox", {
                    PlaceholderText = opt.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)
                box.FocusLost:Connect(function()
                    if opt.Callback then opt.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton    end

            function Section:AddTextbox(opt)
                local box = Create("TextBox", {
                    PlaceholderText = opt.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)
                box.FocusLost:Connect(function()
                    if opt.Callback then opt.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton        if opt.Callback then opt.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton)
    Create("UICorner", {CornerRadius = UDim.new(0,10), Parent = Top})

    local Title = Create("TextLabel", {
        Text = options.Name or "Skeleton UI v1.2",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Main, Top)

    -- Tabs
    local TabsHolder = Create("Frame", {
        Size = UDim2.new(0,150,1,-45),
        Position = UDim2.new(0,0,0,45),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local TabsLayout = Create("UIListLayout", {
        Padding = UDim.new(0,6),
        Parent = TabsHolder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    -- Pages
    local Pages = Create("Frame", {
        Size = UDim2.new(1,-150,1,-45),
        Position = UDim2.new(0,150,0,45),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- Toggle UI
    local function ToggleUI()
        GuiVisible = not GuiVisible
        Main.Visible = GuiVisible
    end

    UIS.InputBegan:Connect(function(input,gp)
        if not gp and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            ToggleUI()
        end
    end)

    -- Mobile Toggle Button
    local MobileBtn = Create("TextButton", {
        Size = UDim2.new(0,48,0,48),
        Position = UDim2.new(0,20,0.5,-24),
        Text = "☠",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundColor3 = Theme.Secondary,
        TextColor3 = Theme.Text,
        Visible = UIS.TouchEnabled,
        Parent = ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(1,0), Parent = MobileBtn})
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    MakeDraggable(MobileBtn, MobileBtn)

    -- Create Tab
    function Window:CreateTab(name)
        local Tab = {}

        local TabBtn = Create("TextButton", {
            Text = name,
            Size = UDim2.new(1,-12,0,36),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = TabsHolder
        })
        Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = TabBtn})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(),
            ScrollBarImageTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local PageLayout = Create("UIListLayout", {
            Padding = UDim.new(0,12),
            Parent = Page
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 12)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            Page.Visible = true
        end)

        -- Section
        function Tab:AddSection(title)
            local Section = {}

            local Holder = Create("Frame", {
                Size = UDim2.new(1,-12,0,32),
                BackgroundTransparency = 1,
                Parent = Page
            })

            local Label = Create("TextLabel", {
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,20),
                Parent = Holder
            })

            local Divider = Create("Frame", {
                Size = UDim2.new(1,0,0,1),
                Position = UDim2.new(0,0,0,24),
                BackgroundColor3 = Theme.Divider,
                Parent = Holder
            })

            local Container = Create("Frame", {
                Size = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,0,30),
                BackgroundTransparency = 1,
                Parent = Holder
            })

            local Layout = Create("UIListLayout", {
                Padding = UDim.new(0,8),
                Parent = Container
            })

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1,0,0,Layout.AbsoluteContentSize.Y)
                Holder.Size = UDim2.new(1,-12,0,Layout.AbsoluteContentSize.Y + 38)
            end)

            function Section:AddButton(o)
                local b = Create("TextButton", {
                    Text = o.Name or "Button",
                    Size = UDim2.new(1,0,0,40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = b})
                b.MouseButton1Click:Connect(function()
                    if o.Callback then o.Callback() end
                end)
            end

            function Section:AddToggle(o)
                local state = o.Default or false
                local t = Create("TextButton", {
                    Text = o.Name .. ": " .. (state and "ON" or "OFF"),
                    Size = UDim2.new(1,0,0,40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = t})
                t.MouseButton1Click:Connect(function()
                    state = not state
                    t.Text = o.Name .. ": " .. (state and "ON" or "OFF")
                    if o.Callback then o.Callback(state) end
                end)
            end

            function Section:AddTextbox(o)
                local box = Create("TextBox", {
                    PlaceholderText = o.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = box})
                box.FocusLost:Connect(function()
                    if o.Callback then o.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// Window
function Skeleton:CreateWindow(options)
    options = options or {}

    local Window = {}

    local ScreenGui = Create("ScreenGui", {
        Name = "SkeletonUI",
        ResetOnSpawn = false,
        Parent = game.CoreGui
    })

    local Main = Create("Frame", {
        Size = UDim2.new(0, 540, 0, 400),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        Parent = ScreenGui
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Main})

    -- Topbar
    local Top = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Top})

    local Title = Create("TextLabel", {
        Text = options.Name or "Skeleton UI Library",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Main, Top)

    -- Tabs
    local TabsHolder = Create("Frame", {
        Size = UDim2.new(0, 150, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local TabsLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = TabsHolder
    })
    TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Pages
    local Pages = Create("Frame", {
        Size = UDim2.new(1, -150, 1, -45),
        Position = UDim2.new(0, 150, 0, 45),
        BackgroundTransparency = 1,
        Parent = Main
    })

    --// Create Tab
    function Window:CreateTab(name)
        local Tab = {}

        local Button = Create("TextButton", {
            Text = name,
            Size = UDim2.new(1, -12, 0, 36),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = TabsHolder
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Button})

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarImageTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local PageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            Parent = Page
        })

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 12)
        end)

        Button.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then
                    p.Visible = false
                end
            end
            Page.Visible = true
        end)

        --// Section
        function Tab:AddSection(title)
            local Section = {}

            local Holder = Create("Frame", {
                Size = UDim2.new(1, -12, 0, 32),
                BackgroundTransparency = 1,
                Parent = Page
            })

            local Label = Create("TextLabel", {
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Parent = Holder
            })

            local Divider = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 0, 24),
                BackgroundColor3 = Theme.Divider,
                Parent = Holder
            })

            local Container = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = Holder
            })

            local Layout = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                Parent = Container
            })

            Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y)
                Holder.Size = UDim2.new(1, -12, 0, Layout.AbsoluteContentSize.Y + 38)
            end)

            --// Button
            function Section:AddButton(options)
                local Btn = Create("TextButton", {
                    Text = options.Name or "Button",
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})

                Btn.MouseButton1Click:Connect(function()
                    if options.Callback then
                        options.Callback()
                    end
                end)
            end

            --// Toggle
            function Section:AddToggle(options)
                local State = options.Default or false

                local Btn = Create("TextButton", {
                    Text = options.Name .. ": " .. (State and "ON" or "OFF"),
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Btn})

                Btn.MouseButton1Click:Connect(function()
                    State = not State
                    Btn.Text = options.Name .. ": " .. (State and "ON" or "OFF")
                    if options.Callback then
   --// Skeleton UI Library v1.3.1 (STABLE RELEASE)
--// Mobile + PC | Fancy | No Bugs

local Skeleton = {}
Skeleton.__index = Skeleton

--// Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

--// Theme
local Theme = {
    Background = Color3.fromRGB(18,18,20),
    Secondary  = Color3.fromRGB(28,28,32),
    Accent     = Color3.fromRGB(120,180,255),
    Text       = Color3.fromRGB(235,235,235),
    Divider    = Color3.fromRGB(55,55,60)
}

--// Utils
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k] = v end
    return obj
end

local function Tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quint), props):Play()
end

--// Drag (Touch + Mouse)
local function MakeDraggable(frame, handle)
    local dragging, startPos, startInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if dragging then
            local delta = input.Position - startInput
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

--// Auto Scale
local function AutoScale(frame)
    local size = Camera.ViewportSize
    local scale = math.clamp(size.X / 900, 0.75, 1)
    frame.Size = UDim2.new(0, 540 * scale, 0, 420 * scale)
end

--// Window
function Skeleton:CreateWindow(options)
    options = options or {}
    local Window = {}

    local isMobile = UIS.TouchEnabled
    local isVisible = isMobile

    -- ScreenGui
    local Gui = Create("ScreenGui", {
        Name = "SkeletonUI",
        Parent = game.CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })

    -- Shadow
    local Shadow = Create("ImageLabel", {
        Image = "rbxassetid://1316045217",
        BackgroundTransparency = 1,
        ImageTransparency = 0.75,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(10,10,118,118),
        Parent = Gui
    })

    -- Main
    local Main = Create("Frame", {
        AnchorPoint = Vector2.new(0.5,0.5),
        Position = UDim2.fromScale(0.5,0.5),
        BackgroundColor3 = Theme.Background,
        Visible = isVisible,
        Parent = Gui
    })
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

    AutoScale(Main)
    Shadow.Size = Main.Size + UDim2.fromOffset(24,24)
    Shadow.Position = Main.Position - UDim2.fromOffset(12,12)
    Shadow.Visible = isVisible

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        AutoScale(Main)
        Shadow.Size = Main.Size + UDim2.fromOffset(24,24)
    end)

    -- Topbar
    local Top = Create("Frame", {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })
    Instance.new("UICorner", Top).CornerRadius = UDim.new(0,14)

    Create("TextLabel", {
        Text = options.Name or "Skeleton UI v1.3.1",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,12,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Top
    })

    MakeDraggable(Main, Top)

    -- Toggle Function
    local function ToggleUI()
        isVisible = not isVisible

        if isVisible then
            Main.Visible = true
            Shadow.Visible = true
            Tween(Main, 0.25, {BackgroundTransparency = 0})
        else
            Tween(Main, 0.25, {BackgroundTransparency = 1})
            task.delay(0.25, function()
                Main.Visible = false
                Shadow.Visible = false
            end)
        end
    end

    -- PC Toggle
    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.UserInputType == Enum.UserInputType.Keyboard
        and input.KeyCode == (options.ToggleKey or Enum.KeyCode.RightShift) then
            ToggleUI()
        end
    end)

    -- Mobile Button
    local MobileBtn = Create("TextButton", {
        Size = UDim2.new(0,50,0,50),
        Position = UDim2.new(0,20,0.7,0),
        Text = "☠",
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        BackgroundColor3 = Theme.Secondary,
        TextColor3 = Theme.Text,
        ZIndex = 999,
        Parent = Gui
    })
    Instance.new("UICorner", MobileBtn).CornerRadius = UDim.new(1,0)
    MobileBtn.Visible = isMobile
    MobileBtn.MouseButton1Click:Connect(ToggleUI)
    MakeDraggable(MobileBtn, MobileBtn)

    -- Tabs
    local Tabs = Create("Frame", {
        Size = UDim2.new(0,150,1,-48),
        Position = UDim2.new(0,0,0,48),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local Pages = Create("Frame", {
        Size = UDim2.new(1,-150,1,-48),
        Position = UDim2.new(0,150,0,48),
        BackgroundTransparency = 1,
        Parent = Main
    })

    -- Create Tab
    function Window:CreateTab(name)
        local Tab = {}

        local Btn = Create("TextButton", {
            Text = name,
            Size = UDim2.new(1,-12,0,38),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = Tabs
        })
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            ScrollBarImageTransparency = 1,
            CanvasSize = UDim2.new(),
            Visible = false,
            Parent = Pages
        })

        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0,12)

        Btn.MouseButton1Click:Connect(function()
            for _,p in pairs(Pages:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            Page.Visible = true
        end)

        -- Section
        function Tab:AddSection(title)
            local Section = {}

            local Holder = Create("Frame", {
                Size = UDim2.new(1,-12,0,30),
                BackgroundTransparency = 1,
                Parent = Page
            })

            Create("TextLabel", {
                Text = title,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Text,
                BackgroundTransparency = 1,
                Size = UDim2.new(1,0,0,20),
                Parent = Holder
            })

            local Container = Create("Frame", {
                Position = UDim2.new(0,0,0,24),
                BackgroundTransparency = 1,
                Parent = Holder
            })

            local List = Instance.new("UIListLayout", Container)
            List.Padding = UDim.new(0,8)

            List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y)
                Holder.Size = UDim2.new(1,-12,0,List.AbsoluteContentSize.Y + 30)
                Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
            end)

            function Section:AddButton(opt)
                local b = Create("TextButton", {
                    Text = opt.Name or "Button",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
                b.MouseButton1Click:Connect(function()
                    if opt.Callback then opt.Callback() end
                end)
            end

            function Section:AddToggle(opt)
                local state = opt.Default or false
                local t = Create("TextButton", {
                    Text = opt.Name .. ": " .. (state and "ON" or "OFF"),
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    Parent = Container
                })
                Instance.new("UICorner", t).CornerRadius = UDim.new(0,10)
                t.MouseButton1Click:Connect(function()
                    state = not state
                    t.Text = opt.Name .. ": " .. (state and "ON" or "OFF")
                    if opt.Callback then opt.Callback(state) end
                end)
            end

            function Section:AddTextbox(opt)
                local box = Create("TextBox", {
                    PlaceholderText = opt.Placeholder or "Enter text...",
                    Size = UDim2.new(1,0,0,42),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)
                box.FocusLost:Connect(function()
                    if opt.Callback then opt.Callback(box.Text) end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton                     options.Callback(State)
                    end
                end)
            end

            --// Textbox
            function Section:AddTextbox(options)
                local Box = Create("TextBox", {
                    PlaceholderText = options.Placeholder or "Enter text...",
                    Size = UDim2.new(1, 0, 0, 40),
                    BackgroundColor3 = Theme.Secondary,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    ClearTextOnFocus = false,
                    Parent = Container
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Box})

                Box.FocusLost:Connect(function()
                    if options.Callback then
                        options.Callback(Box.Text)
                    end
                end)
            end

            return Section
        end

        return Tab
    end

    return Window
end

return Skeleton
