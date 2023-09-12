local mod = get_mod("Weapon Balance")

-- Melee Weapon Changes
-- boost_curve_coefficient_headshot = headshot damage multiplier changes
-- power_distribution = overall damage changes
-- armor_modifier = damage changes against certain armor types. Infantry, armour, monster, berzerker, player, super armour in that order
-- cleave_distribution = cleave changes
-- anim_time_scale = changing attack speeds
-- range_mod = weapon attack range increases

--1h hammer
Weapons.one_handed_hammer_template_1.dodge_count = 4
Weapons.one_handed_hammer_template_2.dodge_count = 4
Weapons.one_handed_hammer_priest_template.dodge_count = 4

--light 1, 2, bop (Also affects hammer and shield light 2, mace and sword light 3,4)
DamageProfileTemplates.light_blunt_tank.cleave_distribution.attack = 0.23
DamageProfileTemplates.light_blunt_tank_diag.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_blunt_tank_diag.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_blunt_tank_diag.targets[1].power_distribution.attack = 0.225
DamageProfileTemplates.light_blunt_tank_diag.targets[2].power_distribution.attack = 0.15 --0.075
DamageProfileTemplates.light_blunt_tank_diag.armor_modifier.attack = { 1, 0.5, 1, 1, 0.75, 0.25 } --{ 1, 0, 1, 1, 0 }
DamageProfileTemplates.light_blunt_tank_diag.critical_strike.attack_armor_power_modifer = {	1, 0.6, 1, 1, 0.75 } --{ 1, 0.5, 1, 1, 0.25 }

--light 3, 4  (Also affects hammer and shield bop and light 3, hammer and tome lights, dual hammers bop 2, (flaming) flail light 3,4 and sienna mace light 1,2)
--DamageProfileTemplates changes also affect 1h axe lights
DamageProfileTemplates.light_blunt_smiter.default_target.boost_curve_coefficient_headshot = 2 --1.5
DamageProfileTemplates.light_blunt_smiter.armor_modifier.attack = { 1.25, 0.75, 3, 1, 1.25, 0.6 } --{ 1.25, 0.65, 2.5, 1, 0.75, 0.6 }
DamageProfileTemplates.light_blunt_smiter.critical_strike.attack_armor_power_modifer = { 1.25, 0.85, 2.75, 1, 1 } --{ 1.25, 0.75, 2.75, 1, 1 }
Weapons.one_handed_hammer_template_1.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_template_2.actions.action_one.light_attack_down.anim_time_scale = 1.5 --1.35
Weapons.one_handed_hammer_priest_template.actions.action_one.light_attack_04.anim_time_scale = 1.5 --1.35

--Heavies
DamageProfileTemplates.medium_blunt_smiter_1h.armor_modifier.attack = { 1, 0.8, 2.5, 0.75, 1 } -- { 1, 0.8, 1.75, 0.75, 0.8 }
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --0
Weapons.one_handed_hammer_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_01.range_mod = 1.2 --0
Weapons.one_handed_hammer_priest_template.actions.action_one.heavy_attack_02.range_mod = 1.2 --0

NewDamageProfileTemplates.gs_1h_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			2.5,
			1,
			0.75,
			1
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		boost_curve_coefficient_headshot = 1.5,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.45,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true
}

--1h sword
Weapons.one_handed_swords_template_1.dodge_count = 4
--light 1,2
DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].boost_curve_type = "ninja_curve"
DamageProfileTemplates.light_slashing_linesman_finesse.targets[1].power_distribution.attack = 0.2
DamageProfileTemplates.light_slashing_linesman_finesse.targets[2].power_distribution.attack = 0.15
DamageProfileTemplates.light_slashing_linesman_finesse.default_target.power_distribution.attack = 0.125
--light 3
DamageProfileTemplates.light_slashing_smiter_finesse.shield_break = true
Weapons.one_handed_swords_template_1.actions.action_one.light_attack_last.range_mod = 1.4 --1.2

--Heavies
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].armor_modifier.attack = {	1, 0.65, 2, 1, 0.75 }  --{ 1, 0.5, 1, 1, 0.75 }
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].boost_curve_coefficient_headshot = 1.5
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[1].power_distribution.attack = 0.35 --0.3
DamageProfileTemplates.medium_slashing_tank_1h_finesse.targets[2].power_distribution.attack = 0.175 --0.1
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_left.range_mod = 1.4 --1.25
Weapons.one_handed_swords_template_1.actions.action_one.heavy_attack_right.range_mod = 1.4 --1.25
DamageProfileTemplates.medium_slashing_tank_1h_finesse.cleave_distribution = "cleave_distribution_tank_L"
DamageProfileTemplates.medium_slashing_tank_1h_finesse.critical_strike = "critical_strike_stab_smiter_H"

--Executioner
--Lights
Weapons.two_handed_swords_executioner_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.1 --1
Weapons.two_handed_swords_executioner_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.1 --1
Weapons.two_handed_swords_executioner_template_1.actions.action_one.light_attack_left_diagonal.anim_time_scale = 1.1 --1
Weapons.two_handed_swords_executioner_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.2 --1
DamageProfileTemplates.medium_slashing_linesman_executioner.targets[2].boost_curve_coefficient_headshot = 4
DamageProfileTemplates.medium_slashing_linesman_executioner.targets[3].boost_curve_coefficient_headshot = 4
DamageProfileTemplates.medium_slashing_linesman_executioner.cleave_distribution.attack = 0.35
DamageProfileTemplates.medium_slashing_linesman_executioner.cleave_distribution.impact = 0.35
DamageProfileTemplates.medium_slashing_linesman_executioner.default_target.boost_curve_coefficient_headshot = 4

--Heavy 1
Weapons.two_handed_swords_executioner_template_1.actions.action_one.heavy_attack_left.additional_critical_strike_chance = 0 --0.2

--Mace and Sword
--lights 1,2
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left_diagonal.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT

--lights 3,4
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_left.damage_profile = "light_slashing_linesman_finesse"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_right_diagonal.damage_profile = "light_slashing_linesman_finesse"

--Heavy
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.hit_mass_count = nil
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.hit_mass_count = nil
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack.damage_profile_right = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_left = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.damage_profile_right = "mace_sword_heavy"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_left = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.light_attack_bopp.damage_profile_right = "mace_sword_bopp"
Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.15

--Weapons.dual_wield_hammer_sword_template.actions.action_one.heavy_attack_2.anim_time_scale = 1.25

-- Tuskgor Spear
-- Bop and Heavy 2
DamageProfileTemplates.heavy_slashing_tank.targets[1].power_distribution.attack = 0.4 --0.275
DamageProfileTemplates.heavy_slashing_tank.targets[2].power_distribution.attack = 0.3 --0.15
DamageProfileTemplates.heavy_slashing_tank.targets[3].power_distribution.attack = 0.2 --0.075

-- light 1,3,4
DamageProfileTemplates.medium_spear_smiter_stab.default_target.boost_curve_coefficient_headshot = 2 --1.5
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_stab_1 .anim_time_scale = 0.75
-- light 2
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_right.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.two_handed_heavy_spears_template.actions.action_one.light_attack_right.anim_time_scale = 1.05
Weapons.two_handed_heavy_spears_template.actions.action_one.default_left.allowed_chain_actions[2].sub_action = "heavy_attack_left"
Weapons.two_handed_heavy_spears_template.actions.action_one.default_left.allowed_chain_actions[6].sub_action = "heavy_attack_left"
Weapons.two_handed_heavy_spears_template.actions.action_one.default_left.allowed_chain_actions[6].auto_chain = nil
Weapons.two_handed_heavy_spears_template.actions.action_one.default_left.anim_event = "attack_swing_charge_stab"

-- 2h sword
--bop
Weapons.two_handed_swords_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.35
--Heavies
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_two_handed_sword_heavy"
Weapons.two_handed_swords_template_1.actions.action_one.heavy_attack_right.damage_profile = "tb_two_handed_sword_heavy"
NewDamageProfileTemplates.tb_two_handed_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.2,
			2,
			1,
			0.5
		},
		impact = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.4,
			2.5,
			1,
			0.5
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			0.5,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.75,
		impact = 0.4
	},
	default_target = {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.14,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient = 2,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.275
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.4,
				impact = 0.15
			},
			armor_modifier = {
				attack = { 1, 0.2, 2, 1, 0.5 },
				impact = { 1, 0.5, 0.5, 1, 1 }
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	}
}

--lights
DamageProfileTemplates.medium_slashing_linesman.targets[1].power_distribution.attack = 0.275
DamageProfileTemplates.medium_slashing_linesman.targets[2].power_distribution.attack = 0.2
DamageProfileTemplates.medium_slashing_linesman.targets[3].power_distribution.attack = 0.15
DamageProfileTemplates.medium_slashing_linesman.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.targets[3].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman.default_target.power_distribution.attack = 0.1
DamageProfileTemplates.medium_slashing_linesman.cleave_distribution.impact = 0.4

--2h hammer
--Heavies
DamageProfileTemplates.heavy_blunt_tank.cleave_distribution.attack = 0.5 --0.3
DamageProfileTemplates.heavy_blunt_tank.targets[1].power_distribution.attack = 0.525
DamageProfileTemplates.heavy_blunt_tank.targets[1].armor_modifier.attack = { 1, 0.3, 1.5, 0.75, 0.5, 0.3 }
DamageProfileTemplates.heavy_blunt_tank.targets[2].power_distribution.attack = 0.35
DamageProfileTemplates.heavy_blunt_tank.targets[2].armor_modifier = { attack = { 0.8, 0.3, 2, 1, 0.5, 0.3}, impact = { 1.5, 1, 1, 1, 0.75} }
DamageProfileTemplates.heavy_blunt_tank.targets[3].power_distribution.attack = 0.1
DamageProfileTemplates.heavy_blunt_tank.default_target.power_distribution.attack = 0.075
DamageProfileTemplates.heavy_blunt_tank.shield_break = true

--Bop
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.damage_profile = "light_blunt_tank_diag"
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_push_left_up.anim_time_scale = 1.2
--light 3
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_left_up.additional_critical_strike_chance = 0.1
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_left_up.anim_time_scale = 1.6
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_left_up.damage_profile = "light_blunt_tank_diag"
Weapons.two_handed_hammers_template_1.actions.action_one.light_attack_left_up.hit_mass_count = TANK_HIT_MASS_COUNT
--lights

--2h hammer saltz
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_01.anim_time_scale = 1
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_02.anim_time_scale = 1
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.damage_profile = "medium_slashing_linesman_uppercut"
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.anim_time_scale = 1.1
DamageProfileTemplates.priest_hammer_heavy_blunt_tank_upper.shield_break = true
Weapons.two_handed_hammer_priest_template.actions.action_three.default.anim_time_scale = 1.1
Weapons.two_handed_hammer_priest_template.actions.action_three.default.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.35,
		action = "action_one",
		end_time = 1,
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		release_required = "action_two_hold",
		end_time = 0.3,
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.3,
		action = "action_wield",
		end_time = 0.5,
		input = "action_wield"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_01.allowed_chain_actions[7].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_02.allowed_chain_actions[7].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.heavy_attack_03.allowed_chain_actions[7].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_01.allowed_chain_actions[8].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_02.allowed_chain_actions[8].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.light_attack_03.allowed_chain_actions[8].start_time = 0.5
Weapons.two_handed_hammer_priest_template.actions.action_one.push.allowed_chain_actions[7].start_time = 0.5

--Kruber Spear and Shield
Weapons.es_deus_01_template.actions.action_one.light_attack_left.allowed_chain_actions[4].start_time = 0.4

--Mace and Shield
Weapons.one_handed_hammer_shield_template_1.actions.action_one.heavy_attack_left.damage_profile = "heavy_slashing_tank"
Weapons.one_handed_hammer_shield_template_2.actions.action_one.heavy_attack_left.damage_profile = "heavy_slashing_tank"
Weapons.one_handed_hammer_shield_priest_template.actions.action_one.heavy_attack_left.damage_profile = "heavy_slashing_tank"

--Sword and Shield
Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_last.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_last.damage_profile = "light_slashing_linesman_finesse"
Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_left.damage_profile = "light_slashing_linesman_finesse"
Weapons.one_handed_sword_shield_template_1.actions.action_one.light_attack_right.damage_profile = "light_slashing_linesman_finesse"

--Bret Sword and Shield
Weapons.one_handed_sword_shield_template_2.actions.action_one.light_attack_left.damage_profile = "light_slashing_linesman_finesse"

--Bret Sword
NewDamageProfileTemplates.gs_heavy_slashing_smiter = {
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.5,
			1,
			0.75
		},
		impact = {
			1,
			1,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.75,
			1.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_coefficient_headshot = 1.5,
		boost_curve_coefficient = 1,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "heavy_slashing_smiter",
		power_distribution = {
			attack = 0.65,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "smiter_curve",
			attack_template = "stab_smiter",
			power_distribution = {
				attack = 0.2,
				impact = 0.1
			}
		}
	},
	shield_break = true
}
Weapons.bastard_sword_template.actions.action_one.light_attack_left.allowed_chain_actions[1].start_time = 0.5
Weapons.bastard_sword_template.actions.action_one.heavy_attack_down.damage_profile = "gs_heavy_slashing_smiter"
AttackTemplates.heavy_slashing_smiter.headshot_sound = "executioner_sword_critical"
DamageProfileTemplates.heavy_slashing_axe_linesman.armor_modifier.attack[2] = 0.5
DamageProfileTemplates.heavy_slashing_axe_linesman.armor_modifier.attack[6] = 0.2

