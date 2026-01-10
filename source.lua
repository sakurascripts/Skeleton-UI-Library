--// Skeleton UI Library v1.1
--// Stable • Sectioned • Clean

local Skeleton = {}
Skeleton.__index = Skeleton

--// Services
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

--// Theme
local Theme = {
    Background = Color3.fromRGB(20,20,20),
    Secondary = Color3.fromRGB(30,30,30),
    Accent = Color3.fromRGB(220,220,220),
    Text = Color3.fromRGB(240,240,240),
    Divider = Color3.fromRGB(45,45,45)
}

--// Utility
local function Create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

--// Drag System
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
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
                        options.Callback(State)
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
