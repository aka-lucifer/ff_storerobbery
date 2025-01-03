lib.locale()

GlobalState["ff_shoprobbery:active"] = false
GlobalState["ff_shoprobbery:cooldown"] = false

local peds = require "server.peds"
require "server.version"

--- Gets the closest store to the provided coords
---@param position vector3
---@return number | nil
local function getClosestStore(position)
    local closest, closestDist = nil, nil

    for i = 1, #Config.Locations do
        local clerkPos = Config.Locations[i].ped
        local dist = #(vector3(clerkPos.x, clerkPos.y, clerkPos.z) - position)

        if not closestDist or dist < closestDist then
            closest = i
            closestDist = dist
        end
    end

    return closest
end

--- Generates the code for a safe
local function generateCode()
    local number = tostring(math.random(0, 9999))
    return string.format("%04d", number) -- Format string by placing 0 in front of 3 digit numbers
end

local function updateStore(storeIndex, key, value)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    if not key or type(key) ~= "string" then return end
    if not value then return end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]

    for k, v in pairs(storeData) do
        if k == key then
            storeData[k] = value
        end
    end

    GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)] = storeData
end

--- Resets all the robbery states back to default value
---@param index number
local function finishRobbery(index)
    if not index or type(index) ~= "number" then return end
    if not GlobalState[string.format("ff_shoprobbery:store:%s", index)] then return end

    local safeNetworkId = GlobalState[string.format("ff_shoprobbery:store:%s", index)].safeNet
    GlobalState["ff_shoprobbery:active"] = false
    GlobalState["ff_shoprobbery:cooldown"] = os.time() + Config.GlobalCooldown
    GlobalState[string.format("ff_shoprobbery:store:%s", index)] = {
        robbedTill = false,
        cooldown = Config.UseStoreCooldown and os.time() + Config.StoreCooldown or -1,
        lastSafe = safeNetworkId,
        hackedComputer = false,
        safeCode = generateCode(),
        openedSafe = false,
        safeNet = -1
    }

    TriggerClientEvent("ff_shoprobbery:client:disableComputer", -1, index)

    -- Handle resetting global cooldown
    SetTimeout(Config.GlobalCooldown * 1000, function()
        -- If the global cooldown is still active (hasn't been reset with commands, reset it)
        if GlobalState["ff_shoprobbery:cooldown"] then
            GlobalState["ff_shoprobbery:cooldown"] = false
            Wait(1000) -- Wait a second for the statebag to sync
            TriggerClientEvent("ff_shoprobbery:client:reset", -1)
        end
    end)

    -- Handle resetting store cooldown
    if not Config.UseStoreCooldown then return end
    SetTimeout(Config.StoreCooldown * 1000, function()
        -- If the store cooldown is still active (hasn't been reset with commands, reset it)
        if GlobalState[string.format("ff_shoprobbery:store:%s", index)].cooldown ~= -1 then
            updateStore(index, "cooldown", -1)
            
            local safeNet = GlobalState[string.format("ff_shoprobbery:store:%s", index)].lastSafe
            if safeNet then
                local entity = NetworkGetEntityFromNetworkId(safeNet)
                if not entity or not DoesEntityExist(entity) then return end

                DeleteEntity(entity)
                updateStore(index, "lastSafe", -1)
            end
        end
    end)
end

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    peds.deleteAll()
end)

---@param tillCoords vector3
---@param tillRotation vector3
RegisterNetEvent("ff_shoprobbery:server:startedRobbery", function(tillCoords, tillRotation)
    if not tillCoords or not tillRotation then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    -- Prevent robbing the store if it's already being robbed
    if GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end

    -- Prevent robbing the store if not found or store cooldown is active
    local closestStore = getClosestStore(tillCoords)
    if not closestStore or GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].cooldown ~= -1 then
        return Notify(src, locale("error.already_robbed"), "error")
    end

    -- Prevent robbing the store if not enough police are available
    local activePolice = GetPoliceCount()
    if activePolice < Config.RequiredPolice then
        return Notify(src, string.format(locale("error.not_enough_police"), Config.RequiredPolice), "error")
    end

    local netId, distance = peds.getClosest(tillCoords)
    
    -- Check if the stores clerk exists
    if not netId or not distance then
        return
    end

    -- Make sure the clerk is close enough
    if distance >= 3.0 then
        return
    end

    GlobalState["ff_shoprobbery:active"] = true
    TriggerClientEvent("ff_shoprobbery:client:robTill", src, netId, tillCoords, tillRotation)
    SendLog(src, GetPlayerName(src), locale("logs.started.title"), string.format(locale("logs.started.description"), closestStore), Colours.FiveForgeBlue)
end)

