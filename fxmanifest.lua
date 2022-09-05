fx_version 	 'cerulean'
game 		 'gta5'
author 		 '𝙉𝙞𝙯𝙩𝙚𝙧𝙙𝙓987#9220'
lua54 		 'yes'
use_fxv2_oal 'yes'

ui_page 'html/index.html'

files {
	'html/*'
}

shared_script {
	'@es_extended/locale.lua',
	'@es_extended/imports.lua',
	'locales/*.lua',
	'Config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

