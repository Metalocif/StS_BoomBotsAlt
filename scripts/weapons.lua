local mod = modApi:getCurrentMod()
local path = mod_loader.mods[modApi.currentMod].resourcePath
local customAnim = require(mod_loader.mods[modApi.currentMod].scriptPath .."libs/customAnim")
local artilleryArc = require(mod_loader.mods[modApi.currentMod].scriptPath .."libs/artilleryArc")
local weaponArmed = require(mod_loader.mods[modApi.currentMod].scriptPath .."libs/weaponArmed")

modApi:appendAsset("img/effects/shotup_stickybomb.png", path .."img/effects/shotup_stickybomb.png")
modApi:appendAsset("img/effects/stickybomb2.png", path .."img/effects/stickybomb2.png")
modApi:appendAsset("img/effects/smartlaser_damage.png", path .."img/effects/smartlaser_damage.png")
modApi:appendAsset("img/effects/smartlaser_shield.png", path .."img/effects/smartlaser_shield.png")
modApi:appendAsset("img/effects/smartlaser_heal.png", path .."img/effects/smartlaser_heal.png")

ANIMS.stickyBombAnim = Animation:new{ 	
	Image = "effects/stickybomb2.png",
	PosX = 0, PosY = 10,
	NumFrames = 2,
	Frames = {0, 1},
	Time = 1,
	Loop = true
}
ANIMS.stickyBombAnim2 = Animation:new{ 	
	Image = "effects/stickybomb2.png",
	PosX = 0, PosY = 10,
	NumFrames = 2,
	Frames = {0, 1},
	Time = 0.5,
	Loop = true
}

------Artillery Bot------
Nico_artilleryboom=Nico_artilleryboom:new{
	Name="Sticky Bombs Mark I",
	Description="Launch sticky bombs at 3 tiles, pushing targets hit. Sticky bombs explode when dealt damage by other Boom Bot weapons.",
	Damage = 0,
	PowerCost = 0,
	TwoClick = true,
	Anim = "stickyBombAnim",
	Upgrades = 2,
	UpgradeList = { "+1 Shot",  "+1 Damage"  },
	UpgradeCost = { 2 , 3 },
	MissileCount = 3,
	LaunchSound = "/enemy/snowart_1/attack",
	ImpactSound = "/impact/generic/explosion",
	TipImage = {
		Unit = Point(3,3),
		Target = Point(3,2),
		Enemy1 = Point(1,1),
		Enemy2 = Point(3,1),
		Mountain1 = Point(1,0),
		Mountain2 = Point(3,0),
		Second_Click = Point(3,1),
		Second_Origin = Point(3,3),
		Second_Target = Point(3,1),
        CustomPawn="Nico_artilleryboom_mech",
		CustomEnemy="Scorpion1",
	},
	}
	
Nico_artilleryboom_A = Nico_artilleryboom:new{
	UpgradeDescription = "Fires an extra sticky bomb, affecting 4 tiles instead of 3.",
	Description="Launch sticky bombs at 4 tiles, pushing targets hit. Sticky bombs explode when dealt damage by other Boom Bot weapons.",
	MissileCount = 4,
}

Nico_artilleryboom_B = Nico_artilleryboom:new{	
	UpgradeDescription = "Increases sticky bomb damage by 1.",
	Anim = "stickyBombAnim2",
}

Nico_artilleryboom_AB = Nico_artilleryboom:new{
	Anim = "stickyBombAnim2",
	MissileCount = 4,
}

function Nico_artilleryboom:GetTargetArea(point)
	local ret = PointList()
	for dir = DIR_START, DIR_END do
		for i = 1, 8 do
			if Board:IsValid(point + DIR_VECTORS[dir]*i) then
				ret:push_back(point + DIR_VECTORS[dir]*i)
			end
		end
	end
	ret:push_back(point)
	return ret
end

