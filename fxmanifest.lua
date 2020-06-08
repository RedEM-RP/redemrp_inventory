game 'rdr3'

fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
ui_page 'html/ui.html'

client_scripts {
  'client/main.lua',
  'config.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'config.lua',
  'server/main.lua'
}

files {
    'html/ui.html',
    'html/css/contextMenu.min.css',
    'html/css/jquery.dialog.min.css',
    'html/css/ui.min.css',
    'html/js/config.js',
    'html/js/contextMenu.min.js',
    'html/js/jquery.dialog.min.js',
    'html/fonts/crock.ttf',
	'html/img/bgPanel.png',
	'html/img/bg.png',
    -- ICONS
	'html/img/items/*.png'
}
