local mod = get_mod("Weapon Balance")

-- Buff and Talent Functions
local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end
function mod.add_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end
    TalentBuffTemplates[hero_name][buff_name] = new_talent_buff
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.modify_talent_buff_template(self, hero_name, buff_name, buff_data, extra_data)
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    if extra_data then
        new_talent_buff = merge(new_talent_buff, extra_data)
    elseif type(buff_data[1]) == "table" then
        new_talent_buff = {
            buffs = buff_data,
        }
        if new_talent_buff.buffs[1].name == nil then
            new_talent_buff.buffs[1].name = buff_name
        end
    end

    local original_buff = TalentBuffTemplates[hero_name][buff_name]
    local merged_buff = original_buff
    for i=1, #original_buff.buffs do
        if new_talent_buff.buffs[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs[i])
        elseif original_buff[i] then
            merged_buff.buffs[i] = merge(original_buff.buffs[i], new_talent_buff.buffs)
        else
            merged_buff.buffs = merge(original_buff.buffs, new_talent_buff.buffs)
        end
    end

    TalentBuffTemplates[hero_name][buff_name] = merged_buff
    BuffTemplates[buff_name] = merged_buff
end
function mod.add_buff_template(self, buff_name, buff_data)
    local new_talent_buff = {
        buffs = {
            merge({ name = buff_name }, buff_data),
        },
    }
    BuffTemplates[buff_name] = new_talent_buff
    local index = #NetworkLookup.buff_templates + 1
    NetworkLookup.buff_templates[index] = buff_name
    NetworkLookup.buff_templates[buff_name] = index
end
function mod.add_proc_function(self, name, func)
    ProcFunctions[name] = func
end
function mod.add_buff_function(self, name, func)
    BuffFunctionTemplates.functions[name] = func
end
function mod.add_talent(self, career_name, tier, index, new_talent_name, new_talent_data)
    local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
    local talent_tree_index = career_settings.talent_tree_index

    local new_talent_index = #Talents[hero_name] + 1

    Talents[hero_name][new_talent_index] = merge({
        name = new_talent_name,
        description = new_talent_name .. "_desc",
        icon = "icons_placeholder",
        num_ranks = 1,
        buffer = "both",
        requirements = {},
        description_values = {},
        buffs = {},
        buff_data = {},
    }, new_talent_data)

    TalentTrees[hero_name][talent_tree_index][tier][index] = new_talent_name
    TalentIDLookup[new_talent_name] = {
        talent_id = new_talent_index,
        hero_name = hero_name
    }
end
function mod.modify_talent(self, career_name, tier, index, new_talent_data)
	local career_settings = CareerSettings[career_name]
    local hero_name = career_settings.profile_name
	local talent_tree_index = career_settings.talent_tree_index

	local old_talent_name = TalentTrees[hero_name][talent_tree_index][tier][index]
	local old_talent_id_lookup = TalentIDLookup[old_talent_name]
	local old_talent_id = old_talent_id_lookup.talent_id
	local old_talent_data = Talents[hero_name][old_talent_id]

    Talents[hero_name][old_talent_id] = merge(old_talent_data, new_talent_data)
end
function mod.add_buff(self, owner_unit, buff_name)
    if Managers.state.network ~= nil then
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit

        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
        local is_server = Managers.player.is_server

        if is_server then
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

            buff_extension:add_buff(buff_name)
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end
end

mod:add_proc_function("reduce_activated_ability_cooldown", function (player, buff, params)
	local player_unit = player.player_unit

	if Unit.alive(player_unit) then
		local attack_type = params[2]
		local target_number = params[4]
		local career_extension = ScriptUnit.extension(player_unit, "career_system")

		if not attack_type or attack_type == "heavy_attack" or attack_type == "light_attack" then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		elseif attack_type == "aoe" then
            return
		elseif target_number and target_number == 1 then
			career_extension:reduce_activated_ability_cooldown(buff.bonus)
		end
	end
end)

table.insert(PassiveAbilitySettings.we_1.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.we_2.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.we_thornsister.buffs, "kerillian_waywatcher_passive_increased_zoom")

--Waystalker Talents-------------------------------------------------------------------------------------------------------------------------
mod:hook_origin(ActionCareerWEWaywatcher, "client_owner_post_update", function (self, dt, t, world, can_damage)
    local current_action = self.current_action

	if self.state == "waiting_to_shoot" and self.time_to_shoot <= t then
		self.state = "shooting"
	end

	if self.state == "shooting" then
		local has_extra_shots = self:_update_extra_shots(self.owner_buff_extension, 1)
		local add_spread = not self.extra_buff_shot

		self:fire(current_action, add_spread)

		if has_extra_shots and has_extra_shots > 1 then
			self.state = "waiting_to_shoot"
			self.time_to_shoot = t + 0.1
			self.extra_buff_shot = true
		else
			self.state = "shot"
		end

		local first_person_extension = self.first_person_extension

		if self.current_action.reset_aim_on_attack then
			first_person_extension:reset_aim_assist_multiplier()
		end

		local fire_sound_event = self.current_action.fire_sound_event

		if fire_sound_event then
			local play_on_husk = self.current_action.fire_sound_on_husk

			first_person_extension:play_hud_sound_event(fire_sound_event, nil, play_on_husk)
		end

		if self.current_action.extra_fire_sound_event then
			local position = POSITION_LOOKUP[self.owner_unit]

			WwiseUtils.trigger_position_event(self.world, self.current_action.extra_fire_sound_event, position)
		end
	end
end)
local function is_server()
	return Managers.player.is_server
