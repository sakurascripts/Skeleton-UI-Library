local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local Skeleton = {}
Skeleton.__index = Skeleton

local function draggable(frame, handle)
	local dragging = false
	local dragStart, startPos

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

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
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

function Skeleton.new(title)
	local self = setmetatable({}, Skeleton)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.new(0, 60, 0, 60)
	OpenBtn.Position = UDim2.new(0, 20, 1, -90)
	OpenBtn.Text = "💀"
	OpenBtn.TextScaled = true
	OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
	OpenBtn.TextColor3 = Color3.new(1,1,1)
	OpenBtn.Parent = ScreenGui
	Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

	local Window = Instance.new("Frame")
	Window.Size = UDim2.new(0, 420, 0, 320)
	Window.Position = UDim2.new(0.5, -210, 0.5, -160)
	Window.BackgroundColor3 = Color3.fromRGB(25,25,30)
	Window.Visible = false
	Window.Parent = ScreenGui
	Instance.new("UICorner", Window).CornerRadius = UDim.new(0,16)

	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -20, 0, 45)
	Header.Position = UDim2.new(0, 10, 0, 10)
	Header.Text = title
	Header.TextScaled = true
	Header.Font = Enum.Font.GothamBold
	Header.TextColor3 = Color3.fromRGB(230,230,255)
	Header.BackgroundTransparency = 1
	Header.Parent = Window

	local TabsBar = Instance.new("Frame")
	TabsBar.Size = UDim2.new(1, -20, 0, 40)
	TabsBar.Position = UDim2.new(0, 10, 0, 60)
	TabsBar.BackgroundTransparency = 1
	TabsBar.Parent = Window

	local TabsLayout = Instance.new("UIListLayout", TabsBar)
	TabsLayout.FillDirection = Enum.FillDirection.Horizontal
	TabsLayout.Padding = UDim.new(0, 6)

	local Pages = Instance.new("Frame")
	Pages.Size = UDim2.new(1, -20, 1, -120)
	Pages.Position = UDim2.new(0, 10, 0, 110)
	Pages.BackgroundTransparency = 1
	Pages.Parent = Window

	draggable(Window, Header)
	draggable(OpenBtn, OpenBtn)

	OpenBtn.Activated:Connect(function()
		Window.Visible = not Window.Visible
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			Window.Visible = not Window.Visible
		end
	end)

	self.Window = Window
	self.TabsBar = TabsBar
	self.Pages = Pages
	self.CurrentTab = nil

	return self
end

function Skeleton:AddTab(name)
	local Tab = {}
	Tab.__index = Tab

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 120, 1, 0)
	Button.Text = name
	Button.TextScaled = true
	Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Parent = self.TabsBar
	Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.CanvasSize = UDim2.new(0, 0, 0, 0)
	Page.ScrollBarImageTransparency = 1
	Page.Visible = false
	Page.Parent = self.Pages

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0, 10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	Button.Activated:Connect(function()
		if self.CurrentTab then
			self.CurrentTab.Page.Visible = false
			self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
		end

		self.CurrentTab = Tab
		Page.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(70,70,100)
	end)

	Tab.Button = Button
	Tab.Page = Page

	function Tab:AddSection()
		local Section = {}

		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.new(1, 0, 0, 10)
		Frame.BackgroundColor3 = Color3.fromRGB(35,35,45)
		Frame.BackgroundTransparency = 0.25
		Frame.Parent = Page
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,12)

		local Layout = Instance.new("UIListLayout", Frame)
		Layout.Padding = UDim.new(0, 6)

		function Section:AddButton(text, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -20, 0, 40
