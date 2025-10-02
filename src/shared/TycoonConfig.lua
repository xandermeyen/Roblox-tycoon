-- src/shared/TycoonConfig.lua
local TycoonConfig = {}

-- Define all buildings/purchases in your tycoon
-- You'll create the actual models in Studio and reference them here
TycoonConfig.Buildings = {
	{
		Id = "Entrance",
		Name = "Haunted Entrance",
		Cost = 0, -- Free starter building
		Unlocks = { "GhostSpawner" }, -- What this building unlocks
		Income = 0, -- Additional income per interval
	},
	{
		Id = "GhostSpawner",
		Name = "Ghost Spawner",
		Cost = 250,
		Requires = { "Entrance" }, -- What buildings are needed before this
		Unlocks = { "PumpkinPatch", "SpookyTree" },
		Income = 10,
	},
	{
		Id = "PumpkinPatch",
		Name = "Pumpkin Patch",
		Cost = 500,
		Requires = { "GhostSpawner" },
		Unlocks = { "HauntedMansion" },
		Income = 25,
	},
	{
		Id = "SpookyTree",
		Name = "Spooky Tree",
		Cost = 750,
		Requires = { "GhostSpawner" },
		Unlocks = { "HauntedMansion" },
		Income = 35,
	},
	{
		Id = "HauntedMansion",
		Name = "Haunted Mansion",
		Cost = 2000,
		Requires = { "PumpkinPatch", "SpookyTree" }, -- Needs BOTH
		Unlocks = {},
		Income = 100,
	},
}

-- Helper function to get building by ID
function TycoonConfig.GetBuilding(buildingId)
	for _, building in ipairs(TycoonConfig.Buildings) do
		if building.Id == buildingId then
			return building
		end
	end
	return nil
end

return TycoonConfig
