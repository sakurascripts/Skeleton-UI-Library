--// Skeleton UI Library
--// Clean • Mobile Safe • Tabs + Sections
--// Title bar = Window

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local Skeleton = {}
Skeleton.__index = Skeleton

----------------------------------------------------------------
-- UTILS
----------------------------------------------------------------
local function round(obj, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = obj
end

local function autoscale(frame)
	local scale = Instance.new("UIScale")
	scale.Parent = frame

	local function resize()
		local vp = workspace.CurrentCamera.ViewportSize
		scale.Scale = math.clamp(vp.X / 600, 0.75, 1)
	end

	resize()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
end

----------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------
function Skeleton.new(title)
	assert(typeof(title) == "string" and title ~= "", "Window title is REQUIRED")

	local self = setmetatable({}, Skeleton)

	---------------- ScreenGui ----------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "SkeletonUI"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.Parent = Player:WaitForChild("PlayerGui")

	---------------- Main ----------------
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 420, 0, 320)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(25,25,30)
	main.Parent = gui
	round(main, 16)
	autoscale(main)

	---------------- Header (WINDOW) ----------------
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 46)
	header.BackgroundColor3 = Color3.fromRGB(32,32,42)
	header.Parent = main
	round(header, 16)

	local fix = Instance.new("Frame")
	fix.Size = UDim2.new(1, 0, 0.5, 0)
	fix.Position = UDim2.new(0,0,0.5,0)
	fix.BackgroundColor3 = header.BackgroundColor3
	fix.BorderSizePixel = 0
	fix.Parent = header

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -20, 1, 0)
	titleLbl.Position = UDim2.new(0, 10, 0, 0)
	titleLbl.Text = title
	titleLbl.TextXAlignment = Left
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextScaled = true
	titleLbl.TextColor3 = Color3.fromRGB(235,235,255)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Parent = header

	---------------- Drag ----------------
	local drag, start, startPos
	header.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = true
			start = i.Position
			startPos = main.Position
		end
	end)

	header.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			drag = false
		end
	end)

	UIS.InputChanged:Connect(function(i)
		if drag then
			local d = i.Position - start
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)

	---------------- Tabs ----------------
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, -20, 0, 40)
	tabBar.Position = UDim2.new(0, 10, 0, 56)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = main

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Horizontal
	tabLayout.Padding = UDim.new(0, 8)
	tabLayout.Parent = tabBar

	---------------- Pages ----------------
	local pages = Instance.new("Frame")
	pages.Size = UDim2.new(1, -20, 1, -110)
	pages.Position = UDim2.new(0, 10, 0, 100)
	pages.BackgroundTransparency = 1
	pages.Parent = main

	self.Gui = gui
	self.Main = main
	self.TabBar = tabBar
	self.Pages = pages
	self.Tabs = {}

	return self
end

----------------------------------------------------------------
-- TAB
----------------------------------------------------------------
function Skeleton:AddTab(name)
	assert(name and name ~= "", "Tab name required")

	local tab = {}

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 120, 1, 0)
	btn.Text = name
	btn.Font = Enum.Font.Gotham
	btn.TextScaled = true
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,55)
	btn.Parent = self.TabBar
	round(btn, 10)

	local page = Instance.new("Frame")
	page.Size = UDim2.new(1,0,1,0)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = self.Pages

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.Parent = page

	function tab:SetTitle(text)
		if tab.Title then tab.Title:Destroy() end

		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1,0,0,36)
		t.Text = text
		t.Font = Enum.Font.GothamBold
		t.TextScaled = true
		t.TextColor3 = Color3.fromRGB(235,235,255)
		t.BackgroundTransparency = 1
		t.Parent = page

		tab.Title = t
	end

	function tab:AddSection()
		local sec = Instance.new("Frame")
		sec.Size = UDim2.new(1,0,0,0)
		sec.AutomaticSize = Y
		sec.BackgroundColor3 = Color3.fromRGB(35,35,45)
		sec.BackgroundTransparency = 0.25
		sec.Parent = page
		round(sec, 14)

		local lay = Instance.new("UIListLayout")
		lay.Padding = UDim.new(0,8)
		lay.Parent = sec

		return sec
	end

	function tab:AddButton(section, text, cb)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-12,0,44)
		b.Position = UDim2.new(0,6,0,0)
		b.Text = text
		b.TextScaled = true
		b.Font = Enum.Font.Gotham
		b.BackgroundColor3 = Color3.fromRGB(0,170,255)
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = section
		round(b, 12)
		b.Activated:Connect(cb)
	end

	function tab:AddToggle(section, text, cb)
		local on = false

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1,-12,0,44)
		row.Position = UDim2.new(0,6,0,0)
		row.Text = text
		row.TextScaled = true
		row.Font = Enum.Font.Gotham
		row.TextColor3 = Color3.fromRGB(230,230,255)
		row.BackgroundColor3 = Color3.fromRGB(45,45,60)
		row.Parent = section
		round(row, 12)

		row.Activated:Connect(function()
			on = not on
			row.BackgroundColor3 = on and Color3.fromRGB(0,170,120) or Color3.fromRGB(45,45,60)
			cb(on)
		end)
	end

	btn.Activated:Connect(function()
		for _, t in pairs(self.Tabs) do
			t.Page.Visible = false
			t.Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
	end)

	if #self.Tabs == 0 then
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(70,70,100)
	end

	table.insert(self.Tabs, {Button = btn, Page = page})

	return tab
end

----------------------------------------------------------------
return Skeleton