end
mod:hook_origin(ActionCareerWEWaywatcher, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	ActionCareerWEWaywatcher.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)
	self:_play_vo()

	self._cooldown_started = false
    local owner_unit = self.owner_unit
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
    local network_manager =  Managers.state.network
	local network_transmit = network_manager.network_transmit
    local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
    if talent_extension:has_talent("kerillian_waywatcher_activated_ability_restore_ammo_on_career_skill_special_kill", "wood_elf", true) then
        local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
        local buff_name = "damage_boost_potion_reduced"
        local unit_object_id = network_manager:unit_game_object_id(owner_unit)
		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

        if is_server then
            buff_extension:add_buff(buff_name, {
                attacker_unit = self.owner_unit
            })
            network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end
    end

	inventory_extension:check_and_drop_pickups("career_ability")
end)

mod:modify_talent("we_waywatcher", 6, 3, {
    buffs = {}
})

mod:add_text("kerillian_waywatcher_activated_ability_restore_ammo_on_career_skill_special_kill_desc", "Gains effect of a strenght potion when using True Flight.")

ActivatedAbilitySettings.we_3[1].cooldown = 50
local sniper_dropoff_ranges = {
	dropoff_start = 30,
	dropoff_end = 50
}
--Piercing Shot Crit FF fix
DamageProfileTemplates.arrow_sniper_ability_piercing.critical_strike.attack_armor_power_modifer = {  2.15, 1.4, 2, 0.25, 1, 1 }
DamageProfileTemplates.arrow_sniper_ability_piercing.critical_strike.impact_armor_power_modifer = {  2.15, 1.4, 2, 0.25, 1, 1}
DamageProfileTemplates.arrow_sniper_ability_piercing.armor_modifier_near.attack = { 2.15, 1.4, 2, 0.25, 1, 1 }
DamageProfileTemplates.arrow_sniper_ability_piercing.armor_modifier_near.impact = { 1, 1, 0, 0, 1, 1 }
DamageProfileTemplates.arrow_sniper_ability_piercing.armor_modifier_far.attack = { 2.15, 1.4, 2, 0.25, 1, 1 }
DamageProfileTemplates.arrow_sniper_ability_piercing.armor_modifier_far.impact = { 1, 1, 0, 0, 1, 0 }
DamageProfileTemplates.arrow_sniper_ability_piercing.default_target.boost_curve_coefficient_headshot = 2.5
DamageProfileTemplates.arrow_sniper_ability_piercing.max_friendly_damage = 30
DamageProfileTemplates.arrow_sniper_trueflight = {
    charge_value = "projectile",
    no_stagger_damage_reduction_ranged = true,
    critical_strike = {
        attack_armor_power_modifer = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact_armor_power_modifer = {
            1,
            1,
            0,
            1,
            1,
            1
        }
    },
    armor_modifier_near = {
        attack = {
            1.5,
            1,
            1,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            1
        }
    },
    armor_modifier_far = {
        attack = {
            1.5,
            1,
            2,
            0.25,
            1,
            0.6
        },
        impact = {
            1,
            1,
            0,
            0,
            1,
            0
        }
    },
    cleave_distribution = {
        attack = 0.375,
        impact = 0.375
    },
    default_target = {
        boost_curve_coefficient_headshot = 2.5,
        boost_curve_type = "ninja_curve",
        boost_curve_coefficient = 0.75,
        attack_template = "arrow_sniper",
        power_distribution_near = {
            attack = 0.5,
            impact = 0.3
        },
        power_distribution_far = {
            attack = 0.5,
            impact = 0.25
        },
        range_dropoff_settings = sniper_dropoff_ranges
    },
	max_friendly_damage = 10
}
Weapons.kerillian_waywatcher_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}

