-- Generated from template
require( "libraries/timers" )
require( "libraries/notifications" )
require("libraries/buildinghelper")
require( "game_mode" )

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	PrecacheResource("particle_folder", "particles/buildinghelper", context)
end

-- Create the game mode when we activate
function Activate()
	BuildMode:InitGameMode()
end