function Nico_artilleryboom:IsTwoClickException(p1,p2)
	return p1 == p2 --we don't do two-click if self-targeting because it's the suicide move
end

function Nico_artilleryboom:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local dir = GetDirection(p2 - p1)
	for i = DIR_START, DIR_END do
		ret:push_back(p2 + DIR_VECTORS[i])
	end
	return ret
end

function Nico_artilleryboom:GetSkillEffect(p1,p2)
	ret = SkillEffect()
	if p1 == p2 then return SelfDestruct(p1) else ret:AddDamage(SpaceDamage(p2, 0)) return ret end
end

function Nico_artilleryboom:GetFinalEffect(p1,p2,p3)
	local ret = SkillEffect()
	local direction = GetDirection(p2-p1)
	local distance = p3:Manhattan(p2)
	local direction2 = GetDirection(p3-p2)
	for i = self.MissileCount - 1, 0, -1 do
		local curr = p2 + DIR_VECTORS[direction2] * i
		-- ret:AddDamage(SpaceDamage(curr, self.Damage, direction2))
		if Board:IsValid(curr) then ret:AddArtillery(p1, SpaceDamage(curr, self.Damage, direction2), "effects/shotup_stickybomb.png", FULL_DELAY) end
		if Board:GetPawn(curr) then
			ret:AddScript(string.format("CustomAnim:add(%s, %q)", Board:GetPawn(curr):GetId(), self.Anim))
		else
			--ret:AddScript(string.format("Board:SetItem(%s, %q)", curr:GetString(), "Meta_StickyBomb"))
		end
		ret:AddDelay(0.2)
	end
	return ret
end


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

function Detonate(point)
	ret = SkillEffect()
	if CustomAnim:get(Board:GetPawn(point):GetId(), "stickyBombAnim") then
		local damage = SpaceDamage(point, 1)
		damage.sAnimation = "ExploArt1"
		damage.sScript = string.format("CustomAnim:rem(%s, %q)", Board:GetPawn(point):GetId(), "stickyBombAnim")
		damage.fDelay = 0.3
		Board:DamageSpace(damage)
		for i = DIR_START, DIR_END do
			local curr = point + DIR_VECTORS[i]
			local damage = SpaceDamage(curr, 1)
			damage.sAnimation = "exploout1_"..i
			if Board:GetPawn(curr) and (CustomAnim:get(Board:GetPawn(curr):GetId(), "stickyBombAnim2") or CustomAnim:get(Board:GetPawn(curr):GetId(), "stickyBombAnim")) then
				damage.sScript = string.format("Detonate(%s)", curr:GetString())
			end
			Board:DamageSpace(damage)
		end
	elseif CustomAnim:get(Board:GetPawn(point):GetId(), "stickyBombAnim2") then
		local damage = SpaceDamage(point, 2)
		damage.sAnimation = "ExploArt2"
		damage.sScript = string.format("CustomAnim:rem(%s, %q)", Board:GetPawn(point):GetId(), "stickyBombAnim2")
		damage.fDelay = 0.3
		Board:DamageSpace(damage)
		for i = DIR_START, DIR_END do
			local curr = point + DIR_VECTORS[i]
			local damage = SpaceDamage(curr, 2)
			damage.sAnimation = "exploout2_"..i
			if Board:GetPawn(curr) and (CustomAnim:get(Board:GetPawn(curr):GetId(), "stickyBombAnim2") or CustomAnim:get(Board:GetPawn(curr):GetId(), "stickyBombAnim")) then
				damage.sScript = string.format("Detonate(%s)", curr:GetString())
			end
			Board:DamageSpace(damage)
		end
	end
	return ret
end

function SelfDestruct(point)
	ret = SkillEffect()
	ret:AddScript(string.format("Detonate(%s)", point:GetString()))
	local selfDamage = SpaceDamage(point, DAMAGE_DEATH)
	ret:AddDamage(selfDamage)
	return ret
end