mod:add_proc_function("kerillian_waywatcher_consume_extra_shot_buff", function (player, buff, params)
    local is_career_skill = params[5]
    local should_consume_shot = nil

    if is_career_skill == "RANGED_ABILITY" or is_career_skill == nil then
        should_consume_shot = false
    else
        should_consume_shot = true
    end

    return should_consume_shot
end)
mod:modify_talent("we_waywatcher", 2, 3, {
    description_values = {
        {
            value_type = "baked_percent",
            value = 1.15
        },
        {
            value = 10
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_waywatcher_attack_speed_on_ranged_headshot_buff", {
    duration = 10,
    buffer = "server"
})

mod:add_buff_function("gs_update_kerillian_waywatcher_regen", function (unit, buff, params, world)
    local t = params.t
    local buff_template = buff.template
    local next_heal_tick = buff.next_heal_tick or 0
    local regen_cap = 1
    local network_manager = Managers.state.network
    local network_transmit = network_manager.network_transmit
    local heal_type_id = NetworkLookup.heal_types.career_skill
    local time_between_heals = buff_template.time_between_heals

    if next_heal_tick < t and Unit.alive(unit) then
        local talent_extension = ScriptUnit.extension(unit, "talent_system")
        local cooldown_talent = talent_extension:has_talent("kerillian_waywatcher_passive_cooldown_restore", "wood_elf", true)

        if cooldown_talent then
            local weapon_slot = "slot_ranged"
            local inventory_extension = ScriptUnit.extension(unit, "inventory_system")
            local slot_data = inventory_extension:get_slot_data(weapon_slot)

            if slot_data then
                local right_unit_1p = slot_data.right_unit_1p
                local left_unit_1p = slot_data.left_unit_1p
                local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
                local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
                local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension

                if ammo_extension then
                    local ammo_bonus_fraction = 0.05
                    local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

                    ammo_extension:add_ammo_to_reserve(ammo_amount)
                end

                local local_player = Managers.player:local_player()
		        local local_player_unit = local_player and local_player.player_unit
                local energy_extension = ScriptUnit.has_extension(local_player_unit, "energy_system")

                if energy_extension then
                    local max_energy = energy_extension:get_max()
                    local energy_amount = 0.05 * max_energy

                    energy_extension:add_energy(energy_amount)
                end

            end
        end

        if Managers.state.network.is_server and not cooldown_talent then
            local health_extension = ScriptUnit.extension(unit, "health_system")
            local status_extension = ScriptUnit.extension(unit, "status_system")
            local heal_amount = buff_template.heal_amount

            if talent_extension:has_talent("kerillian_waywatcher_improved_regen", "wood_elf", true) then
                regen_cap = 1
                heal_amount = heal_amount * 2
            end

            if health_extension:is_alive() and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() then
                if talent_extension:has_talent("kerillian_waywatcher_group_regen", "wood_elf", true) then
                    local side = Managers.state.side.side_by_unit[unit]

                    if not side then
                        return
                    end

                    heal_amount = heal_amount

                    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS

                    for i = 1, #player_and_bot_units, 1 do
                        if Unit.alive(player_and_bot_units[i]) then
                            local health_extension = ScriptUnit.extension(player_and_bot_units[i], "health_system")
                            local status_extension = ScriptUnit.extension(player_and_bot_units[i], "status_system")

                            if health_extension:current_permanent_health_percent() <= regen_cap and not status_extension:is_knocked_down() and not status_extension:is_assisted_respawning() and health_extension:is_alive() then
                                --DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "career_passive")
                                local unit_object_id = network_manager:unit_game_object_id(player_and_bot_units[i])
                                if unit_object_id then
                                    DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "heal_from_proc")
								    DamageUtils.heal_network(player_and_bot_units[i], unit, heal_amount, "career_passive")
                                end
                            end
                        end
                    end
                elseif health_extension:current_permanent_health_percent() <= regen_cap then
                    DamageUtils.heal_network(unit, unit, heal_amount, "heal_from_proc")
					DamageUtils.heal_network(unit, unit, heal_amount, "career_passive")
                end
            end
        end

        buff.next_heal_tick = t + time_between_heals
    end
end)

mod:add_proc_function("gs_poison_explosion_on_special_func", function(player, buff, params)
    local hit_data = params[5]
    local attack_type = params[2]

    if not hit_data or hit_data == "n/a" or hit_data ~= "RANGED" then
        return
    end

    if attack_type ~= "instant_projectile" and attack_type ~= "projectile" then
        return
    end

	local player_unit = player.player_unit

	if ALIVE[player_unit] then
		local area_damage_system = Managers.state.entity:system("area_damage_system")
		local career_extension = ScriptUnit.extension(player_unit, "career_system")
		local power_level = career_extension:get_career_power_level()
		local hit_unit = params[1]
		local position = POSITION_LOOKUP[hit_unit]
		local damage_source = "buff"
		local explosion_template = "waystalker_poison_explosion"

		local rotation = Quaternion.identity()
		local scale = 1
		local is_critical_strike = false

		local world_manager = Managers.world
		local world = world_manager:world("level_world")
		local wwise_world = world_manager:wwise_world(world)

		WwiseWorld.trigger_event(wwise_world, "talent_power_swing")

		area_damage_system:create_explosion(player_unit, position, rotation, explosion_template, scale, damage_source, power_level, is_critical_strike)
        return true
	end
end)
mod:modify_talent("we_waywatcher", 2, 2, {
    description = "kerillian_waywatcher_critical_bleed_desc",
    buffer = "both",
    buffs = {
        "gs_poison_explosion_on_special"
    }
})
mod:add_text("kerillian_waywatcher_critical_bleed_desc", "After killing a Special Kerillian's next ranged attack will create a poison cloud.")
mod:add_talent_buff_template("wood_elf", "gs_poison_explosion_on_special", {
    event = "on_kill",
    buff_func = "add_buff_on_special_kill",
    buff_to_add = "gs_poison_explosion_on_special_buff"
})
mod:add_talent_buff_template("wood_elf", "gs_poison_explosion_on_special_buff", {
    event = "on_hit",
    buff_func = "gs_poison_explosion_on_special_func",
    remove_on_proc = true,
    icon = "kerillian_waywatcher_critical_bleed",
    max_stacks = 1
})
mod:modify_talent("we_waywatcher", 2, 3, {
    description_values = {
        {
            value_type = "baked_percent",
            value = 1.20
        },
        {
            value = 10
        }
    }
})
mod:modify_talent_buff_template("wood_elf", "kerillian_waywatcher_attack_speed_on_ranged_headshot_buff", {
    duration = 10,
	multiplier = 0.20
})
mod:modify_talent("we_waywatcher", 4, 1, {
    description = "gs_increased_healing_passive_waywatcher_desc",
})
mod:add_text("gs_increased_healing_passive_waywatcher_desc", "Increases Kerillian's health regenerated from Amaranthe by 100%% and now heals above 50%% health as well.")

