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