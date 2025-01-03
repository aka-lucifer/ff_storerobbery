if Config.Framework ~= "QB" then return end

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

    if GetResourceState("ox_inventory") == "started" then
        if exports.ox_inventory:Search(source, 'count', item) >= amount then
            return true
        end
    elseif GetResourceState("qb-inventory") == "started" then
        if QBCore.Functions.HasItem(source, item, amount) then
            return true
        end
    end
    
    return false
end

---@param source integer
---@param item string
---@param amount? integer
---@param metadata? table
---@return boolean
function GiveItem(source, item, amount, metadata)
    if not amount then amount = 1 end

    if GetResourceState("ox_inventory") == "started" then
        local success, resp = exports.ox_inventory:AddItem(source, item, amount, metadata)
        if not success then
            Debug("Unable to add item to inventory (" .. resp .. ")", DebugTypes.Error)
        end

        return success
    elseif GetResourceState("qb-inventory") == "started" then
        local player = GetPlayer(source)
        if not player then return false end

        local success = exports['qb-inventory']:AddItem(player.PlayerData.citizenid, item, amount, false, metadata)

        if not success then
            Debug("Unable to add item to inventory (" .. source .. ")", DebugTypes.Error)
        end
    end

    return false
end

---@param source integer
---@param item string
---@param amount? integer
---@return boolean
function RemoveItem(source, item, amount)
    if not amount then amount = 1 end

    if GetResourceState("ox_inventory") == "started" then
        local success = exports.ox_inventory:RemoveItem(source, item, amount)
        if not success then
            Debug("Unable to remove item from inventory (" .. source .. ")", DebugTypes.Error)
        end

        return success
    elseif GetResourceState("qb-inventory") == "started" then
        local player = GetPlayer(source)
        if not player then return false end

        local success = QBCore.Functions.RemoveItem(player.PlayerData.citizenid, item, amount)

        if not success then
            Debug("Unable to remove item from inventory (" .. source .. ")", DebugTypes.Error)
        end

        return success
    end

    return false
end

---@param item string
---@param itemUse function
function CreateUsableItem(item, itemUse)
    QBCore.Functions.CreateUseableItem(item, itemUse)
end

---@param source integer
---@return table
function GetPlayer(source)
    return QBCore.Functions.GetPlayer(source)
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
    local players = QBCore.Functions.GetPlayers()
    local count = 0

    for _, playerId in pairs(players) do
        local player = QBCore.Functions.GetPlayer(playerId)
        for i = 1, #Config.DispatchJobs do
            if player.PlayerData.job.name == Config.DispatchJobs[i] and player.PlayerData.job.onduty then
                count += 1
            end
        end
    end

    return count
end

---@return integer[]
function GetPolice()
    local players = QBCore.Functions.GetPlayers()
    local formattedPlayers = {}
    
    for _, playerId in pairs(players) do
        local player = QBCore.Functions.GetPlayer(playerId)
        for i = 1, #Config.DispatchJobs do
            if player.PlayerData.job.name == Config.DispatchJobs[i] and player.PlayerData.job.onduty then
                formattedPlayers[_] = playerId
            end
        end
    end

    return formattedPlayers
end

---@param source integer
---@return boolean
function CanReset(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end

    local jobId = player.PlayerData.job.name
    local gradeId = player.PlayerData.job.grade.level
    local onDuty = player.PlayerData.job.onduty

    if Config.ResetAccess.Jobs[jobId] and Config.ResetAccess.Jobs[jobId] <= gradeId and onDuty then
        return true
    end

    for i = 1, #Config.ResetAccess.Groups do
        if QBCore.Functions.HasPermissionn(source, Config.ResetAccess.Groups[i]) then
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
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return false end
    SendWebhook(source, username, player.PlayerData.citizenid, title, message, colour)
end