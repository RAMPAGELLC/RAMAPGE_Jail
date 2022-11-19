--[[ FX Information ]] --
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
games {'rdr3', 'gta5'}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

name 'RAMPAGE_Jail'
author 'RAMPAGE Interactive'
lua54 'yes'

dependencies 'ox_lib'
files 'database.json'
client_scripts 'client.lua'
server_scripts {'config.lua', 'server.lua'}
shared_script '@ox_lib/init.lua'