mod:modify_talent("we_waywatcher", 4, 2, {
    description = "gs_gain_ammo_passive_waywatcher_desc",
})
mod:add_text("gs_gain_ammo_passive_waywatcher_desc", "Amaranthe gives Kerillian 5%% ammo every tick. No longer restores health.")

mod:modify_talent_buff_template("wood_elf", "kerillian_waywatcher_passive", {
    update_func = "gs_update_kerillian_waywatcher_regen"
})

mod:modify_talent("we_waywatcher", 5, 1, {
    description = "gs_increased_headshot_damage_waywatcher_desc",
    buffer = "server",
    buffs = {
        "gs_increased_headshot_damage_waywatcher"
    }
})
mod:add_text("gs_increased_headshot_damage_waywatcher_desc", "Increased headshot damage bonus by 50%%")

mod:add_talent_buff_template("wood_elf", "gs_increased_headshot_damage_waywatcher", {
    stat_buff = "headshot_multiplier",
    multiplier = 0.5
})
mod:modify_talent("we_waywatcher", 5, 2, {
    description = "gs_ricochet_desc",
    buffs = {
        "kerillian_waywatcher_projectile_ricochet",
        "gs_extra_crit"
    }
})
mod:add_text("gs_ricochet_desc", "Kerillian's arrows now ricochet, each bouncing up to 3 times or until it hits an enemy. Increases critical strike chance by 10%%.")
mod:add_talent_buff_template("wood_elf", "gs_extra_crit", {
    stat_buff = "critical_strike_chance",
    bonus = 0.1
})

mod:add_proc_function("kerillian_waywatcher_consume_extra_shot_buff", function (player, buff, params)
    local is_career_skill = params[5]
    local should_consume_shot = nil

    if is_career_skill == "RANGED_ABILITY" or is_career_skill == nil then
        should_consume_shot = false
    else
        should_consume_shot = true
    end

    return should_consume_shot
end)

mod:add_talent_buff_template("wood_elf", "gs_way_ammo_on_melee_kills", {
    event = "on_kill",
    buff_func = "gs_ammo_on_melee_kills",
    ammo_bonus_fraction = 0.05,
    required_kills = 40,
    display_buff = "gs_display_buff_way_ammo"
})

mod:add_talent_buff_template("empire_soldier", "gs_display_buff_way_ammo", {
    max_stacks = 100,
	icon = "kerillian_waywatcher_activated_ability_cooldown"
})

mod:modify_talent("we_waywatcher", 5, 3, {
    description = "gs_way_ammo_on_melee_kills_desc",
    buffer = "both",
    buffs = {
        "gs_way_ammo_on_melee_kills"
    }
})
mod:add_text("gs_way_ammo_on_melee_kills_desc", "Receive 5%% ammo for melee kills that would provide 40 kill thp.")

mod:add_text("kerillian_waywatcher_activated_ability_piercing_shot_desc", "Trueflight Volley fires 3 additional arrows.")

--Handmaiden---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ActivatedAbilitySettings.we_2[1].cooldown = 40
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_ability_cooldown_on_damage_taken", {
    bonus = 0.25
})
table.insert(PassiveAbilitySettings.we_2.buffs, "gs_dash_ult_toggle_function")
mod:add_text("career_active_desc_we_2_2", "Kerillian places a banner for 10 seconds that grants 20% increased health to Allies nearby. Kerillian can also perform a dash instead by switching with weapon special. Buffs provided by the banner only apply to Kerillian when dashing. Dashing through an enemy causes them to bleed for significant damage over time.")
PassiveAbilitySettings.we_2.perks = {
	{
        display_name = "career_passive_name_we_2b",
        description = "career_passive_desc_we_2b_2"
    },
    {
        display_name = "career_passive_name_we_2c",
        description = "career_passive_desc_we_2c_2"
    },
	{
		display_name = "rebaltourn_career_passive_name_we_2d",
		description = "rebaltourn_career_passive_desc_we_2d_2"
	}
}
mod:add_text("career_passive_desc_we_2b_2", "Aura that increases stamina regeneration speed by 50%.")
mod:add_text("rebaltourn_career_passive_name_we_2d", "Shrouded by Isha")
mod:add_text("rebaltourn_career_passive_desc_we_2d_2", "Damage taken from trash enemies reduced by 30%.")
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_stamina_regen_aura", {
    range = 15
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_passive_stamina_regen_buff", {
    multiplier = 0.5
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_remover", {
	remove_buff_func = "remove_deus_rally_flag",
	name = "deus_rally_flag_lifetime",
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_remover_long", {
	remove_buff_func = "remove_deus_rally_flag",
	name = "deus_rally_flag_lifetime",
	duration = 15
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_effect", {
	decal = "units/decals/decal_heavens_01",
	name = "deus_rally_flag_aoe_decal",
	decal_scale = 7,
	remove_buff_func = "remove_generic_decal",
	apply_buff_func = "apply_generic_decal"
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_buff",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_buff", {
	name = "deus_rally_flag_health_buff",
	stat_buff = "max_health",
	multiplier = 0.2
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_heal", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_heal_buff",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff", {
	stat_buff = "healing_received",
	multiplier = 0.2
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_large", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_buff_large",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_buff_large", {
	name = "deus_rally_flag_health_buff",
	stat_buff = "max_health",
	multiplier = 0.5
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_heal_large", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_heal_buff_large",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff_large", {
	stat_buff = "healing_received",
	multiplier = 0.5
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_aoe_protection", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_buff_protection",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection", {
	icon = "kerillian_maidenguard_activated_ability_invis_duration",
	name = "deus_rally_flag_health_regen_buff",
	stat_buff = "protection_aoe",
	multiplier = -1,
	perk = "poison_proof"
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection_ranged", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_buff_protection_ranged_buff",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection_ranged_buff", {
	stat_buff = "damage_taken_ranged",
	multiplier = -1
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_wraith", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "kerillian_maidenguard_passive_noclip_dodge_start",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_wraith_1", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "kerillian_maidenguard_passive_noclip_dodge_end",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_grabber_protection", {
	name = "deus_rally_flag_aoe_buff",
	update_func = "update_generic_aoe",
	remove_buff_func = "remove_generic_aoe",
	apply_buff_func = "apply_generic_aoe",
	in_range_units_buff_name = "gs_deus_rally_flag_aoe_buff_grabber_protection_buff",
	range_check = {
		radius = 7,
		update_rate = 0.01,
		only_players = true,
		unit_left_range_func = "unit_left_range_generic_buff",
		unit_entered_range_func = "unit_entered_range_generic_buff"
	}
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_grabber_protection_buff", {
	icon = "kerillian_maidenguard_activated_ability_buff_on_enemy_hit",
	name = "deus_rally_flag_health_regen_buff",
	perk = "ledge_self_rescue"
})

