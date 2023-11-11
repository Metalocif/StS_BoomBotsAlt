------Laser Bot------
Nico_laserboom=Nico_laserboom:new{
	Name="Smart Phaser Mark I",
	Class = "TechnoVek",
	Icon = "weapons/Nico_laserboom.png",
	Description="Fires phasing lasers at three tiles, reviving dead allies and shielding buildings.",
	Damage = 1,
	PowerCost = 0,
	ArtilleryHeight = 0,
	ActAgain = false,
	ShieldFriendy = false,
	TwoClick = true,
	Upgrades = 2,
	UpgradeList = { "Shield Friendly",  "Overdrive"  },
	UpgradeCost = { 2 , 3 },
	LaunchSound = "/weapons/burst_beam",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(3,3),
		Building = Point(3,2),
		Target = Point(3,1),
		Enemy1 = Point(2,1),
		Enemy2 = Point(3,1),
		Mountain1 = Point(1,0),
		Mountain2 = Point(3,0),
		Second_Click = Point(3,2),
		Second_Origin = Point(3,3),
		Second_Target = Point(3,2),
        CustomPawn="Nico_laserboom_mech",
		CustomEnemy="Scorpion1",
	},
	}
Nico_laserboom_A = Nico_laserboom:new{
	UpgradeDescription = "Lasers now shield non-mech friendly units.",
	ShieldFriendly = true,
}

Nico_laserboom_B = Nico_laserboom:new{	
	UpgradeDescription = "Lasers now let allies act again.",
	ActAgain = true,
}

Nico_laserboom_AB = Nico_laserboom:new{
	ShieldFriendly = true,
	ActAgain = true,
}
function Nico_laserboom:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			if Board:IsValid(point + DIR_VECTORS[dir]*i) then ret:push_back(point + DIR_VECTORS[dir]*i) end
		end
	end
	ret:push_back(point)
	return ret
end

function Nico_laserboom:IsTwoClickException(p1,p2)
	return p1 == p2 --we don't do two-click if self-targeting because it's the suicide move
end

function Nico_laserboom:GetSecondTargetArea(p1, p2)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		if Board:IsValid(p2 + DIR_VECTORS[dir]) then ret:push_back(p2 + DIR_VECTORS[dir]) end	--gets adjacent tiles to p2
		if Board:IsValid(p2 + DIR_VECTORS[dir] + DIR_VECTORS[(dir + 1) % 4]) then ret:push_back(p2 + DIR_VECTORS[dir] + DIR_VECTORS[(dir + 1) % 4]) end	--gets diagonally adjacent
	end
	return ret
end

function Nico_laserboom:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	if p1 == p2 then return SelfDestruct(p1) else ret:AddDamage(SpaceDamage(p2, 0)) return ret end
end

function Nico_laserboom:GetFinalEffect(p1,p2,p3)
	ret = SkillEffect()
	local offset = p3 - p2
	for i = -1, 1 do
		local curr = p2 + offset * i
		local target = Board:GetPawn(curr)
		local damage = SpaceDamage(curr)
		ret:AddSound(self.LaunchSound)
		damage.sSound = self.ImpactSound
		damage.fDelay = 0.5
		if target and target:IsMech() and target:IsDead() then
			damage.iDamage = -1
			damage.iShield = 0
			if self.ActAgain then ret:AddScript(string.format("Board:GetPawn(%s):SetActive(true)",target:GetId())) end
			--doesn't work on the user... this is probably for the best balance-wise
			damage.sScript = string.format("Detonate(%s)", curr:GetString())
			ret:AddArtillery(p1, damage, "effects/smartlaser_heal.png", NO_DELAY)
		elseif Board:IsBuilding(curr) or (self.ShieldFriendly and target and target:IsPlayer() and not target:IsMech()) then
			damage.iDamage = 0
			damage.iShield = 1
			damage.sScript = ""
			ret:AddArtillery(p1, damage, "effects/smartlaser_shield.png", NO_DELAY)
		else
			damage.iDamage = self.Damage
			damage.iShield = 0
			if self.ActAgain and target and target:IsMech() then ret:AddScript(string.format("Board:GetPawn(%s):SetActive(true)",target:GetId())) end
			damage.sScript = string.format("Detonate(%s)", curr:GetString())
			ret:AddArtillery(p1, damage, "effects/smartlaser_damage.png", NO_DELAY)
		end
	end
	return ret
end