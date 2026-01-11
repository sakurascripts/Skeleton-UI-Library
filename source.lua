--// Skeleton Hub UI Library (Final Stable)

--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--------------------------------------------------
-- ROOT TABLE
--------------------------------------------------
local Skeleton = {}
Skeleton.__index = Skeleton

--------------------------------------------------
-- GUI FOLDER (Rayfield / Kavo style)
--------------------------------------------------
local Folder = Instance.new("Folder")
Folder.Name = "SkeletonHub"
Folder.Parent = PlayerGui

--------------------------------------------------
-- SCREEN GUI
--------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkeletonUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Folder

--------------------------------------------------
-- UI SCALE
--------------------------------------------------
local UIScale = Instance.new("UIScale")
UIScale.Scale = math.clamp(workspace.CurrentCamera.ViewportSize.X / 1200, 0.85, 1)
UIScale.Parent = ScreenGui

--------------------------------------------------
-- BLUR
--------------------------------------------------
local Blur = Instance.new("BlurEffect")
Blur.Size = 0
Blur.Parent = Lighting

--------------------------------------------------
-- FLOATING OPEN BUTTON
--------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 1, -90)
OpenBtn.Text = "💀"
OpenBtn.TextScaled = true
OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

--------------------------------------------------
-- DRAG OPEN BUTTON (PC + MOBILE)
--------------------------------------------------
do
	local dragging, startPos, startInput

	OpenBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInput = i.Position
			startPos = OpenBtn.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - startInput
			OpenBtn.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function()
		dragging = false
	end)
end

--------------------------------------------------
-- MAIN PANEL
--------------------------------------------------
local Panel = Instance.new("Frame")
Panel.Size = UDim2.new(0, 540, 0, 380)
Panel.Position = UDim2.new(0.5, -270, 0.5, -190)
Panel.BackgroundColor3 = Color3.fromRGB(20,20,30)
Panel.Visible = true
Panel.Parent = ScreenGui
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,18)

--------------------------------------------------
-- TOP TITLE (TAB TITLE)
--------------------------------------------------
local TabTitle = Instance.new("TextLabel")
TabTitle.Size = UDim2.new(1, -20, 0, 42)
TabTitle.Position = UDim2.new(0, 10, 0, 10)
TabTitle.BackgroundTransparency = 1
TabTitle.Text = ""
TabTitle.Font = Enum.Font.GothamBold
TabTitle.TextSize = 22
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.TextColor3 = Color3.fromRGB(240,240,255)
TabTitle.Parent = Panel

--------------------------------------------------
-- TAB BAR
--------------------------------------------------
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, -20, 0, 38)
TabBar.Position = UDim2.new(0, 10, 0, 58)
TabBar.ScrollBarThickness = 0
TabBar.CanvasSize = UDim2.new(0,0,0,0)
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.BackgroundTransparency = 1
TabBar.Parent = Panel

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)
TabLayout.Parent = TabBar

--------------------------------------------------
-- CONTENT HOLDER
--------------------------------------------------
local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1, -20, 1, -110)
Pages.Position = UDim2.new(0, 10, 0, 100)
Pages.BackgroundTransparency = 1
Pages.Parent = Panel

--------------------------------------------------
-- TAB SYSTEM
--------------------------------------------------
local CurrentTab