local function is_husk(unit)
	local player = Managers.player:owner(unit)

	return (player and (player.remote or player.bot_player)) or false
end

mod:add_buff_function("gs_unit_entered_range_generic_buffs", function(unit, buffer_unit, buff, params, world)
	local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

	if buff_extension then
		if not is_husk(unit) then
			local wwise_world = Managers.world:wwise_world(world)

			WwiseWorld.trigger_event(wwise_world, "Play_blessing_rally_flag_loop")
		end

		local buff_names = buff.template.in_range_units_buff_names
		local buff_id = {}
		for i = 1, #buff_names, 1 do
			local buff_name = buff_names[i]
			local buffs_to_add = buff_extension:add_buff(buff_name)
			buff_id[#buff_id + 1] = buffs_to_add
		end
		return buff_id
	end
end)

mod:hook_origin(CareerAbilityWEMaidenGuard, "_run_ability", function(self)
	self:_stop_priming()

	local world = self._world
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")


	--CharacterStateHelper.play_animation_event(owner_unit, "shade_stealth_ability")
	if buff_extension:has_buff_type("gs_dash_ult_toggle") then
		local status_extension = self._status_extension
		local buff_names = {
			"kerillian_maidenguard_activated_ability"
		}

		if talent_extension:has_talent("kerillian_maidenguard_activated_ability_invis_duration", "wood_elf", true) then
			buff_names = {
				"kerillian_maidenguard_activated_ability",
				"gs_deus_rally_flag_buff_protection_ranged_buff_dash",
				"gs_deus_rally_flag_buff_protection_dash",
				"gs_deus_rally_flag_buff_dash",
				"gs_deus_rally_flag_heal_buff_dash"
			}
		elseif talent_extension:has_talent("kerillian_maidenguard_activated_ability_damage", "wood_elf", true) then
			buff_names = {
				"kerillian_maidenguard_activated_ability",
				"gs_deus_rally_flag_buff_large_dash",
				"gs_deus_rally_flag_heal_buff_large_dash",
			}
		elseif talent_extension:has_talent("kerillian_maidenguard_activated_ability_buff_on_enemy_hit", "wood_elf", true) then
			buff_names = {
				"kerillian_maidenguard_activated_ability",
				"gs_deus_rally_flag_buff_long_dash",
				"gs_deus_rally_flag_heal_buff_long_dash",
				"gs_deus_rally_flag_aoe_buff_grabber_protection_buff_dash"
			}
		end

		local unit_object_id = network_manager:unit_game_object_id(owner_unit)

		for i = 1, #buff_names, 1 do
			local buff_name = buff_names[i]
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if is_server then
				buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
			end
		end

		if (is_server and bot_player) or local_player then
			local first_person_extension = self._first_person_extension

			first_person_extension:animation_event("shade_stealth_ability")
			first_person_extension:play_remote_unit_sound_event("Play_career_ability_maiden_guard_charge", owner_unit, 0)
			career_extension:set_state("kerillian_activate_maiden_guard")

			if local_player then
				first_person_extension:play_hud_sound_event("Play_career_ability_maiden_guard_charge")
			end
		end

		status_extension:add_noclip_stacking()

		if network_manager:game() then
			status_extension:set_is_dodging(true)

			local unit_id = network_manager:unit_game_object_id(owner_unit)

			network_transmit:send_rpc_server("rpc_status_change_bool", NetworkLookup.statuses.dodging, true, unit_id, 0)
		end

		local damage_profile = "maidenguard_dash_ability_bleed"

		status_extension.do_lunge = {
			animation_end_event = "maiden_guard_active_ability_charge_hit",
			allow_rotation = false,
			first_person_animation_end_event = "dodge_bwd",
			first_person_hit_animation_event = "charge_react",
			falloff_to_speed = 5,
			dodge = true,
			first_person_animation_event = "shade_stealth_ability",
			first_person_animation_end_event_hit = "dodge_bwd",
			duration = 0.65,
			initial_speed = 25,
			animation_event = "maiden_guard_active_ability_charge_start",
			damage = {
				depth_padding = 0.4,
				height = 1.8,
				collision_filter = "filter_explosion_overlap_no_player",
				hit_zone_hit_name = "full",
				ignore_shield = true,
				interrupt_on_max_hit_mass = false,
				interrupt_on_first_hit = false,
				width = 1.5,
				allow_backstab = true,
				damage_profile = damage_profile,
				power_level_multiplier = (bleed and 1) or 0,
				stagger_angles = {
					max = 90,
					min = 90
				}
			}
		}
	else
		if (is_server and bot_player) or local_player then
			local first_person_extension = self._first_person_extension

			first_person_extension:animation_event("shade_stealth_ability")
			first_person_extension:play_hud_sound_event("career_ability_priest_explosion")
			first_person_extension:play_remote_unit_sound_event("career_ability_priest_explosion", owner_unit, 0)
		end

		local player_position = POSITION_LOOKUP[owner_unit]
		local player_rotation = Unit.local_rotation(owner_unit, 0)
		local forward = Quaternion.forward(player_rotation)
		local rotation = Quaternion.identity()
		local position = player_position + forward * 0.75
		local UNIT_TEMPLATE_NAME = "banner_unit"

		Managers.state.unit_spawner:request_spawn_network_unit(UNIT_TEMPLATE_NAME, position, player_rotation, owner_unit, 0)

		local explosion_template_name = "handmaiden_banner_explosion"
		local explosion_template = ExplosionTemplates[explosion_template_name]
		local scale = 1
		local damage_source = "career_ability"
		local is_husk = false
		local career_power_level = career_extension:get_career_power_level()
		local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
		local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
		local damage_source_id = NetworkLookup.damage_sources[damage_source]
		local buff_name = "gs_deus_rally_flag_buff_protection_duration"
		if talent_extension:has_talent("kerillian_maidenguard_activated_ability_buff_on_enemy_hit", "wood_elf", true) then
			buff_name = "gs_deus_rally_flag_buff_protection_duration_long"
		end
		local unit_object_id = network_manager:unit_game_object_id(owner_unit)
		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})
			network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
		end

		if is_server then
			network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
		else
			network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
		end

		DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false, owner_unit)
	end
	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end)
