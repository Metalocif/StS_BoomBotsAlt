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