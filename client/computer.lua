AddEventHandler("ff_shoprobbery:client:hackComputer", function(_, data)
    if not data or type(data.index) ~= "number" then return end
    
    lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    TaskPlayAnim(cache.ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 2.0, 2.0, -1, 50, 0, false, false, false)
    
    local hackedComputer = exports.fallouthacking:start(6, 8)
    if hackedComputer then
        local success, safeCode = lib.callback.await('ff_shoprobbery:getSafeCode', false, data.index)
        if not success then return end

        Notify(string.format(locale("notification.safe_code"), safeCode), "inform", 20000)
    else
        NetworkAlert(GetEntityCoords(cache.ped, false))
    end
    
    ClearPedTasks(cache.ped)
end)

local computer = {
    zones = {}
}

--- Create computer hack target for the current store
---@param index number
function computer.createTarget(index)
    if not index or type(index) ~= "number" then return end

    table.insert(computer.zones, string.format("ff_shoprobbery_computer_%s_hack", index))
    if Config.Target ~= "mythic-targeting" then
        AddCircleZoneTarget({
            name = string.format("ff_shoprobbery_computer_%s_hack", index),
            coords = Config.Locations[index].computer.coords,
            radius = Config.Locations[index].computer.radius,
            debug = Config.Debug,
            options = {
                {
                    name = string.format("ff_shoprobbery_computer_%s_hack", index),
                    icon = 'fas fa-network-wired',
                    label = locale('target.computer'),
                    distance = 2.0,
                    onSelect = function()
                        lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
                        TaskPlayAnim(cache.ped, "anim@heists@prison_heiststation@cop_reactions", "cop_b_idle", 2.0, 2.0, -1, 50, 0, false, false, false)
                        
                        local hackedComputer = exports.fallouthacking:start(6, 8)
                        if hackedComputer then
                            local success, safeCode = lib.callback.await('ff_shoprobbery:getSafeCode', false, index)
                            if not success then return end

                            Notify(string.format(locale("notification.safe_code"), safeCode), "inform", 20000)
                        else
                            NetworkAlert(GetEntityCoords(cache.ped, false))
                        end

                        ClearPedTasks(cache.ped)
                    end,
                    canInteract = function()
                        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                        if not storeData then return false end

                        return GlobalState["ff_shoprobbery:active"]
                        and not GlobalState["ff_shoprobbery:cooldown"]
                        and storeData.robbedTill and not storeData.hackedComputer and not storeData.openedSafe
                    end,
                }
            }
        })
    else
        AddCircleZoneTarget({
            zoneId = string.format("ff_shoprobbery_computer_%s_hack", index),
            icon = "network-wired",
            coords = Config.Locations[index].computer.coords,
            radius = Config.Locations[index].computer.radius,
            options = {
                debugPoly = Config.Debug
            },
            menuArray = {
                {
                    icon = "network-wired",
                    text = locale('target.computer'),
                    event = "ff_shoprobbery:client:hackComputer",
                    data = { index = index },
                    isEnabled = function()
                        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                        if not storeData then return false end

                        return GlobalState["ff_shoprobbery:active"]
                        and not GlobalState["ff_shoprobbery:cooldown"]
                        and storeData.robbedTill and not storeData.hackedComputer and not storeData.openedSafe
                    end
                }
            },
            proximity = 2.0
        })
    end
end

--- Delete all registered computer targets
function computer.deleteTargets()
    for i = 1, #computer.zones do
        RemoveCircleZoneTarget(computer.zones[i])
    end
end

--- Delete a specific computer target and remove it from the array
---@param index number
function computer.deleteTarget(index)
    if not index or type(index) ~= "number" then return end
    local zoneId = string.format("ff_shoprobbery_computer_%s_hack", index)

    RemoveCircleZoneTarget(zoneId)
    
    for i = 1, #computer.zones do
        if computer.zones[i] == zoneId then
            table.remove(computer.zones, i)
        end
    end
end

return computer