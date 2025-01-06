lib.locale()

local safe = require "client.safe"
local network = require "client.network"
require "client.peds"
require "client.tills"

--- Handle starting robbery by aiming at clerk
local function startClerkTask()
    CreateThread(function()
        while not GlobalState["ff_shoprobbery:active"] and not GlobalState["ff_shoprobbery:cooldown"] do
            local weapon = cache.weapon
            if weapon and weapon ~= `WEAPON_UNARMED` then
                if GetWeaponDamageType(weapon) == 3 then
                    if IsPlayerFreeAiming(cache.playerId) then
                        local found, entity = GetEntityPlayerIsFreeAimingAt(cache.playerId)
                        if found then
                            if GetEntityType(entity) == 1 and not IsPedAPlayer(entity) then
                                if Entity(entity).state["ff_shoprobbery:registerPed"] then
                                    local clerkPos = GetEntityCoords(entity, false)
                                    local till = GetClosestObjectOfType(clerkPos.x, clerkPos.y, clerkPos.z, 5.0, `prop_till_01`, false, false, false)
                                    if not till or not DoesEntityExist(till) then return end
                                    
                                    local tillCoords = GetOffsetFromEntityInWorldCoords(till, 0.0, 0.0, -0.12)
                                    local tillRotation = GetEntityRotation(till, 2)
                                    TriggerServerEvent("ff_shoprobbery:server:startedRobbery", tillCoords, tillRotation)
                                    
                                    Wait(5000) -- Make you wait 5 seconds before sending any other requests so it's not spammed every second
                                end
                            end
                        end
                    end
                end
            end
            Wait(1000)
        end
    end)
end

startClerkTask()

-- Deleting all targets on resource stop/restart
AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    network.deleteTargets()
    safe.deleteTargets()
end)

--- Used for recreating the aim at clerk task when cooldown is over
RegisterNetEvent("ff_shoprobbery:client:reset", startClerkTask)

--- Disable a networks target
---@param index number
RegisterNetEvent("ff_shoprobbery:client:disableNetwork", function(index)
    if not index or type(index) ~= "number" then return end
    network.deleteTarget(index)
end)

-- Handle statebag updates
for i = 1, #Config.Locations do
    AddStateBagChangeHandler(string.format("ff_shoprobbery:store:%s", i), "", function(bagName, key, value, reserved, replicated)
        Debug("Store data updated (" .. json.encode(value, { indent = true }) .. ")", DebugTypes.Info)

        if value and value.robbedTill and not value.hackedNetwork then
            network.createTarget(i)

            if not value.safeNet or not NetworkDoesNetworkIdExist(value.safeNet) then return end
            safe.createTarget(i, value.safeNet)
        end
    end)
end

--- Create the safe at the specified position
---@param safePosition vector4
---@return boolean, number?
lib.callback.register('ff_shoprobbery:createSafe', function(safePosition)
    return safe.create(safePosition)
end)