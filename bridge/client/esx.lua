if Config.Framework ~= "ESX" then return end
local isDead = false

AddEventHandler('esx:onPlayerDeath', function()
    isDead = true
end)

---@param ped? integer
---@return boolean
function IsDead(ped)
    if not ped then ped = cache.ped end
    return isDead
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    if not amount then amount = 1 end

    if GetResourceState("ox_inventory") == "started" then
        if exports.ox_inventory:Search('count', item) >= amount then
            return true
        end
    elseif GetResourceState("esx_inventory") == "started" then
        local xPlayer = ESX.GetPlayerData()
        if xPlayer and xPlayer.inventory then
            for _, item in pairs(xPlayer.inventory) do
                if item.name == item and item.count >= amount then
                    return true
                end
            end
        end
    end
    
    return false
end