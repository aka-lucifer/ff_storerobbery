--- Starts the network scene for opening the safe
---@param coords vector3
---@param rotation vector3
---@param safe number
---@param bag number
---@return boolean
local function safeIdleScene(coords, rotation, safe, bag)
    local scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(
        cache.ped,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "idle_player",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    NetworkAddEntityToSynchronisedScene(
        safe,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "idle_safe",
        1.0,
        1.0,
        1
    )
    NetworkAddEntityToSynchronisedScene(
        bag,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "idle_bag",
        1.0,
        1.0,
        1
    )
    NetworkStartSynchronisedScene(scene)
    Wait(10000)
    NetworkStopSynchronisedScene(scene)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(
        cache.ped,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "door_open_player",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    NetworkAddEntityToSynchronisedScene(
        safe,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "door_open_safe",
        1.0,
        1.0,
        1
    )
    NetworkAddEntityToSynchronisedScene(
        bag,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "door_open_bag",
        1.0,
        1.0,
        1
    )
    NetworkStartSynchronisedScene(scene)
    Wait(2533)
    NetworkStopSynchronisedScene(scene)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(
        cache.ped,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "success_with_stack_bonds_player",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    NetworkAddEntityToSynchronisedScene(
        safe,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "success_with_stack_bonds_safe",
        1.0,
        1.0,
        1
    )
    NetworkAddEntityToSynchronisedScene(
        bag,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "success_with_stack_bonds_bag",
        1.0,
        1.0,
        1
    )
    NetworkStartSynchronisedScene(scene)
    Wait(1799)
    NetworkStopSynchronisedScene(scene)

    scene = NetworkCreateSynchronisedScene(coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, 2, false, false, -1, 0, 1.0)
    NetworkAddPedToSynchronisedScene(
        cache.ped,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "exit_player",
        1.5,
        -4.0,
        1,
        16,
        1148846080,
        0
    )
    NetworkAddEntityToSynchronisedScene(
        safe,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "exit_safe",
        1.0,
        1.0,
        1
    )
    NetworkAddEntityToSynchronisedScene(
        bag,
        scene,
        "anim@scripted@heist@ig15_safe_crack@male@",
        "exit_bag",
        1.0,
        1.0,
        1
    )
    NetworkStartSynchronisedScene(scene)
    Wait(666)
    NetworkStopSynchronisedScene(scene)
    DeleteEntity(bag)
    return true
end

--- Create duffel bag and start opening the safe
---@param safeEntity any
---@return boolean
local function openSafe(safeEntity)
    if not safeEntity or not DoesEntityExist(safeEntity) then return false end
    -- Load the model into memory
    lib.requestModel(`hei_p_m_bag_var22_arm_s`)

    -- Create the bag for the scene
    local safeCoords = GetEntityCoords(safeEntity, false)
    local safeRotation = GetEntityRotation(safeEntity, 2)
    local bag = CreateObject(`hei_p_m_bag_var22_arm_s`, safeCoords.x, safeCoords.y, safeCoords.z, true, false, false)

    local exists = lib.waitFor(function()
        if DoesEntityExist(bag) and NetworkGetEntityOwner(bag) ~= -1 then return true end
    end)

    if not exists then return false end

    -- Remove your weapon from your hand
    local currentWeapon = GetSelectedPedWeapon(cache.ped)
    RemoveWeaponFromPed(cache.ped, currentWeapon)
    SetModelAsNoLongerNeeded(`hei_p_m_bag_var22_arm_s`)

    -- Start the network scene
    return safeIdleScene(safeCoords, safeRotation, safeEntity, bag)
end

--- Event used for mythic safe code entering
---@param entity any
---@param data any
AddEventHandler("ff_shoprobbery:client:enterSafeCode", function(entity, data)
    if not entity.entity or not DoesEntityExist(entity.entity) then return end
    if not data or (not data.index or type(data.index) ~= "number") or (not data.netId or type(data.netId) ~= "number") then return end

    local inputtedCode = lib.inputDialog(locale("prompt.safe.title"), {
        {
            type = 'number',
            label = locale("prompt.safe.input.code.label"),
            description = locale("prompt.safe.input.code.description"),
            icon = 'qrcode',
            required = true
        },
    }, {
        allowCancel = true
    })
    if not inputtedCode then return end

    local success = lib.callback.await('ff_shoprobbery:openSafe', false, data.index, string.format("%04d", inputtedCode[1]))
    if success then
        if not openSafe(entity.entity) then return end
        
        TriggerServerEvent("ff_shoprobbery:server:lootedSafe", data.index, data.netId)
    else
        Notify(locale("error.incorrect_code"), 'error')
    end
end)

local safe = {
    targets = {}
}

--- Create the safe object
---@param safePosition vector4
---@return boolean, number?
function safe.create(safePosition)
    if not safePosition then return false end
    -- Load the memory into memory
    lib.requestModel(`h4_prop_h4_safe_01a`)

    -- Create the safe object
    local obj = CreateObject(`h4_prop_h4_safe_01a`, safePosition.x, safePosition.y, safePosition.z, true, false, false)
    -- Wait until the object exists and has a network owner
    local exists = lib.waitFor(function()
        if DoesEntityExist(obj) and NetworkGetEntityOwner(obj) ~= -1 then return true end
    end)

    if not exists then return false end
    SetEntityHeading(obj, safePosition.w - 180.0)
    SetModelAsNoLongerNeeded(`h4_prop_h4_safe_01a`)

    return true, NetworkGetNetworkIdFromEntity(obj)
end

--- Addd the target to the provided safe
---@param index number
---@param netId number
function safe.createTarget(index, netId)
    if not index or type(index) ~= "number" then return end
    if not netId or type(netId) ~= "number" then return end
    if not netId or not NetworkDoesNetworkIdExist(netId) then return end
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then return end

    -- Add the target to the safe
    table.insert(safe.targets, entity)

    if Config.Target ~= "mythic-targeting" then
        AddTargetEntity(entity, {
            {
                name = 'open_safe',
                label = locale('target.safe'),
                icon = 'fas fa-qrcode',
                distance = 2.0,
                onSelect = function()
                    local inputtedCode = lib.inputDialog(locale("prompt.safe.title"), {
                        {
                            type = 'number',
                            label = locale("prompt.safe.input.code.label"),
                            description = locale("prompt.safe.input.code.description"),
                            icon = 'qrcode',
                            required = true
                        },
                    }, {
                        allowCancel = true
                    })
                    if not inputtedCode then return end
                
                    local success = lib.callback.await('ff_shoprobbery:openSafe', false, index, string.format("%04d", inputtedCode[1]))
                    if success then
                        if not openSafe(entity) then return end
                        
                        TriggerServerEvent("ff_shoprobbery:server:lootedSafe", index, netId)
                    else
                        Notify(locale("error.incorrect_code"), 'error')
                    end
                end,
                canInteract = function()
                    local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                    if not storeData then return false end

                    return GlobalState["ff_shoprobbery:active"]
                    and not GlobalState["ff_shoprobbery:cooldown"]
                    and storeData.robbedTill and storeData.hackedNetwork and not storeData.openedSafe
                end
            }
        }, 2.0)
    else
        AddTargetEntity(entity, {
            icon = "qrcode",
            menuArray = {
                {
                    icon = "qrcode",
                    text = locale('target.safe'),
                    event = "ff_shoprobbery:client:enterSafeCode",
                    data = { index = index, netId = netId},
                    isEnabled = function()
                        local storeData = GlobalState[string.format("ff_shoprobbery:store:%s", index)]
                        if not storeData then return false end

                        return GlobalState["ff_shoprobbery:active"]
                        and not GlobalState["ff_shoprobbery:cooldown"]
                        and storeData.robbedTill and storeData.hackedNetwork and not storeData.openedSafe
                    end
                }
            },
        }, 2.0)
    end
end

--- Remove all targets for any of the created safes
function safe.deleteTargets()
    for i = 1, #safe.targets do
        RemoveTargetEntity(safe.targets[i], "open_safe")
        DeleteEntity(safe.targets[i])
    end
end

return safe