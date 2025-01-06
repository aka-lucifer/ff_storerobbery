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
Config.NetworkAlertTimeout = 120 -- How often in seconds it limits the network alert so it can only be sent once and then have to wait this long before sending again (prevents spam)
Config.RequiredPolice = 2 -- How many police on duty to start heist

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
    },
    {
        item = "rolex",
        amount = { min = 1, max = 6},
    }
}

-- All the different store location data
Config.Locations = {
    {
        ped = vec4(2676.61, 3280.18, 54.24, 328.88),
        safe = vec4(2674.7, 3288.57, 54.24, 154.33),
        network = {
            coords = vec3(2672.87060546875, 3288.09326171875, 55.23943328857422),
            radius = 0.6
        }
    },
    {
        ped = vec4(-2966.25, 391.53, 15.04, 86.9),
        safe = vec4(-2959.03, 387.61, 13.04, 0.58),
        network = {
            coords = vec3(-2957.36474609375, 390.2129211425781, 14.49756336212158),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(1959.43, 3741.15, 32.34, 300.68),
        safe = vec4(1961.91, 3749.47, 31.34, 119.41),
        network = {
            coords = vec3(1960.0970458984376, 3750.116943359375, 32.38667297363281),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(1697.53, 4923.12, 42.06, 325.96),
        safe = vec4(1707.32, 4919.07, 41.06, 57.39),
        network = {
            coords = vec3(1707.291259765625, 4921.75634765625, 42.01290893554687),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(372.85, 327.87, 103.57, 247.13),
        safe = vec4(380.37, 332.08, 102.57, 77.41),
        network = {
            coords = vec3(379.6080322265625, 333.66180419921877, 103.54884338378906),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(1134.15, -983.28, 46.42, 277.94),
        safe = vec4(1126.24, -980.77, 44.42, 184.81),
        network = {
            coords = vec3(1125.1610107421876, -983.6082763671875, 45.8283805847168),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(1164.93, -323.53, 69.21, 103.01),
        safe = vec4(1160.77, -313.69, 68.21, 192.51),
        network = {
            coords = vec3(1158.995361328125, -315.3978271484375, 69.1527099609375),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(-706.09, -914.6, 19.22, 91.94),
        safe = vec4(-708.58, -904.25, 18.22, 181.12),
        network = {
            coords = vec3(-710.4667358398438, -905.4218139648438, 19.13999557495117),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(-1221.29, -908.03, 12.33, 34.85),
        safe = vec4(-1220.04, -916.32, 10.33, 302.49),
        network = {
            coords = vec3(-1216.9649658203126, -915.9669799804688, 11.73851585388183),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(-1486.7, -377.5, 40.16, 138.08),
        safe = vec4(-1479.06, -374.17, 38.16, 50.64),
        network = {
            coords = vec3(-1479.7227783203126, -371.64654541015627, 39.5917854309082),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(-47.17, -1758.37, 29.42, 50.71),
        safe = vec4(-42.26, -1749.3, 28.42, 138.63),
        network = {
            coords = vec3(-44.71, -1748.96, 29.2),
	        radius = 0.6,
        }
    },
    {
        ped = vec4(24.14, -1345.66, 28.5, 272.08),
        safe = vec4(30.96, -1339.91, 28.5, 89.05),
        network = {
            coords = vec3(29.52338027954101, -1338.5648193359376, 29.50686836242675),
            radius = 0.6
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