---@param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:server:removeTill", function(tillCoords)
    if not tillCoords then return end
    TriggerClientEvent("ff_shoprobbery:client:removeTill", -1, tillCoords)
end)

---@param tillCoords vector3
RegisterNetEvent("ff_shoprobbery:server:restoreTill", function(tillCoords)
    if not tillCoords then return end
    TriggerClientEvent("ff_shoprobbery:client:restoreTill", -1, tillCoords)
end)

---@param pickupCoords vector3
RegisterNetEvent("ff_shoprobbery:server:cashDropped", function(pickupCoords)
    if not pickupCoords then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    -- Prevent robbing the store if it's already being robbed
    if not GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end

    -- Prevent robbing the store if not found or store cooldown is active
    local closestStore = getClosestStore(pickupCoords)
    if not closestStore or GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].cooldown ~= -1 then return end

    local success, netId = lib.callback.await("ff_shoprobbery:createSafe", src, Config.Locations[closestStore].safe)
    if not success or (not netId or netId <= 0) then return end

    updateStore(closestStore, "safeNet", netId)
    updateStore(closestStore, "robbedTill", true)
    TriggerClientEvent("ff_shoprobbery:client:cashDropped", -1, pickupCoords)
    SendLog(src, GetPlayerName(src), locale("logs.loot_dropped.title"), string.format(locale("logs.loot_dropped.description"), closestStore), Colours.FiveForgeBlue)
end)

---@param pickupCoords vector3
RegisterNetEvent("ff_shoprobbery:server:cashCollected", function(pickupCoords)
    if not pickupCoords then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return end

    -- Prevent robbing the store if it's already being robbed
    if not GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end
    
    -- Prevent robbing the store if not found or store cooldown is active
    local closestStore = getClosestStore(pickupCoords)
    if not closestStore or GlobalState[string.format("ff_shoprobbery:store:%s", closestStore)].cooldown ~= -1 then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    if #(pedCoords - pickupCoords) > 1.5 then return end

    TriggerClientEvent("ff_shoprobbery:client:cashCollected", -1, pickupCoords)

    local value = math.random(Config.TillValue.min, Config.TillValue.max)
    GiveMoney(src, value, "collected money from till")
    SendLog(src, GetPlayerName(src), locale("logs.loot_collected.title"), string.format(locale("logs.loot_collected.description"), value, closestStore), Colours.FiveForgeBlue)
end)

---@param source number
---@param storeIndex number
---@return boolean, string?
lib.callback.register('ff_shoprobbery:getSafeCode', function(source, storeIndex)
    if not storeIndex or type(storeIndex) ~= "number" then return false end

    local src = source
    local player = GetPlayer(src)
    if not player then return false end

    -- Prevent robbing the store if it's already being robbed
    if not GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig then return false end

    if #(pedCoords - storeConfig.computer.coords) > 2.0 then return false end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData then return false end

    updateStore(storeIndex, "hackedComputer", true)
    SendLog(src, GetPlayerName(src), locale("logs.hacked_computer.title"), string.format(locale("logs.hacked_computer.description"), storeIndex), Colours.FiveForgeBlue)
    return true, storeData.safeCode
end)

---@param source number
---@param storeIndex number
---@param enteredCode string
---@return boolean
lib.callback.register('ff_shoprobbery:openSafe', function(source, storeIndex, enteredCode)
    if not storeIndex or type(storeIndex) ~= "number" then return false end
    if not enteredCode or type(enteredCode) ~= "string" then return false end

    local src = source
    local player = GetPlayer(src)
    if not player then return false end

    -- Prevent robbing the store if it's already being robbed
    if not GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig then return false end

    if #(pedCoords - vector3(storeConfig.safe.x, storeConfig.safe.y, storeConfig.safe.z)) > 2.0 then return false end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData then return false end

    if storeData.safeCode ~= enteredCode then return false end
    updateStore(storeIndex, "openedSafe", true)
    SendLog(src, GetPlayerName(src), locale("logs.opened_safe.title"), string.format(locale("logs.opened_safe.description"), storeData.safeCode, storeIndex), Colours.FiveForgeBlue)
    return true
end)

