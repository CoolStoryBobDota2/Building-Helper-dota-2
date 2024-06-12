if BuildMode == nil then
	BuildMode = class({})
end

function BuildMode:InitGameMode()

	GameRules:SetStartingGold(100000)
	GameRules:SetHeroSelectionTime(0)
	GameRules:SetPreGameTime(10)
	GameRules:SetGoldTickTime(0.1)
	GameRules:SetStrategyTime( 0.0 )
	GameRules:SetShowcaseTime( 0.0 )	
	GameRules:GetGameModeEntity():SetCustomGameForceHero("npc_dota_hero_antimage")
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )

   ListenToGameEvent('npc_spawned', Dynamic_Wrap(self , 'OnNpcSpawned'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnStateChange'), self)
end

function BuildMode:OnStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:StartGame()
	end 
end

function BuildMode:OnNpcSpawned(data)
 	local npc = EntIndexToHScript(data.entindex)

    if npc:IsRealHero() and npc.FirstSpawned == nil then
       npc.FirstSpawned = true

        for i=0, 5 do 
        	local ability = npc:GetAbilityByIndex(i)

        	ability:SetLevel(1)
        end
	end
end

function BuildMode:StartGame()
	print("Игра началась!")
end