mod:add_buff_template("gs_deus_rally_flag_buff_protection_duration", {
	icon = "kerillian_maidenguard_passive",
	duration = 10,
	max_stacks = 1,
	refresh_durations = true
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection_duration_long", {
	icon = "kerillian_maidenguard_passive",
	duration = 15,
	max_stacks = 1,
	refresh_durations = true
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff_long_dash", {
	stat_buff = "healing_received",
	multiplier = 0.2,
	duration = 15
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection_dash", {
	icon = "kerillian_maidenguard_activated_ability_invis_duration",
	stat_buff = "protection_aoe",
	multiplier = -1,
	perk = "poison_proof",
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_buff_protection_ranged_buff_dash", {
	stat_buff = "damage_taken_ranged",
	multiplier = -1,
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_buff_dash", {
	stat_buff = "max_health",
	multiplier = 0.2,
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff_dash", {
	stat_buff = "healing_received",
	multiplier = 0.2,
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_buff_long_dash", {
	stat_buff = "max_health",
	multiplier = 0.2,
	duration = 15
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff_long_dash", {
	stat_buff = "healing_received",
	multiplier = 0.2,
	duration = 15
})
mod:add_buff_template("gs_deus_rally_flag_aoe_buff_grabber_protection_buff_dash", {
	icon = "kerillian_maidenguard_activated_ability_buff_on_enemy_hit",
	perk = "ledge_self_rescue",
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_buff_large_dash", {
	name = "deus_rally_flag_health_buff",
	stat_buff = "max_health",
	multiplier = 0.5,
	duration = 10
})
mod:add_buff_template("gs_deus_rally_flag_heal_buff_large_dash", {
	stat_buff = "healing_received",
	multiplier = 0.5,
	duration = 10
})

local function is_server()
	return Managers.player.is_server
end