--Halberd
--light 1
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.allowed_chain_actions[2].start_time = 0.5
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_left.damage_profile = "tb_halberd_light_slash"
NewDamageProfileTemplates.tb_halberd_light_slash = {
	armor_modifier = "armor_modifier_axe_linesman_M",
	critical_strike = "critical_strike_axe_linesman_M",
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.4,
		impact = 0.25
	},
	default_target = "default_target_axe_linesman_M",
	targets = {
		{
			boost_curve_coefficient_headshot = 1.5,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1.25,
					0.3,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.75,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.225,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.1
			}
		}
	}
}
--Heavy 2 (Also affects Elf Spear heavy 1)
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].armor_modifier.attack[1] = 1.15
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].power_distribution.attack = 0.45
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[2].power_distribution.attack = 0.35
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[3].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[4].power_distribution.attack = 0.15
DamageProfileTemplates.heavy_slashing_linesman_polearm.default_target.power_distribution.attack = 0.10

--light 2
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_stab.damage_profile = "tb_halberd_light_stab"
NewDamageProfileTemplates.tb_halberd_light_stab = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1,
            .8,
            2.5,
            1,
            1
        },
        impact_armor_power_modifer = {
            1,
            1,
            1,
            1,
            1
        }
    },
    armor_modifier = {
        attack = {
            1,
            .7,
            2.25,
            1,
            0.75
        },
        impact = {
            1,
            0.75,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 2,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.25,
            impact = 0.125
        }
    },
    melee_boost_override = 2.5
}
--Heavy 2
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].armor_modifier.attack[1] = 1.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[1].power_distribution.attack = 0.45
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[2].power_distribution.attack = 0.35
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[3].power_distribution.attack = 0.25
--DamageProfileTemplates.heavy_slashing_linesman_polearm.targets[4].power_distribution.attack = 0.15
--DamageProfileTemplates.heavy_slashing_linesman_polearm.default_target.power_distribution.attack = 0.10
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_left.damage_profile = "tb_halberd_heavy_slash"
NewDamageProfileTemplates.tb_halberd_heavy_slash = {
	armor_modifier = "armor_modifier_linesman_H",
	critical_strike = "critical_strike_linesman_H",
	charge_value = "heavy_attack",
	cleave_distribution = "cleave_distribution_linesman_executioner_H",
	default_target =  {
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient_headshot = 0.25,
		attack_template = "light_slashing_linesman",
		power_distribution = {
			attack = 0.1,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 1,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			},
			armor_modifier = {
				attack = {
					1.15,
					0.5,
					1.5,
					1,
					0.75
				},
				impact = {
					0.9,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.35,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.25,
				impact = 0.1
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.15,
				impact = 0.075
			}
		}
	},
}
--Heavy 1
Weapons.two_handed_halberds_template_1.actions.action_one.heavy_attack_stab.damage_profile = "tb_halberd_heavy_stab"
NewDamageProfileTemplates.tb_halberd_heavy_stab = {
    charge_value = "heavy_attack",
   	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
    critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.56,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.3,
			2,
			1,
			0.75
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.75
		}
	},
	default_target = {
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "heavy_stab_smiter",
		power_distribution = {
			attack = 0.2,
			impact = 0.15
		}
	},
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "ninja_curve",
			boost_curve_coefficient = 0.75,
			attack_template = "heavy_stab_smiter",
			armor_modifier = {
				attack = {
					1,
					0.56,
					2,
					1,
					0.75
				},
				impact = {
					1,
					0.65,
					1,
					1,
					0.75
				}
			},
			power_distribution = {
				attack = 0.45,
				impact = 0.25
			}
		}
	},
	melee_boost_override = 2.5
}
--light 3 and push stab
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_down.damage_profile = "tb_halberd_light_chop"
Weapons.two_handed_halberds_template_1.actions.action_one.light_attack_last.damage_profile = "tb_halberd_light_chop"
NewDamageProfileTemplates.tb_halberd_light_chop = {
    charge_value = "light_attack",
	cleave_distribution = {
        attack = 0.075,
        impact = 0.075
    },
    critical_strike = {
        attack_armor_power_modifer = {
            1.25,
            .76,
            2.5,
            1,
            1
        },
        impact_armor_power_modifer = {
            1,
            1,
            1,
            1,
            1
        }
    },
    armor_modifier = {
        attack = {
            1.25,
            .76,
            2.5,
            1,
            0.75
        },
        impact = {
            1,
            0.8,
            1,
            1,
            0.75
        }
    },
    default_target = {
        boost_curve_coefficient_headshot = 1.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 1,
        attack_template = "stab_smiter",
        power_distribution = {
            attack = 0.325,
            impact = 0.2
        }
    },
    melee_boost_override = 2.5,
	shield_break = true
}

-- 1h axe
--lights
Weapons.one_hand_axe_template_1.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
Weapons.one_hand_axe_template_2.actions.action_one.light_attack_last.anim_time_scale = 1.3 --1.035
DamageProfileTemplates.light_slashing_smiter.default_target.boost_curve_coefficient_headshot = 2 --1.5
DamageProfileTemplates.light_slashing_smiter_flat.default_target.boost_curve_coefficient_headshot = 2 --1.5
DamageProfileTemplates.light_slashing_smiter_diag.default_target.boost_curve_coefficient_headshot = 2 --1.5
DamageProfileTemplates.light_slashing_smiter.armor_modifier[3] = 2

--Heavy
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_1.actions.action_one.heavy_attack_right.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_left.range_mod = 1.2 --1
Weapons.one_hand_axe_template_2.actions.action_one.heavy_attack_right.range_mod = 1.2 --1

--War Pick
--lights
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.damage_profile = "medium_slashing_linesman_uppercut" --medium_blunt_tank
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.damage_profile = "medium_slashing_linesman_uppercut" --medium_blunt_tank
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_right.anim_time_scale = 0.95
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_left.anim_time_scale = 0.95

--Heavies
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left_charged.additional_critical_strike_chance = 1 --0
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right_charged.additional_critical_strike_chance = 1 --0
DamageProfileTemplates.heavy_blunt_smiter_charged.default_target.boost_curve_coefficient_headshot = 1.5
DamageProfileTemplates.heavy_blunt_smiter_charged.default_target.power_distribution.attack = 0.8
DamageProfileTemplates.heavy_blunt_smiter_charged.armor_modifier.attack =  { 1, 0.85, 2.5, 1, 0.85 } --{ 1, 0.85, 1.5, 1, 0.75 }

Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_left.anim_time_scale = 1.2 --1
Weapons.two_handed_picks_template_1.actions.action_one.heavy_attack_right.anim_time_scale = 1.2 --1
--bop
Weapons.two_handed_picks_template_1.actions.action_one.light_attack_bopp.damage_profile = "medium_blunt_smiter_bop_pick"
NewDamageProfileTemplates.medium_blunt_smiter_bop_pick = {
	stagger_duration_modifier = 1.5,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.3,
		impact = 0.8
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.05
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			boost_curve_coefficient_headshot = 1,
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.2
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.15
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.2,
			1,
			1,
			0.75
		},
		impact = {
			1,
			1,
			0.5,
			1,
			0.75
		}
	}
}


--Great Axe
--lights
DamageProfileTemplates.medium_slashing_smiter_2h.default_target.boost_curve_coefficient_headshot = 2.5
--light 3
Weapons.two_handed_axes_template_1.actions.action_one.light_attack_up.anim_time_scale = 0.9 --0.81

--Heavies
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.slide_armour_hit = true --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_right.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil
Weapons.two_handed_axes_template_1.actions.action_one.heavy_attack_left.hit_mass_count = HEAVY_LINESMAN_HIT_MASS_COUNT --nil

--Cog Hammer
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.anim_time_scale = 0.95 --1
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left_pose.anim_time_scale = 0.95 --1
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.anim_time_scale = 0.95 --1
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.additional_critical_strike_chance = 0.1 --0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.additional_critical_strike_chance = 0.1  --0
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.2  --1

--Dual Axes
--Heavies
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.925  --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.1 --1.035
Weapons.dual_wield_axes_template_1.actions.action_one.heavy_attack_3.additional_critical_strike_chance = 0.2 --0
--push
Weapons.dual_wield_axes_template_1.actions.action_one.push.damage_profile_inner = "light_push"
Weapons.dual_wield_axes_template_1.actions.action_one.push.fatigue_cost = "action_stun_push"

--Axe and Shield
Weapons.one_hand_axe_shield_template_1.actions.action_one.light_attack_bopp.additional_critical_strike_chance = 0.1
DamageProfileTemplates.medium_slashing_tank_1h.targets[1].power_distribution.attack = 0.35
DamageProfileTemplates.medium_slashing_tank_1h.targets[2].power_distribution.attack = 0.25
DamageProfileTemplates.medium_slashing_tank_1h.targets[3].power_distribution.attack = 0.175

--FLail
Weapons.one_handed_flail_template_1.actions.action_one.default_right.allowed_chain_actions[4].sub_action = "default_charge_2"
Weapons.one_handed_flail_template_1.actions.action_one.default_right.anim_event = "attack_swing_charge_left"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[1].sub_action = "default"
Weapons.one_handed_flail_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions[1].sub_action = "default"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.allowed_chain_actions[1].sub_action = "default_right"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions[1].sub_action = "default_right"
Weapons.one_handed_flail_template_1.actions.action_one.heavy_attack.anim_time_scale = 0.875
DamageProfileTemplates.light_blunt_tank_spiked.targets[1].power_distribution.attack = 0.25 --0.2
DamageProfileTemplates.light_blunt_tank_spiked.targets[2].power_distribution.attack = 0.15 --0.075
DamageProfileTemplates.light_blunt_tank_spiked.default_target.power_distribution.attack = 0.1 --0.075

--Flail & Shield
Weapons.one_handed_flail_shield_template.buffs.change_dodge_distance.external_optional_multiplier = 1
Weapons.one_handed_flail_shield_template.buffs.change_dodge_speed.external_optional_multiplier = 1
Weapons.one_handed_flail_shield_template.actions.action_one.light_attack_01.hit_mass_count = nil
Weapons.one_handed_flail_shield_template.actions.action_one.light_attack_02.hit_mass_count = nil
Weapons.one_handed_flail_shield_template.actions.action_one.light_attack_02_pose.hit_mass_count = nil
Weapons.one_handed_flail_shield_template.actions.action_one.light_attack_04.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flail_shield_template.actions.action_one.light_attack_05.hit_mass_count = TANK_HIT_MASS_COUNT

--Falchion
--light 1,2 and bop
DamageProfileTemplates.light_slashing_axe_linesman.targets[1].power_distribution.attack = 0.25 --0.2
DamageProfileTemplates.light_slashing_axe_linesman.targets[2].power_distribution.attack = 0.175 --0.2
DamageProfileTemplates.light_slashing_axe_linesman.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_slashing_axe_linesman.targets[3].power_distribution.attack = 0.125
DamageProfileTemplates.light_slashing_axe_linesman.targets[3].boost_curve_coefficient_headshot = 2
Weapons.one_hand_falchion_template_1.actions.action_one.heavy_attack_2.allowed_chain_actions[1].sub_action = "default_down"
--Heavy
Weapons.one_hand_falchion_template_1.actions.action_one.heavy_attack.damage_profile = "falchion_heavy"
Weapons.one_hand_falchion_template_1.actions.action_one.heavy_attack_2.damage_profile = "falchion_heavy"
NewDamageProfileTemplates.falchion_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "light_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 2,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.4,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true,
	melee_boost_override = 5
}


--Billhook
DamageProfileTemplates.medium_slashing_smiter_stab.default_target.power_distribution.attack = 0.25
--Tome and hammer
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_01.hit_mass_count = nil
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_01_pose.hit_mass_count = nil
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_02.hit_mass_count = nil
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_01.anim_time_scale = 1.05
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_01_pose.anim_time_scale = 1.05
Weapons.one_handed_hammer_book_priest_template.actions.action_one.light_attack_02.anim_time_scale = 1.05
--Heavy
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.damage_profile = "gs_1h_heavy"
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.range_mod = 1.2 --1
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.width_mod = 35 --25
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_stab_charged.lunge_settings.duration = 0.64
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_stab_charged.lunge_settings.initial_speed = 20
DamageProfileTemplates.hammer_book_charged_explosion.default_target.power_distribution.attack = 0.9
DamageProfileTemplates.hammer_book_charged_explosion.armor_modifier.attack = { 1, 0.8, 1.5, 1.3, 1, 0.6 }
DamageProfileTemplates.hammer_book_charged_explosion.armor_modifier.impact = { 1, 1.5, 1, 1, 1.5, .3}
ExplosionTemplates.hammer_book_charged_impact_explosion.explosion.radius_max = 2
Weapons.one_handed_hammer_book_priest_template.actions.action_one.default.charge_speed = 0.67
Weapons.one_handed_hammer_book_priest_template.actions.action_one.default_pose.charge_speed = 0.67
Weapons.one_handed_hammer_book_priest_template.actions.action_one.default_right.charge_speed = 0.67
Weapons.one_handed_hammer_book_priest_template.actions.action_three.default.charge_speed = 0.67
Weapons.one_handed_hammer_book_priest_template.actions.action_one.heavy_attack_left_charged.damage_profile = "heavy_dash"

NewDamageProfileTemplates.heavy_dash = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			2.5,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.45,
			impact = 1.5
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true
}

--Sienna Mace
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_upper.hit_mass_count = nil
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.3
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.light_attack_bopp.anim_time_scale = 1.2
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_left.additional_critical_strike_chance = 0.1
Weapons.one_handed_hammer_wizard_template_1.actions.action_one.heavy_attack_right_up.additional_critical_strike_chance = 0.1

