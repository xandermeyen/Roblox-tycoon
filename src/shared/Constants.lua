-- src/shared/Constants.lua
local Constants = {}

-- Tycoon settings
Constants.MAX_TYCOONS = 10 -- Maximum number of tycoon plots
Constants.TYCOON_CLAIM_DISTANCE = 50 -- How close player needs to be to claim

-- Money settings
Constants.STARTING_MONEY = 100
Constants.DEFAULT_INCOME_RATE = 5 -- Money per interval
Constants.INCOME_INTERVAL = 2 -- Seconds between income

-- Colors
Constants.CLAIM_BUTTON_COLOR = Color3.fromRGB(85, 255, 127)
Constants.PURCHASE_BUTTON_COLOR = Color3.fromRGB(255, 170, 0)
Constants.LOCKED_BUTTON_COLOR = Color3.fromRGB(150, 150, 150)

return Constants
