fx_version 'cerulean'
game 'gta5'

author 'redsan1312'
description 'Komendy na givecar oraz savecar'
version '1.0'

client_scripts {
    '@es_extended/locale.lua',
    '@es_extended/imports.lua',
    'client/main.lua'  
}

lua54 'yes'

shared_scripts {
    '@es_extended/locale.lua',
    '@es_extended/imports.lua',
    'config.lua',
    'locales/*.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'oxmysql'
}