--Dagger
Weapons.one_handed_daggers_template_1.actions.action_one.push_stab.allowed_chain_actions[2].sub_action = "default_right_heavy"
Weapons.one_handed_daggers_template_1.actions.action_one.push_stab.allowed_chain_actions[1].sub_action = "default_right_heavy"

--Flaming Flail
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_left.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.light_attack_right.hit_mass_count = TANK_HIT_MASS_COUNT
Weapons.one_handed_flails_flaming_template.actions.action_one.heavy_attack.anim_time_scale = 1
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.impact = 0.375
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.attack = 0.06
DamageProfileTemplates.flaming_flail_explosion.default_target.power_distribution.impact = 0.375
DamageProfileTemplates.heavy_blunt_smiter_burn.default_target.power_distribution.attack = 0.25

--Crowbill
DamageProfileTemplates.light_pointy_smiter.default_target.power_distribution.attack = 0.25
DamageProfileTemplates.light_pointy_smiter.armor_modifier.attack = { 1, 0.6, 2, 1, 0.7, 0.4 }
DamageProfileTemplates.light_pointy_smiter_diag.default_target.power_distribution.attack = 0.3
DamageProfileTemplates.light_pointy_smiter_diag.armor_modifier.attack = { 1, 0.6, 2, 1, 0.7, 0.4 }
DamageProfileTemplates.light_pointy_smiter_flat.default_target.power_distribution.attack = 0.3
DamageProfileTemplates.light_pointy_smiter_flat.armor_modifier.attack = { 1, 0.6, 2, 1, 0.7, 0.4 }
DamageProfileTemplates.light_pointy_smiter_upper.default_target.power_distribution.attack = 0.3
DamageProfileTemplates.light_pointy_smiter_upper.armor_modifier.attack = { 1, 0.6, 2, 1, 0.7, 0.4 }
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.damage_profile = "medium_pointy_smiter_flat_1h"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack.damage_profile = "medium_pointy_smiter_flat_1h"
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_right_up.additional_critical_strike_chance = 0.1
Weapons.one_handed_crowbill.actions.action_one.heavy_attack.additional_critical_strike_chance = 0.1
Weapons.one_handed_crowbill.actions.action_one.heavy_attack_left.additional_critical_strike_chance = 0.1
DamageProfileTemplates.medium_pointy_smiter_flat_1h.armor_modifier.attack = { 1.1, 1.1, 2, 1, 1, 1.1 }
DamageProfileTemplates.medium_pointy_smiter_flat_1h.critical_strike.attack = { 1.1, 1.1, 2, 1, 1, 1, 1.1 }
DamageProfileTemplates.light_blunt_smiter_stab_burn.targets[1].power_distribution.attack = 0.3
DamageProfileTemplates.light_blunt_smiter_stab_burn.armor_modifier.attack = { 1, 0.5, 3, 1, 0.75 }

--Flame Sword
DamageProfileTemplates.dagger_burning_slam.default_target.dot_template_name =  "burning_1W_dot"
DamageProfileTemplates.dagger_burning_slam.default_target.power_distribution.attack = 0.2
DamageProfileTemplates.dagger_burning_slam.default_target.power_distribution.impact = 0.3
Weapons.flaming_sword_template_1.actions.action_one.light_attack_right.damage_profile = "light_slashing_linesman_finesse"
Weapons.flaming_sword_template_1.actions.action_one.light_attack_left.damage_profile = "light_slashing_linesman_finesse"
Weapons.flaming_sword_template_1.actions.action_one.light_attack_stab.allowed_chain_actions[2].sub_action = "default_right_heavy"
Weapons.flaming_sword_template_1.actions.action_one.light_attack_stab.allowed_chain_actions[1].sub_action = "default_right_heavy"
Weapons.flaming_sword_template_1.actions.action_one.light_attack_stab.ignore_armour_hit = true
Weapons.flaming_sword_template_1.actions.action_one.light_attack_stab.anim_time_scale = 1.4
Weapons.flaming_sword_template_1.actions.action_one.light_attack_left.anim_time_scale = 1.35
Weapons.flaming_sword_template_1.actions.action_one.light_attack_right.anim_time_scale = 1.2
Weapons.flaming_sword_template_1.dodge_count = 4
DamageProfileTemplates.medium_burning_tank.cleave_distribution.attack = 0.1
DamageProfileTemplates.medium_burning_tank.armor_modifier.attack = { 1, 0.75, 2.5, 1, 1.5, 0.5 }
DamageProfileTemplates.medium_burning_tank.critical_strike.attack_armor_power_modifer = { 1, 0.75, 2.5, 1, 1.5, 0.5 }
DamageProfileTemplates.medium_burning_tank.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_burning_tank.targets[1].boost_curve_coefficient_headshot = 1.5
DamageProfileTemplates.medium_burning_tank.targets[1].power_distribution.attack = 0.4

