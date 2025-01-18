function RobberyAlert(coords)
    if Config.Dispatch == "cd_dispatch" then
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.DispatchJobs, 
            coords = coords,
            title = '10-68 - Store Robbery',
            message = "Robbery reported at general store.",
            flash = 0,
            unique_id = 'storerobbery',
            sound = 1,
            blip = {
                sprite = 52, 
                scale = 1.0, 
                colour = 1,
                flashes = false, 
                time = 5
            }
        })
    elseif Config.Dispatch == "qs-dispatch" then
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.DispatchJobs,
            callLocation = coords,
            callCode = { code = '10-68', snippet = 'Store Robbery' },
            message = "Robbery reported at general store.",
            flashes = false,
            blip = {
                sprite = 52, 
                scale = 1.0, 
                colour = 1,
                time = (5 * 60000),
            }
        })
    elseif Config.Dispatch == "ps-dispatch" then
        exports["ps-dispatch"]:StoreRobbery()
    elseif Config.Dispatch == "rcore_dispatch" then
        local data = {
            code = '10-68',
            default_priority = 'medium',
            coords = coords,
            job = Config.DispatchJobs,
            text = 'Store Robbery',
            type = 'alerts',
            blip_time = 0,
            blip = {
                sprite = 52, 
                scale = 1.0, 
                colour = 1,
                radius = 0,
            }
        }
        TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
    elseif Config.Dispatch == "mythic-mdt" then
        TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "storeRobbery", {
			icon = "store",
			details = "Robbery reported at general store."
		})
    elseif Config.Dispatch == "custom" then
        -- fill this here
    end
end

function NetworkAlert(coords)
    if Config.Dispatch == "cd_dispatch" then
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.DispatchJobs, 
            coords = coords,
            title = '10-17 - Network Access',
            message = "Unauthorized network access at general store.",
            flash = 0,
            unique_id = 'storenetwork',
            sound = 1,
            blip = {
                sprite = 629, 
                scale = 1.0, 
                colour = 1,
                flashes = false, 
                time = 5
            }
        })
    elseif Config.Dispatch == "qs-dispatch" then
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = Config.DispatchJobs,
            callLocation = coords,
            callCode = { code = '10-17', snippet = 'Network Access' },
            message = "Unauthorized network access at general store.",
            flashes = false,
            blip = {
                sprite = 629, 
                scale = 1.0, 
                colour = 1,
                time = (5 * 60000),
            }
        })
    elseif Config.Dispatch == "ps-dispatch" then
        exports["ps-dispatch"]:CustomAlert({
            message = "Attempted Network Access",
            code = "10-17",
            icon = "fas fa-network-wired",
            coords = coords,
            job = Config.DispatchJobs,
            alert = {
                sprite = 629, 
                scale = 1.0, 
                colour = 1,
            }
        })
    elseif Config.Dispatch == "rcore_dispatch" then
        local data = {
            code = '10-17',
            default_priority = 'medium',
            coords = coords,
            job = Config.DispatchJobs,
            text = 'Unauthorized network access at general store.',
            type = 'alerts',
            blip_time = 0,
            blip = {
                sprite = 629, 
                scale = 1.0, 
                colour = 1,
                radius = 0,
            }
        }
        TriggerServerEvent('rcore_dispatch:server:sendAlert', data)
    elseif Config.Dispatch == "mythic-mdt" then
        TriggerServerEvent("EmergencyAlerts:Server:DoPredefined", "storeNetwork", {
			icon = "network-wired",
			details = "Unauthorized network access at general store."
		})
    elseif Config.Dispatch == "custom" then
        -- fill this here
    end
end