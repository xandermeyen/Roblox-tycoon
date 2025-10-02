local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = require(script.UIController)

print("🎃 Haunted Tycoon Client Starting...")

-- Initialize UI
UIController.Initialize()

-- Example: Handle purchase button clicks in the 3D world
-- You'll create ClickDetectors on purchase buttons in Studio, then use this pattern:
--[[
local function setupPurchaseButton(button, buildingId)
	local clickDetector = button:FindFirstChildOfClass("ClickDetector")
	if clickDetector then
		clickDetector.MouseClick:Connect(function()
			local purchaseEvent = ReplicatedStorage.RemoteEvents.PurchaseBuilding
			purchaseEvent:FireServer(buildingId)
		end)
	end
end
--]]

print("✅ Haunted Tycoon Client Ready!")