--Glaive
--lights
DamageProfileTemplates.medium_slashing_axe_linesman.targets[2].power_distribution.attack = 0.225
DamageProfileTemplates.medium_slashing_axe_linesman.targets[3].power_distribution.attack = 0.15
DamageProfileTemplates.medium_slashing_axe_linesman.cleave_distribution.attack = 0.4
DamageProfileTemplates.medium_slashing_axe_linesman.targets[1].armor_modifier.attack[1] = 1.25
Weapons.two_handed_axes_template_2.actions.action_one.light_attack_bopp.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.hit_mass_count = nil
DamageProfileTemplates.heavy_slashing_smiter_glaive.default_target.power_distribution.attack = 0.7
DamageProfileTemplates.heavy_slashing_smiter_glaive.default_target.armor_modifier.attack = { 1, 0.85, 2, 1, 0.85 }
DamageProfileTemplates.heavy_slashing_smiter_glaive.default_target.attack_template = "heavy_slashing_smiter_hs_executioner"
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.additional_critical_strike_chance = 1
Weapons.two_handed_axes_template_2.actions.action_one.heavy_attack_down_first.damage_profile = "glaive_uppercut"
NewDamageProfileTemplates.glaive_uppercut = {
	armor_modifier = {
		attack = {
			1,
			0.8,
			1.75,
			1,
			0.75
		},
		impact = {
			1,
			0.6,
			1,
			1,
			0.75
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.7,
			2.5,
			1,
			0.75,
			0.6
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	charge_value = "heavy_attack",
	cleave_distribution = {
		attack = 0.075,
		impact = 0.075
	},
	default_target = {
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 2,
		attack_template = "slashing_smiter",
		power_distribution = {
			attack = 0.3,
			impact = 0.25
		}
	},
	targets = {
		[2] = {
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	shield_break = true
}

--Elf Spear
Weapons.two_handed_spears_elf_template_1.actions.action_one.heavy_attack_stab.hit_mass_count = nil
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.hit_mass_count = nil
Weapons.two_handed_spears_elf_template_1.actions.action_one.heavy_attack_left.hit_mass_count = nil
DamageProfileTemplates.medium_slashing_linesman_spear.targets[1].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_linesman_spear.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman_spear.targets[1].boost_curve_coefficient = 1
DamageProfileTemplates.medium_slashing_linesman_spear.targets[2].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_linesman_spear.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman_spear.targets[2].boost_curve_coefficient = 1
DamageProfileTemplates.medium_slashing_linesman_spear.targets[3].boost_curve_type = "ninja_curve"
DamageProfileTemplates.medium_slashing_linesman_spear.targets[3].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.medium_slashing_linesman_spear.targets[3].boost_curve_coefficient = 1
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_start = 0.27
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_left.damage_window_end = 0.38
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_start = 0.17
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_1.damage_window_end = 0.34
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_start = 0.19
Weapons.two_handed_spears_elf_template_1.actions.action_one.light_attack_stab_2.damage_window_end = 0.33

--Elf 1h Sword
Weapons.we_one_hand_sword_template_1.actions.action_one.heavy_attack_up.hit_mass_count = LINESMAN_HIT_MASS_COUNT
Weapons.we_one_hand_sword_template_1.actions.action_one.heavy_attack_up.damage_profile = "medium_slashing_axe_linesman"
DamageProfileTemplates.light_slashing_linesman_elf.armor_modifier.attack = { 1, 0, 2, 1, 1 }
DamageProfileTemplates.light_slashing_smiter_stab_swords.targets[1].power_distribution.attack = 0.2
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[1].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[2].start_time = 0.5
Weapons.we_one_hand_sword_template_1.actions.action_one.light_attack_last.allowed_chain_actions[3].start_time = 0.5

--Sword and Dagger
Weapons.dual_wield_sword_dagger_template_1.actions.action_one.heavy_attack_2.additional_critical_strike_chance = 0
Weapons.dual_wield_sword_dagger_template_1.actions.action_one.push_stab.additional_critical_strike_chance = 0
Weapons.dual_wield_sword_dagger_template_1.actions.action_one.heavy_attack.anim_time_scale = 1

--2h sword elf
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_bopp.anim_time_scale = 0.95
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_right_upward.anim_time_scale = 1.25
Weapons.two_handed_swords_wood_elf_template.actions.action_one.light_attack_left_upward.anim_time_scale = 1.25
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.anim_time_scale = 1.6
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_second.anim_time_scale = 1.1
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[1].external_multiplier = 1.5
Weapons.two_handed_swords_wood_elf_template.actions.action_one.heavy_attack_down_first.buff_data[2].external_multiplier = 0.5
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.heavy_slashing_smiter_stab.targets[1].armor_modifier.attack = { 1, 0.6, 2.5, 1, 0.75 }
DamageProfileTemplates.heavy_slashing_smiter_stab.critical_strike.attack_armor_power_modifer = { 1, 0.6, 3, 1, 1 }
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[1].power_distribution.attack = 0.325
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[2].power_distribution.attack = 0.25
DamageProfileTemplates.heavy_slashing_linesman_executioner.targets[3].power_distribution.attack = 0.15


--Dual Swords
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack.anim_time_scale = 1
Weapons.dual_wield_swords_template_1.actions.action_one.heavy_attack_2.anim_time_scale = 1.35
DamageProfileTemplates.light_slashing_linesman_dual_medium.targets[1].power_distribution.attack = 0.175
DamageProfileTemplates.light_slashing_linesman_dual_medium.targets[1].armor_modifier.attack = { 1, 0.5, 2, 1, 1 }
DamageProfileTemplates.light_slashing_linesman_dual_medium.targets[2].power_distribution.attack = 0.15
DamageProfileTemplates.light_slashing_linesman_dual_medium.targets[2].boost_curve_coefficient_headshot = 2
DamageProfileTemplates.light_slashing_linesman_dual_medium.default_target.power_distribution.attack = 0.1

--Dual Daggers
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_left.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.light_attack_right.additional_critical_strike_chance = 0.1
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.actions.action_one.heavy_attack_stab.allowed_chain_actions[5].start_time = 0.35
Weapons.dual_wield_daggers_template_1.max_fatigue_points = 6
Weapons.dual_wield_daggers_template_1.buffs.change_dodge_distance.external_optional_multiplier = 1.25
Weapons.dual_wield_daggers_template_1.buffs.change_dodge_speed.external_optional_multiplier = 1.25

--Elf Spear and Shield
Weapons.one_handed_spears_shield_template.actions.action_one.default_left.anim_event = "attack_swing_charge_stab"
Weapons.one_handed_spears_shield_template.actions.action_one.default_left.allowed_chain_actions[2].sub_action = "heavy_attack_stab"
Weapons.one_handed_spears_shield_template.actions.action_one.default_left.allowed_chain_actions[6].sub_action = "heavy_attack_stab"
DamageProfileTemplates.medium_slashing_smiter_stab_1h.default_target.power_distribution.attack = 0.35

--Weapon availability
ItemMasterList.es_2h_heavy_spear.can_wield = { "es_huntsman", "es_knight", "es_mercenary", "es_questingknight" }
ItemMasterList.wh_1h_falchion.can_wield = { "wh_zealot", "wh_bountyhunter", "wh_captain", "wh_priest" }
ItemMasterList.wh_2h_sword.can_wield = { "wh_zealot", "wh_bountyhunter", "wh_captain", "wh_priest" }
ItemMasterList.wh_1h_axe.can_wield = { "wh_zealot", "wh_bountyhunter", "wh_captain", "wh_priest" }
ItemMasterList.wh_dual_wield_axe_falchion.can_wield = { "wh_zealot", "wh_bountyhunter", "wh_captain", "wh_priest" }

--Ranged
--Repeater Handgun
Weapons.repeating_handgun_template_1.actions.action_one.bullet_spray.anim_time_scale = 1.3
Weapons.repeating_handgun_template_1.actions.action_one.bullet_spray.recoil_settings.vertical_climb = 3.5
Weapons.repeating_handgun_template_1.ammo_data.max_ammo = 60
SpreadTemplates.repeating_handgun.continuous.moving.max_yaw = 0.75
SpreadTemplates.repeating_handgun.continuous.moving.min_yaw = 0.75
SpreadTemplates.repeating_handgun.continuous.crouch_moving.max_yaw = 0.3
SpreadTemplates.repeating_handgun.continuous.crouch_moving.min_yaw = 0.3

--Coruscation
Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.6
Weapons.bw_deus_01_template_1.actions.action_one.default.allowed_chain_actions[1].start_time = 0.5
Weapons.bw_deus_01_template_1.actions.action_one.default.total_time = 0.65
Weapons.bw_deus_01_template_1.actions.action_one.default.shot_count = 15
Weapons.bw_deus_01_template_1.actions.action_two.default.max_radius = 30
Weapons.bw_deus_01_template_1.actions.action_two.default.charge_time = 30
DamageProfileTemplates.staff_magma.default_target.power_distribution_near.attack = 0.1
DamageProfileTemplates.staff_magma.default_target.power_distribution_far.attack = 0.05
PlayerUnitStatusSettings.overcharge_values.magma_basic = 4
ExplosionTemplates.magma.aoe.duration = 3
ExplosionTemplates.magma.aoe.damage_interval = 0.75
PlayerUnitStatusSettings.overcharge_values.magma_charged_2 = 10
PlayerUnitStatusSettings.overcharge_values.magma_charged = 14

--Fireball
Weapons.staff_fireball_fireball_template_1.actions.action_one.default.total_time = 0.6
Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.scale_power_level = 0.3 --Reduce to make difference bigger between partial and full charge
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_near.attack = 0.4
DamageProfileTemplates.staff_fireball_charged.default_target.power_distribution_far.attack = 0.4
DamageProfileTemplates.fireball_charged_explosion.default_target.power_distribution.attack = 0.15
DamageProfileTemplates.fireball_charged_explosion_glance.default_target.power_distribution.attack = 0.1
DamageProfileTemplates.fireball_charged_explosion.no_friendly_fire = true
DamageProfileTemplates.fireball_charged_explosion_glance.no_friendly_fire = true
Projectiles.fireball_charged.radius_max = 0.75
ExplosionTemplates.fireball_charged.explosion.radius_max = 5
ExplosionTemplates.fireball_charged.explosion.max_damage_radius_max = 5
Projectiles.fireball_charged.times_bigger = 6

--Repeater pistol
DamageProfileTemplates.shot_machinegun_shotgun.shield_break = true

--Brace of Pistols
DamageProfileTemplates.shot_carbine.default_target.boost_curve_coefficient_headshot = 2
Weapons.brace_of_pistols_template_1.ammo_data.ammo_per_clip = nil
Weapons.brace_of_pistols_template_1.ammo_data.ammo_immediately_available = true
Weapons.brace_of_pistols_template_1.ammo_data.single_clip = true

--Weapons.brace_of_pistols_template_1.actions.action_one.fast_shot.allowed_chain_actions[2].start_time = 0.05
--Weapons.brace_of_pistols_template_1.actions.action_one.fast_shot.allowed_chain_actions[3].start_time = 0.05
--Weapons.brace_of_pistols_template_1.ammo_data.max_ammo = 200

--Volley crossbow
DamageProfileTemplates.crossbow_bolt_repeating.cleave_distribution.attack = 0.3

--Trollhammer
Weapons.dr_deus_01_template_1.ammo_data.reload_time = 4
DamageProfileTemplates.dr_deus_01_explosion.armor_modifier.attack = {
	0.25,
	0.1,
	0.1,
	0.1,
	0.1,
	0.1
}
DamageProfileTemplates.dr_deus_01_glance.armor_modifier.attack = {
	0.25,
	0.1,
	0.1,
	0.1,
	0.1,
	0.1
}

DamageProfileTemplates.dr_deus_01_explosion.default_target.power_distribution.attack = 0.25
DamageProfileTemplates.dr_deus_01_glance.default_target.power_distribution.attack = 0.05

DamageProfileTemplates.dr_deus_01.default_target.boost_curve_coefficient_headshot = 4.5
DamageProfileTemplates.dr_deus_01.default_target.power_distribution_near.attack = 1.1

----Removed Grenadier from proccing on Trollhammer
--mod:hook(ActionGrenadeThrower, "client_owner_post_update", function(func, self, dt, t, world, can_damage)
--	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
--		self.state = "shooting"
--	end
--
--	if self.state == "shooting" then
--		local owner_unit = self.owner_unit
--
--		if not Managers.player:owner(self.owner_unit).bot_player then
--			Managers.state.controller_features:add_effect("rumble", {
--				rumble_effect = "crossbow_fire"
--			})
--		end
--
--		local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
--		local position, rotation = first_person_extension:get_projectile_start_position_rotation()
--		local spread_extension = self.spread_extension
--		local current_action = self.current_action
--
--		if spread_extension then
--			rotation = spread_extension:get_randomised_spread(rotation)
--
--			spread_extension:set_shooting()
--		end
--
--		local angle = ActionUtils.pitch_from_rotation(rotation)
--		local speed = current_action.speed
--		local target_vector = Vector3.normalize(Vector3.flat(Quaternion.forward(rotation)))
--		local lookup_data = current_action.lookup_data
--
--		ActionUtils.spawn_player_projectile(owner_unit, position, rotation, 0, angle, target_vector, speed, self.item_name, lookup_data.item_template_name, lookup_data.action_name, lookup_data.sub_action_name, self._is_critical_strike, self.power_level)
--
--		local fire_sound_event = self.current_action.fire_sound_event
--
--		if fire_sound_event then
--			first_person_extension:play_hud_sound_event(fire_sound_event)
--		end
--
--		if self.ammo_extension and not self.extra_buff_shot then
--			local ammo_usage = current_action.ammo_usage
--			local _, procced = self.owner_buff_extension:apply_buffs_to_value(0, "not_consume_grenade")
--
--			self.ammo_extension:use_ammo(ammo_usage)
--		end
--
--		local add_spread = not self.extra_buff_shot
--
--		if self:_update_extra_shots(self.owner_buff_extension, 1) then
--			self.state = "waiting_to_shoot"
--			self.time_to_shoot = t + 0.1
--			self.extra_buff_shot = true
--		else
--			self.state = "shot"
--		end
--
--		first_person_extension:reset_aim_assist_multiplier()
--	end
--
--	if self.state == "shot" and self.active_reload_time then
--		local owner_unit = self.owner_unit
--		local input_extension = ScriptUnit.extension(owner_unit, "input_system")
--
--		if self.active_reload_time < t then
--			local ammo_extension = self.ammo_extension
--
--			if (input_extension:get("weapon_reload") or input_extension:get_buffer("weapon_reload")) and ammo_extension:can_reload() then
--				local status_extension = ScriptUnit.extension(self.owner_unit, "status_system")
--
--				status_extension:set_zooming(false)
--
--				local weapon_extension = ScriptUnit.extension(self.weapon_unit, "weapon_system")
--
--				weapon_extension:stop_action("reload")
--			end
--		elseif input_extension:get("weapon_reload") then
--			input_extension:add_buffer("weapon_reload", 0)
--		end
--	end
--end)
--mod:add_proc_function("replenish_ammo_on_headshot_ranged", function (owner_unit, buff, params)
--	local owner_unit = player.owner_unit
--	local attack_type = params[2]
--	local hit_zone_name = params[3]
--
--	if Unit.alive(owner_unit) and hit_zone_name == "head" and (attack_type == "instant_projectile" or attack_type == "projectile") then
--		local ranged_buff_type = params[5]
--
--		if ranged_buff_type and ranged_buff_type == "RANGED_ABILITY" then
--			return
--		end
--
--		local weapon_slot = "slot_ranged"
--		local ammo_amount = buff.bonus
--		local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
--		local slot_data = inventory_extension:get_slot_data(weapon_slot)
--		local right_unit_1p = slot_data.right_unit_1p
--		local left_unit_1p = slot_data.left_unit_1p
--		local ammo_extension = GearUtils.get_ammo_extension(right_unit_1p, left_unit_1p)
--
--		if slot_data then
--			local item_data = slot_data.item_data
--			local item_name = item_data.name
--			if item_name == "dr_deus_01" then
--				return
--			end
--		end
--
--		if ammo_extension then
--			ammo_extension:add_ammo_to_reserve(ammo_amount)
--		end
--	end
--end)

--Javelin
DamageProfileTemplates.thrown_javelin.default_target.boost_curve_coefficient_headshot = 2
DamageProfileTemplates.thrown_javelin.default_target.boost_curve_type = "ninja_curve"
DamageProfileTemplates.thrown_javelin.cleave_distribution.attack = 0.475
DamageProfileTemplates.thrown_javelin.cleave_distribution.impact = 0.475
DamageProfileTemplates.thrown_javelin.default_target.power_distribution_near.impact = 0.5
DamageProfileTemplates.thrown_javelin.default_target.power_distribution_far.impact = 0.5

--Life Staff
Weapons.staff_life.actions.action_one.cast_vortex.allowed_chain_actions[4].start_time = 0.6
Weapons.staff_life.actions.action_one.cast_vortex.overcharge_amount = 10
VortexTemplates.spirit_storm.time_of_life = { 6,6 }
VortexTemplates.spirit_storm.reduce_duration_per_breed = { chaos_warrior = 0.5 }

--Volley Crossbow Elf
Weapons.repeating_crossbow_elf_template.ammo_data.max_ammo = 60
Weapons.repeating_crossbow_elf_template.actions.action_one.default.impact_data.damage_profile = "repeating_crossbow_elf_projectile"
Weapons.repeating_crossbow_elf_template.actions.action_one.zoomed_shot.impact_data.damage_profile = "repeating_crossbow_elf_projectile"
local carbine_dropoff_ranges = {
	dropoff_start = 15,
	dropoff_end = 30
}
NewDamageProfileTemplates.repeating_crossbow_elf_projectile = {
	charge_value = "projectile",
	no_stagger_damage_reduction_ranged = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1,
			1.5,
			1,
			0.5,
			0.45
		},
		impact_armor_power_modifer = {
			1,
			0.5,
			1,
			1,
			1,
			0.5
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			1,
			1.5,
			1,
			0.5,
			0.45
		},
		impact = {
			1,
			0.5,
			1,
			1,
			1,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			1,
			1.5,
			1,
			0.5,
			0.4
		},
		impact = {
			1,
			0.8,
			1,
			1,
			1,
			0.25
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 0.2
	},
	default_target = {
		boost_curve_coefficient_headshot = 1.5,
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "bolt_carbine",
		power_distribution_near = {
			attack = 0.4,
			impact = 0.25
		},
		power_distribution_far = {
			attack = 0.25,
			impact = 0.15
		},
		range_dropoff_settings = carbine_dropoff_ranges
	}
}

--Masterwork Pistol
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.aim_assist_ramp_decay_delay = 0.2
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.aim_assist_ramp_multiplier = 0.1
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.aim_assist_max_ramp_multiplier = 0.3
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.crosshair_style = "default"
Weapons.heavy_steam_pistol_template_1.actions.action_two.default.crosshair_style = "default"
Weapons.heavy_steam_pistol_template_1.actions.action_two.default.spread_template_override = "brace_of_drake_pistols"
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.spread_template_override = "brace_of_drake_pistols"
Weapons.heavy_steam_pistol_template_1.actions.action_one.fast_shot.impact_data.damage_profile = "shot_sniper_pistol_burst"
Weapons.heavy_steam_pistol_template_1.default_spread_template = "spear"
Weapons.heavy_steam_pistol_template_1.actions.action_one.default.charge_time = 0.7
Weapons.heavy_steam_pistol_template_1.actions.action_one.default.total_time = 1
Weapons.heavy_steam_pistol_template_1.actions.action_one.default.anim_time_scale = 1.1

--Duck foot
local balanced_barrels =  { {	yaw = -1, pitch = 0, shot_count = 2 }, { yaw = -0.5, pitch = 0, shot_count = 2 },	{ yaw = 0, pitch = 0, shot_count = 4 }, { yaw = 0.5,  pitch = 0, shot_count = 2 }, { yaw = 1, pitch = 0, shot_count = 2 } }
Weapons.wh_deus_01_template_1.actions.action_one.default.barrels = balanced_barrels
DamageProfileTemplates.shot_duckfoot.cleave_distribution.attack = 0.05
DamageProfileTemplates.shot_duckfoot.cleave_distribution.impact = 0.05

--Conflag
DamageProfileTemplates.geiser.targets[1].power_distribution.attack = 0.6
DamageProfileTemplates.geiser.targets[2].power_distribution.impact = 0.7

BreedActions.chaos_raider.special_attack_cleave.ignore_staggers = { true, true, false, true, true, false }

--Grudge Raker
Weapons.grudge_raker_template_1.actions.action_one.default.hit_mass_count = nil
Weapons.grudge_raker_template_1.actions.action_one.default.damage_profile = "shot_shotgun_cbr"
Weapons.grudge_raker_template_1.actions.action_one.default.allowed_chain_actions[2].start_time = 0.6
Weapons.grudge_raker_template_1.actions.action_one.default.allowed_chain_actions[4].start_time = 0.6
Weapons.grudge_raker_template_1.ammo_data.max_ammo = 24
local machinegun_dropoff_ranges = {
	dropoff_start = 10,
	dropoff_end = 30
}
NewDamageProfileTemplates.shot_shotgun_cbr = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.3,
			0.5,
			1,
			1,
			0
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			0.5
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			0.2,
			0.4,
			0.75,
			1,
			0
		},
		impact = {
			1,
			0.75,
			3,
			0,
			1,
			0.75
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			0,
			0.25,
			0.75,
			1,
			0
		},
		impact = {
			1,
			0.5,
			0.5,
			0,
			1,
			0.5
		}
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.7
	},
	default_target = {
		boost_curve_coefficient_headshot = 0.75,
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "shot_shotgun",
		power_distribution_near = {
			attack = 0.25,
			impact = 1
		},
		power_distribution_far = {
			attack = 0.15,
			impact = 0.6
		},
		range_dropoff_settings = machinegun_dropoff_ranges
	}
}
table.insert(Weapons.grudge_raker_template_1.actions.action_one.default.allowed_chain_actions, 5, { sub_action = "default", start_time = 0.6, action = "action_three", input = "action_three" })
table.insert(Weapons.grudge_raker_template_1.actions.action_one.default.allowed_chain_actions, 5, { sub_action = "default", start_time = 0.3, action = "action_three", input = "action_three" })
Weapons.grudge_raker_template_1.actions.action_three = {
	default = {
		damage_window_start = 0.1,
		play_reload_animation = true,
		fire_at_gaze_setting = "tobii_fire_at_gaze_grudgeraker",
		total_time_secondary = 2,
		bullseye = true,
		num_layers_spread = 1,
		damage_profile = "grudge_action_three",
		charge_value = "light_attack",
		alert_sound_range_fire = 15,
		alert_sound_range_hit = 4,
		hit_effect = "shotgun_bullet_impact",
		anim_event_last_ammo = "attack_shoot_last",
		reload_when_out_of_ammo = true,
		ranged_attack = true,
		damage_window_end = 0,
		range = 100,
		ammo_usage = 1,
		fire_time = 0,
		shot_count = 1,
		kind = "shotgun",
		apply_recoil = true,
		anim_event_secondary = "reload",
		active_reload_time = 0.35,
		anim_event = "attack_shoot",
		reload_time = 2.5,
		total_time = 0.66,
		spread_template_override = "repeating_handgun",
		allowed_chain_actions = {
			{
				sub_action = "default",
				start_time = 0.4,
				action = "action_wield",
				input = "action_wield"
			},
			{
				sub_action = "default",
				start_time = 0.75,
				action = "action_one",
				doubleclick_window = 0.2,
				input = "action_one"
			},
			{
				sub_action = "default",
				start_time = 0.4,
				action = "action_two",
				input = "action_two"
			},
			{
				sub_action = "default",
				start_time = 0.5,
				action = "weapon_reload",
				input = "weapon_reload"
			},
			{
				sub_action = "auto_reload_on_empty",
				start_time = 0.6,
				action = "weapon_reload",
				auto_chain = true
			}
		},
		enter_function = function (attacker_unit, input_extension)
			input_extension:clear_input_buffer()

			return input_extension:reset_release_input()
		end,
		recoil_settings = {
			horizontal_climb = 0,
			restore_duration = 0.2,
			vertical_climb = 2,
			climb_duration = 0.2,
			climb_function = math.easeInCubic,
			restore_function = math.ease_out_quad
		}
	}
}
local shotgun_special_dropoff_ranges = {
	dropoff_start = 4,
	dropoff_end = 10
}
NewDamageProfileTemplates.grudge_action_three = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.8,
			1.5,
			1,
			0.5,
			0.25
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.5
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			0.8,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.8,
			1,
			1,
			1,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			0.6,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			0.6,
			1,
			1,
			1,
			0.25
		}
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3
	},
	default_target = {
		boost_curve_coefficient_headshot = 2.5,
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 1,
		attack_template = "bolt_sniper",
		power_distribution_near = {
			attack = 0.7,
			impact = 0.4
		},
		power_distribution_far = {
			attack = 0.35,
			impact = 0.3
		},
		range_dropoff_settings = shotgun_special_dropoff_ranges
	}
}

