-- src/server/init.server.lua
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataManager = require(script.DataManager)
local TycoonManager = require(script.TycoonManager)
local BuildingManager = require(script.BuildingManager)
local Constants = require(ReplicatedStorage.Modules.Constants)
local TycoonConfig = require(ReplicatedStorage.Modules.TycoonConfig)

print("🎃 Haunted Tycoon Server Starting...")

-- Initialize managers
TycoonManager.Initialize()
BuildingManager.Initialize()

-- Player joined
Players.PlayerAdded:Connect(function(player)
	print(player.Name .. " joined the game")
	DataManager.OnPlayerAdded(player)

	-- Start income loop after short delay
	task.wait(2)

	-- Income generator
	task.spawn(function()
		while player.Parent do
			task.wait(Constants.INCOME_INTERVAL)

			local playerData = DataManager.GetData(player)
			if not playerData then
				continue
			end

			-- Calculate total income from owned buildings
			local totalIncome = Constants.DEFAULT_INCOME_RATE
			for _, buildingId in ipairs(playerData.OwnedBuildings) do
				local buildingData = TycoonConfig.GetBuilding(buildingId)
				if buildingData then
					totalIncome += buildingData.Income
				end
			end

			DataManager.AddMoney(player, totalIncome)
		end
	end)
end)

-- Player left
Players.PlayerRemoving:Connect(function(player)
	print(player.Name .. " left the game")
	DataManager.OnPlayerRemoving(player)
	TycoonManager.OnPlayerRemoving(player)
end)

-- Auto-save every 5 minutes
task.spawn(function()
	while true do
		task.wait(300) -- 5 minutes
		print("Auto-saving all player data...")
		for _, player in ipairs(Players:GetPlayers()) do
			DataManager.SaveData(player)
		end
	end
end)

-- Handle server shutdown
game:BindToClose(function()
	print("Server shutting down, saving all data...")
	for _, player in ipairs(Players:GetPlayers()) do
		DataManager.SaveData(player)
	end
	task.wait(3) -- Give time for saves to complete
end)

print("✅ Haunted Tycoon Server Ready!")
