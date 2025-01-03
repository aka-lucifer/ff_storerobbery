---@param message string
---@param priority string
function Debug(message, priority)
    if not Config.Debug then return end
    priority = priority or DebugTypes.Info
    print(("^5[FiveForge Debug] ^7- %s %s"):format(priority, message))
end

if not IsDuplicityVersion() then
    function GetEntityAndNetIdFromBagName(bagName)
        local netId = tonumber(bagName:gsub('entity:', ''), 10)
    
        local entity = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(netId) then
                return NetworkGetEntityFromNetworkId(netId)
            end
        end, ('statebag timed out while awaiting entity creation! (%s)'):format(bagName), 10000)
    
        if not entity then
            lib.print.error(('statebag received invalid entity! (%s)'):format(bagName))
            return 0, 0
        end
    
        return entity, netId
    end
end

function Error(message)
    print("^1[Error] ^7- ^1" .. message .. "^0")
end