--local side_player = Managers.state.side.side_by_unit[player_unit]
--local side_damage = Managers.state.side.side_by_unit[attacker_unit]
mod:add_proc_function("gs_maidenguard_reset_unharmed_buff", function (player, buff, params)
    local player_unit = player.player_unit
    local attacker_unit = params[1]
    local damage_amount = params[2]
    local damaged = true
    local side = Managers.state.side.side_by_unit[player_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local shot_by_friendly = false
    local allies = (player_and_bot_units and #player_and_bot_units) or 0

    if damage_amount and damage_amount == 0 then
        damaged = false
    end

    for i = 1, allies, 1 do
        local ally_unit =  player_and_bot_units[i]
        if ally_unit == attacker_unit then
            shot_by_friendly = true
        end
    end

    if Unit.alive(player_unit) and not shot_by_friendly and damaged then
        local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")
        local buff_name = "kerillian_maidenguard_power_level_on_unharmed_cooldown"
        local network_manager = Managers.state.network
        local network_transmit = network_manager.network_transmit
        local unit_object_id = network_manager:unit_game_object_id(player_unit)
        local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

        if is_server() then
            buff_extension:add_buff(buff_name, {
                attacker_unit = player_unit
            })
        else
            network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
        end

        return true
    end
end)

mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed", {
    multiplier = 0.25,
    buff_func = "gs_maidenguard_reset_unharmed_buff"
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_level_on_unharmed_cooldown", {
    duration = 5
})
mod:add_text("kerillian_maidenguard_power_level_on_unharmed_desc", "After not taking damage for 5 seconds, increases Kerillian's power by 25.0%%. Reset upon taking damage from an enemy.")
mod:modify_talent("we_maidenguard", 2, 2, {
    buffs = {
			"gs_kerillian_maidenguard_crit_chance_allies"
		}
})
mod:add_text("kerillian_maidenguard_crit_chance_desc", "Each nearby ally increases crit chance by 5%%.")
mod:add_talent_buff_template("wood_elf", "gs_kerillian_maidenguard_crit_chance_allies", {
    buff_to_add = "gs_kerillian_maidenguard_crit_chance_allies_buff",
    chunk_size = 1,
    range = 10,
    max_stacks = 3,
    update_func = "activate_buff_stacks_based_on_ally_proximity"
})
mod:add_talent_buff_template("wood_elf", "gs_kerillian_maidenguard_crit_chance_allies_buff", {
    max_stacks = 3,
    bonus = 0.05,
    stat_buff = "critical_strike_chance",
    icon = "kerillian_maidenguard_damage_reduction_on_last_standing"
})
mod:modify_talent("we_maidenguard", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15
        }
    },
})
mod:modify_talent("we_maidenguard", 2, 3, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15
        },
        {
            value_type = "percent",
            value = 0.1
        }
    },
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block", {
    amount_to_add = 5,
    max_sub_buff_stacks = 5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_push", {
    amount_to_add = 5,
    max_sub_buff_stacks = 5
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_buff", {
    multiplier = 0.15
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_power_on_block_buff", {
    multiplier = 0.1
})
mod:modify_talent_buff_template("wood_elf", "kerillian_maidenguard_speed_on_block_dummy_buff", {
    max_stacks = 5
})
mod:add_text("kerillian_maidenguard_speed_on_block_desc", "Blocking an attack or pushing an enemy grants the next five strikes 15%% attack speed and 10%% power.")
mod:add_talent_buff_template("wood_elf", "gs_kerillian_maidenguard_passive_dr_on_dodge", {
    event = "on_dodge",
    buff_to_add = "gs_kerillian_maidenguard_passive_dr_on_dodge_buff",
    buff_func = "add_buff"
})
mod:add_talent_buff_template("wood_elf", "gs_kerillian_maidenguard_passive_dr_on_dodge_buff", {
   refresh_durations = true,
   icon = "kerillian_maidenguard_passive_noclip_dodge",
   stat_buff = "damage_taken",
   max_stacks = 4,
   multiplier = -0.05,
   duration = 6
})
mod:modify_talent("we_maidenguard", 4, 3, {
    description = "gs_we_maidenguard_4_3",
    description_values = {},
    buffs = {
        "gs_kerillian_maidenguard_passive_dr_on_dodge"
    }
})
mod:add_text("gs_we_maidenguard_4_3", "Dodging reduces damage taken by 5%% for 6 seconds. Stacks 4 times.")
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_moonbow_speed", {
    stat_buff = "attack_speed_drakefire",
    multiplier = 0.2,
    max_stacks = 1
})
mod:add_talent_buff_template("wood_elf", "kerillian_maidenguard_moonbow_damage", {
    stat_buff = "power_level_ranged_drakefire",
    multiplier = 0.2,
    max_stacks = 1
})
mod:modify_talent("we_maidenguard", 5, 3, {
    description = "gs_we_maidenguard_5_3",
    description_values = {},
    buffs = {
        "kerillian_maidenguard_max_ammo",
        "kerillian_maidenguard_moonbow_speed"
    }
})
mod:add_text("gs_we_maidenguard_5_3", "increases max ammo by 40%% and buffs moonbow attackspeed by 20%% and recharge rate by 33%%")

mod:modify_talent("we_maidenguard", 6, 1, {
    description = "gs_we_maidenguard_6_1"
})
mod:modify_talent("we_maidenguard", 6, 2, {
    description = "gs_we_maidenguard_6_2"
})
mod:modify_talent("we_maidenguard", 6, 3, {
    description = "gs_we_maidenguard_6_3",
    buffs = {}
})
mod:add_text("gs_we_maidenguard_6_1", "Banner also grants immunity to aoe damage.")
mod:add_text("gs_we_maidenguard_6_2", "Banner now increases max health by 50%%")
mod:add_text("gs_we_maidenguard_6_3", "Banner also grants immunity to grabbers. Banner duration is now 20 seconds")

