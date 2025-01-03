if Config.Framework ~= "Qbox" then return end

---@param ped? integer
---@return boolean
function IsDead(ped)
    if not ped then ped = cache.ped end
    return QBX.PlayerData.metadata.isdead or QBX.PlayerData.metadata.inlaststand
end

---@param item string
---@param amount? number
---@return boolean
function HasItem(item, amount)
    if not amount then amount = 1 end
    if exports.ox_inventory:Search('count', item) >= amount then
        return true
    end

    return false
end