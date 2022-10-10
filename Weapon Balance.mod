return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`Weapon Balance` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("Weapon Balance", {
			mod_script       = "scripts/mods/Weapon Balance/Weapon Balance",
			mod_data         = "scripts/mods/Weapon Balance/Weapon Balance_data",
			mod_localization = "scripts/mods/Weapon Balance/Weapon Balance_localization",
		})
	end,
	packages = {
		"resource_packages/Weapon Balance/Weapon Balance",
	},
}