--Blunderbuss
Weapons.blunderbuss_template_1.actions.action_one.default.hit_mass_count = nil
Weapons.blunderbuss_template_1.actions.action_one.default.damage_profile = "shot_shotgun_cbr"
Weapons.blunderbuss_template_1.ammo_data.max_ammo = 24
table.insert(Weapons.blunderbuss_template_1.actions.action_one.default.allowed_chain_actions, 5, { sub_action = "default", start_time = 0.6, action = "action_three", input = "action_three" })
--table.insert(Weapons.blunderbuss_template_1.actions.action_one.default.allowed_chain_actions, 5, { sub_action = "default", start_time = 0.3, action = "action_three", input = "action_three" })
Weapons.blunderbuss_template_1.actions.action_three = {
	default = {
		damage_window_start = 0.1,
		play_reload_animation = true,
		fire_at_gaze_setting = "tobii_fire_at_gaze_blunderbuss",
		kind = "shotgun",
		damage_profile = "blunder_action_three",
		num_layers_spread = 2,
		total_time_secondary = 1,
		charge_value = "light_attack",
		alert_sound_range_fire = 12,
		alert_sound_range_hit = 5,
		reload_when_out_of_ammo = true,
		hit_effect = "shotgun_bullet_impact",
		anim_event_last_ammo = "attack_shoot_last",
		bullseye = false,
		shot_count = 1,
		damage_window_end = 0,
		range = 100,
		ammo_usage = 1,
		fire_time = 0,
		apply_recoil = true,
		anim_event_secondary = "reload",
		active_reload_time = 0.35,
		anim_event = "attack_shoot",
		total_time = 1,
		spread_template_override = "repeating_handgun",
		allowed_chain_actions = {
			{
				sub_action = "default",
				start_time = 0.4,
				action = "action_wield",
				input = "action_wield"
			},
			{
				sub_action = "default",
				start_time = 0.75,
				action = "action_one",
				input = "action_one"
			},
			{
				sub_action = "default",
				start_time = 0.4,
				action = "action_two",
				input = "action_two"
			},
			{
				sub_action = "default",
				start_time = 0.6,
				action = "weapon_reload",
				input = "weapon_reload"
			},
			{
				sub_action = "default",
				start_time = 0.75,
				action = "weapon_reload",
				auto_chain = true
			}
		},
		recoil_settings = {
			horizontal_climb = 0,
			restore_duration = 0.2,
			vertical_climb = 2,
			climb_duration = 0.2,
			climb_function = math.easeInCubic,
			restore_function = math.ease_out_quad
		}
	}
}
NewDamageProfileTemplates.blunder_action_three = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			1.4,
			1.5,
			1,
			0.75,
			0.6
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			1.2,
			1.5,
			1,
			0.75,
			0.5
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			1,
			1,
			1,
			0.75,
			0.25
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0.75
		}
	},
	cleave_distribution = {
		attack = 0.3,
		impact = 0.3
	},
	default_target = {
		headshot_boost_boss = 0.5,
		boost_curve_coefficient_headshot = 1,
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 1,
		attack_template = "shot_sniper",
		power_distribution_near = {
			attack = 1,
			impact = 0.5
		},
		power_distribution_far = {
			attack = 0.5,
			impact = 0.5
		},
		range_dropoff_settings = shotgun_special_dropoff_ranges
	}
}

--Drakefire Pistols
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.default.speed = 10000
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.default.allowed_chain_actions[2].start_time = 0.2
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.default.allowed_chain_actions[3].start_time = 0.2
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.shoot_charged.ignore_shield_hit = true
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.shoot_charged.allowed_chain_actions[1].start_time = 0.3
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.shoot_charged.allowed_chain_actions[2].start_time = 0.6
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.shoot_charged.allowed_chain_actions[3].start_time = 0.6
Weapons.brace_of_drakefirepistols_template_1.actions.action_one.shoot_charged.allowed_chain_actions[4].start_time = 0.6
PlayerUnitStatusSettings.overcharge_values.brace_of_drake_pistols_basic = 2.5
DamageProfileTemplates.shot_drakefire.armor_modifier_near.attack = { 1, 0.4, 2, 1, 0.75, 0.1 }
DamageProfileTemplates.shot_drakefire.armor_modifier_far.attack = { 0.8, 0.2, 1.5, 1, 0.5, 0 }
DamageProfileTemplates.shot_drakefire.critical_strike.attack_armor_power_modifer = { 1, 0.3, 2, 1, 0.75, 0.25 }
DamageProfileTemplates.blast.default_target.power_distribution_near.impact = 0.5
DamageProfileTemplates.blast.armor_modifier.impact = { 1, 1, 1, 1, 1, 0.25 }
DamageProfileTemplates.blast.critical_strike.impact_armor_power_modifer = { 1, 1, 1, 1, 1, 0.25 }
DamageProfileTemplates.shot_drakefire.default_target.power_distribution_near.attack = 0.225
DamageProfileTemplates.shot_drakefire.default_target.power_distribution_far.attack = 0.1
DamageProfileTemplates.blast.armor_modifier.attack[5] = 0.6
DamageProfileTemplates.blast.critical_strike.attack_armor_power_modifer[5] = 0.6
local drake_pistol_dropoff_ranges = {	dropoff_start = 5,	dropoff_end = 10 }
DamageProfileTemplates.shot_drakefire.default_target.range_dropoff_settings = drake_pistol_dropoff_ranges

--Drakefire Gun
Weapons.drakegun_template_1.actions.action_one.shoot_charged.particle_effect_flames = "fx/wpnfx_flamethrower_01"

--Throwing Axes
Weapons.one_handed_throwing_axes_template.actions.weapon_reload.default.one_ammo_catch_time = 1.25
Weapons.one_handed_throwing_axes_template.actions.weapon_reload.default.total_time = 2.5

Weapons.one_handed_throwing_axes_template.actions.weapon_reload.default.allowed_chain_actions[2].start_time = 0.3
--Elf bows
Weapons.shortbow_template_1.weapon_type_bow = true
Weapons.shortbow_hagbane_template_1.weapon_type_bow = true
Weapons.longbow_template_1.weapon_type_bow = true
Weapons.javelin_template.weapon_type_bow = true
Weapons.shortbow_template_1.weapon_type_bow = true
Weapons.shortbow_template_1.ammo_data.max_ammo = 65
Weapons.shortbow_hagbane_template_1.ammo_data.max_ammo = 25
Weapons.longbow_template_1.ammo_data.max_ammo = 30

--Swift Bow
DamageProfileTemplates.arrow_machinegun.cleave_distribution.attack = 0.25
DamageProfileTemplates.arrow_machinegun.cleave_distribution.impact = 0.25
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.attack = 0.35
DamageProfileTemplates.arrow_carbine_shortbow.cleave_distribution.impact = 0.45
Weapons.shortbow_template_1.actions.action_one.default.additional_critical_strike_chance = 0.1
Weapons.shortbow_template_1.actions.action_one.shoot_charged.anim_event_secondary = "reload"
Weapons.shortbow_template_1.actions.action_one.shoot_charged.reload_when_out_of_ammo = true
Weapons.shortbow_template_1.actions.action_one.shoot_charged.kind = "crossbow"
Weapons.shortbow_template_1.actions.action_one.shoot_charged.multi_projectile_spread = .0125
Weapons.shortbow_template_1.actions.action_one.shoot_charged.num_projectiles = 5
Weapons.shortbow_template_1.actions.action_one.shoot_charged.ammo_usage = 1
Weapons.shortbow_template_1.ammo_data.ammo_per_reload = 5
Weapons.shortbow_template_1.ammo_data.ammo_per_clip = 5
Weapons.shortbow_template_1.ammo_data.ammo_per_clip = 5
Weapons.shortbow_template_1.ammo_data.play_reload_anim_on_wield_reload = true
Weapons.shortbow_template_1.actions.action_two.default.num_projectiles = 5
Weapons.shortbow_template_1.actions.action_two.default.charge_time = 10
Weapons.shortbow_template_1.actions.action_two.default.anim_time_scale = 1
Weapons.shortbow_template_1.actions.action_two.default.allowed_chain_actions = {
	{
		sub_action = "shoot_charged",
		start_time = 1,
		action = "action_one",
		end_time = 1.25,
		input = "action_one"
	},
	{
		sub_action = "shoot_charged",
		start_time = 0.75,
		action = "action_one",
		input = "action_one",
		end_time = math.huge
	},
	{
		softbutton_threshold = 0.75,
		start_time = 0.65,
		action = "action_one",
		sub_action = "shoot_charged",
		input = "action_one_softbutton_gamepad",
		end_time = math.huge
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield",
		end_time = math.huge
	},
	{
		sub_action = "default",
		start_time = 0.1,
		action = "weapon_reload",
		input = "weapon_reload"
	},
	{
		sub_action = "auto_reload",
		start_time = 0.8,
		action = "weapon_reload",
		auto_chain = true
	}
}
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_near.attack = 0.2
DamageProfileTemplates.arrow_carbine_shortbow.default_target.power_distribution_far.attack = 0.15
DamageProfileTemplates.arrow_carbine_shortbow.armor_modifier_near.attack[2] = 0.3
DamageProfileTemplates.arrow_carbine_shortbow.armor_modifier_near.attack[5] = 0.75
DamageProfileTemplates.arrow_carbine_shortbow.armor_modifier_far.attack[5] = 0.75
DamageProfileTemplates.arrow_carbine_shortbow.critical_strike.attack_armor_power_modifer[2] = 0.3
DamageProfileTemplates.arrow_carbine_shortbow.critical_strike.attack_armor_power_modifer[5] = 0.75

--ItemMasterList.we_shortbow.ammo_unit = "units/weapons/player/wpn_we_quiver_t1/wpn_we_tripple_arrow_t1"

--Manbow
function add_chain_actions(action_no, action_from, new_data)
    local value = "allowed_chain_actions"
    local row = #action_no[action_from][value] + 1
    action_no[action_from][value][row] = new_data
end

for _, weapon in ipairs{
    "longbow_empire_template",
} do
    local weapon_template = Weapons[weapon]
    local action_one = weapon_template.actions.action_one
    local action_two = weapon_template.actions.action_two
    add_chain_actions(action_one, "shoot_charged_heavy", {
        sub_action = "default",
        start_time = 0, -- 0.3
        action = "action_wield",
        input = "action_wield",
        end_time = math.huge
    })
end

Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].start_time = 0.25
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].sub_action = "default"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].action = "action_one"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].release_required = "action_two_hold"
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[4].input = "action_one"

Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.reload_event_delay_time = 0.1
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.override_reload_time = nil
Weapons.longbow_empire_template.actions.action_one.shoot_charged_heavy.allowed_chain_actions[2].start_time = 0.68

