fx_version 'cerulean'
game 'gta5'

author 'redsan1312'
description 'Komendy na givecar oraz savecar'
version '1.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'locales/*.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
