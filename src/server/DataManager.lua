-- src/server/DataManager.lua
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Modules.Constants)

local DataManager = {}
DataManager.PlayerData = {} -- [Player] = data table

local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v1")

local DEFAULT_DATA = {
	Money = Constants.STARTING_MONEY,
	OwnedBuildings = {}, -- Array of building IDs
	TycoonSlot = nil, -- Which plot number they own
}

-- Load player data
function DataManager.LoadData(player)
	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(player.UserId)
	end)

	if success then
		if data then
			-- Merge with defaults in case new fields were added
			for key, value in pairs(DEFAULT_DATA) do
				if data[key] == nil then
					data[key] = value
				end
			end
			DataManager.PlayerData[player] = data
		else
			-- New player
			DataManager.PlayerData[player] = table.clone(DEFAULT_DATA)
		end
		return true
	else
		warn("Failed to load data for " .. player.Name)
		return false
	end
end

-- Save player data
function DataManager.SaveData(player)
	if not DataManager.PlayerData[player] then
		return
	end

	local success = pcall(function()
		PlayerDataStore:SetAsync(player.UserId, DataManager.PlayerData[player])
	end)

	if success then
		print("Saved data for " .. player.Name)
	else
		warn("Failed to save data for " .. player.Name)
	end

	return success
end

-- Get player data
function DataManager.GetData(player)
	return DataManager.PlayerData[player]
end

-- Add money to player
function DataManager.AddMoney(player, amount)
	local data = DataManager.GetData(player)
	if data then
		data.Money += amount
		DataManager.UpdateClient(player)
	end
end

-- Remove money from player (returns true if successful)
function DataManager.RemoveMoney(player, amount)
	local data = DataManager.GetData(player)
	if data and data.Money >= amount then
		data.Money -= amount
		DataManager.UpdateClient(player)
		return true
	end
	return false
end

-- Check if player owns a building
function DataManager.OwnsBuilding(player, buildingId)
	local data = DataManager.GetData(player)
	if not data then
		return false
	end

	return table.find(data.OwnedBuildings, buildingId) ~= nil
end

-- Add building to owned list
function DataManager.AddBuilding(player, buildingId)
	local data = DataManager.GetData(player)
	if data and not DataManager.OwnsBuilding(player, buildingId) then
		table.insert(data.OwnedBuildings, buildingId)
		DataManager.UpdateClient(player)
	end
end

-- Update client with current data
function DataManager.UpdateClient(player)
	local updateEvent = ReplicatedStorage.RemoteEvents.UpdatePlayerData
	local data = DataManager.GetData(player)
	if data then
		updateEvent:FireClient(player, data)
	end
end

-- Initialize for new player
function DataManager.OnPlayerAdded(player)
	local success = DataManager.LoadData(player)
	if success then
		DataManager.UpdateClient(player)
	end
end

-- Cleanup when player leaves
function DataManager.OnPlayerRemoving(player)
	DataManager.SaveData(player)
	DataManager.PlayerData[player] = nil
end

return DataManager
