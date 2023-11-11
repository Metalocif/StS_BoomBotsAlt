local description = "Refitted Boom Bots, packed with extra explosives. Requires the Sentient Weapons mod by Generic, with the Boom Bots squad unlocked."
local mod = {
	id = "Meta_BoomBotsAlt",
	name = "Boom Bots - Alternative",
	version = "1.0",
	requirements = {},
	dependencies = {
		"Nico_Sent_weap",
	},
	enabled=false,
	modApiVersion = "2.9.2",
	icon = "img/mod_icon.png",
	description = description,
}

function mod:init()
	local options = mod_loader.currentModContent[mod.id].options
	require(self.scriptPath .."pawns")
	require(self.scriptPath .."weapons_otherstuff")
	if options.MetaBBAlt_ReplaceArtillery and options.MetaBBAlt_ReplaceArtillery.enabled then require(self.scriptPath .."weapons_Artillery") end
	if options.MetaBBAlt_ReplaceCannon and options.MetaBBAlt_ReplaceCannon.enabled then require(self.scriptPath .."weapons_Cannon") end
	if options.MetaBBAlt_ReplaceLaser and options.MetaBBAlt_ReplaceLaser.enabled then require(self.scriptPath .."weapons_Laser") end
end

function mod:metadata()
	modApi:addGenerationOption(
		"MetaBBAlt_ReplaceArtillery",
		"Use the alternative artillery weapon",
		"Requires a timeline restart.",
		{ enabled = true }
	)
	modApi:addGenerationOption(
		"MetaBBAlt_ReplaceCannon",
		"Use the alternative cannon weapon",
		"Requires a timeline restart.",
		{ enabled = true }
	)
	modApi:addGenerationOption(
		"MetaBBAlt_ReplaceLaser",
		"Use the alternative laser weapon",
		"Requires a timeline restart.",
		{ enabled = true }
	)
end

function mod:load( options, version)
	mod.icon = self.resourcePath .."img/mod_icon.png"
end

return mod