Weapons.longbow_empire_template.actions.action_one.default.allowed_chain_actions[2].start_time = 0.4
Weapons.longbow_empire_template.actions.action_one.default.override_reload_time = 0.15
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_delay = nil
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_event = nil
Weapons.longbow_empire_template.actions.action_two.default.aim_zoom_delay = 100
Weapons.longbow_empire_template.ammo_data.reload_time = 0
Weapons.longbow_empire_template.ammo_data.reload_on_ammo_pickup = true


SpreadTemplates.empire_longbow.continuous.still = {max_yaw = 0.25, max_pitch = 0.25 }
SpreadTemplates.empire_longbow.continuous.moving = {max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.crouch_still = {max_yaw = 0.75, max_pitch = 0.75 }
SpreadTemplates.empire_longbow.continuous.crouch_moving = {max_yaw = 2, max_pitch = 2 }
SpreadTemplates.empire_longbow.continuous.zoomed_still = {max_yaw = 0, max_pitch = 0}
SpreadTemplates.empire_longbow.continuous.zoomed_moving = {max_yaw = 0.4, max_pitch = 0.4 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_still = {max_yaw = 0, max_pitch = 0 }
SpreadTemplates.empire_longbow.continuous.zoomed_crouch_moving = {max_yaw = 0.4, max_pitch = 0.4 }

function add_chain_actions(action_no, action_from, new_data)
    local value = "allowed_chain_actions"
    local row = #action_no[action_from][value] + 1
    action_no[action_from][value][row] = new_data
end

for _, weapon in ipairs{
    "longbow_empire_template",
} do
    local weapon_template = Weapons[weapon]
    local action_one = weapon_template.actions.action_one
    local action_two = weapon_template.actions.action_two
    add_chain_actions(action_one, "shoot_charged", {
        sub_action = "default",
        start_time = 0, -- 0.3
        action = "action_wield",
        input = "action_wield",
        end_time = math.huge
    })
end

Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].start_time = 0.4
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].sub_action = "default"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].action = "action_one"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].release_required = "action_two_hold"
Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[4].input = "action_one"

Weapons.longbow_empire_template.actions.action_one.shoot_charged.allowed_chain_actions[2].start_time = 0.7
Weapons.longbow_empire_template.actions.action_one.shoot_charged.reload_event_delay_time = 0.15
Weapons.longbow_empire_template.actions.action_one.shoot_charged.override_reload_time = nil
Weapons.longbow_empire_template.actions.action_one.shoot_charged.speed = 11000

Weapons.longbow_empire_template.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.longbow_empire_template.actions.action_two.default.heavy_aim_flow_event = nil
Weapons.longbow_empire_template.actions.action_two.default.default_zoom = "zoom_in_trueflight"
Weapons.longbow_empire_template.actions.action_two.default.buffed_zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }
DamageProfileTemplates.arrow_sniper_kruber.armor_modifier_near.attack = { 1, 1.25, 1.5, 1, 0.75, 0.25 }

Weapons.staff_spark_spear_template_1.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.staff_spark_spear_template_1.actions.action_two.default.default_zoom = "zoom_in_trueflight"
Weapons.staff_spark_spear_template_1.actions.action_two.default.zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }
Weapons.staff_spark_spear_template_1.actions.action_two.default.zoom_condition_function = function ()
	return true
end
--ActionHandgun.client_owner_start_action
--Beam
DamageProfileTemplates.beam_shot.default_target.power_distribution_near.attack = 0.85
Weapons.staff_blast_beam_template_1.actions.action_two.default.aim_zoom_delay = 0.01
Weapons.staff_blast_beam_template_1.actions.action_one.default.default_zoom = "zoom_in"
Weapons.staff_blast_beam_template_1.actions.action_one.default.zoom_thresholds = { "zoom_in_trueflight", "zoom_in" }
Weapons.staff_blast_beam_template_1.actions.action_one.default.zoom_condition_function = function ()
	return true
end

PlayerUnitStatusSettings.overcharge_values.beam_staff_shotgun = 5
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.spread_template_override = "spear"
Weapons.staff_blast_beam_template_1.actions.action_two.charged_beam.damage_window_start = 0.01
Weapons.staff_blast_beam_template_1.actions.action_one.shoot_charged.damage_profile = "beam_blast"
NewDamageProfileTemplates.beam_blast = {
	charge_value = "projectile",
	no_stagger_damage_reduction_ranged = true,
	dot_template_name = "burning_1W_dot",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.2,
			1,
			1,
			0.7,
			0.15
		},
		impact_armor_power_modifer = {
			1,
			0.8,
			1,
			1,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			1,
			0,
			1,
			1,
			0.6,
			0
		},
		impact = {
			1,
			0.25,
			1,
			1,
			1,
			0
		}
	},
	cleave_distribution = {
		attack = 0.05,
		impact = 0.05
	},
	default_target = {
		boost_curve_coefficient_headshot = 2,
		boost_curve_type = "linesman_curve",
		boost_curve_coefficient = 0.5,
		attack_template = "flame_blast",
		power_distribution_near = {
			attack = 0.1,
			impact = 0.275
		},
		power_distribution_far = {
			attack = 0.05,
			impact = 0.15
		},
		range_dropoff_settings = carbine_dropoff_ranges
	}
}

local INDEX_POSITION = 1
local INDEX_ACTOR = 4

mod:hook_origin(ActionBeam, "client_owner_post_update", function(self, dt, t, world, can_damage)
	local owner_unit = self.owner_unit
	local current_action = self.current_action
	local is_server = self.is_server
	local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")
	local buff_extension = self.owner_buff_extension
	local status_extension = self.status_extension

	if current_action.zoom_thresholds and input_extension:get("action_three") then
		status_extension:switch_variable_zoom(current_action.buffed_zoom_thresholds)
	end

	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	self.overcharge_timer = self.overcharge_timer + dt

	if current_action.overcharge_interval <= self.overcharge_timer then
		local overcharge_amount = PlayerUnitStatusSettings.overcharge_values.charging

		self.overcharge_extension:add_charge(overcharge_amount)

		self._is_critical_strike = ActionUtils.is_critical_strike(owner_unit, current_action, t)
		self.overcharge_timer = 0
		self.overcharge_target_hit = false
	end

	if self.state == "shooting" then
		if not Managers.player:owner(self.owner_unit).bot_player and not self._rumble_effect_id then
			self._rumble_effect_id = Managers.state.controller_features:add_effect("persistent_rumble", {
				rumble_effect = "reload_start"
			})
		end

		local first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
		local current_position, current_rotation = first_person_extension:get_projectile_start_position_rotation()
		local direction = Quaternion.forward(current_rotation)
		local physics_world = World.get_data(self.world, "physics_world")
		local range = current_action.range or 30
		local result = PhysicsWorld.immediate_raycast_actors(physics_world, current_position, direction, range, "static_collision_filter", "filter_player_ray_projectile_static_only", "dynamic_collision_filter", "filter_player_ray_projectile_ai_only", "dynamic_collision_filter", "filter_player_ray_projectile_hitbox_only")
		local beam_end_position = current_position + direction * range
		local hit_unit, hit_position = nil

		if result then
			local difficulty_settings = Managers.state.difficulty:get_difficulty_settings()
			local owner_player = self.owner_player
			local allow_friendly_fire = DamageUtils.allow_friendly_fire_ranged(difficulty_settings, owner_player)

			for _, hit_data in pairs(result) do
				local potential_hit_position = hit_data[INDEX_POSITION]
				local hit_actor = hit_data[INDEX_ACTOR]
				local potential_hit_unit = Actor.unit(hit_actor)
				potential_hit_unit, hit_actor = ActionUtils.redirect_shield_hit(potential_hit_unit, hit_actor)

				if potential_hit_unit ~= owner_unit then
					local breed = Unit.get_data(potential_hit_unit, "breed")
					local hit_enemy = nil

					if breed then
						local is_enemy = DamageUtils.is_enemy(owner_unit, potential_hit_unit)
						local node = Actor.node(hit_actor)
						local hit_zone = breed.hit_zones_lookup[node]
						local hit_zone_name = hit_zone.name
						hit_enemy = (allow_friendly_fire or is_enemy) and hit_zone_name ~= "afro"
					else
						hit_enemy = true
					end

					if hit_enemy then
						hit_position = potential_hit_position - direction * 0.15
						hit_unit = potential_hit_unit

						break
					end
				end
			end

			if hit_position then
				beam_end_position = hit_position
			end

			if hit_unit then
				local health_extension = ScriptUnit.has_extension(hit_unit, "health_system")

				if health_extension then
					if hit_unit ~= self.current_target then
						self.ramping_interval = 0.4
						self.damage_timer = 0
						self._num_hits = 0
					end

					if self.damage_timer >= current_action.damage_interval * self.ramping_interval then
						Managers.state.entity:system("ai_system"):alert_enemies_within_range(owner_unit, POSITION_LOOKUP[owner_unit], 5)

						self.damage_timer = 0

						if health_extension then
							self.ramping_interval = math.clamp(self.ramping_interval * 1.4, 0.45, 1.5)
						end
					end

					if self.damage_timer == 0 then
						local is_critical_strike = self._is_critical_strike
						local hud_extension = ScriptUnit.has_extension(owner_unit, "hud_system")

						self:_handle_critical_strike(is_critical_strike, buff_extension, hud_extension, first_person_extension, "on_critical_shot", nil)

						if health_extension then
							local override_damage_profile = nil
							local power_level = self.power_level
							power_level = power_level * self.ramping_interval

							if hit_unit ~= self.current_target then
								self.consecutive_hits = 0
								power_level = power_level * 0.5
								override_damage_profile = current_action.initial_damage_profile or current_action.damage_profile or "default"
							else
								self.consecutive_hits = self.consecutive_hits + 1

								if self.consecutive_hits < 3 then
									override_damage_profile = current_action.initial_damage_profile or current_action.damage_profile or "default"
								end
							end

							first_person_extension:play_hud_sound_event("staff_beam_hit_enemy", nil, false)

							local check_buffs = self._num_hits > 1

							DamageUtils.process_projectile_hit(world, self.item_name, owner_unit, is_server, result, current_action, direction, check_buffs, nil, nil, self._is_critical_strike, power_level, override_damage_profile)

							self._num_hits = self._num_hits + 1

							if not Managers.player:owner(self.owner_unit).bot_player then
								Managers.state.controller_features:add_effect("rumble", {
									rumble_effect = "hit_character_light"
								})
							end

							if health_extension:is_alive() then
								local overcharge_amount = PlayerUnitStatusSettings.overcharge_values[current_action.overcharge_type]

								if is_critical_strike and buff_extension:has_buff_perk("no_overcharge_crit") then
									overcharge_amount = 0
								end

								self.overcharge_extension:add_charge(overcharge_amount * self.ramping_interval)
							end
						end
					end

					self.damage_timer = self.damage_timer + dt
					self.current_target = hit_unit
				end
			end
		end

		if self.beam_effect_id then
			local weapon_unit = self.weapon_unit
			local end_of_staff_position = Unit.world_position(weapon_unit, Unit.node(weapon_unit, "fx_muzzle"))
			local distance = Vector3.distance(end_of_staff_position, beam_end_position)
			local beam_direction = Vector3.normalize(end_of_staff_position - beam_end_position)
			local rotation = Quaternion.look(beam_direction)

			World.move_particles(world, self.beam_effect_id, beam_end_position, rotation)
			World.set_particles_variable(world, self.beam_effect_id, self.beam_effect_length_id, Vector3(0.3, distance, 0))
			World.move_particles(world, self.beam_end_effect_id, beam_end_position, rotation)
		end
	end
end)

--New Damage Profiles
--Masterwork pistol
local burst_dropoff = {
	dropoff_start = 1,
	dropoff_end = 15
}
NewDamageProfileTemplates.shot_sniper_pistol_burst = {
	charge_value = "instant_projectile",
	no_stagger_damage_reduction_ranged = true,
	shield_break = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.35,
			1.5,
			1,
			0.4,
			0
		},
		impact_armor_power_modifer = {
			1,
			1,
			1,
			1,
			1,
			0
		}
	},
	armor_modifier_near = {
		attack = {
			1,
			0.35,
			1,
			1,
			0.4,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			0.35,
			1,
			1,
			0.4,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			0
		}
	},
	cleave_distribution = {
		attack = 0.5,
		impact = 0.5
	},
	default_target = {
		headshot_boost_boss = 0.5,
		boost_curve_coefficient_headshot = 0.75,
		boost_curve_type = "smiter_curve",
		boost_curve_coefficient = 1,
		attack_template = "shot_sniper",
		power_distribution_near = {
			attack = 1.225,
			impact = 0.5
		},
		power_distribution_far = {
			attack = 0.01,
			impact = 0.5
		},
		range_dropoff_settings = burst_dropoff
	}
}
NewDamageProfileTemplates.mace_sword_bopp = {
	stagger_duration_modifier = 1.5,
	charge_value = "light_attack",
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			2,
			1,
			1
		},
		impact_armor_power_modifer = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	cleave_distribution = {
		attack = 0.2,
		impact = 0.2
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			2.5,
			1,
			0.9,
			0.5
		},
		impact = {
			1,
			1,
			0.5,
			1,
			1
		}
	},
	default_target = {
		boost_curve_type = "tank_curve",
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.075,
			impact = 0.075
		}
	},
	targets = {
		{
			boost_curve_type = "tank_curve",
			attack_template = "blunt_tank",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			}
		},
		{
			boost_curve_type = "tank_curve",
			attack_template = "light_blunt_tank",
			power_distribution = {
				attack = 0.075,
				impact = 0.1
			}
		}
	},
}
NewDamageProfileTemplates.mace_sword_heavy = {
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.5,
			1,
			0.75,
			0.5
		},
		impact = {
			1,
			0.3,
			0.5,
			1,
			1
		}
	},
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.5,
			1.5,
			1,
			0.6,
			0.5
		},
		impact_armor_power_modifer = {
			0.9,
			0.5,
			1,
			1,
			0.75
		}
	},
    charge_value = "heavy_attack",
    cleave_distribution = {
        attack = 0.15,
        impact = 0.3
    },
    default_target = {
        boost_curve_type = "linesman_curve",
        attack_template = "light_slashing_linesman",
        power_distribution = {
            attack = 0.075,
            impact = 0.075
        }
    },
	targets = {
		{
			boost_curve_coefficient_headshot = 2,
			boost_curve_type = "linesman_curve",
			attack_template = "heavy_slashing_linesman",
			power_distribution = {
				attack = 0.275,
				impact = 0.2
			},
			armor_modifier = {
				attack = {
					1,
					0.5,
					1.5,
					1,
					0.75,
					0.5
				},
				impact = {
					1,
					0.5,
					1,
					1,
					0.75
				}
			}
		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "slashing_linesman",
			power_distribution = {
				attack = 0.2,
				impact = 0.125
			},

		},
		{
			boost_curve_type = "linesman_curve",
			attack_template = "light_slashing_linesman",
			power_distribution = {
				attack = 0.1,
				impact = 0.1
			}
		}
	},
	melee_boost_override = 6
}


