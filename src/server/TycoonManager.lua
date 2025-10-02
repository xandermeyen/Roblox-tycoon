-- src/server/TycoonManager.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage.Modules.Constants)
local TycoonConfig = require(ReplicatedStorage.Modules.TycoonConfig)

local TycoonManager = {}
TycoonManager.ActiveTycoons = {} -- [plotNumber] = {Owner = player, Buildings = {}}

local TycoonPlots = Workspace:WaitForChild("TycoonPlots")
local TycoonTemplate = ServerStorage:WaitForChild("TycoonTemplate")

-- Initialize all tycoon plots
function TycoonManager.Initialize()
	-- Create plot folders if they don't exist
	for i = 1, Constants.MAX_TYCOONS do
		local plotFolder = TycoonPlots:FindFirstChild("Plot" .. i)
		if not plotFolder then
			plotFolder = Instance.new("Folder")
			plotFolder.Name = "Plot" .. i
			plotFolder.Parent = TycoonPlots

			-- You'll add a SpawnLocation and ClaimButton in Studio
			-- These are just placeholders to show the structure
			warn("Plot" .. i .. " created - add SpawnLocation and ClaimButton in Studio!")
		end

		TycoonManager.SetupClaimButton(plotFolder, i)
	end
end

-- Setup claim button for a plot
function TycoonManager.SetupClaimButton(plotFolder, plotNumber)
	local claimButton = plotFolder:FindFirstChild("ClaimButton")
	if not claimButton then
		return
	end

	-- Make it look like a claim button
	if claimButton:IsA("Part") then
		claimButton.BrickColor = BrickColor.new("Lime green")
		claimButton.CanCollide = false
	end

	-- Handle claiming
	claimButton.Touched:Connect(function(hit)
		local character = hit.Parent
		local player = game.Players:GetPlayerFromCharacter(character)

		if player and not TycoonManager.PlayerOwnsTycoon(player) then
			TycoonManager.ClaimTycoon(player, plotNumber)
		end
	end)
end

-- Check if player already owns a tycoon
function TycoonManager.PlayerOwnsTycoon(player)
	for _, tycoonData in pairs(TycoonManager.ActiveTycoons) do
		if tycoonData.Owner == player then
			return true
		end
	end
	return false
end

-- Claim a tycoon for a player
function TycoonManager.ClaimTycoon(player, plotNumber)
	-- Check if already claimed
	if TycoonManager.ActiveTycoons[plotNumber] then
		return false
	end

	-- Initialize tycoon data
	TycoonManager.ActiveTycoons[plotNumber] = {
		Owner = player,
		Buildings = {},
		PlotNumber = plotNumber,
	}

	-- Hide claim button
	local plotFolder = TycoonPlots:FindFirstChild("Plot" .. plotNumber)
	if plotFolder then
		local claimButton = plotFolder:FindFirstChild("ClaimButton")
		if claimButton then
			claimButton.Transparency = 1
			claimButton.CanCollide = false
		end
	end

	-- Spawn starter buildings
	TycoonManager.SpawnStarterBuildings(plotNumber)

	print(player.Name .. " claimed tycoon plot " .. plotNumber)
	return true
end

-- Spawn initial free buildings
function TycoonManager.SpawnStarterBuildings(plotNumber)
	for _, buildingData in ipairs(TycoonConfig.Buildings) do
		if buildingData.Cost == 0 then
			TycoonManager.SpawnBuilding(plotNumber, buildingData.Id)
		end
	end
end

-- Spawn a building on a plot
function TycoonManager.SpawnBuilding(plotNumber, buildingId)
	local tycoonData = TycoonManager.ActiveTycoons[plotNumber]
	if not tycoonData then
		return
	end

	-- Check if already spawned
	if tycoonData.Buildings[buildingId] then
		return
	end

	-- Find the building model in template
	local buildingModel = TycoonTemplate:FindFirstChild(buildingId)
	if not buildingModel then
		warn("Building model not found: " .. buildingId)
		return
	end

	-- Clone and place in plot
	local plotFolder = TycoonPlots:FindFirstChild("Plot" .. plotNumber)
	local clone = buildingModel:Clone()
	clone.Parent = plotFolder

	-- Store reference
	tycoonData.Buildings[buildingId] = clone

	print("Spawned " .. buildingId .. " in plot " .. plotNumber)
end

-- Get tycoon owned by player
function TycoonManager.GetPlayerTycoon(player)
	for plotNumber, tycoonData in pairs(TycoonManager.ActiveTycoons) do
		if tycoonData.Owner == player then
			return tycoonData, plotNumber
		end
	end
	return nil
end

-- Unclaim tycoon when player leaves
function TycoonManager.OnPlayerRemoving(player)
	for plotNumber, tycoonData in pairs(TycoonManager.ActiveTycoons) do
		if tycoonData.Owner == player then
			-- Clear all buildings
			local plotFolder = TycoonPlots:FindFirstChild("Plot" .. plotNumber)
			if plotFolder then
				for _, child in ipairs(plotFolder:GetChildren()) do
					if child.Name ~= "ClaimButton" and child.Name ~= "SpawnLocation" then
						child:Destroy()
					end
				end

				-- Show claim button again
				local claimButton = plotFolder:FindFirstChild("ClaimButton")
				if claimButton then
					claimButton.Transparency = 0
					claimButton.CanCollide = false
				end
			end

			-- Clear data
			TycoonManager.ActiveTycoons[plotNumber] = nil
			break
		end
	end
end

return TycoonManager
