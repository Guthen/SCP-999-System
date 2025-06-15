--[[
    Fonctionnalités :

		- Pouvoir calmer 096.
		- Entité bol de bonbon, le permettant de grossir
		- Swep bonbon pour le nourrir et le faire grossir
		- Entité bol d'eau pour le faire rétrécir
		- Swep bouteille d'eau pour le faire rétrécir

		- Ajouter une fonctionnalité Horreur où 999 peut tuer avec une barre de progression, lorsqu'il atteint une taille assez grosse
			- Sons horrifiques scp 999
			- Trainée de sang ?
			- Changer la  couleur Orange de SCP 999 vers du gris/noir maybe ?
		- Ajouter des sons pour 999"

]]--

local MODULE = {
    name = "SCP-999",
    author = "RevanAngel",
    version = "0.1.0",
    description = "Become a large gelatinous mass of orange slime",
    icon = "icon16/user.png",
	version_url = "https://raw.githubusercontent.com/Revan-Angel/SCP-999-System/refs/heads/main/lua/guthscp/modules/revscp999/main.lua",
    dependencies = {
		base = "2.4.0",
		guthscpkeycard = "2.1.6",
	},
    requires = {
		["server.lua"] = guthscp.REALMS.SERVER,
		["shared.lua"] = guthscp.REALMS.SHARED,
		["client.lua"] = guthscp.REALMS.CLIENT,
	},
}

