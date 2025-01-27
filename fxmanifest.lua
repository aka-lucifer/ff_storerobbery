fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'ff_shoprobbery'
author 'FiveForge Studios'
version '1.0.1'
description 'A convenience store robbery system'

files {
    'locales/*.json',
    "client/peds.lua",
    "client/tills.lua",
    "client/safe.lua",
    "client/network.lua"
}

shared_scripts {
    '@ox_lib/init.lua',
	"config/config.lua",
    "shared/*.lua",
    "bridge/framework.lua"
}

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- Remove this if not using Qbox
    "bridge/client/*.lua",
    "client/main.lua"
}

server_scripts {
    "config/sv-config.lua",
    "bridge/server/*.lua",
    "server/main.lua"
}

dependencies {
    '/server:7290',
    '/onesync',
    "ox_lib"
}

use_experimental_fxv2_oal 'yes'