--// Skeleton UI Library
--// Tabs • Sections • Buttons • Toggles
--// Mobile + PC • Draggable • Clean API

local Skeleton = {}
Skeleton.__index = Skeleton

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

-------------------------------------------------
-- SCREEN GUI
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkeletonUI"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

-------------------------------------------------
-- FLOATING OPEN BUTTON
-------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 20, 1, -90)
OpenBtn.Text = "💀"
OpenBtn.TextScaled = true
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
OpenBtn.TextColor3 = Color3.new(1,1,1)
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1,0)

-------------------------------------------------
-- DRAG OPEN BUTTON (PC + MOBILE)
-------------------------------------------------
do
	local dragging, dragStart, startPos

	OpenBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = OpenBtn.Position
		end
	end)

	OpenBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local delta = i.Position - dragStart
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
function Skeleton:CreateWindow(title)
	assert(title, "Skeleton UI: Window title is required")

	local Window = {}
	Window.Tabs = {}

	-- MAIN FRAME
	local Main = Instance.new("Frame")
	Main.Size = UDim2.new(0, 420, 0, 300)
	Main.Position = UDim2.new(0.5, -210, 0.5, -150)
	Main.BackgroundColor3 = Color3.fromRGB(25,25,30)
	Main.Visible = false
	Main.Parent = ScreenGui
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)

	-- HEADER (WINDOW TITLE)
	local Header = Instance.new("TextLabel")
	Header.Size = UDim2.new(1, -20, 0, 45)
	Header.Position = UDim2.new(0, 10, 0, 10)
	Header.BackgroundTransparency = 1
	Header.Text = title
	Header.Font = Enum.Font.GothamBold
	Header.TextSize = 22
	Header.TextXAlignment = Enum.TextXAlignment.Left
	Header.TextColor3 = Color3.fromRGB(240,240,255)
	Header.Parent = Main

	-- TAB BUTTON BAR
	local TabBar = Instance.new("Frame")
	TabBar.Size = UDim2.new(1, -20, 0, 40)
	TabBar.Position = UDim2.new(0, 10, 0, 60)
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = Main

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0, 6)
	TabLayout.Parent = TabBar

	-- CONTENT HOLDER
	local ContentHolder = Instance.new("Frame")
	ContentHolder.Size = UDim2.new(1, -20, 1, -120)
	ContentHolder.Position = UDim2.new(0, 10, 0, 110)
	ContentHolder.BackgroundTransparency = 1
	ContentHolder.Parent = Main

	-------------------------------------------------
	-- TOGGLE WINDOW
	-------------------------------------------------
	OpenBtn.MouseButton1Click:Connect(function()
		Main.Visible = not Main.Visible
	end)

	-------------------------------------------------
	-- ADD TAB
	-------------------------------------------------
	function Window:AddTab(name)
		local Tab = {}
		Tab.Sections = {}

		-- TAB BUTTON
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 120, 1, 0)
		TabBtn.Text = name
		TabBtn.Font = Enum.Font.Gotham
		TabBtn.TextScaled = true
		TabBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
		TabBtn.TextColor3 = Color3.new(1,1,1)
		TabBtn.Parent = TabBar
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0,10)

		-- TAB CONTENT
		local TabFrame = Instance.new("ScrollingFrame")
		TabFrame.Size = UDim2.new(1,0,1,0)
		TabFrame.CanvasSize = UDim2.new(0,0,0,0)
		TabFrame.ScrollBarImageTransparency = 1
		TabFrame.BackgroundTransparency = 1
		TabFrame.Visible = false
		TabFrame.Parent = ContentHolder

		local Layout = Instance.new("UIListLayout")
		Layout.Padding = UDim.new(0, 10)
		Layout.Parent = TabFrame

		Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabFrame.CanvasSize = UDim2.new(0,0,0,Layout.AbsoluteContentSize.Y + 10)
		end)

		-- SWITCH TAB
		TabBtn.MouseButton1Click:Connect(function()
			for _, t in pairs(Window.Tabs) do
				t.Frame.Visible = false
				t.Button.BackgroundColor3 = Color3.fromRGB(40,40,55)
			end
			TabFrame.Visible = true
			TabBtn.BackgroundColor3 = Color3.fromRGB(70,70,100)
		end)

		-------------------------------------------------
		-- ADD SECTION (NO TITLE)
		-------------------------------------------------
		function Tab:AddSection()
			local Section = {}

			local Holder = Instance.new("Frame")
			Holder.BackgroundColor3 = Color3.fromRGB(35,35,45)
			Holder.BackgroundTransparency = 0.15
			Holder.Size = UDim2.new(1,0,0,0)
			Holder.Parent = TabFrame
			Instance.new("UICorner", Holder).CornerRadius = UDim.new(0,12)

			local Layout = Instance.new("UIListLayout")
			Layout.Padding = UDim.new(0, 8)
			Layout.Parent = Holder

			Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Holder.Size = UDim2.new(1,0,0,Layout.AbsoluteContentSize.Y + 10)
			end)

			-------------------------------------------------
			-- BUTTON
			-------------------------------------------------
			function Section:AddButton(text, callback)
				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(1, -20, 0, 40)
				Btn.Text = text
				Btn.Font = Enum.Font.Gotham
				Btn.TextScaled = true
				Btn.BackgroundColor3 = Color3.fromRGB(0,170,255)
				Btn.TextColor3 = Color3.new(1,1,1)
				Btn.Parent = Holder
				Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,10)

				Btn.MouseButton1Click:Connect(function()
					if callback then
						callback()
					end
				end)
			end

			-------------------------------------------------
			-- TOGGLE
			-------------------------------------------------
			function Section:AddToggle(text, callback)
				local Toggle = Instance.new("TextButton")
				Toggle.Size = UDim2.new(1, -20, 0, 40)
				Toggle.Text = text
				Toggle.Font = Enum.Font.Gotham
				Toggle.TextScaled = true
				Toggle.BackgroundColor3 = Color3.fromRGB(120,120,120)
				Toggle.TextColor3 = Color3.new(1,1,1)
				Toggle.Parent = Holder
				Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0,10)

				local state = false

				Toggle.MouseButton1Click:Connect(function()
					state = not state
					Toggle.BackgroundColor3 = state
						and Color3.fromRGB(0,170,120)
						or Color3.fromRGB(120,120,120)

					if callback then
						callback(state)
					end
				end)
			end

			return Section
		end

		table.insert(Window.Tabs, {
			Button = TabBtn,
			Frame = TabFrame
		})

		if #Window.Tabs == 1 then
			TabBtn:Activate()
		end

		return Tab
	end

	return Window
end

return Skeleton
