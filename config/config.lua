Config = {}

-- Debug Information
Config.Debug = false

-- Locales
Config.Language = 'en' -- Locale language

-- Framework Related
Config.UseCustomFramework = false -- Set to true if using custom framework
Config.Framework = 'Qbox' -- Supports Qbox, QB, ESX & Mythic
Config.FrameworkCore = 'LEAVE_EMPTY_UNLESS_CUSTOM' -- You need to put your frameworks core resource name here if using custom framework
Config.Target = "ox_target" -- Supports ox_target, qb-target & mythic-targeting

-- Interface Related Options
Config.Notifications = "ox_lib" -- Supports ox_lib, qb, esx, mythic, okok, sd-notify, wasabi_notify, gta or custom
Config.Progress = "ox_lib_bar" -- Support ox_lib_bar, ox_lib_circle or mythic

-- Police & Dispatch Related
Config.Dispatch = "ps-dispatch" -- Supports cd_dispatch, qs-dispatch, ps-dispatch, rcore_dispatch, mythic-mdt, custom
Config.DispatchJobs = { "police" } -- Only for Qbox, QB & ESX
Config.RequiredPolice = 0 -- How many police on duty to start heist

-- Cooldown
Config.GlobalCooldown = 900 -- In seconds currently at 15 minutes
Config.UseStoreCooldown = true -- Individual cooldown for different stores aswell as global
Config.StoreCooldown = 2700 -- In seconds currently at 45 minutes

-- Robbery Loot
Config.UseMoneyItem = true -- Whether or not to give them dirty money as an item (only setup for Qbox, QB & Mythic)
Config.TillValue = { min = 250, max = 800 }
Config.SafeItems = {
    {
        item = "goldbar",
        amount = { min = 1, max = 3 },
        chance = 60
    }
}

-- All the different store location data
Config.Locations = {
    {
        ped = vec4(-47.17, -1758.37, 29.42, 50.71),
        safe = vec4(-42.26, -1749.3, 28.42, 138.63),
        computer = {
            coords = vec3(-44.71, -1748.96, 29.2),
	        radius = 0.6,
        }
    }
}

-- List of peds used for the cashier
Config.Peds = {
    `mp_m_shopkeep_01`
}

Config.ResetAccess = {
    Jobs = {
        ['police'] = 0
    },
    Groups = { "admin", "god" }
}