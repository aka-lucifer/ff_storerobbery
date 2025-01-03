if Config.Framework ~= "QB" then return end

---@param ped? integer
---@return boolean
function IsDead(ped)
    if not ped then ped = cache.ped end
    return QBCore.Functions.GetPlayerData().metadata.isdead or QBCore.Functions.GetPlayerData().metadata.inlaststand
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
    elseif GetResourceState("qb-inventory") == "started" then
        if QBCore.Functions.HasItem(item, amount) then
            return true
        end
    end
    
    return false
end