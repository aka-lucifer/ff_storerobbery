if Config.Framework ~= "ESX" then return end

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
    elseif GetResourceState("esx_inventory") == "started" then
        local player = GetPlayer(source)
        if player.getInventoryItem(item)?.count > amount then
            return true
        end
    end
    
    return false
end

---@param source integer
---@param item string
---@param amount? integer
---@return boolean
function GiveItem(source, item, amount)
    if not amount then amount = 1 end

    if GetResourceState("ox_inventory") == "started" then
        local success, resp = exports.ox_inventory:AddItem(source, item, amount)
        if not success then
            Debug("Unable to add item to inventory (" .. resp .. ")", DebugTypes.Error)
        end

        return success
    elseif GetResourceState("esx_inventory") == "started" then
        local player = GetPlayer(source)
        if not player then return false end
        player.addInventoryItem(item, amount)
        return true
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
    elseif GetResourceState("esx_inventory") == "started" then
        local player = GetPlayer(source)
        if not player then return false end
        player.removeInventoryItem (item, amount)
        return true
    end

    return false
end

---@param item string
---@param itemUse function
function CreateUsableItem(item, itemUse)
    ESX.RegisterUsableItem(item, itemUse)
end

---@param source integer
---@return table
function GetPlayer(source)
    return ESX.GetPlayerFromId(source)
end

---@param source integer
---@param amount number
---@param account "cash" | "bank" | "money"
---@param reason string
function AddMoney(source, amount, account, reason)
    local player = GetPlayer(source)
    if not player then return end
    if account == "cash" then account = "money" end
    player.addAccountMoney(account, math.ceil(amount), reason)
end

---@return integer
function GetPoliceCount()
    local players = ESX.GetPlayers()
    local count = 0
    
    for _, playerId in pairs(players) do
        local player = ESX.GetPlayerFromId(playerId)
        for i = 1, #Config.DispatchJobs do
            if player.job.name == Config.DispatchJobs[i] then
                count += 1
            end
        end
    end

    return count
end

---@return integer[]
function GetPolice()
    local players = ESX.GetPlayers()
    local formattedPlayers = {} -- Have to convert table to this format, for framework compatibility

    for _, playerId in pairs(players) do
        local player = ESX.GetPlayerFromId(playerId)
        for i = 1, #Config.DispatchJobs do
            if player.job.name == Config.DispatchJobs[i] then
                formattedPlayers[_] = playerId
            end
        end
    end

    return formattedPlayers
end

---@param source integer
---@return boolean
function CanReset(source)
    local player = ESX.GetPlayerFromId(source)
    if not player then return false end

    local jobId = player.job.name
    local gradeId = player.job.grade
    local playerGroup = player.getGroup()

    if Config.ResetAccess.Jobs[jobId] and Config.ResetAccess.Jobs[jobId] <= gradeId then
        return true
    end

    for i = 1, #Config.ResetAccess.Groups do
        if playerGroup == Config.ResetAccess.Groups[i] then
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
    local player = ESX.GetPlayerFromId(source)
    if not player then return false end
    SendWebhook(source, username, player.cid, title, message, colour)
end