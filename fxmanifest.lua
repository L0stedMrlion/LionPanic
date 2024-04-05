fx_version 'cerulean'
games  { 'gta5' }
name "LionPanic"
author 'Mrlion'
description "Mrlion's panic for LEO"
version '1.4'
lua54 'yes'

shared_scripts {
    'config.lua',
    '@es_extended/imports.lua',
    "@ox_lib/init.lua",
}

client_scripts {
    'client/panic.lua',
    'client/location.lua',
}

server_scripts {
    'server/panic.lua',
    "server/location.lua",
    'webhook.lua',
}

ui_page "html/index.html"

files {
	"html/index.html",
	"html/sounds/localpanic.ogg",
    "html/sounds/externalpanic1.ogg",
}
