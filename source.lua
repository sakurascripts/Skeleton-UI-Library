local Skeleton = {}
Skeleton.__index = Skeleton

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-------------------------------------------------
-- WINDOW
-------------------------------------------------
function Skeleton.new(title)
	assert(title, "Skeleton.new requires title")

	local self = setmetatable({}, Skeleton)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SkeletonUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	self.ScreenGui = ScreenGui

	-- Open Button
	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.fromOffset(48,48)
	OpenBtn.Position = UDim2.new(0.5,-24,0,10)
	OpenBtn.Text = "💀"
	OpenBtn.TextScaled = true
	OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	OpenBtn.BackgroundTransparency = 0.15
	OpenBtn.Parent = ScreenGui
	Instance.new("UICorner",OpenBtn).CornerRadius = UDim.new(1,0)

	-- Window
	local Window = Instance.new("Frame")
	Window.Size = UDim2.fromOffset(520,360)
	Window.Position = UDim2.new(0.5,-260,0.5,-180)
	Window.BackgroundColor3 = Color3.fromRGB(25,25,30)
	Window.BackgroundTransparency = 0.2
	Window.Visible = false
	Window.Parent = ScreenGui
	Instance.new("UICorner",Window).CornerRadius = UDim.new(0,16)
	self.Window = Window

	-- Drag
	local dragging, dragStart, startPos
	Window.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = Window.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			Window.Position = startPos + UDim2.fromOffset(delta.X,delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	OpenBtn.MouseButton1Click:Connect(function()
		Window.Visible = not Window.Visible
	end)

	-- Header
	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1,-20,0,40)
	Header.Position = UDim2.fromOffset(10,10)
	Header.BackgroundTransparency = 1
	Header.Text = title
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 22
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextColor3 = Color3.fromRGB(240,240,255)
	Header.Parent = Window

	-- Tabs (Left)
	local TabBar = Instance.new("ScrollingFrame")
	TabBar.Size = UDim2.fromOffset(140,260)
	TabBar.Position = UDim2.fromOffset(10,60)
	TabBar.ScrollBarThickness = 4
	TabBar.CanvasSize = UDim2.new()
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Window
	self.TabBar = TabBar

	local TabLayout = Instance.new("UIListLayout",TabBar)
	TabLayout.Padding = UDim.new(0,6)
	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabBar.CanvasSize = UDim2.new(0,0,0,TabLayout.AbsoluteContentSize.Y + 6)
	end)

	-- Content
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1,-170,1,-70)
	Content.Position = UDim2.fromOffset(160,60)
	Content.BackgroundTransparency = 1
	Content.Parent = Window
	self.Content = Content

	self.ActiveTab = nil
	return self
end

-------------------------------------------------
-- TAB
-------------------------------------------------
function Skeleton:AddTab(name)
	local Tab = {}

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1,0,0,40)
	Btn.Text = name
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 15
	Btn.BackgroundColor3 = Color3.fromRGB(45,45,60)
	Btn.BackgroundTransparency = 0.2
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.Parent = self.TabBar
	Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,10)

	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1,0,1,0)
	Page.CanvasSize = UDim2.new()
	Page.ScrollBarThickness = 6
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.Parent = self.Content

	local Layout = Instance.new("UIListLayout",Page)
	Layout.Padding = UDim.new(0,10)
	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
	end)

	Btn.MouseButton1Click:Connect(function()
		if self.ActiveTab then
			self.ActiveTab.Page.Visible = false
		end
		Page.CanvasPosition = Vector2.zero
		Page.Visible = true
		self.ActiveTab = Tab
	end)

	if not self.ActiveTab then
		Page.Visible = true
		self.ActiveTab = Tab
	end

	Tab.Page = Page

	-------------------------------------------------
	-- SECTION
	-------------------------------------------------
	function Tab:AddSection()
		local Section = {}

		local Holder = Instance.new("Frame")
		Holder.Size = UDim2.new(1,0,0,0)
		Holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Holder.BackgroundTransparency = 0.2
		Holder.Parent = Page
		Instance.new("UICorner",Holder).CornerRadius = UDim.new(0,12)

		local List = Instance.new("UIListLayout",Holder)
		List.Padding = UDim.new(0,8)
		List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Holder.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y + 10)
		end)

		function Section:AddButton(text, cb)
			local B = Instance.new("TextButton")
			B.Size = UDim2.new(1,-20,0,40)
			B.Position = UDim2.fromOffset(10,0)
			B.Text = text
			B.Font = Enum.Font.Gotham
			B.TextSize = 15
			B.BackgroundColor3 = Color3.fromRGB(0,170,255)
			B.BackgroundTransparency = 0.15
			B.TextColor3 = Color3.new(1,1,1)
			B.Parent = Holder
			Instance.new("UICorner",B).CornerRadius = UDim.new(1,0)

			B.MouseButton1Click:Connect(function()
				task.spawn(cb)
			end)
		end

		function Section:AddToggle(text, cb)
			local Row = Instance.new("Frame")
			Row.Size = UDim2.new(1,-20,0,40)
			Row.Position = UDim2.fromOffset(10,0)
			Row.BackgroundTransparency = 1
			Row.Parent = Holder

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-70,1,0)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Text = text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 15
			Label.TextColor3 = Color3.fromRGB(220,220,240)
			Label.Parent = Row

			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.fromOffset(50,24)
			Toggle.Position = UDim2.new(1,-55,0.5,-12)
			Toggle.Text = ""
			Toggle.BackgroundColor3 = Color3.fromRGB(120,120,120)
			Toggle.Parent = Row
			Instance.new("UICorner",Toggle).CornerRadius = UDim.new(1,0)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.fromOffset(20,20)
			Knob.Position = UDim2.fromOffset(2,2)
			Knob.BackgroundColor3 = Color3.fromRGB(240,240,255)
			Knob.Parent = Toggle
			Instance.new("UICorner",Knob).CornerRadius = UDim.new(1,0)

			local State = false
			Toggle.MouseButton1Click:Connect(function()
				State = not State
				TweenService:Create(Knob,TweenInfo.new(0.15),{
					Position = State and UDim2.new(1,-22,0,2) or UDim2.fromOffset(2,2)
				}):Play()
				cb(State)
			end)
		end

		return Section
	end

	return Tab
end

print("Skeleton UI Loaded")
return Skeleton
