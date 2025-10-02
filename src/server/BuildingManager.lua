-- src/server/BuildingManager.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TycoonConfig = require(ReplicatedStorage.Modules.TycoonConfig)
local DataManager = require(script.Parent.DataManager)
local TycoonManager = require(script.Parent.TycoonManager)

local BuildingManager = {}

-- Check if player can purchase a building
function BuildingManager.CanPurchase(player, buildingId)
	local buildingData = TycoonConfig.GetBuilding(buildingId)
	if not buildingData then
		return false, "Building not found"
	end

	-- Check if already owned
	if DataManager.OwnsBuilding(player, buildingId) then
		return false, "Already owned"
	end

	-- Check if player has enough money
	local playerData = DataManager.GetData(player)
	if not playerData or playerData.Money < buildingData.Cost then
		return false, "Not enough money"
	end

	-- Check if requirements are met
	if buildingData.Requires then
		for _, requiredId in ipairs(buildingData.Requires) do
			if not DataManager.OwnsBuilding(player, requiredId) then
				return false, "Missing required building: " .. requiredId
			end
		end
	end

	return true
end

-- Process building purchase
function BuildingManager.PurchaseBuilding(player, buildingId)
	local canPurchase, reason = BuildingManager.CanPurchase(player, buildingId)
	if not canPurchase then
		warn(player.Name .. " cannot purchase " .. buildingId .. ": " .. reason)
		return false
	end

	local buildingData = TycoonConfig.GetBuilding(buildingId)

	-- Remove money
	if not DataManager.RemoveMoney(player, buildingData.Cost) then
		return false
	end

	-- Add to owned buildings
	DataManager.AddBuilding(player, buildingId)

	-- Spawn the building
	local tycoonData, plotNumber = TycoonManager.GetPlayerTycoon(player)
	if tycoonData then
		TycoonManager.SpawnBuilding(plotNumber, buildingId)
	end

	-- Unlock dependent buildings (make their buttons visible)
	if buildingData.Unlocks then
		BuildingManager.UnlockBuildings(player, buildingData.Unlocks)
	end

	print(player.Name .. " purchased " .. buildingId)
	return true
end

-- Unlock buildings (you'll implement button visibility in Studio)
function BuildingManager.UnlockBuildings(player, buildingIds)
	local tycoonData, plotNumber = TycoonManager.GetPlayerTycoon(player)
	if not tycoonData then
		return
	end

	-- This will make purchase buttons visible
	-- You'll create the actual button models in Studio
	for _, buildingId in ipairs(buildingIds) do
		print("Unlocked " .. buildingId .. " for " .. player.Name)
	end
end

-- Setup remote event
function BuildingManager.Initialize()
	local purchaseEvent = ReplicatedStorage.RemoteEvents.PurchaseBuilding

	purchaseEvent.OnServerEvent:Connect(function(player, buildingId)
		BuildingManager.PurchaseBuilding(player, buildingId)
	end)
end

return BuildingManager
