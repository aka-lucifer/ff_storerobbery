if Config.Framework ~= "Qbox" then return end

---@param source integer
---@return boolean
function IsAdmin(source)
    return IsPlayerAceAllowed(tostring(source), "command")
end

---@param source number
---@param item string
---@param amount? number
---@return boolean
function HasItem(source, item, amount)
    if not amount then amount = 1 end
    if exports.ox_inventory:Search(source, 'count', item) >= amount then
        return true
    end

    return false
end

---@param source integer
---@param item string
---@param amount? integer
---@param metadata? integer
---@return boolean
function GiveItem(source, item, amount, metadata)
    if not amount then amount = 1 end
    local success, resp = exports.ox_inventory:AddItem(source, item, amount, metadata)
    if not success then
        Debug("Unable to add item to inventory (" .. resp .. ")", DebugTypes.Error)
    end

    return success
end

---@param source integer
---@param item string
---@param amount? integer
---@return boolean
function RemoveItem(source, item, amount)
    if not amount then amount = 1 end
    local success = exports.ox_inventory:RemoveItem(source, item, amount)
    if not success then
        Debug("Unable to remove item from inventory (" .. source .. ")", DebugTypes.Error)
    end

    return success
end


---@param item string
---@param itemUse function
function CreateUsableItem(item, itemUse)
    exports.qbx_core:CreateUseableItem(item, function(source, item)
        itemUse(source, item)
    end)
end

---@param source integer
---@return table
function GetPlayer(source)
    return exports.qbx_core:GetPlayer(source)
end

---@param source integer
---@param amount number
---@param account "cash" | "bank" | "money"
---@param reason string
function AddMoney(source, amount, account, reason)
    if account == "money" then account = "cash" end
    local player = GetPlayer(source)
    if not player then return end
    player.Functions.AddMoney(account, math.ceil(amount), reason)
end

---@return integer
function GetPoliceCount()
    local count, _ = exports.qbx_core:GetDutyCountType('leo')
    return count
end

---@return integer[]
function GetPolice()
    local _, players = exports.qbx_core:GetDutyCountType('leo')
    return players
end

---@param source integer
---@return boolean
function CanReset(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end

    local jobId = player.PlayerData.job.name
    local gradeId = player.PlayerData.job.grade.level
    local onDuty = player.PlayerData.job.onduty

    if Config.ResetAccess.Jobs[jobId] and Config.ResetAccess.Jobs[jobId] <= gradeId and onDuty then
        return true
    end

    for i = 1, #Config.ResetAccess.Groups do
        if exports.qbx_core:HasPermission(source, Config.ResetAccess.Groups[i]) then
            return true
        end
    end

    return false
end

---@param source integer
---@param username string
---@param title string
---@param message string
---@param colour? integer
function SendLog(source, username, title, message, colour)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return false end
    if Config.Debug then
        Debug(string.format("[%s] - %s", title, message), DebugTypes.Debug)
    end
    
    SendWebhook(source, username, player.PlayerData.citizenid, title, message, colour)
end