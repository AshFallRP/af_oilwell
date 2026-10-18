fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
games { 'gta5' }

author 'AshFallRP, Swkeep'
description 'Desert oil extraction, petrochemical refining, and logistics economy'

shared_script {
    '@ox_lib/init.lua',
    'config.lua',
    'shared/shared_main.lua'
}

client_scripts {
    'client/client.lua',
    'client/client_lib/client_lib_entry.lua',
    'client/client_lib/menu/CDU_menu.lua',
    'client/client_lib/menu/edit_menu.lua',
    'client/client_lib/menu/pump_menu.lua',
    'client/client_lib/menu/storage_menu.lua',
    'client/client_lib/menu/blender_menu.lua',
    'client/client_lib/menu/transport_menu.lua',
    'client/target/target.lua',
    'client/target/qb_target.lua',
}

server_script {
    '@oxmysql/lib/MySQL.lua',
    'server/server_lib/server_lib_entry.lua',
    'server/server_lib/Server_GlobalScirptData.lua',
    'server/server_lib/refund.lua',
    'server/server_main.lua',
}

dependencies {
    'oxmysql',
    'ox_lib',
    'af_core',
    'af_target',
    'af_inventory',
    'af_fuel'
}

lua54 'yes'