---@param storeIndex number
---@param safeNet number
RegisterNetEvent("ff_shoprobbery:server:lootedSafe", function(storeIndex, safeNet)
    if not storeIndex or type(storeIndex) ~= "number" then return end
    if not safeNet or type(safeNet) ~= "number" then return end

    local src = source
    local player = GetPlayer(src)
    if not player then return false end

    -- Prevent robbing the store if it's already being robbed
    if not GlobalState["ff_shoprobbery:active"] then
        return Notify(src, locale("error.active"), "error")
    end

    -- Prevent robbing the store if global cooldown is active
    if GlobalState["ff_shoprobbery:cooldown"] then
        return Notify(src, locale("error.cooldown"), "error")
    end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped, false)
    local storeConfig = Config.Locations[storeIndex]
    if not storeConfig then return false end

    if #(pedCoords - vector3(storeConfig.safe.x, storeConfig.safe.y, storeConfig.safe.z)) > 2.0 then return false end

    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)]
    if not storeData then return false end

    for _, itemData in pairs(Config.SafeItems) do
        if math.random(100) >= itemData.chance then
            GiveItem(src, itemData.item, math.random(itemData.amount.min, itemData.amount.max))
        end
    end

    finishRobbery(storeIndex)
    SendLog(src, GetPlayerName(src), locale("logs.looted_safe.title"), string.format(locale("logs.looted_safe.description"), storeIndex), Colours.FiveForgeBlue)
end)

-- Process store initial setup (store global states and till clerks)
CreateThread(function()
    for i = 1, #Config.Locations do
        GlobalState[string.format("ff_shoprobbery:store:%s", i)] = {
            robbedTill = false,
            cooldown = -1,
            hackedComputer = false,
            safeCode = generateCode(),
            openedSafe = false,
            safeNet = -1
        }
        peds.create(Config.Locations[i].ped)
    end
end)

local function canResetStores(source)
    return true
end

lib.addCommand('resetstore', {
    help = 'This will remove a specific store cooldown. (Will not remove global cooldown)',
    params = {
        {
            name = "storeId",
            type = "number",
            help = "The ID of the store to reset"
        }
    },
}, function(source, args)
    if not canResetStores(source) then return end
    local src = source

    local storeIndex = tonumber(args.storeId)
    if not storeIndex then return end

    if GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)].cooldown ~= -1 then
        updateStore(storeIndex, "cooldown", -1)
        
        local safeNet = GlobalState[string.format("ff_shoprobbery:store:%s", storeIndex)].lastSafe
        if safeNet then
            local entity = NetworkGetEntityFromNetworkId(safeNet)
            if not entity or not DoesEntityExist(entity) then return end

            DeleteEntity(entity)
            updateStore(storeIndex, "lastSafe", -1)
        end
        
        SendLog(src, GetPlayerName(src), locale("logs.store_cooldown.title"), string.format(locale("logs.store_cooldown.description"), storeIndex), Colours.FiveForgeBlue)
    else
        Notify(src, locale("error.global_cooldown"), "error")
    end
end)

lib.addCommand('resetstores', {
    help = 'This will reset all store cooldowns and the global cooldown.',
    params = {},
}, function(source, args)
    if not canResetStores(source) then return end
    local src = source

    if GlobalState["ff_shoprobbery:cooldown"] then
        GlobalState["ff_shoprobbery:cooldown"] = false
        Wait(1000) -- Wait a second for the statebag to sync
    else
        Notify(src, locale("error.global_cooldown"), "error")
    end

    TriggerClientEvent("ff_shoprobbery:client:reset", -1)

    for i = 1, #Config.Locations do
        if GlobalState[string.format("ff_shoprobbery:store:%s", i)].cooldown ~= -1 then
            local safeNet = GlobalState[string.format("ff_shoprobbery:store:%s", i)].lastSafe
            if safeNet then
                local entity = NetworkGetEntityFromNetworkId(safeNet)
                if not entity or not DoesEntityExist(entity) then return end

                DeleteEntity(entity)
            end
        end

        GlobalState[string.format("ff_shoprobbery:store:%s", i)] = {
            robbedTill = false,
            cooldown = -1,
            hackedComputer = false,
            safeCode = generateCode(),
            openedSafe = false,
            safeNet = -1
        }
    end

    SendLog(src, GetPlayerName(src), locale("logs.global_cooldown.title"), string.format(locale("logs.global_cooldown.description"), storeIndex), Colours.FiveForgeBlue)
end)