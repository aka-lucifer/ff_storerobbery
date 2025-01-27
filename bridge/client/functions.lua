---@param data table
---@param finished? function
---@param cancelled? function
function ProgressBar(data, finished, cancelled)
    if Config.Progress == "ox_lib_bar" then
        if lib.progressBar(data) then
            if finished then finished() end
        else
            if cancelled then cancelled() end
        end
    elseif Config.Progress == "ox_lib_circle" then
        if lib.progressCircle(data) then
            if finished then finished() end
        else
            if cancelled then cancelled() end
        end
    elseif Config.Progress == "mythic" then
        Progress:Progress(data, function(cancel)
            if not cancel then
                if finished then finished() end
            else
                if cancelled then cancelled() end
            end
        end)
    end
end

---@param message string
---@param type 'inform' | 'error' | 'success' | 'warning'
---@param time? integer
---@param icon? string
function Notify(message, type, time, icon)
    if Config.Notifications ~= "gta" then
        -- Removes tilda styling which is used in GTA labels
        message = message:gsub("~.-~", "")
    end

    if Config.Notifications == 'ox_lib' then
        lib.notify({
            description = message,
            type = type,
            icon = icon and ("fas fa-%s"):format(icon) or nil,
            duration = time or 5000
        })
    elseif Config.Notifications == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Notifications == 'esx' then
        ESX.ShowNotification(message)
    elseif Config.Notifications == "mythic" then
        if Config.Framework ~= "Mythic" then return error("Unable to send notify as Config.Notifications is set to 'mythic' and the framework isn't!") end
        if type == 'inform' then
            Notification:Info(message, time or 5000, icon and icon or nil)
        elseif type == 'error' then
            Notification:Error(message, time or 5000, icon and icon or nil)
        elseif type == 'success' then
            Notification:Success(message, time or 5000, icon and icon or nil)
        elseif type == 'warning' then
            Notification:Warn(message, time or 5000, icon and icon or nil)
        end
    elseif Config.Notifications == 'okok' then
        exports['okokNotify']:Alert(message, time or 5000, type, false)
    elseif Config.Notifications == 'sd-notify' then
        exports['sd-notify']:Notify(message, type)
    elseif Config.Notifications == 'wasabi_notify' then
        exports.wasabi_notify:notify(message, time or 5000, type, false, icon and ("fas fa-%s"):format(icon) or nil)
    elseif Config.Notifications == 'custom' then
        -- Custom notification here
    end
end

RegisterNetEvent("ff_shoprobbery:client:notify", Notify)

function HelpNotify(text)
    AddTextEntry('ff_shoprobbery', text)
    BeginTextCommandDisplayHelp('ff_shoprobbery')
    EndTextCommandDisplayHelp(0, false, true, -1)
end

---@param entity integer
---@param data table
---@param distance? number
AddTargetEntity = function(entity, data, distance)
    if Config.Target == 'ox_target' then
        exports.ox_target:addLocalEntity(entity, data)
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddTargetEntity(entity, {options = data, distance = distance or 2.0})
    elseif Config.Target == 'qtarget' then
        exports.qtarget:AddTargetEntity(entity, {options = data, distance = distance or 2.0})
    elseif Config.Target == "mythic-targeting" then
        Targeting:AddEntity(entity, data.icon, data.menuArray, distance or 2.0)
    elseif Config.Target == 'custom' then
        -- Add support for a custom target system here
    else
        Debug('No target system defined in the config file.', DebugTypes.Error)
    end
end

-- Remove target from entity
--- @param entity number
--- @param data? table|string|nil
RemoveTargetEntity = function(entity, data)
    if Config.Target == 'ox_target' then
        exports.ox_target:removeLocalEntity(entity, data)
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:RemoveTargetEntity(entity, nil)
    elseif Config.Target == 'qtarget' then
        exports.qtarget:RemoveTargetEntity(entity, data)
    elseif Config.Target == "mythic-targeting" then
        Targeting:RemoveEntity(entity)
    elseif Config.Target == 'custom' then
        -- Add support for a custom target system here
    else
        Debug('No target system defined in the config file.', DebugTypes.Error)
    end
end

---@param data table
---@return string | integer
function AddCircleZoneTarget(data)
    if Config.Target == "ox_target" then
        exports.ox_target:addSphereZone(data)
        return data.name
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:AddCircleZone(data)
        return data.name
    elseif Config.Target == 'qtarget' then
        exports.qtarget:AddCircleZone(data.name, data.coords, data.radius, {
            name = data.name,
            debugPoly = data.debugPoly,
            options = data.options
        })

        return data.name
    elseif Config.Target == "mythic-targeting" then
        Targeting.Zones:AddCircle(data.zoneId, data.icon, data.coords, data.radius, data.options, data.menuArray, data.proximity or 2.0, true)
        Targeting.Zones:Refresh() -- Have to call this here as Mythic Target dumb asf
        return data.zoneId
    end
end

---@param zone string | integer
function RemoveCircleZoneTarget(zone)
    if Config.Target == "ox_target" then
        exports.ox_target:removeZone(zone)
    elseif Config.Target == 'qb-target' then
        exports['qb-target']:RemoveZone(zone)
    elseif Config.Target == 'qtarget' then
        exports.qtarget:RemoveZone(zone)
    elseif Config.Target == "mythic-targeting" then
        Targeting.Zones:RemoveZone(zone)
    end
end