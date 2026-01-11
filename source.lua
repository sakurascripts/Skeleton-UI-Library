local Skeleton = {}
Skeleton.__index = Skeleton

-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-------------------------------------------------
-- CREATE WINDOW
-------------------------------------------------
function Skeleton.new(title)
	assert(title, "Skeleton.new requires a title")

	local self = setmetatable({}, Skeleton)

	-- ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SkeletonUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")
	self.ScreenGui = ScreenGui

	-- Open Button
	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.fromOffset(56,56)
	OpenBtn.Position = UDim2.new(0,20,1,-90)
	OpenBtn.Text = "💀"
	OpenBtn.TextScaled = true
	OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	OpenBtn.TextColor3 = Color3.new(1,1,1)
	OpenBtn.Parent = ScreenGui
	Instance.new("UICorner",OpenBtn).CornerRadius = UDim.new(1,0)

	-- Main Window
	local Window = Instance.new("Frame")
	Window.Size = UDim2.fromOffset(420,320)
	Window.Position = UDim2.new(0.5,-210,0.5,-160)
	Window.BackgroundColor3 = Color3.fromRGB(25,25,30)
	Window.Visible = true
	Window.Parent = ScreenGui
	Instance.new("UICorner",Window).CornerRadius = UDim.new(0,16)
	self.Window = Window

	-- Header (WINDOW TITLE)
	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1,-20,0,40)
	Header.Position = UDim2.fromOffset(10,10)
	Header.BackgroundTransparency = 1
	Header.Text = title
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 22
	Header.TextColor3 = Color3.fromRGB(240,240,255)
	Header.Parent = Window

	-- Tabs Bar
	local TabBar = Instance.new("ScrollingFrame")
	TabBar.Size = UDim2.new(1,-20,0,40)
	TabBar.Position = UDim2.fromOffset(10,60)
	TabBar.CanvasSize = UDim2.new()
	TabBar.ScrollBarThickness = 0
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Window

	local TabLayout = Instance.new("UIListLayout",TabBar)
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0,6)

	self.Tabs = {}
	self.ActiveTab = nil

	-- Content Holder
	local ContentHolder = Instance.new("Frame")
	ContentHolder.Size = UDim2.new(1,-20,1,-120)
	ContentHolder.Position = UDim2.fromOffset(10,110)
	ContentHolder.BackgroundTransparency = 1
	ContentHolder.Parent = Window
	self.ContentHolder = ContentHolder

	-- Toggle window
	OpenBtn.MouseButton1Click:Connect(function()
		Window.Visible = not Window.Visible
	end)

	return self
end

-------------------------------------------------
-- CREATE TAB
-------------------------------------------------
function Skeleton:AddTab(name)
	local Tab = {}
	Tab.Sections = {}

	-- Tab Button
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.fromOffset(120,40)
	Btn.Text = name
	Btn.Font = Enum.Font.GothamBold
	Btn.TextSize = 16
	Btn.TextColor3 = Color3.new(1,1,1)
	Btn.BackgroundColor3 = Color3.fromRGB(45,45,60)
	Btn.Parent = self.Window.ScrollingFrame or self.Window:FindFirstChildWhichIsA("ScrollingFrame")
	Instance.new("UICorner",Btn).CornerRadius = UDim.new(0,10)

	-- Tab Content
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1,0,1,0)
	Page.CanvasSize = UDim2.new()
	Page.ScrollBarThickness = 6
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.Parent = self.ContentHolder

	local Layout = Instance.new("UIListLayout",Page)
	Layout.Padding = UDim.new(0,10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
	end)

	Btn.MouseButton1Click:Connect(function()
		if self.ActiveTab then
			self.ActiveTab.Page.Visible = false
			self.ActiveTab.Button.BackgroundColor3 = Color3.fromRGB(45,45,60)
		end
		Page.Visible = true
		Btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
		self.ActiveTab = Tab
	end)

	if not self.ActiveTab then
		Btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
		Page.Visible = true
		self.ActiveTab = Tab
	end

	Tab.Page = Page
	Tab.Button = Btn

	-------------------------------------------------
	-- SECTION (NO TITLE)
	-------------------------------------------------
	function Tab:AddSection()
		local Section = {}

		local Holder = Instance.new("Frame")
		Holder.Size = UDim2.new(1,0,0,0)
		Holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Holder.BackgroundTransparency = 0.15
		Holder.Parent = Page
		Instance.new("UICorner",Holder).CornerRadius = UDim.new(0,12)

		local List = Instance.new("UIListLayout",Holder)
		List.Padding = UDim.new(0,8)

		List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Holder.Size = UDim2.new(1,0,0,List.AbsoluteContentSize.Y + 10)
		end)

		-------------------------------------------------
		-- BUTTON
		-------------------------------------------------
		function Section:AddButton(text, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1,-20,0,40)
			Btn.Position = UDim2.fromOffset(10,0)
			Btn.Text = text
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 16
			Btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
			Btn.TextColor3 = Color3.new(1,1,1)
			Btn.Parent = Holder
			Instance.new("UICorner",Btn).CornerRadius = UDim.new(1,0)

			Btn.MouseButton1Click:Connect(function()
				task.spawn(callback)
			end)
		end

		-------------------------------------------------
		-- TOGGLE
		-------------------------------------------------
		function Section:AddToggle(text, callback)
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
				Toggle.BackgroundColor3 = State and Color3.fromRGB(0,170,120) or Color3.fromRGB(120,120,120)
				callback(State)
			end)
		end

		return Section
	end

	return Tab
end

return Skeleton
