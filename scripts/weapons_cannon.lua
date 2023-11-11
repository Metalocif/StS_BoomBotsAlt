------Cannon Bot------
Nico_cannonboom=Nico_cannonboom:new{
	Name="Massive Cannon Mark I",
	Class = "TechnoVek",
	Description="Fires a massive projectile, causing recoil dependent on the distance to target. Can also be used to perform a suicidal rocket jump.",
	Icon = "weapons/Nico_cannonboom.png",
	Damage = 2,
	PowerCost = 0,
	Upgrades = 2,
	UpgradeList = { "+1 Damage",  "+1 Damage"  },
	UpgradeCost = { 2 , 3 },
	LaunchSound = "/enemy/snowart_1/attack",
	ImpactSound = "/impact/generic/explosion",
	CustomTipImage = "",
	TipImage = {
		Unit = Point(3,3),
		Target = Point(3,2),
		Enemy1 = Point(1,1),
		Enemy2 = Point(3,1),
		Mountain1 = Point(1,0),
		Mountain2 = Point(3,0),
        CustomPawn="Nico_cannonboom_mech",
		CustomEnemy="Scorpion1",
	},
	}
Nico_cannonboom_A = Nico_cannonboom:new{
	UpgradeDescription = "Increases damage dealt by 1.",
	Damage = 3,
}

Nico_cannonboom_B = Nico_cannonboom:new{	
	UpgradeDescription = "Increases damage dealt by 1.",
	Damage = 3,
}

Nico_cannonboom_AB = Nico_cannonboom:new{
	Damage = 4,
}
function Nico_cannonboom:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		local foundBlocker = false
		for i = 1, 8 do
			if Board:IsBlocked(point + DIR_VECTORS[dir]*i, PATH_PROJECTILE) then
				if not foundBlocker then 
					ret:push_back(point + DIR_VECTORS[dir]*i) 
					foundBlocker = true 
				end
			else
				if Board:IsValid(point + DIR_VECTORS[dir]*i) then ret:push_back(point + DIR_VECTORS[dir]*i) else break end
			end
		end
	end
	ret:push_back(point)
	return ret
end

function Nico_cannonboom:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	
	if p1 == p2 then 				--we're selfdestructing
		return SelfDestruct(p1) 	
	end
	local direction = GetDirection(p2-p1)
	local target = GetProjectileEnd(p1, p1 + DIR_VECTORS[direction], PATH_PROJECTILE)
	local distance = p1:Manhattan(p2)
	if target ~= p2 then 		--we're rocket jumping
		ret:AddAnimation(p1, "ExploArt1")
		local move = PointList()
		move:push_back(p1)
		move:push_back(p2)
		ret:AddBounce(p1,5)
		ret:AddLeap(move, FULL_DELAY)
		ret:AddDamage(SpaceDamage(p2, DAMAGE_DEATH))
	else							--we're firing a projectile and experiencing recoil
		local damage = SpaceDamage(p2, self.Damage, direction)
		damage.sAnimation = "ExploArt3"
		damage.sScript = string.format("Detonate(%s)", damage.loc:GetString())
		ret:AddProjectile(p1, damage, "effects/shot_bigone", NO_DELAY)
		local chargeEnd = p1
		for i = 1, distance do
			if not Board:IsValid(chargeEnd - DIR_VECTORS[direction]) or Board:IsBlocked(chargeEnd - DIR_VECTORS[direction], PATH_PROJECTILE) then break end
			chargeEnd = chargeEnd - DIR_VECTORS[direction]
		end
		if p1 ~= chargeEnd then ret:AddCharge(Board:GetSimplePath(p1, chargeEnd), NO_DELAY) end
		if p1:Manhattan(chargeEnd) < distance and Board:IsValid(chargeEnd - DIR_VECTORS[direction]) then --we were stopped by something, therefore collision, damage
			ret:AddDamage(SpaceDamage(chargeEnd, 1))
			ret:AddDamage(SpaceDamage(chargeEnd - DIR_VECTORS[direction], math.max(distance - p1:Manhattan(chargeEnd), 1)))
			--if we should have travelled 5 tiles but went 2 tiles, something absorbed 3 recoils and therefore takes 3 damage
		end
		
	end
	return ret
end