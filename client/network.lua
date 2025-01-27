local lastAlert = nil

local network = {
    zones = {},
    hackingInteract = false
}

AddEventHandler("ff_shoprobbery:client:hackNetwork", function(_, data)
    if not data or type(data.index) ~= "number" then
        network.hackingInteract = false
        return
    end
    
    lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    TaskPlayAnim(cache.ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 2.0, 2.0, -1, 50, 0, false, false, false)
    
    local hackedNetwork = exports.fallouthacking:start(6, 8)
    if hackedNetwork then
        local success, safeCode = lib.callback.await('ff_shoprobbery:getSafeCode', false, data.index)
        if not success then
            network.hackingInteract = false
            return
        end
        Notify(string.format(locale("notification.safe_code"), safeCode), "inform", 20000)
    else
        if not lastAlert or GetGameTimer() > lastAlert then -- Handles cooldown for alert so it isn't spammed
            NetworkAlert(GetEntityCoords(cache.ped, false))
            lastAlert = GetGameTimer() + Config.NetworkAlertTimeout * 1000
        end
    end
    
    network.hackingInteract = false
    ClearPedTasks(cache.ped)
end)

--- Create network hack target for the current store
---@param index number
function network.createTarget(index)
    if not index or type(index) ~= "number" then return end

    table.insert(network.zones, string.format("ff_shoprobbery_network_%s_hack", index))
    if Config.Target ~= "mythic-targeting" then
        AddCircleZoneTarget({
            name = string.format("ff_shoprobbery_network_%s_hack", index),
            coords = Config.Locations[index].network.coords,
            radius = Config.Locations[index].network.radius,
            debug = Config.Debug,
            options = {
                {
                    name = string.format("ff_shoprobbery_network_%s_hack", index),
                    icon = 'fas fa-network-wired',
                    label = locale('target.network'),
                    distance = 2.0,
                    onSelect = function()
                        lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
                        TaskPlayAnim(cache.ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 2.0, 2.0, -1, 50, 0, false, false, false)
                        
                        local hackedNetwork = exports.fallouthacking:start(6, 8)
                        if hackedNetwork then
                            local success, safeCode = lib.callback.await('ff_shoprobbery:getSafeCode', false, index)
                            if not success then
                                network.hackingInteract = false
                                return
                            end

                            Notify(string.format(locale("notification.safe_code"), safeCode), "inform", 20000)
                        else
                            if not lastAlert or GetGameTimer() > lastAlert then -- Handles cooldown for alert so it isn't spammed
                                NetworkAlert(GetEntityCoords(cache.ped, false))
                                lastAlert = GetGameTimer() + Config.NetworkAlertTimeout * 1000
                            end
                        end

                        network.hackingInteract = false
                        ClearPedTasks(cache.ped)
                    end,
                    canInteract = function()
                        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                        if not storeData then return false end

                        return GlobalState["ff_shoprobbery:active"]
                        and not GlobalState["ff_shoprobbery:cooldown"]
                        and storeData.robbedTill and not storeData.hackedNetwork and not storeData.openedSafe
                    end,
                }
            }
        })
    else
        AddCircleZoneTarget({
            zoneId = string.format("ff_shoprobbery_network_%s_hack", index),
            icon = "network-wired",
            coords = Config.Locations[index].network.coords,
            radius = Config.Locations[index].network.radius,
            options = {
                debugPoly = Config.Debug
            },
            menuArray = {
                {
                    icon = "network-wired",
                    text = locale('target.network'),
                    event = "ff_shoprobbery:client:hackNetwork",
                    data = { index = index },
                    isEnabled = function()
                        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                        if not storeData then return false end

                        return GlobalState["ff_shoprobbery:active"]
                        and not GlobalState["ff_shoprobbery:cooldown"]
                        and storeData.robbedTill and not storeData.hackedNetwork and not storeData.openedSafe
                    end
                }
            },
            proximity = 2.0
        })
    end
end

--- Delete all registered network targets
function network.deleteTargets()
    for i = 1, #network.zones do
        RemoveCircleZoneTarget(network.zones[i])
    end
end

--- Delete a specific network target and remove it from the array
---@param index number
function network.deleteTarget(index)
    if not index or type(index) ~= "number" then return end
    local zoneId = string.format("ff_shoprobbery_network_%s_hack", index)

    RemoveCircleZoneTarget(zoneId)
    
    for i = 1, #network.zones do
        if network.zones[i] == zoneId then
            table.remove(network.zones, i)
        end
    end
end

--- Create network hack interaction for the current store
---@param index number
function network.createInteract(index)
    if not index or type(index) ~= "number" then return end
    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
    if not storeData then return end

    local coords = Config.Locations[index].network.coords
    CreateThread(function()
        while GlobalState["ff_shoprobbery:active"]
        and GlobalState[string.format("ff_shoprobbery:store:%s", index)].robbedTill
        and not GlobalState[string.format("ff_shoprobbery:store:%s", index)].hackedNetwork do
            if not network.hackingInteract then
                if #(GetEntityCoords(cache.ped, false) - coords) < 2.0 then
                    HelpNotify(locale("interact.network"))
                    if IsControlJustPressed(0, 47) then
                        network.hackingInteract = true
                        TriggerEvent("ff_shoprobbery:client:hackNetwork", nil, { index = index })
                    end

                    Wait(5)
                else
                    Wait(1000)
                end
            else
                Wait(1000)
            end
        end
    end)
end

return network