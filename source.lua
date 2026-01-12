-- Skeleton UI Library (Enhanced, Safe)
-- Original structure preserved
-- Added: animations, scrolling, autoscale, transparency

local Skeleton = {}
Skeleton.__index = Skeleton

-- SERVICES
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

-------------------------------------------------
-- WINDOW
-------------------------------------------------
function Skeleton.new(title)
	assert(title, "Title required")

	local self = setmetatable({}, Skeleton)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "SkeletonUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = Player:WaitForChild("PlayerGui")

	-- AUTO SCALE (SAFE)
	local UIScale = Instance.new("UIScale")
	UIScale.Scale = math.clamp(
		workspace.CurrentCamera.ViewportSize.X / 1200,
		0.75,
		1
	)
	UIScale.Parent = ScreenGui

	-- FLOATING OPEN BUTTON
	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.fromOffset(56, 56)
	OpenBtn.Position = UDim2.new(0, 20, 1, -90)
	OpenBtn.Text = "💀"
	OpenBtn.TextScaled = true
	OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	OpenBtn.BackgroundTransparency = 0.2
	OpenBtn.TextColor3 = Color3.new(1, 1, 1)
	OpenBtn.Parent = ScreenGui
	Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)

	-- WINDOW
	local Window = Instance.new("Frame")
	Window.Size = UDim2.fromOffset(520, 360)
	Window.Position = UDim2.new(0.5, -260, 0.5, -180)
	Window.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	Window.BackgroundTransparency = 0.2
	Window.Visible = true
	Window.Parent = ScreenGui
	Instance.new("UICorner", Window).CornerRadius = UDim.new(0, 16)

	-- HEADER
	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -20, 0, 40)
	Header.Position = UDim2.fromOffset(10, 10)
	Header.BackgroundTransparency = 1
	Header.Text = title
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 22
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextColor3 = Color3.fromRGB(240, 240, 255)
	Header.Parent = Window

	-- TAB BAR (SCROLLING)
	local TabBar = Instance.new("ScrollingFrame")
	TabBar.Size = UDim2.fromOffset(140, 280)
	TabBar.Position = UDim2.fromOffset(10, 60)
	TabBar.ScrollBarThickness = 4
	TabBar.CanvasSize = UDim2.new()
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Window

	local TabLayout = Instance.new("UIListLayout", TabBar)
	TabLayout.Padding = UDim.new(0, 6)

	TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabBar.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 6)
	end)

	-- CONTENT HOLDER
	local ContentHolder = Instance.new("Frame")
	ContentHolder.Size = UDim2.new(1, -170, 1, -70)
	ContentHolder.Position = UDim2.fromOffset(160, 60)
	ContentHolder.BackgroundTransparency = 1
	ContentHolder.Parent = Window

	OpenBtn.MouseButton1Click:Connect(function()
		Window.Visible = not Window.Visible
	end)

	self.Window = Window
	self.TabBar = TabBar
	self.ContentHolder = ContentHolder
	self.ActiveTab = nil

	return self
end

-------------------------------------------------
-- TAB
-------------------------------------------------
function Skeleton:AddTab(name)
	local Tab = {}

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 0, 40)
	Button.Text = name
	Button.Font = Enum.Font.GothamBold
	Button.TextSize = 15
	Button.TextColor3 = Color3.new(1, 1, 1)
	Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	Button.BackgroundTransparency = 0.2
	Button.Parent = self.TabBar
	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.CanvasSize = UDim2.new()
	Page.ScrollBarThickness = 6
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = self.ContentHolder

	local Layout = Instance.new("UIListLayout", Page)
	Layout.Padding = UDim.new(0, 10)

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
	end)

	Button.MouseButton1Click:Connect(function()
		if self.ActiveTab then
			self.ActiveTab.Page.Visible = false
			TweenService:Create(self.ActiveTab.Button, TweenInfo.new(0.15), {
				BackgroundColor3 = Color3.fromRGB(45, 45, 60)
			}):Play()
		end

		Page.Visible = true
		TweenService:Create(Button, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		}):Play()

		self.ActiveTab = Tab
	end)

	if not self.ActiveTab then
		Page.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
		self.ActiveTab = Tab
	end

	Tab.Page = Page
	Tab.Button = Button

	-------------------------------------------------
	-- SECTION
	-------------------------------------------------
	function Tab:AddSection()
		local Section = {}

		local Holder = Instance.new("Frame")
		Holder.Size = UDim2.new(1, 0, 0, 0)
		Holder.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
		Holder.BackgroundTransparency = 0.2
		Holder.Parent = Page
		Instance.new("UICorner", Holder).CornerRadius = UDim.new(0, 12)

		local List = Instance.new("UIListLayout", Holder)
		List.Padding = UDim.new(0, 8)

		List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Holder.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 10)
		end)

		function Section:AddButton(text, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -20, 0, 40)
			Btn.Position = UDim2.fromOffset(10, 0)
			Btn.Text = text
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 15
			Btn.TextColor3 = Color3.new(1, 1, 1)
			Btn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
			Btn.BackgroundTransparency = 0.15
			Btn.Parent = Holder
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)

			Btn.MouseButton1Click:Connect(function()
				TweenService:Create(Btn, TweenInfo.new(0.1), {
					Size = Btn.Size - UDim2.fromOffset(4, 4)
				}):Play()

				task.delay(0.1, function()
					TweenService:Create(Btn, TweenInfo.new(0.1), {
						Size = Btn.Size
					}):Play()
				end)

				task.spawn(callback)
			end)
		end

		function Section:AddToggle(text, callback)
			local Row = Instance.new("Frame")
			Row.Size = UDim2.new(1, -20, 0, 40)
			Row.Position = UDim2.fromOffset(10, 0)
			Row.BackgroundTransparency = 1
			Row.Parent = Holder

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -70, 1, 0)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Text = text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 15
			Label.TextColor3 = Color3.fromRGB(220, 220, 240)
			Label.Parent = Row

			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.fromOffset(50, 24)
			Toggle.Position = UDim2.new(1, -55, 0.5, -12)
			Toggle.Text = ""
			Toggle.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
			Toggle.BackgroundTransparency = 0.2
			Toggle.Parent = Row
			Instance.new("UICorner", Toggle).CornerRadius = UDim.new(1, 0)

			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.fromOffset(20, 20)
			Knob.Position = UDim2.fromOffset(2, 2)
			Knob.BackgroundColor3 = Color3.fromRGB(240, 240, 255)
			Knob.Parent = Toggle
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			local State = false
			Toggle.MouseButton1Click:Connect(function()
				State = not State
				TweenService:Create(Knob, TweenInfo.new(0.15), {
					Position = State and UDim2.new(1, -22, 0, 2) or UDim2.fromOffset(2, 2)
				}):Play()

				Toggle.BackgroundColor3 = State
					and Color3.fromRGB(0, 170, 120)
					or Color3.fromRGB(120, 120, 120)

				callback(State)
			end)
		end

		return Section
	end

	return Tab
end

return Skeleton