MODULE.menu = {
	config = {
		form = {
			"General",
			{
				{
					type = "Number",
					name = "Keycard Level",
					id = "keycard_level",
					desc = [[Compatibility with keycard system. Set a keycard level to SCP-999's swep]],
					default = 1,
					min = 0,
					max = function( self, numwang )
						if self:is_disabled() then return 0 end

						return guthscp.modules.guthscpkeycard.max_keycard_level
					end,
					is_disabled = function( self, numwang )
						return guthscp.modules.guthscpkeycard == nil
					end,
				},
				{
					type = "Bool",
					name = "Disable Jump",
					id = "disable_jump",
					desc = "Should SCP-999 be able to jump?",
					default = true,
				},
				{
					type = "Bool",
					name = "Immortal",
					id = "scp999_immortal",
					desc = "If checked, SCP-999 can't take damage",
					default = true,
				},
				{
					type = "Bool",
					name = "Heal Players",
					id = "scp999_heal",
					desc = "If checked, SCP-999 can Heal player",
					default = true,
				},
				{
					type = "Number",
					name = "Heal Delay",
					id = "heal_time",
					desc = "Healing time by SCP-999 (in seconds)",
					default = 2,
					min = 0.1,
				},
				{
					type = "Number",
					name = "Heal Number",
					id = "heal_number",
					desc = "How much scp 999 can heal (in hp)",
					default = 3,
					min = 1,
				},
				{
					type = "Bool",
					name = "Update Hull and ViewOffset",
					id = "enable_hull_view_update",
					desc = "If checked, adjusts the SCP's collision and view height based on size",
					default = false,
				},
				{
					type = "Bool",
					name = "Ignores SCPs",
					id = "ignore_scps",
					desc = "If checked, SCP-999 won't be trigger by others SCP's Teams",
					default = true,
				},
				{
					type = "Teams",
					name = "Ignore Teams",
					id = "ignore_teams",
					desc = "All teams that can't trigger SCP-999 (And maybe all team that scp 999 can't kill ?).",
					default = {},
				},
			},
			"Horror Mod [Next Update]",
			{
				{
					type = "Bool",
					name = "Horror Mod",
					id = "scp999_horror",
					desc = "If checked, SCP-999 can eat people when he's big",
					default = false,
				},
				{
					type = "Bool",
					name = "Progress Bar",
					id = "progressbar",
					desc = "Should progress bar for SCP-999 be enabled when he want to kill someone?",
					default = false,
				},
				{
					type = "Number",
					name = "Progress speed",
					id = "progressbar_speed",
					desc = "How fast should the operation be ?",
					default = 2,
				},
			},
			"Sounds [Next Update]",
			{
				{
					type = "String[]",
					name = "Random Sounds",
					id = "random_sound",
					desc = "Random-sound played by 999",
					default = {
						"revscp/999/scp999_1.wav",
						"revscp/999/scp999_2.wav",
						"revscp/999/scp999_3.wav",
						"revscp/999/scp999_4.wav",
						"revscp/999/scp999_5.wav",
						"revscp/999/scp999_6.wav",
						"revscp/999/scp999_7.wav",
					},
				},
			},
			"Translations",
			{
				type = "String",
				name = "Instructions", 
				id = "translation_1", 
				desc = "Text display with the weapon as a Instructions", 
				default = "LMB - Eat? ; RMB - Heal people",
			},
			{
				type = "String",
				name = "Food",
				id = "translation_2", 
				desc = "Text display when 999 takes food", 
				default = "You eat candy",
			},
			{
				type = "String",
				name = "Water",
				id = "translation_3", 
				desc = "Text display when 999 takes waters", 
				default = "You drink water",
			},
			{
				type = "String",
				name = "Heal People",
				id = "translation_4", 
				desc = "Text display when 999 heal someone", 
				default = "You currently heal someone",
			},
			{
				type = "String",
				name = "Heal People",
				id = "translation_5", 
				desc = "Text display when 999 can't heal", 
				default = "You can't heal",
			},
			{
				type = "String",
				name = "Start Eating",
				id = "translation_progress_start", 
				desc = "Text shown to the player when 999 starting to eat another player",
				default = "Your attack on player start !",
			},
			{
				type = "String",
				name = "Eating Complete",
				id = "translation_progress_finish", 
				desc = "Text shown to the player when 999 completed to eat another player",
				default = "Your attack is sucessful !",
			},
			{
				type = "String",
				name = "Stop Eating",
				id = "translation_progress_stop", 
				desc = "Text shown to the player when scp 999 stopped to eat another player",
				default = "Your attack has been canceled !",
			},
			"Food and Water",
			{
				type = "String",
				name = "Model FOOD",
				id = "food_model", 
				desc = "The model of the entities",
				default = "models/props_junk/watermelon01.mdl",
			},
			{
				type = "Number",
				name = "Cooldown to use food",
				id = "food_cooldown",
				desc = "Cooldown to use entities FOOD",
				default = 5,
			},
			{
				type = "String",
				name = "Model WATER",
				id = "water_model", 
				desc = "The model of the entities",
				default = "models/props_junk/MetalBucket01a.mdl",
			},
			{
				type = "Number",
				name = "Cooldown to use water",
				id = "water_cooldown",
				desc = "Cooldown to use entities WATER",
				default = 5,
			},
			{
				type = "Number",
				name = "Grow/retract Amount", 
				id = "growamount", 
				desc = "When use the food/water, How much does he grow/retract (Default : 0.1 for 10%)", 
				default = 0.1,
			},
			"DLC SCP-096 (Guthen Only) [Next update]",
			{
				type = "Bool",
				name = "Unrage SCP-096",
				id = "unrage_scp096",
				desc = "Should SCP096 be able to calm 096 when it stays near him?",
				default = false,
			},
			{
				type = "Number",
				name = "Duration Stay",
				id = "duration_stay",
				desc = "How long does SCP 999 need to be near 096 to calm it down",
				default = 3,
				min = 1,
			},
		},
	},
	details = {
		{
			text = "CC-BY-SA",
			icon = "icon16/page_white_key.png",
		},
		"Wiki",
		{
			text = "Read Me",
			icon = "icon16/information.png",
			url = "",
		},
		"Social",
		{
			text = "Github",
			icon = "guthscp/icons/github.png",
			url = "",
		},
		{
			text = "Steam",
			icon = "guthscp/icons/steam.png",
			url = "https://steamcommunity.com/id/RevanAngel/"
		},
		{
			text = "Discord",
			icon = "guthscp/icons/discord.png",
			url = "https://discord.gg/Jpr7gshRXR",	
		},
	},
}

function MODULE:init()
    MODULE:info("The 999 system has been loaded !")
end

guthscp.module.hot_reload("revscp999")
return MODULE
