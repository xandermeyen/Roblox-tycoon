-- src/client/UIController.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = {}
UIController.CurrentData = nil

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create simple UI
function UIController.CreateUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TycoonUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	-- Money display
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "MoneyFrame"
	moneyFrame.Size = UDim2.new(0, 200, 0, 60)
	moneyFrame.Position = UDim2.new(0, 20, 0, 20)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = screenGui

	local moneyLabel = Instance.new("TextLabel")
	moneyLabel.Name = "MoneyLabel"
	moneyLabel.Size = UDim2.new(1, -20, 1, -20)
	moneyLabel.Position = UDim2.new(0, 10, 0, 10)
	moneyLabel.BackgroundTransparency = 1
	moneyLabel.Text = "$0"
	moneyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	moneyLabel.TextScaled = true
	moneyLabel.Font = Enum.Font.GothamBold
	moneyLabel.Parent = moneyFrame

	-- Round corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = moneyFrame

	return screenGui
end

-- Update UI with new data
function UIController.UpdateUI(data)
	UIController.CurrentData = data

	local screenGui = playerGui:FindFirstChild("TycoonUI")
	if not screenGui then
		return
	end

	local moneyLabel = screenGui.MoneyFrame.MoneyLabel
	moneyLabel.Text = "$" .. tostring(data.Money)
end

-- Listen for data updates from server
function UIController.Initialize()
	local ui = UIController.CreateUI()

	local updateEvent = ReplicatedStorage.RemoteEvents.UpdatePlayerData
	updateEvent.OnClientEvent:Connect(function(data)
		UIController.UpdateUI(data)
	end)

	print("UI Controller initialized")
end

return UIController
