 
 
 
function Build( event )
    local caster = event.caster
    local ability = event.ability
    local ability_name = ability:GetAbilityName()
    local building_name = ability:GetAbilityKeyValues()['UnitName']
    local gold_cost = ability:GetGoldCost(1) 
    local hero = caster:IsRealHero() and caster or caster:GetOwner()
    local playerID = hero:GetPlayerID()

    hero:ModifyGold(gold_cost, false, 0)

    BuildingHelper:AddBuilding(event)

    event:OnPreConstruction(function(vPos)

        if not BuildingHelper:MeetsHeightCondition(vPos) then
            BuildingHelper:print("Failed placement of " .. building_name .." - Placement is below the min height required")
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_minimum_height_condition_exceeded", {})
            return false
        end

        if PlayerResource:GetGold(playerID) < gold_cost then
			print(playerID)
            BuildingHelper:print("Failed placement of " .. building_name .." - Not enough gold!")
			CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_not_enough_gold", {})
			return false
        end
		
    end)

    -- Position for a building was confirmed and valid
    event:OnBuildingPosChosen(function(vPos)
        -- Spend resources
        hero:ModifyGold(-gold_cost, false, 0)

        EmitSoundOnClient("DOTA_Item.ObserverWard.Activate", PlayerResource:GetPlayer(playerID))
    end)

    -- The construction failed and was never confirmed due to the gridnav being blocked in the attempted area
    event:OnConstructionFailed(function()
        local playerTable = BuildingHelper:GetPlayerTable(playerID)
        local building_name = playerTable.activeBuilding
        BuildingHelper:print("Failed placement of " .. building_name)
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "error_building_site_is_blocked", {})
	end)

    -- Cancelled due to ClearQueue
    event:OnConstructionCancelled(function(work)
        local building_name = work.name
        BuildingHelper:print("Cancelled construction of " .. building_name)

        if work.refund then
            hero:ModifyGold(gold_cost, false, 0)
			
        end
    end)
	
    event:OnConstructionStarted(function(unit)
        BuildingHelper:print("Started construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        -- Play construction sound

        -- If it's an item-ability and has charges, remove a charge or remove the item if no charges left
        if ability.GetCurrentCharges and not ability:IsPermanent() then
            local charges = ability:GetCurrentCharges()
            charges = charges-1
            if charges == 0 then
                ability:RemoveSelf()
            else
                ability:SetCurrentCharges(charges)
            end
        end

        unit.item_building_cancel = CreateItem("item_building_cancel", hero, hero)
        if unit.item_building_cancel then 
            unit:AddItem(unit.item_building_cancel)
            unit.gold_cost = gold_cost
        end

        FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
        caster:AddNewModifier(caster, nil, "modifier_phased", {duration=0.03})

        unit:RemoveModifierByName("modifier_invulnerable")
		unit:AddNewModifier(unit, nil, "modifier_stunned", {})
    end)

    -- A building finished construction
    event:OnConstructionCompleted(function(unit)
        BuildingHelper:print("Completed construction of " .. unit:GetUnitName() .. " " .. unit:GetEntityIndex())
        
        unit.state = "complete"
 
		unit:RemoveModifierByName("modifier_stunned")
    end)
end

function CancelBuilding( keys )
    local building = keys.unit
    local hero = building:GetOwner()
    local playerID = building:GetPlayerOwnerID()

    BuildingHelper:print("CancelBuilding "..building:GetUnitName().." "..building:GetEntityIndex())

    if building.gold_cost then
        hero:ModifyGold(building.gold_cost, false, 0)
    end

    local builder = building.builder_inside
    if builder then
        BuildingHelper:ShowBuilder(builder)
    end

    building:Kill(nil, hero)  
end

function UpgradeBegin(event)
    local caster = event.caster
    local ability = event.ability
end

function UpgradeBuilding( event )
    local ability = event.ability
    local building = ability:GetCaster()
    local NewBuildingName = ability:GetAbilityKeyValues()['UnitName']
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local gold_cost = ability:GetGoldCost(1)

	local health_pct = building:GetHealthPercent()/100
	BuildingHelper:RemoveBuilding(building, true)

    local newBuilding = BuildingHelper:UpgradeBuilding(building,NewBuildingName)
    newBuilding.state = "complete"	
	newBuilding:SetHealth(newBuilding:GetMaxHealth()*health_pct)
    newBuilding:AddItemByName("item_building_cancel") 

	if building.gold_cost then
		newBuilding.gold_cost = gold_cost + building.gold_cost
	end
 
    UTIL_Remove(building)
end

function CancelUpgradeBuilding( event )
    local building = event.caster
    local ability = event.ability
    local NewBuildingName = ability:GetAbilityKeyValues()['UnitName']
    local playerID = building:GetPlayerOwnerID()
    local hero = PlayerResource:GetSelectedHeroEntity(playerID)
    local gold_cost = ability:GetGoldCost(1)

    hero:ModifyGold(gold_cost, false, 0)
end


