fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
client_scripts {
	'client/dataview.lua',
	'config.lua',
	'client/main.lua',
}

server_scripts {
	'config.lua',
	'@oxmysql/lib/MySQL.lua',
	'server/items.lua',
	'server/main.lua',
}

files{
	'html/css/*',
	'html/items/*',
	'html/js/*',
	'html/*',
}

client_exports {
	'GetItemsList',
}

server_exports {
	'GetStashWeight',
	'GetItemsList'
}

ui_page "html/inventory.html"