--Shade
mod:add_proc_function("shade_backstab_ammo_gain", function (player, buff, params)
    local player_unit = player.player_unit
    local buff_extension = ScriptUnit.has_extension(player_unit, "buff_system")

    if buff_extension and not buff_extension:has_buff_type("kerillian_shade_backstabs_replenishes_ammunition_cooldown") then
        if Unit.alive(player_unit) then
            local weapon_slot = "slot_ranged"
            local ammo_bonus_fraction = buff.template.ammo_bonus_fraction
            local inventory_extension = ScriptUnit.extension(player_unit, "inventory_system")
            local slot_data = inventory_extension:get_slot_data(weapon_slot)
            local right_unit_1p = slot_data.right_unit_1p
            local left_unit_1p = slot_data.left_unit_1p
            local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
            local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
            local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension

            if ammo_extension then
                local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)
                ammo_extension:add_ammo_to_reserve(ammo_amount)
            end
        end

        buff_extension:add_buff("kerillian_shade_backstabs_replenishes_ammunition_cooldown")
    end
end)
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_backstabs_replenishes_ammunition", {
	ammo_bonus_fraction = 0.05
})
mod:add_text("kerillian_shade_backstabs_replenishes_ammunition_desc_2", "Backstabs return 5%% of ammunition. 2 second cooldown.")
mod:modify_talent_buff_template("wood_elf", "kerillian_shade_activated_ability_phasing", {
	restealth = true,
	perk = "shade_melee_boost"
})
mod:add_text("kerillian_shade_activated_ability_phasing_desc", "Leaving Infiltrate grants Kerillian 10%% movement speed and 15%% Power with the ability to pass through enemies for 10 seconds.")

mod:add_proc_function("shade_activated_ability_on_hit", function(player, buff, params)
    local player_unit = player.player_unit

    if ALIVE[player_unit] then
        local hit_unit = params[1]
        local behind_target = ActionUtils.is_backstab(player_unit, hit_unit)

        if behind_target then
            local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")

            if first_person_extension then
                first_person_extension:play_hud_sound_event("Play_career_ability_shade_backstab")
            end
        end

        local talent_extension = ScriptUnit.extension(player_unit, "talent_system")
        local buff_extension = ScriptUnit.extension(player_unit, "buff_system")

        if talent_extension:has_talent("kerillian_shade_activated_ability_restealth") and buff.template.restealth then
            local t = Managers.time:time("game")
            buff.start_time = t - buff.template.duration - 0.05
            local first_person_extension = ScriptUnit.has_extension(player_unit, "first_person_system")

            if first_person_extension then
                first_person_extension:play_hud_sound_event("Play_career_ability_kerillian_shade_enter")
                first_person_extension:animation_event("shade_stealth_ability")
            end
        else
            buff_extension:remove_buff(buff.id)
        end
    end
end)

--Sister of the Thorn
ActivatedAbilitySettings.we_thornsister.cooldown = 50
BuffTemplates.thorn_sister_passive_poison.buffs[1].multiplier = 0.15
BuffTemplates.thorn_sister_passive_poison_improved.buffs[1].multiplier = 0.15
mod:modify_talent_buff_template("wood_elf", "thorn_sister_ability_cooldown_on_hit", {
	bonus = 0.35
})
mod:modify_talent_buff_template("wood_elf", "thorn_sister_ability_cooldown_on_damage_taken", {
	bonus = 0.25
})
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_set_back", {
	amount = -3
})
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_passive_temp_health_funnel_aura_buff", {
	multiplier = 0.4
})
mod:add_buff_function("gs_activate_buff_stacks_based_on_health_percentage", function(unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local max_health = health_extension:get_max_health()
	local health_threshold = template.health_threshold
	local current_health = health_extension:current_health()
	local max_stacks = math.floor(1 / health_threshold)
	local health_percentage = current_health / max_health
	local health_chunks = math.floor(health_percentage / health_threshold)
	local buff_to_add = template.buff_to_add
	local num_chunks = math.min(max_stacks, health_chunks)
	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	if num_buff_stacks < num_chunks then
		local difference = num_chunks - num_buff_stacks

		for i = 1, difference, 1 do
			local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
			local stack_ids = buff.stack_ids
			stack_ids[#stack_ids + 1] = buff_id
		end
	elseif num_chunks < num_buff_stacks then
		local difference = num_buff_stacks - num_chunks

		for i = 1, difference, 1 do
			local stack_ids = buff.stack_ids
			local buff_id = table.remove(stack_ids, 1)

			buff_system:remove_server_controlled_buff(unit, buff_id)
		end
	end
end)

mod:modify_talent("we_thornsister", 2, 1, {
	buffs = {
		"gs_activate_buff_stacks_based_on_health_percentage"
	}
})

mod:add_talent_buff_template("wood_elf", "gs_activate_buff_stacks_based_on_health_percentage", {
	buff_to_add = "kerillian_thorn_sister_attack_speed_on_full_buff",
	update_func = "gs_activate_buff_stacks_based_on_health_percentage",
	update_frequency = 0.2,
	health_threshold = 0.25
})
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_attack_speed_on_full_buff", {
	max_stacks = 4,
	icon = "kerillian_thornsister_attack_speed_on_full",
	stat_buff = "attack_speed",
	multiplier = 0.05
})
mod:add_text("kerillian_thorn_sister_attack_speed_on_full_desc", "Kerilian gains 5%% Attack Speed for every 25%% health.")
mod:modify_talent_buff_template("wood_elf", "kerillian_thorn_sister_crit_on_any_ability", {
	amount_to_add = 3
})
mod:modify_talent("we_thornsister", 2, 3, {
    description_values = {
        {
            value = 3
        }
    }
})

ExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion.explosion.radius = 5.5
ExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion_improved.explosion.radius = 5.5