--Burn and explosion Stuff------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NewDamageProfileTemplates.long_burn_explosion = {
	charge_value = "grenade",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			0.8,
			0.25,
			1,
			0.6,
			0.6,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	default_target = {
		dot_template_name = "long_burn_low_damage",
		damage_type = "drakegun",
		attack_template = "drakegun",
		power_distribution = {
			attack = 0.1,
			impact = 0
		}
	}
}
NewDamageProfileTemplates.long_burn_explosion_glance = {
	charge_value = "grenade",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			0,
			0,
			0,
			0,
			0
		},
		impact = {
			1,
			0.5,
			0,
			1,
			1
		}
	},
	default_target = {
		dot_template_name = "long_burn_low_damage",
		damage_type = "drakegun",
		attack_template = "drakegun",
		power_distribution = {
			attack = 0,
			impact = 0.1
		}
	}
}
NewDamageProfileTemplates.melee_kill_explosion = {
	charge_value = "grenade",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.25,
			1,
			0.6,
			0.6,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	},
	default_target = {
		dot_template_name = "long_burn_extra_low_damage",
		damage_type = "grenade",
		attack_template = "drakegun",
		power_distribution = {
			attack = 0.15,
			impact = 0
		}
	}
}
NewDamageProfileTemplates.melee_kill_explosion_glance = {
	charge_value = "grenade",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			0,
			0,
			0,
			0,
			0
		},
		impact = {
			1,
			0.5,
			0,
			1,
			1
		}
	},
	default_target = {
		dot_template_name = "long_burn_extra_low_damage",
		damage_type = "grenade",
		attack_template = "drakegun",
		power_distribution = {
			attack = 0.1,
			impact = 0
		}
	}
}
NewDamageProfileTemplates.dot_low_damage = {
	charge_value = "n/a",
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25
	},
	armor_modifier = {
		attack = {
			0.2,
			0.1,
			0.4,
			1,
			0.2,
			0
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.5,
			0
		}
	},
	default_target = {
		damage_type = "burninating",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient = 0.2,
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.1,
			impact = 0.1
		},
		armor_modifier = {
			attack = {
				0.2,
				0.1,
				0.4,
				1,
				0.2,
				0
			},
			impact = {
				1,
				0,
				0,
				1,
				1,
				0
			}
		},
		no_stagger = true,
		is_dot = true,
		no_stagger_damage_reduction_ranged = true,
	}
}
NewDamageProfileTemplates.handmaiden_banner_explosion_damage = {
	charge_value = "ability",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.2,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			0.5,
			0.5,
			1,
			0.5,
			1.5,
			0.5
		}
	},
	default_target = {
		attack_template = "flame_blast",
		damage_type = "burn_shotgun",
		power_distribution = {
			attack = 0.05,
			impact = 1
		}
	}
}
NewDamageProfileTemplates.warrior_priest_explosion_damage = {
	charge_value = "ability",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.2,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			1,
			100,
			1,
			1.5,
			1
		}
	},
	cleave_distribution = {
		attack = 1,
		impact = 1
	},
	default_target = {
		stagger_duration_modifier = 2,
		attack_template = "flame_blast",
		damage_type = "burn_shotgun",
		power_distribution = {
			attack = 0.2,
			impact = 2
		}
	}
}
NewDamageProfileTemplates.warrior_priest_explosion_damage_strong = {
	charge_value = "ability",
	is_explosion = true,
	no_stagger_damage_reduction_ranged = true,
	armor_modifier = {
		attack = {
			1,
			0.2,
			1.5,
			1,
			0.75,
			0
		},
		impact = {
			1,
			1,
			1,
			1,
			1.5,
			1
		}
	},
	cleave_distribution = {
		attack = 0,
		impact = 1
	},
	default_target = {
		stagger_duration_modifier = 2,
		attack_template = "flame_blast",
		damage_type = "burn_shotgun",
		power_distribution = {
			attack = 0.25,
			impact = 1
		}
	}
}
NewDamageProfileTemplates.dot_low_low_damage = {
	charge_value = "n/a",
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25
	},
	armor_modifier = {
		attack = {
			0.2,
			0.1,
			0.4,
			1,
			0.2,
			0
		},
		impact = {
			1,
			0.5,
			1,
			1,
			0.5,
			0
		}
	},
	default_target = {
		damage_type = "burninating",
		boost_curve_type = "tank_curve",
		boost_curve_coefficient = 0.2,
		attack_template = "light_blunt_tank",
		power_distribution = {
			attack = 0.05,
			impact = 0.1
		},
		armor_modifier = {
			attack = {
				0.2,
				0.1,
				0.4,
				1,
				0.2,
				0
			},
			impact = {
				1,
				0,
				0,
				1,
				1,
				0
			}
		},
		no_stagger = true,
		is_dot = true,
		no_stagger_damage_reduction_ranged = true,
	}
}
NewDamageProfileTemplates.heavy_poison_aoe = {
	is_dot = true,
	charge_value = "aoe",
	require_damage_for_dot = true,
	no_stagger_damage_reduction_ranged = true,
	no_stagger = false,
	armor_modifier = {
		attack = {
			1.25,
			0,
			1.5,
			1,
			1,
			0
		},
		impact = {
			1,
			0.75,
			1,
			1,
			0.5,
			0
		}
	},
	default_target = {
		attack_template = "arrow_poison_aoe",
		dot_template_name = "aoe_heavy_poison_dot",
		damage_type = "poison",
		power_distribution = {
			attack = 0.05,
			impact = 0.5
		}
	}
}
NewDamageProfileTemplates.heavy_poison = {
	is_dot = true,
	charge_value = "n/a",
	no_stagger_damage_reduction_ranged = true,
	no_stagger = true,
	cleave_distribution = {
		attack = 0.25,
		impact = 0.25
	},
	armor_modifier = {
		attack = {
			1,
			1,
			3,
			1,
			0.5,
			0.2
		},
		impact = {
			1,
			1,
			3,
			1,
			0.5,
			0
		}
	},
	default_target = {
		attack_template = "arrow_poison_aoe",
		damage_type = "arrow_poison_dot",
		power_distribution = {
			attack = 0.035,
			impact = 0
		}
	}
}
NewDamageProfileTemplates.dummy = {
	armor_modifier = "armor_modifier_push_Ability",
	is_explosion = true,
	charge_value = "ability",
	cleave_distribution = "cleave_distribution_push_default",
	default_target = {
		stagger_duration_modifier = 1,
		damage_type = "push",
		boost_curve_type = "default",
		attack_template = "ability_push",
		power_distribution = {
			attack = 0.01,
			impact = 0
	},
	no_friendly_fire = true
}
}
SpreadTemplates.rake_shot.contious = {
	still = {
		max_yaw = 8,
		max_pitch = 6.5
	},
	moving = {
		max_yaw = 8,
		max_pitch = 6.5
	},
	crouch_still = {
		max_yaw = 8,
		max_pitch = 6.5
	},
	crouch_moving = {
		max_yaw = 8,
		max_pitch = 6.5
	},
	zoomed_still = {
		max_yaw = 0,
		max_pitch = 0
	},
	zoomed_moving = {
		max_yaw = 0.4,
		max_pitch = 0.4
	},
	zoomed_crouch_still = {
		max_yaw = 0,
		max_pitch = 0
	},
	zoomed_crouch_moving = {
		max_yaw = 0.4,
		max_pitch = 0.4
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default = {
	aim_assist_ramp_decay_delay = 0.1,
	anim_end_event = "attack_finished",
	kind = "melee_start",
	attack_hold_input = "action_one_hold",
	aim_assist_max_ramp_multiplier = 0.4,
	aim_assist_ramp_multiplier = 0.2,
	anim_event = "attack_swing_charge",
	anim_end_event_condition_func = function (unit, end_reason)
		return end_reason ~= "new_interupting_action" and end_reason ~= "action_complete"
	end,
	total_time = math.huge,
	buff_data = {
		{
			start_time = 0,
			external_multiplier = 0.6,
			buff_name = "planted_charging_decrease_movement"
		}
	},
	allowed_chain_actions = {
		{
			sub_action = "light_attack_left",
			start_time = 0,
			end_time = 0.3,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 0.6,
			end_time = 1.2,
			action = "action_one",
			input = "action_one_release"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_two",
			input = "action_two_hold"
		},
		{
			sub_action = "default",
			start_time = 0,
			action = "action_wield",
			input = "action_wield"
		},
		{
			start_time = 0.6,
			end_time = 1.2,
			blocker = true,
			input = "action_one_hold"
		},
		{
			sub_action = "heavy_attack_left",
			start_time = 1,
			action = "action_one",
			auto_chain = true
		}
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_left.allowed_chain_actions = {
	{
		sub_action = "light_attack_right",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time =1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_right.allowed_chain_actions = {
	{
		sub_action = "light_attack_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_left",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.default_last.allowed_chain_actions = {
	{
		sub_action = "light_attack_up_right_last",
		start_time = 0,
		end_time = 0.3,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_release"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		action = "action_wield",
		input = "action_wield"
	},
	{
		start_time = 0.6,
		end_time = 1.2,
		blocker = true,
		input = "action_one_hold"
	},
	{
		sub_action = "heavy_attack_right",
		start_time = 1,
		action = "action_one",
		auto_chain = true
	}
}
--Lights 1/2/3/4
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.anim_event = "attack_swing_up_pose"
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_left.baked_sweep = {
	{
		0.31666666666666665,
		0.3103722333908081,
		0.5904569625854492,
		-0.2657968997955322,
		0.7223937511444092,
		-0.29107052087783813,
		0.5494855046272278,
		0.302474707365036
	},
	{
		0.35277777777777775,
		0.1775137186050415,
		0.6366815567016602,
		-0.19225668907165527,
		0.7879757285118103,
		-0.14280153810977936,
		0.5783776640892029,
		0.1555033177137375
	},
	{
		0.3888888888888889,
		0.051915526390075684,
		0.6041536331176758,
		-0.08548450469970703,
		0.8273890018463135,
		-0.0234444011002779,
		0.5306860208511353,
		-0.18234620988368988
	},
	{
		0.425,
		-0.12680041790008545,
		0.4566812515258789,
		-0.04089641571044922,
		0.6963638663291931,
		0.19201868772506714,
		0.41889646649360657,
		-0.5502110719680786
	},
	{
		0.46111111111111114,
		-0.26615601778030396,
		0.21436119079589844,
		-0.12140655517578125,
		0.37910813093185425,
		0.4430711269378662,
		0.2820264995098114,
		-0.7618570327758789
	},
	{
		0.49722222222222223,
		-0.1962783932685852,
		0.1402301788330078,
		-0.22664093971252441,
		0.17541848123073578,
		0.5380390882492065,
		0.08140674978494644,
		-0.8204360008239746
	},
	{
		0.5333333333333333,
		-0.13591063022613525,
		0.1464986801147461,
		-0.29386401176452637,
		0.0605529323220253,
		0.579397976398468,
		-0.1304379105567932,
		-0.8022575974464417
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_last.allowed_chain_actions = {
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_last",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_up_right_last.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		end_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.6,
		action = "action_wield",
		input = "action_wield"
	}
}
--Pushstab
Weapons.two_handed_cog_hammers_template_1.actions.action_one.push.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_one",
		release_required = "action_two_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "light_attack_bopp",
		start_time = 0.4,
		action = "action_one",
		end_time = 0.8,
		input = "action_one_hold",
		hold_required = {
			"action_two_hold",
			"action_one_hold"
		}
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_two",
		send_buffer = true,
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.4,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.light_attack_bopp.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.75,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 1.5,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.65,
		action = "action_wield",
		input = "action_wield"
	}
}
--Heavies
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_left.allowed_chain_actions = {
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_left",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2.2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}
Weapons.two_handed_cog_hammers_template_1.actions.action_one.heavy_attack_right.allowed_chain_actions = {
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one"
	},
	{
		sub_action = "default_right",
		start_time = 0.6,
		action = "action_one",
		release_required = "action_one_hold",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one"
	},
	{
		sub_action = "default",
		start_time = 2,
		action = "action_one",
		input = "action_one_hold"
	},
	{
		sub_action = "default",
		start_time = 0,
		end_time = 0.3,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.75,
		action = "action_two",
		input = "action_two_hold"
	},
	{
		sub_action = "default",
		start_time = 0.5,
		action = "action_wield",
		input = "action_wield"
	}
}

local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod:add_buff_template("aoe_heavy_poison_dot", {
    duration = 4,
	name = "aoe poison dot",
	start_flow_event = "poisoned",
	end_flow_event = "poisoned_end",
	death_flow_event = "poisoned_death",
	remove_buff_func = "remove_dot_damage",
	apply_buff_func = "start_dot_damage",
	update_start_delay = 0.75,
	time_between_dot_damages = 0.75,
	damage_profile = "heavy_poison",
	update_func = "apply_dot_damage",
	reapply_buff_func = "reapply_dot_damage",
	perk = buff_perks.poisoned
})
DotTypeLookup.aoe_heavy_poison_dot = "poison_dot"
--Firebomb fix
ExplosionTemplates.fire_grenade.aoe.dot_template_name = "burning_dot_fire_grenade"
ExplosionTemplates.fire_grenade.explosion.dot_template_name = "burning_dot_fire_grenade"

mod:add_buff_template("burning_dot_fire_grenade", {
	duration = 6,
	name = "burning dot",
	end_flow_event = "smoke",
	start_flow_event = "burn",
	death_flow_event = "burn_death",
	 update_start_delay = 0.75,
	remove_buff_func = "remove_dot_damage",
	apply_buff_func = "start_dot_damage",
	time_between_dot_damages = 1,
	damage_type = "burninating",
	damage_profile = "burning_dot_firegrenade",
	update_func = "apply_dot_damage",
	perk = buff_perks.burning
})

DamageProfileTemplates.burning_dot_firegrenade.default_target.armor_modifier.attack = { 0.9, 0.15, 2, 1, 0.6, 0.1 }

--Moonbow
Weapons.we_deus_01_template_1.weapon_type = "DRAKEFIRE"
Weapons.we_deus_01_template_1.weapon_type_bow = true
Weapons.we_deus_01_template_1.actions.action_two.default.kind = "career_true_flight_aim"
Weapons.we_deus_01_template_1.actions.action_two.default.aim_time = 0
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.kind = "true_flight_bow"
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.kind = "true_flight_bow"
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.energy_weapon = true
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.energy_weapon = true
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.true_flight_template = "active_ability_kerillian_way_watcher"
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.true_flight_template = "active_ability_kerillian_way_watcher"
Weapons.we_deus_01_template_1.actions.action_two.default.anim_time_scale = 0.75
Weapons.we_deus_01_template_1.actions.action_two.default.allowed_chain_actions = {
	{
		sub_action = "default",
		start_time = 0.3,
		action = "action_wield",
		input = "action_wield",
		end_time = math.huge
	},
	{
		sub_action = "shoot_special_charged",
		start_time = 0.5,
		action = "action_one",
		end_time = 0.85,
		input = "action_one"
	},
	{
		sub_action = "shoot_charged",
		start_time = 0.85,
		action = "action_one",
		input = "action_one",
		end_time = math.huge
	},
	{
		softbutton_threshold = 0.75,
		start_time = 0.7,
		action = "action_one",
		sub_action = "shoot_charged",
		input = "action_one_softbutton_gamepad",
		end_time = math.huge
	},
	{
		sub_action = "default",
		start_time = 0.85,
		action = "weapon_reload",
		input = "weapon_reload"
	}
}
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}
mod:hook_origin(PlayerUnitEnergyExtension, "_process_recharge", function (self, dt, t)
	local recharge_rate = self._recharge_rate
	local unit = self.unit
	local talent_extension = ALIVE[unit] and ScriptUnit.extension(unit, "talent_system")

	if talent_extension:has_talent("kerillian_maidenguard_max_ammo") then
		recharge_rate = recharge_rate * 1.33
	end

	self._energy = math.clamp(self._energy + recharge_rate * dt, 0, self._max_energy)
end)

EnergyData.we_waywatcher = {
	recharge_delay = 0.2,
	max_value = 50,
	depletion_cooldown = 15,
	recharge_rate = 0.4
}
EnergyData.we_maidenguard = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 15,
	recharge_rate = 0.4
}
EnergyData.we_shade = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 15,
	recharge_rate = 0.4
}
EnergyData.we_thornsister = {
	recharge_delay = 0.2,
	max_value = 25,
	depletion_cooldown = 15,
	recharge_rate = 0.4
}
Weapons.we_deus_01_template_1.actions.action_one.default.drain_amount = 3
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.drain_amount = 9
Weapons.we_deus_01_template_1.actions.action_one.shoot_charged.drain_amount = 9
Weapons.we_deus_01_template_1.actions.action_one.shoot_special_charged.impact_data.damage_profile = "we_deus_01_charged"


DamageProfileTemplates.we_deus_01_charged = {
	charge_value = "projectile",
	allow_dot_finesse_hit = true,
	no_stagger_damage_reduction_ranged = true,
	require_damage_for_dot = true,
	ignore_stagger_reduction = true,
	critical_strike = {
		attack_armor_power_modifer = {
			1,
			0.7,
			1.35,
			0.75,
			1,
			0.25
		},
		impact_armor_power_modifer = {
			1,
			0.7,
			1,
			0.75,
			1,
			0.25
		}
	},
	armor_modifier = {
		attack = {
			1,
			0.5,
			1.35,
			0.5,
			0.75,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			0.5,
			0.75,
			0.25
		}
	},
	armor_modifier_far = {
		attack = {
			1,
			0.5,
			1.35,
			0.5,
			0.75,
			0.25
		},
		impact = {
			1,
			0.5,
			1,
			0.75,
			0.75,
			0.25
		}
	},
	cleave_distribution = {
		attack = 0.15,
		impact = 0.15
	},
	default_target = {
		boost_curve_coefficient_headshot = 1.5,
		dot_template_name = "we_deus_01_dot_special_charged",
		boost_curve_type = "ninja_curve",
		boost_curve_coefficient = 0.75,
		attack_template = "arrow_carbine",
		power_distribution_near = {
			attack = 0.8,
			impact = 0.3
		},
		power_distribution_far = {
			attack = 0.8,
			impact = 0.25
		},
		range_dropoff_settings = carbine_dropoff_ranges
	}
}
BuffTemplates.we_deus_01_dot_special_charged.buffs[1].ticks = 3

--Weapons.longbow_template_1.actions.action_two.default.kind = "career_true_flight_aim"
--Weapons.longbow_template_1.actions.action_two.default.aim_time = 0
--Weapons.longbow_template_1.actions.action_one.shoot_special_charged.kind = "true_flight_bow"
--Weapons.longbow_template_1.actions.action_one.shoot_charged.kind = "true_flight_bow"
--Weapons.longbow_template_1.actions.action_one.shoot_special_charged.true_flight_template = "sniper"
--Weapons.longbow_template_1.actions.action_one.shoot_charged.true_flight_template = "sniper"
--Weapons.longbow_template_1.actions.action_one.shoot_special_charged.prioritized_breeds = {
--    beastmen_bestigor = 1,
--    skaven_plague_monk = 1,
--    chaos_raider = 1,
--    chaos_warrior = 1,
--    chaos_berzerker = 1,
--    skaven_warpfire_thrower = 1,
--    chaos_vortex_sorcerer = 1,
--    skaven_gutter_runner = 1,
--    skaven_pack_master = 1,
--    skaven_poison_wind_globadier = 1,
--    chaos_corruptor_sorcerer = 1,
--    skaven_ratling_gunner = 1,
--    skaven_storm_vermin_commander = 1,
--    skaven_storm_vermin = 1,
--    beastmen_standard_bearer = 1,
--    skaven_storm_vermin_with_shield = 1,
--    chaos_troll = 1,
--    chaos_spawn = 1,
--    skaven_rat_ogre = 1,
--    skaven_stormfiend = 1,
--    beastmen_minotaur = 1
--}
--Weapons.longbow_template_1.actions.action_one.shoot_charged.prioritized_breeds = {
--    beastmen_bestigor = 1,
--    skaven_plague_monk = 1,
--    chaos_raider = 1,
--    chaos_warrior = 1,
--    chaos_berzerker = 1,
--    skaven_warpfire_thrower = 1,
--    chaos_vortex_sorcerer = 1,
--    skaven_gutter_runner = 1,
--    skaven_pack_master = 1,
--    skaven_poison_wind_globadier = 1,
--    chaos_corruptor_sorcerer = 1,
--    skaven_ratling_gunner = 1,
--    skaven_storm_vermin_commander = 1,
--    skaven_storm_vermin = 1,
--    beastmen_standard_bearer = 1,
--    skaven_storm_vermin_with_shield = 1,
--    chaos_troll = 1,
--    chaos_spawn = 1,
--    skaven_rat_ogre = 1,
--    skaven_stormfiend = 1,
--    beastmen_minotaur = 1
--}
mod:hook_origin(ActionTrueFlightBow, "client_owner_start_action", function(self, new_action, t, chain_action_data, power_level, action_init_data)
	ActionTrueFlightBow.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	self.current_action = new_action
	self.true_flight_template_id = TrueFlightTemplates[new_action.true_flight_template].lookup_id
	local is_moonbow = false
	if new_action and new_action.drain_amount then
		is_moonbow = true
	end

	assert(self.true_flight_template_id)

	local owner_unit = self.owner_unit
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local is_critical_strike = ActionUtils.is_critical_strike(owner_unit, new_action, t)
	local num_extra_shots = self:_update_extra_shots(buff_extension) or 0
	self.num_extra_shots = num_extra_shots

	self:_update_extra_shots(buff_extension, num_extra_shots)

	self.num_projectiles = (new_action.num_projectiles or 1) + num_extra_shots
	local talent_extension = ScriptUnit.has_extension(owner_unit, "talent_system")

	if new_action.true_flight_template == "active_ability_kerillian_way_watcher" and talent_extension:has_talent("kerillian_waywatcher_activated_ability_additional_projectile") and not is_moonbow then
		self.num_projectiles = self.num_projectiles + 2
	end

	self.multi_projectile_spread = new_action.multi_projectile_spread or 0.075
	self.num_projectiles_shot = 1

	if chain_action_data then
		self.targets = chain_action_data.targets

		if not self.targets then
			self.targets = {
				chain_action_data.target
			}
		end
	end

	if action_init_data then
		self.targets = action_init_data.targets

		if not self.targets then
			self.targets = {
				action_init_data.target
			}
		end
	end

	self.state = "waiting_to_shoot"
	self.time_to_shoot = t + (new_action.fire_time or 0)
	self.power_level = power_level
	self.extra_buff_shot = false
	self.owner_buff_extension = buff_extension
	local hud_extension = ScriptUnit.has_extension(owner_unit, "hud_system")

	self:_handle_critical_strike(is_critical_strike, buff_extension, hud_extension, nil, "on_critical_shot", nil)

	self._is_critical_strike = is_critical_strike
end)


mod:hook_origin(ActionTrueFlightBow, "fire", function (self, current_action, add_spread)
	local owner_unit = self.owner_unit
	local speed = current_action.speed
	local first_person_extension = self.first_person_extension
	local position, rotation = first_person_extension:get_projectile_start_position_rotation()
	local spread_extension = self.spread_extension
	local num_projectiles = self.num_projectiles

	for i = 1, num_projectiles, 1 do
		local fire_rotation = rotation

		if spread_extension then
			if self.num_projectiles_shot > 1 then
				local spread_horizontal_angle = math.pi * (self.num_projectiles_shot % 2 + 0.5)
				local shot_count_offset = (self.num_projectiles_shot == 1 and 0) or math.round((self.num_projectiles_shot - 1) * 0.5, 0)
				local angle_offset = self.multi_projectile_spread * shot_count_offset
				fire_rotation = spread_extension:combine_spread_rotations(spread_horizontal_angle, angle_offset, fire_rotation)
			end

			if add_spread then
				spread_extension:set_shooting()
			end
		end

		local angle = ActionUtils.pitch_from_rotation(fire_rotation)
		local target_vector = Vector3.normalize(Quaternion.forward(fire_rotation))

		if i > 1 then
			speed = speed * (1 - i * 0.05)
		end

		local target_unit = self.targets and ((current_action.single_target and self.targets[1]) or self.targets[i])
		local lookup_data = current_action.lookup_data
		local scale = 1

		ActionUtils.spawn_true_flight_projectile(owner_unit, target_unit, self.true_flight_template_id, position, fire_rotation, angle, target_vector, speed, self.item_name, lookup_data.item_template_name, lookup_data.action_name, lookup_data.sub_action_name, scale, self._is_critical_strike, self.power_level)

		if self.ammo_extension and not self.extra_buff_shot then
			local ammo_usage = self.current_action.ammo_usage

			self.ammo_extension:use_ammo(ammo_usage)

			if self.ammo_extension:can_reload() then
				local play_reload_animation = false

				self.ammo_extension:start_reload(play_reload_animation)
			end
		end

		self.num_projectiles_shot = self.num_projectiles_shot + 1
		local overcharge_type = current_action.overcharge_type

		if overcharge_type and not self.extra_buff_shot then
			local overcharge_amount = PlayerUnitStatusSettings.overcharge_values[overcharge_type]

			if current_action.scale_overcharge then
				self.overcharge_extension:add_charge(overcharge_amount, self.charge_level)
			else
				self.overcharge_extension:add_charge(overcharge_amount)
			end
		end

		if current_action.energy_weapon and not self.extra_buff_shot then
			local drain_amount = current_action.drain_amount

			local energy_extension = ScriptUnit.extension(owner_unit, "energy_system")
			energy_extension:drain(drain_amount)
		end

		if current_action.alert_sound_range_fire then
			Managers.state.entity:system("ai_system"):alert_enemies_within_range(owner_unit, POSITION_LOOKUP[owner_unit], current_action.alert_sound_range_fire)
		end
	end
end)