function Skeleton:CreateTab(name)
	local Tab = {}

	-- Tab Button
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 130, 1, 0)
	Button.Text = name
	Button.TextScaled = true
	Button.BackgroundColor3 = Color3.fromRGB(40,40,60)
	Button.TextColor3 = Color3.new(1,1,1)
	Button.Parent = TabBar
	Instance.new("UICorner", Button).CornerRadius = UDim.new(0,10)

	-- Page
	local Page = Instance.new("ScrollingFrame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.CanvasSize = UDim2.new(0,0,0,0)
	Page.ScrollBarThickness = 4
	Page.Visible = false
	Page.BackgroundTransparency = 1
	Page.Parent = Pages

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Padding = UDim.new(0, 12)
	PageLayout.Parent = Page

	PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Page.CanvasSize = UDim2.new(0,0,0,PageLayout.AbsoluteContentSize.Y + 10)
	end)

	Button.Activated:Connect(function()
		if CurrentTab then
			CurrentTab.Page.Visible = false
			CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40,40,60)
		end
		Page.Visible = true
		Button.BackgroundColor3 = Color3.fromRGB(70,70,110)
		CurrentTab = {Page = Page, Button = Button}
	end)

	if not CurrentTab then
		Button:Activate()
	end

	--------------------------------------------------
	-- TAB TITLE (ONE PER TAB)
	--------------------------------------------------
	function Tab:SetTitle(text)
		TabTitle.Text = text
	end

	--------------------------------------------------
	-- SECTION (NO TITLE)
	--------------------------------------------------
	function Tab:CreateSection()
		local Section = Instance.new("Frame")
		Section.BackgroundColor3 = Color3.fromRGB(30,30,40)
		Section.BackgroundTransparency = 0.85
		Section.AutomaticSize = Enum.AutomaticSize.Y
		Section.Parent = Page
		Instance.new("UICorner", Section).CornerRadius = UDim.new(0,14)

		local Padding = Instance.new("UIPadding")
		Padding.PaddingTop = UDim.new(0, 10)
		Padding.PaddingBottom = UDim.new(0, 10)
		Padding.PaddingLeft = UDim.new(0, 10)
		Padding.PaddingRight = UDim.new(0, 10)
		Padding.Parent = Section

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0, 8)
		Layout.Parent = Section

		return Section
	end

	--------------------------------------------------
	-- BUTTON
	--------------------------------------------------
	function Tab:CreateButton(section, text, callback)
		local Btn = Instance.new("TextButton")
		Btn.Size = UDim2.new(1, 0, 0, 44)
		Btn.Text = text
		Btn.TextScaled = true
		Btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
		Btn.TextColor3 = Color3.new(1,1,1)
		Btn.Parent = section
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,12)

		Btn.Activated:Connect(function()
			if callback then
				callback()
			end
		end)
	end

	--------------------------------------------------
	-- TOGGLE
	--------------------------------------------------
	function Tab:CreateToggle(section, text, callback)
		local Toggle = Instance.new("TextButton")
		Toggle.Size = UDim2.new(1, 0, 0, 44)
		Toggle.Text = ""
		Toggle.BackgroundColor3 = Color3.fromRGB(40,40,55)
		Toggle.Parent = section
		Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,12)

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.new(1, -70, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextScaled = true
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextColor3 = Color3.fromRGB(230,230,245)
		Label.Parent = Toggle

		local Switch = Instance.new("Frame")
		Switch.Size = UDim2.new(0, 50, 0, 26)
		Switch.Position = UDim2.new(1, -60, 0.5, -13)
		Switch.BackgroundColor3 = Color3.fromRGB(120,120,120)
		Switch.Parent = Toggle
		Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

		local Knob = Instance.new("Frame")
		Knob.Size = UDim2.new(0, 22, 0, 22)
		Knob.Position = UDim2.new(0, 2, 0.5, -11)
		Knob.BackgroundColor3 = Color3.fromRGB(240,240,255)
		Knob.Parent = Switch
		Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

		local State = false

		Toggle.Activated:Connect(function()
			State = not State
			TweenService:Create(Knob, TweenInfo.new(0.15), {
				Position = State and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
			}):Play()
			Switch.BackgroundColor3 = State and Color3.fromRGB(0,170,120) or Color3.fromRGB(120,120,120)
			if callback then callback(State) end
		end)
	end

	return Tab
end

--------------------------------------------------
-- OPEN / CLOSE
--------------------------------------------------
OpenBtn.Activated:Connect(function()
	Panel.Visible = not Panel.Visible
	Blur.Size = Panel.Visible and 16 or 0
end)

--------------------------------------------------
-- RETURN (SINGLE RETURN ONLY)
--------------------------------------------------
return Skeleton
