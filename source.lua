--// Skeleton UI Library v1
--// Clean • Lightweight • Rayfield Inspired

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
    Text = Color3.fromRGB(240,240,240)
}

--// Utility
local function Create(instance, props)
    local obj = Instance.new(instance)
    for i,v in pairs(props) do
        obj[i] = v
    end
    return obj
end

--// Drag
local function MakeDraggable(frame, handle)
    local dragging, dragInput, startPos, startFramePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = input.Position
            startFramePos = frame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(
                startFramePos.X.Scale,
                startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale,
                startFramePos.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

--// Create Window
function Skeleton:CreateWindow(options)
    local Window = {}

    local ScreenGui = Create("ScreenGui", {
        Name = "SkeletonUI",
        Parent = game.CoreGui
    })

    local Main = Create("Frame", {
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        Parent = ScreenGui
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Main
    })

    local TopBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = TopBar
    })

    local Title = Create("TextLabel", {
        Text = options.Name or "Skeleton UI",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Left,
        Parent = TopBar
    })

    MakeDraggable(Main, TopBar)

    local TabsHolder = Create("Frame", {
        Size = UDim2.new(0, 140, 1, -45),
        Position = UDim2.new(0, 0, 0, 45),
        BackgroundColor3 = Theme.Secondary,
        Parent = Main
    })

    local UIList = Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = TabsHolder
    })

    UIList.HorizontalAlignment = Center

    local Pages = Create("Frame", {
        Size = UDim2.new(1, -140, 1, -45),
        Position = UDim2.new(0, 140, 0, 45),
        BackgroundTransparency = 1,
        Parent = Main
    })

    function Window:CreateTab(name)
        local Tab = {}

        local TabButton = Create("TextButton", {
            Text = name,
            Size = UDim2.new(1, -10, 0, 36),
            BackgroundColor3 = Theme.Background,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            Parent = TabsHolder
        })

        Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = TabButton
        })

        local Page = Create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0,0,0,0),
            ScrollBarImageTransparency = 1,
            Visible = false,
            Parent = Pages
        })

        local Layout = Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            Parent = Page
        })

        Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _,v in pairs(Pages:GetChildren()) do
                if v:IsA("ScrollingFrame") then
                    v.Visible = false
                end
            end
            Page.Visible = true
        end)

        --// Button
        function Tab:AddButton(options)
            local Btn = Create("TextButton", {
                Text = options.Name,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                Parent = Page
            })

            Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = Btn})

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Secondary}):Play()
                options.Callback()
            end)
        end

        --// Toggle
        function Tab:AddToggle(options)
            local Toggle = false

            local Btn = Create("TextButton", {
                Text = options.Name .. ": OFF",
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                Parent = Page
            })

            Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = Btn})

            Btn.MouseButton1Click:Connect(function()
                Toggle = not Toggle
                Btn.Text = options.Name .. ": " .. (Toggle and "ON" or "OFF")
                options.Callback(Toggle)
            end)
        end

        --// Textbox
        function Tab:AddTextbox(options)
            local Box = Create("TextBox", {
                PlaceholderText = options.Placeholder,
                Size = UDim2.new(1, -10, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                ClearTextOnFocus = false,
                Parent = Page
            })

            Create("UICorner", {CornerRadius = UDim.new(0,8), Parent = Box})

            Box.FocusLost:Connect(function()
                options.Callback(Box.Text)
            end)
        end

        return Tab
    end

    return Window
end

return Skeleton
