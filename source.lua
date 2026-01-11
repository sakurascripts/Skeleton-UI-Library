--// Skeleton Premium UI Library
--// Clean | Animated | Mobile + PC | No Errors

local Skeleton = {}
Skeleton.__index = Skeleton

--// Services
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer

--// Safety Camera Wait
while not workspace.CurrentCamera do
	task.wait()
end

----------------------------------------------------------------
-- Utility
----------------------------------------------------------------
local function Tween(obj, info, props)
	return TweenService:Create(obj, info, props):Play()
end

local function MakeDraggable(frame, handle)
	handle = handle or frame
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

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

----------------------------------------------------------------
-- Create Window
----------------------------------------------------------------
function Skeleton.new(title)
	local self = setmetatable({}, Skeleton)

	-- Folder like Rayfield / Kavo
	local Folder = Instance.new("Folder")
	Folder.Name = "SkeletonHub"
	Folder.Parent = Player:WaitForChild("PlayerGui")

	-- ScreenGui
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "SkeletonUI"
	Gui.ResetOnSpawn = false
	Gui.Parent = Folder
	self.Gui = Gui

	-- Blur
	local Blur = Instance.new("BlurEffect")
	Blur.Size = 0
	Blur.Parent = Lighting
	self.Blur = Blur

	-- Main
	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0,520,0,380)
	Main.Position = UDim2.fromScale(0.5,0.5)
	Main.AnchorPoint = Vector2.new(0.5,0.5)
	Main.BackgroundColor3 = Color3.fromRGB(18,18,22)
	Main.Parent = Gui
	self.Main = Main

	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,14)

	-- Top Bar
	local Top = Instance.new("Frame")
	Top.Size = UDim2.new(1,0,0,42)
	Top.BackgroundTransparency = 1
	Top.Parent = Main

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1,-60,1,0)
	Title.Position = UDim2.new(0,14,0,0)
	Title.Text = title or "Skeleton UI"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Color3.new(1,1,1)
	Title.TextXAlignment = Left
	Title.BackgroundTransparency = 1
	Title.Parent = Top

	-- Close Button
	local Close = Instance.new("TextButton")
	Close.Size = UDim2.new(0,32,0,32)
	Close.Position = UDim2.new(1,-40,0,5)
	Close.Text = "×"
	Close.Font = Enum.Font.GothamBold
	Close.TextSize = 20
	Close.BackgroundColor3 = Color3.fromRGB(35,35,45)
	Close.TextColor3 = Color3.new(1,1,1)
	Close.Parent = Top
	Instance.new("UICorner", Close)

	-- Tabs
	local Tabs = Instance.new("ScrollingFrame")
	Tabs.Size = UDim2.new(0,120,1,-42)
	Tabs.Position = UDim2.new(0,0,0,42)
	Tabs.CanvasSize = UDim2.new()
	Tabs.ScrollBarThickness = 2
	Tabs.BackgroundTransparency = 1
	Tabs.Parent = Main

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.Padding = UDim.new(0,6)
	TabLayout.Parent = Tabs

	-- Pages
	local Pages = Instance.new("Folder")
	Pages.Parent = Main

	MakeDraggable(Main, Top)

	----------------------------------------------------------------
	-- Open Button
	----------------------------------------------------------------
	local OpenBtn = Instance.new("TextButton")
	OpenBtn.Size = UDim2.new(0,52,0,52)
	OpenBtn.Position = UDim2.new(0,14,0.5,0)
	OpenBtn.Text = "☰"
	OpenBtn.Font = Enum.Font.GothamBold
	OpenBtn.TextSize = 22
	OpenBtn.BackgroundColor3 = Color3.fromRGB(35,35,45)
	OpenBtn.TextColor3 = Color3.new(1,1,1)
	OpenBtn.Visible = false
	OpenBtn.Parent = Gui
	Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

	----------------------------------------------------------------
	-- Visibility Logic
	----------------------------------------------------------------
	local function Show()
		Main.Visible = true
		OpenBtn.Visible = false
		Tween(Blur, TweenInfo.new(0.25), {Size = 16})
	end

	local function Hide()
		Main.Visible = false
		OpenBtn.Visible = true
		Tween(Blur, TweenInfo.new(0.25), {Size = 0})
	end

	Close.MouseButton1Click:Connect(Hide)
	OpenBtn.MouseButton1Click:Connect(Show)

	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.P then Show() end
		if input.KeyCode == Enum.KeyCode.D then Hide() end
	end)

	----------------------------------------------------------------
	-- Tabs API
	----------------------------------------------------------------
	function self:AddTab(name)
		assert(name, "Tab name missing")

		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1,-10,0,36)
		TabBtn.Text = name
		TabBtn.Font = Enum.Font.Gotham
		TabBtn.TextSize = 14
		TabBtn.TextColor3 = Color3.new(1,1,1)
		TabBtn.BackgroundColor3 = Color3.fromRGB(30,30,40)
		TabBtn.Parent = Tabs
		Instance.new("UICorner", TabBtn)

		local Page = Instance.new("ScrollingFrame")
		Page.Size = UDim2.new(1,-130,1,-52)
		Page.Position = UDim2.new(0,130,0,52)
		Page.CanvasSize = UDim2.new()
		Page.ScrollBarThickness = 3
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.Parent = Main

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0,12)
		Layout.Parent = Page

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 20)
		end)

		TabBtn.MouseButton1Click:Connect(function()
			for _,p in pairs(Pages:GetChildren()) do p.Visible = false end
			Page.Visible = true
		end)

		Page.Parent = Pages
		if #Pages:GetChildren() == 1 then Page.Visible = true end

		local Tab = {}

		function Tab:AddSection(title)
			local Section = Instance.new("Frame")
			Section.Size = UDim2.new(1,-16,0,0)
			Section.BackgroundColor3 = Color3.fromRGB(25,25,32)
			Section.Parent = Page
			Instance.new("UICorner", Section)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1,-16,0,26)
			Label.Position = UDim2.new(0,8,0,6)
			Label.Text = title
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 14
			Label.TextColor3 = Color3.new(1,1,1)
			Label.BackgroundTransparency = 1
			Label.TextXAlignment = Left
			Label.Parent = Section

			local Holder = Instance.new("Frame")
			Holder.Size = UDim2.new(1,-16,0,0)
			Holder.Position = UDim2.new(0,8,0,38)
			Holder.BackgroundTransparency = 1
			Holder.Parent = Section

			local HL = Instance.new("UIListLayout")
			HL.Padding = UDim.new(0,8)
			HL.Parent = Holder

			HL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section.Size = UDim2.new(1,-16,0,HL.AbsoluteContentSize.Y + 48)
			end)

			local Sec = {}

			function Sec:AddButton(text, callback)
				local B = Instance.new("TextButton")
				B.Size = UDim2.new(1,0,0,38)
				B.Text = text
				B.Font = Enum.Font.Gotham
				B.TextSize = 14
				B.TextColor3 = Color3.new(1,1,1)
				B.BackgroundColor3 = Color3.fromRGB(35,35,45)
				B.Parent = Holder
				Instance.new("UICorner", B)

				B.MouseButton1Click:Connect(function()
					if callback then callback() end
				end)
			end

			return Sec
		end

		return Tab
	end

	return self
end

return Skeleton
