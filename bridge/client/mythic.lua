if Config.Framework ~= "Mythic" then return end

local function retrieveComponents()
	Targeting = exports["mythic-base"]:FetchComponent("Targeting")
	Progress = exports["mythic-base"]:FetchComponent("Progress")
	Notification = exports["mythic-base"]:FetchComponent("Notification")
	Callbacks = exports["mythic-base"]:FetchComponent("Callbacks")
	Inventory = exports["mythic-base"]:FetchComponent("Inventory")
end

AddEventHandler("ff_shoprobbery:Shared:DependencyUpdate", retrieveComponents)

AddEventHandler("Core:Shared:Ready", function()
	exports["mythic-base"]:RequestDependencies("ff_shoprobbery", {
		"Targeting",
		"Progress",
		"Notification",
		"Callbacks",
		"Inventory"
	}, function(error)
		if #error > 0 then
			return
		end
		retrieveComponents()
	end)
end)

---@param ped? integer
---@return boolean
function IsDead(ped)
    if not ped then ped = cache.ped end
    return LocalPlayer.state.isDead
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    if not amount then amount = 1 end

    if Inventory.Check.Player:HasItem(item, amount) then
		return true
	end
    
    return false
end
