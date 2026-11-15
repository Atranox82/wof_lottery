fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'atranox_tv'
description 'World of Freedom Lottery System - Daily Draw at 17:00'
version '1.0.0'

lua54 'yes'

shared_script 'config.lua'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'vorp_core',
    'vorp_inventory',
    'oxmysql'
}

-- Escrow: only config stays open / editable
escrow_ignore {
    'config.lua',
    'sql/*.sql',
    'README.md'
}