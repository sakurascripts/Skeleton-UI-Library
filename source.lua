-- Skeleton UI Library (Revamped, Polished, and Bug-Free)

local Library = {}
Library.__index = Library

-- Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Theme
local Theme = {
    Background = Color3.fromRGB(30, 30, 38),
    Secondary  = Color3.fromRGB(40, 40, 50),
    Accent     = Color3.fromRGB(0, 170, 255),
    Text       = Color3.fromRGB(235, 235, 235),
    ToggleOn   = Color3.fromRGB(0, 220, 100),
    ToggleOff  = Color3.fromRGB(120, 120, 120)
}

-- Create utility
local function Create(class, props)
    local obj = Instance.new(class)
    local parent = props and props.Parent
    if props then props.Parent = nil end
    for k,v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

-- Tween helper
local function PlayTween(obj,props)
    TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

-- Draggable (PC/Mobile)
local function MakeDraggable(frame, handle)
    local dragging, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
            input.UserInputType == Enum.UserInputType.Touch) then
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
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function Library.new(title)
    assert(title and type(title) == "string","Window title missing")

    local self = setmetatable({},Library)

    local gui = Create("ScreenGui",{
        Name = "SkeletonUI",
        ResetOnSpawn = false,
        Parent = PlayerGui
    })
    self.Gui = gui

    local main = Create("Frame",{
        Size = UDim2.fromOffset(520,400),
        Position = UDim2.new(0.5, -260, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        Parent = gui
    })
    Create("UICorner",{Parent=main,CornerRadius=UDim.new(0,14)})
    self.Main = main

    local top = Create("Frame",{
        Size = UDim2.new(1,0,0,45),
        BackgroundColor3 = Theme.Secondary,
        Parent = main
    })
    Create("UICorner",{Parent=top,CornerRadius=UDim.new(0,14)})

    Create("TextLabel",{
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = Theme.Text,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,10,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = top
    })

    MakeDraggable(main, top)

    local tabsBar = Create("Frame",{
        Size = UDim2.new(1,0,0,35),
        Position = UDim2.new(0,0,0,45),
        BackgroundTransparency = 1,
        Parent = main
    })

    local pagesHolder = Create("Frame",{
        Size = UDim2.new(1,0,1,-80),
        Position = UDim2.new(0,0,0,80),
        BackgroundTransparency = 1,
        Parent = main
    })
    self.Pages = pagesHolder
    self.TabsButtons = {}

    function self:AddTab(name)
        assert(name and type(name)=="string","Tab name missing")

        local tabBtn = Create("TextButton",{
            Text = name,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = Theme.Text,
            BackgroundColor3 = Theme.Secondary,
            Parent = tabsBar
        })
        Create("UICorner",{Parent=tabBtn,CornerRadius=UDim.new(0,8)})

        local page = Create("ScrollingFrame",{
            Size = UDim2.new(1,0,1,0),
            CanvasSize = UDim2.new(),
            ScrollBarThickness = 4,
            BackgroundTransparency = 1,
            Visible = false,
            Parent = pagesHolder
        })
        local layout = Create("UIListLayout",{Parent=page,Padding=UDim.new(0,8)})
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+10)
        end)

        table.insert(self.TabsButtons,tabBtn)

        tabBtn.MouseButton1Click:Connect(function()
            for _,p in ipairs(pagesHolder:GetChildren()) do
                if p:IsA("ScrollingFrame") then p.Visible = false end
            end
            page.Visible = true
            for _,btn in ipairs(self.TabsButtons) do
                btn.BackgroundColor3 = Theme.Secondary
            end
            tabBtn.BackgroundColor3 = Theme.Accent
        end)

        if #self.TabsButtons == 1 then
            tabBtn:MouseButton1Click()
        end

        return {
            AddSection = function(_,title)
                local sect = Create("Frame",{Size=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Parent=page})
                local header = Create("TextLabel",{
                    Text = title,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextColor3 = Theme.Text,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1,0,0,24),
                    Parent = sect
                })
                local container = Create("Frame",{Parent=sect,BackgroundTransparency=1})
                local contLayout = Create("UIListLayout",{Parent=container,Padding=UDim.new(0,6)})

                contLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    container.Size = UDim2.new(1,0,contLayout.AbsoluteContentSize.Y)
                    sect.Size = UDim2.new(1,-20,0,header.AbsoluteSize.Y + container.AbsoluteSize.Y)
                end)

                return {
                    AddButton = function(_,text,callback)
                        local b = Create("TextButton",{
                            Text=text,
                            Font=Enum.Font.Gotham,
                            TextSize=14,
                            TextColor3=Theme.Text,
                            BackgroundColor3=Theme.Secondary,
                            Size=UDim2.new(1,0,0,36),
                            Parent=container
                        })
                        Create("UICorner",{Parent=b,CornerRadius=UDim.new(0,8)})
                        b.MouseButton1Click:Connect(callback)
                    end,
                    AddToggle = function(_,text,callback)
                        local state=false
                        local row = Create("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Parent=container})
                        local label = Create("TextLabel",{
                            Text=text,
                            Font=Enum.Font.Gotham,
                            TextSize=14,
                            TextColor3=Theme.Text,
                            BackgroundTransparency=1,
                            Size=UDim2.new(0.7,0,1,0),
                            Parent=row
                        })
                        local btn = Create("TextButton",{Size=UDim2.new(0,36,0,24),BackgroundColor3=Theme.ToggleOff,Parent=row})
                        Create("UICorner",{Parent=btn,CornerRadius=UDim.new(1,0)})
                        btn.MouseButton1Click:Connect(function()
                            state = not state
                            callback(state)
                            btn.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
                        end)
                    end
                }
            end
        }
    end

    return self
end

return Library
