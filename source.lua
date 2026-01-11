--// Skeleton Hub UI Library
--// Premium, Clean, Bug-free

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-------------------------------------------------
-- LIB TABLE
-------------------------------------------------
local Skeleton = {}
Skeleton.__index = Skeleton

-------------------------------------------------
-- SCREEN GUI
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkeletonHub"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-------------------------------------------------
-- FLOATING OPEN BUTTON
-------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 56, 0, 56)
OpenBtn.Position = UDim2.new(0, 20, 1, -90)
OpenBtn.Text = "💀"
OpenBtn.TextScaled = true
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

-------------------------------------------------
-- DRAG BUTTON (PC + MOBILE)
-------------------------------------------------
do
	local dragging, dragStart, startPos

	OpenBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = OpenBtn.Position
		end
	end)

	OpenBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			OpenBtn.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-------------------------------------------------
-- CREATE WINDOW
-------------------------------------------------
function Skeleton.new(title)
	assert(title, "Skeleton.new(title) | title is required")

	local self = setmetatable({}, Skeleton)

	-------------------------------------------------
	-- MAIN PANEL
	-------------------------------------------------
	local Panel = Instance.new("Frame")
	Panel.Size = UDim2.new(0, 420, 0, 300)
	Panel.Position = UDim2.new(0.5, -210, 0.5, -150)
	Panel.BackgroundColor3 = Color3.fromRGB(25,25,30)
	Panel.Visible = true
	Panel.Parent = ScreenGui
	Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,16)

	self.Panel = Panel
	self.Tabs = {}

	-------------------------------------------------
	-- HEADER (WINDOW TITLE)
	-------------------------------------------------
	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -20, 0, 40)
	Header.Position = UDim2.new(0, 10, 0, 10)
	Header.BackgroundTransparency = 1
	Header.Text = title
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 22
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextYAlignment = Enum.TextYAlignment.Center
	Header.TextColor3 = Color3.fromRGB(240,240,255)
	Header.Parent = Panel

	-------------------------------------------------
	-- TAB BUTTON BAR
	-------------------------------------------------
	local TabBar = Instance.new("ScrollingFrame")
	TabBar.Size = UDim2.new(1, -20, 0, 42)
	TabBar.Position = UDim2.new(0, 10, 0, 55)
	TabBar.CanvasSize = UDim2.new(0,0,0,0)
	TabBar.ScrollBarImageTransparency = 1
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Panel

	local TabLayout = Instance.new("UIListLayout", TabBar)
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0, 6)

	-------------------------------------------------
	-- TAB CONTENT HOLDER
	-------------------------------------------------
	local ContentHolder = Instance.new("Frame")
	ContentHolder.Size = UDim2.new(1, -20, 1, -110)
	ContentHolder.Position = UDim2.new(0, 10, 0, 100)
	ContentHolder.BackgroundTransparency = 1
	ContentHolder.Parent = Panel

	self.ContentHolder = ContentHolder
	self.TabBar = TabBar

	-------------------------------------------------
	-- OPEN / CLOSE
	-------------------------------------------------
	OpenBtn.Activated:Connect(function()
		Panel.Visible = not Panel.Visible
	end)

	return self
end

-------------------------------------------------
-- CREATE TAB
-------------------------------------------------
function Skeleton:AddTab(name)
	local Tab = {}
	Tab.Sections = {}

	-------------------------------------------------
	-- TAB BUTTON
	-------------------------------------------------
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0, 110, 1, 0)
	Btn.Text = name
	Btn.TextScaled = true
	Btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.Parent = self.TabBar
	Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

	-------------------------------------------------
	-- TAB FRAME
	-------------------------------------------------
	local Frame = Instance.new("ScrollingFrame")
	Frame.Size = UDim2.new(1,0,1,0)
	Frame.CanvasSize = UDim2.new(0,0,0,0)
	Frame.ScrollBarImageTransparency = 1
	Frame.BackgroundTransparency = 1
	Frame.Visible = false
	Frame.Parent = self.ContentHolder

	local Layout = Instance.new("UIListLayout", Frame)
	Layout.Padding = UDim.new(0, 10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Frame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
	end)

	-------------------------------------------------
	-- TAB SWITCH
	-------------------------------------------------
	Btn.Activated:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Frame.Visible = false
			t.Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
		end
		Frame.Visible = true
		Btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
	end)

	-------------------------------------------------
	-- DEFAULT OPEN
	-------------------------------------------------
	if #self.Tabs == 0 then
		Frame.Visible = true
		Btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
	end

	Tab.Frame = Frame
	Tab.Button = Btn
	table.insert(self.Tabs, Tab)

	-------------------------------------------------
	-- SECTION (TITLELESS)
	-------------------------------------------------
	function Tab:AddSection()
		local Section = Instance.new("Frame")
		Section.Size = UDim2.new(1, 0, 0, 0)
		Section.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Section.BackgroundTransparency = 0.2
		Section.Parent = Frame
		Instance.new("UICorner", Section).CornerRadius = UDim.new(0,12)

		local Layout = Instance.new("UIListLayout", Section)
		Layout.Padding = UDim.new(0, 6)

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Section.Size = UDim2.new(1,0,0,Layout.AbsoluteContentSize.Y + 10)
		end)

		return Section
	end

	-------------------------------------------------
	-- BUTTON
	-------------------------------------------------
	function Tab:AddButton(section, text, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, -10, 0, 36)
		Btn.Position = UDim2.new(0, 5, 0, 0)
		Btn.Text = text
		Btn.TextScaled = true
		Btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.Parent = section
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

		Btn.Activated:Connect(function()
			if callback then callback() end
		end)
	end

	-------------------------------------------------
	-- TOGGLE
	-------------------------------------------------
	function Tab:AddToggle(section, text, callback)
		local Holder = Instance.new("Frame")
		Holder.Size = UDim2.new(1, -10, 0, 36)
		Holder.Position = UDim2.new(0, 5, 0, 0)
		Holder.BackgroundColor3 = Color3.fromRGB(45,45,60)
		Holder.Parent = section
		Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,10)

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(0.7,0,1,0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextScaled = true
		Label.TextColor3 = Color3.fromRGB(220,220,240)
		Label.Parent = Holder

		local Toggle = Instance.new("TextButton")
		Toggle.Size = UDim2.new(0, 50, 0, 22)
		Toggle.Position = UDim2.new(1, -60, 0.5, -11)
		Toggle.Text = ""
		Toggle.BackgroundColor3 = Color3.fromRGB(120,120,120)
		Toggle.Parent = Holder
		Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1,0)

		local Knob = Instance.new("Frame")
		Knob.Size = UDim2.new(0, 18, 0, 18)
		Knob.Position = UDim2.new(0, 2, 0.5, -9)
		Knob.BackgroundColor3 = Color3.fromRGB(240,240,255)
		Knob.Parent = Toggle
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

		local State = false

		Toggle.Activated:Connect(function()
			State = not State
			TweenService:Create(Knob, TweenInfo.new(0.15), {
				Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			}):Play()
			Toggle.BackgroundColor3 = State and Color3.fromRGB(0,170,120) or Color3.fromRGB(120,120,120)
			if callback then callback(State) end
		end)
	end

	return Tab
end

-------------------------------------------------
-- RETURN LIB
-------------------------------------------------
return Skeleton
