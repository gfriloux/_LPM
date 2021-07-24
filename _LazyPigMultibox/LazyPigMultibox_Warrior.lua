function LazyPigMultibox_Warrior(dps, dps_pet, heal, rez, buff)
	if dps then
		LazyPigMultibox_Warrior_DPS();
	end
end

function isTwoHanded()
	local slot = GetInventorySlotInfo("MainHandSlot")
	local link = GetInventoryItemLink("player", slot)
	
	if not link then
		Zorlen_debug("You do not have a weapon equipped in the main hand.", 2)
		return false
	end

	local itemType = Zorlen_GetItemSubType(link)
	if    itemType == LOCALIZATION_ZORLEN["Two-Handed Swords"]
	   or itemType == LOCALIZATION_ZORLEN["Two-Handed Axes"]
	   or itemType == LOCALIZATION_ZORLEN["Two-Handed Maces"]
	   or itemType == LOCALIZATION_ZORLEN["Polearms"]
	   or itemType == LOCALIZATION_ZORLEN["Staves"]
	then
		return true
	end
	
	return false
end

function castSlam(test)
	local z = {}
	z.Test = test
	z.SpellName = LOCALIZATION_KURI_DPS.Slam
	if not Zorlen_Button[z.SpellName] then
		if not Zorlen_isMainHandEquipped() then
			return false
		end
		z.ManaNeeded = 15
	end
	return Zorlen_CastCommonRegisteredSpell(z)
end

function LazyPigMultibox_Warrior_DPS()
	-- We do not touch CC targets
	if Zorlen_isNoDamageCC("target") then
		backOff()
		return true
	end
	
	-- If enemy is at correct distance, lets charge it
	if Zorlen_GiveMaxTargetRange(8, 25) then
		swapChargeAndIntercept()
	end

	if not isBerserkerStance() then
		castBerserkerStance()
	end

	castAttack()

	-- Use main skill first
	castBloodthirst()

	-- Use execute if target's HP below 20%
	if         Zorlen_TargetIsDieingEnemy()
	   and not isDefensiveStance() then
		castExecute()
	end

	if isTwoHanded() then
		-- If next swing is in more than 1.5s, using Slam IS a DPS boost.
		if st_timer > 1.5 then
			castSlam()
		end
	end

	-- Dump extra rage
	if UnitMana("player") >= 45 then
		if not isDefensiveStance() then
			castWhirlwind()
		end
		castHeroicStrike()
	end
end
