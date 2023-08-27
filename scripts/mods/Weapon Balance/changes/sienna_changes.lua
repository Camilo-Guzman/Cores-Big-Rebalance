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

-- Battle Wizard Changes------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ActivatedAbilitySettings.bw_2[1].cooldown = 40

local EPSILON = 0.01
local SEGMENT_LIST = {}

local function get_leap_data(physics_world, own_position, target_position)
	local flat_distance = Vector3.length(Vector3.flat(own_position - target_position))

	if flat_distance < EPSILON then
		return Vector3.zero(), 0, own_position
	end

	local gravity = PlayerUnitMovementSettings.gravity_acceleration
	local jump_angle = math.degrees_to_radians(45)
	local sections = 8
	local target_velocity = Vector3.zero()
	local acceptable_accuracy = 0.1
	local jump_speed, hit_pos = WeaponHelper.speed_to_hit_moving_target(own_position, target_position, jump_angle, target_velocity, gravity, acceptable_accuracy)
	local in_los, velocity, _ = WeaponHelper.test_angled_trajectory(physics_world, own_position, target_position, -gravity, jump_speed, jump_angle, SEGMENT_LIST, sections, nil, true)

	fassert(in_los, "no landing location for leap")

	local direction = Vector3.normalize(velocity)

	return direction, jump_speed, hit_pos
end

mod:hook_origin(CareerAbilityBWAdept, "_run_ability", function(self)
	local landing_position = self._last_valid_landing_position:unbox()

	self:_stop_priming()

	if not self._locomotion_extension:is_on_ground() then
		return
	end

	local world = self._world
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = self._network_manager.network_transmit
	local career_extension = self._career_extension
	local status_extension = self._status_extension
	local talent_extension = self._talent_extension
	local locomotion_extension = self._locomotion_extension
	local physics_world = World.get_data(world, "physics_world")
	local direction, speed, hit_pos = get_leap_data(physics_world, POSITION_LOOKUP[owner_unit], landing_position)

	if (local_player or (is_server and bot_player)) and not talent_extension:has_talent("sienna_adept_activated_ability_explosion") then
		local nav_world = Managers.state.entity:system("ai_system"):nav_world()
		local unit_pos = POSITION_LOOKUP[owner_unit]
		local above = 2
		local below = 30
		local projected_start_pos = LocomotionUtils.pos_on_mesh(nav_world, unit_pos, above, below)
		projected_start_pos = projected_start_pos or GwNavQueries.inside_position_from_outside_position(nav_world, unit_pos, above, below, 2, 0.5)

		if projected_start_pos then
			local damage_wave_template_name = "sienna_adept_ability_trail"
			local damage_wave_template_id = NetworkLookup.damage_wave_templates[damage_wave_template_name]
			local source_unit_id = network_manager:unit_game_object_id(owner_unit)

			network_manager.network_transmit:send_rpc_server("rpc_create_damage_wave", source_unit_id, projected_start_pos, hit_pos, damage_wave_template_id)
		end
	end

	if local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("battle_wizard_active_ability_blink")
		career_extension:set_state("sienna_activate_adept")

		MOOD_BLACKBOARD.skill_adept = true
	end

    if Managers.state.network:game() then
		status_extension:set_is_dodging(true)

		local unit_id = Managers.state.network:unit_game_object_id(owner_unit)

		network_transmit:send_rpc_server("rpc_status_change_bool", NetworkLookup.statuses.dodging, true, unit_id, 0)
	end

	if not talent_extension:has_talent("sienna_adept_ability_trail_double") then

		local position = POSITION_LOOKUP[owner_unit]
		local explosion_template_name = "sienna_adept_activated_ability_start_stagger"
		if talent_extension:has_talent("sienna_adept_activated_ability_explosion") then
			explosion_template_name = "sienna_adept_activated_ability_end_stagger_improved"
		end
		local scale = 1
		local explosion_template = ExplosionTemplates[explosion_template_name]
		local damage_source = "career_ability"
		local is_husk = false
		local rotation = Quaternion.identity()
		local career_power_level = career_extension:get_career_power_level()

		DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false)

		local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
		local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
		local damage_source_id = NetworkLookup.damage_sources[damage_source]

		if is_server then
			network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
		else
			network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
		end
	end

	locomotion_extension:teleport_to(landing_position)

	local rotation = Unit.local_rotation(owner_unit, 0)
	local explosion_template_name = "sienna_adept_activated_ability_end_stagger"
	local explosion_template = ExplosionTemplates[explosion_template_name]
	if talent_extension:has_talent("sienna_adept_activated_ability_explosion") then
		explosion_template_name = "sienna_adept_activated_ability_end_stagger_improved"
	end
	local position = landing_position
	local scale = 1
	local damage_source = "career_ability"
	local is_husk = false
	local career_power_level = career_extension:get_career_power_level()

	DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false)

	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
	local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
	local damage_source_id = NetworkLookup.damage_sources[damage_source]

	if is_server then
		network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	else
		network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	end

	if talent_extension:has_talent("sienna_adept_ability_trail_double") then
		if local_player or (is_server and bot_player) then
			local buff_extension = self._buff_extension

			if buff_extension then
				local buff = buff_extension:get_buff_type("sienna_adept_ability_trail_double")

				if buff then
					buff.aborted = true

					buff_extension:remove_buff(buff.id)
					career_extension:start_activated_ability_cooldown()
					career_extension:set_abilities_always_usable(false, "sienna_adept_ability_trail_double")
				else
					buff_extension:add_buff("sienna_adept_ability_trail_double")
					career_extension:set_abilities_always_usable(true, "sienna_adept_ability_trail_double")
				end
			end
		end
	else
		career_extension:start_activated_ability_cooldown()
	end

	self:_play_vo()
end)


-- Battle Wizard Talents
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_increased_burn_damage", {
    multiplier = 1
})
mod:modify_talent("bw_adept", 2, 2, {
    description = "rebaltourn_sienna_adept_increased_burn_damage_desc",
    buffs = {
        "sienna_adept_increased_burn_damage"
    }
})
mod:add_text("rebaltourn_sienna_adept_increased_burn_damage_desc", "Increases burn damage by 100%%.")

mod:modify_talent_buff_template("bright_wizard", "sienna_adept_improved_tranquility", {
	stat_buff = "attack_speed",
	multiplier = 0.1,
	max_stacks = 1
})
mod:add_text("sienna_adept_passive_improved_desc_2", "When Tranquillity is active, Sienna gains 10%% attack speed")
mod:modify_talent_buff_template("bright_wizard", "sienna_adept_damage_reduction_on_ignited_enemy_buff", {
    multiplier = -0.05, -- -0.1,
    max_stacks = 4
})
mod:modify_talent("bw_adept", 5, 1, {
    description = "rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc"
})
mod:add_text("rebaltourn_sienna_adept_damage_reduction_on_ignited_enemy_desc", "Igniting an enemy reduces damage taken by 5%% for 5 seconds. Stacks up to 4 times.")

ExplosionTemplates.sienna_adept_activated_ability_end_stagger_improved.explosion.damage_profile = "kaboom_push"
NewDamageProfileTemplates.kaboom_push = {
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
			0.35,
			0.5,
			100,
			0.5,
			1.5,
			1
		}
	},
	is_explosion = true,
	charge_value = "ability",
	cleave_distribution = {
		attack = 1,
		impact = 1
	},
	default_target = {
		stagger_duration_modifier = 1,
		damage_type = "push",
		boost_curve_type = "default",
		attack_template = "ability_push",
		power_distribution = {
			attack = 0.25,
			impact = 1
		}
	},
	no_friendly_fire = true
}

mod:modify_talent("bw_adept", 6, 3, {
    buffs = {
		"sienna_adept_increased_ult_cooldown"
	}
})
mod:add_talent_buff_template("bright_wizard", "sienna_adept_increased_ult_cooldown", {
	remove_buff_func = "remove_modify_ability_max_cooldown",
	apply_buff_func = "add_modify_ability_max_cooldown",
	multiplier = 0.5
})
mod:add_text("sienna_adept_ability_trail_double_desc", "Fire Walk can be activated a second time within 10 seconds. Increases the cooldown of Fire Walk by 50.0%%.")

-- Pyro------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
table.insert(PassiveAbilitySettings.bw_1.buffs, "sienna_scholar_overcharge_no_slow")
table.insert(PassiveAbilitySettings.bw_1.buffs, "sienna_scholar_first_hit")
table.insert(PassiveAbilitySettings.bw_1.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.bw_2.buffs, "kerillian_waywatcher_passive_increased_zoom")
table.insert(PassiveAbilitySettings.bw_3.buffs, "kerillian_waywatcher_passive_increased_zoom")

mod:add_talent_buff_template("bright_wizard", "sienna_scholar_first_hit", {
	max_stacks = 1,
	multiplier = 0.25,
	stat_buff = "first_ranged_hit_damage"
})

--Burning Head
mod:hook_origin(ActionCareerBWScholar, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	ActionCareerBWScholar.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local talent_extension = self.talent_extension
	local owner_unit = self.owner_unit

	if talent_extension:has_talent("sienna_scholar_activated_ability_dump_overcharge", "bright_wizard", true) then
		local player = Managers.player:owner(owner_unit)

		if player.local_player or (self.is_server and player.bot_player) then
			local overcharge_extension = self.overcharge_extension

			overcharge_extension:reset()

			local network_manager = Managers.state.network
			local network_transmit = network_manager.network_transmit
			local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
			local buff_name = "sienna_scholar_activated_ability_dump_overcharge_buff"
			local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")

			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})

			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if self.is_server then
				network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, true)
			end
		end
	end

	if talent_extension:has_talent("sienna_scholar_activated_ability_heal", "bright_wizard", true) then
		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_id = network_manager:unit_game_object_id(owner_unit)
		local heal_type_id = NetworkLookup.heal_types.career_skill

		network_transmit:send_rpc_server("rpc_request_heal", unit_id, 20, heal_type_id)
	end

	self:_play_vo()
	self.career_extension:start_activated_ability_cooldown()

	local inventory_extension = self.inventory_extension

	inventory_extension:check_and_drop_pickups("career_ability")
end)
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}
DamageProfileTemplates.fire_spear_trueflight.max_friendly_damage = 20
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.attack = {
	1.5,
	1.5,
	2.5,
	0.15,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_near.impact = {
	1.5,
	1.5,
	2.5,
	0.15,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.attack = {
	1.5,
	1.5,
	2.5,
	0.15,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.armor_modifier_far.impact = {
	1.5,
	1.5,
	2.5,
	0.15,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.attack_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.critical_strike.impact_armor_power_modifer  = {
	1.5,
	1.5,
	2.5,
	0.25,
	1.5,
	0.5
}
DamageProfileTemplates.fire_spear_trueflight.default_target.power_distribution_near.attack = 1
DamageProfileTemplates.fire_spear_trueflight.default_target.power_distribution_far.attack = 1
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.attack = 0.375
DamageProfileTemplates.fire_spear_trueflight.cleave_distribution.impact = 0.375
DamageProfileTemplates.fire_spear_trueflight.default_target.boost_curve_coefficient_headshot = 0.5
DamageProfileTemplates.fire_spear_trueflight.default_target.boost_curve_coefficient = 0.5
Weapons.sienna_scholar_career_skill_weapon.actions.action_career_hold.prioritized_breeds = {
    skaven_warpfire_thrower = 1,
    chaos_vortex_sorcerer = 1,
    skaven_gutter_runner = 1,
    skaven_pack_master = 1,
    skaven_poison_wind_globadier = 1,
    chaos_corruptor_sorcerer = 1,
    skaven_ratling_gunner = 1,
    beastmen_standard_bearer = 1,
}

-- Pyromancer Talents
mod:add_proc_function("gs_remove_overcharge_on_melee_kills_func", function(owner_unit, buff, params)
    local buff_template = buff.template

    if not Unit.alive(owner_unit) then
        return
    end

    local killing_blow_data = params[1]

    if not killing_blow_data then
        return
    end

    local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

    if not attack_type or (attack_type ~= "light_attack" and attack_type ~= "heavy_attack") then
        return
    end

    local overcharge_amount = buff_template.bonus
    local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")

    if overcharge_extension then
        overcharge_extension:remove_charge(overcharge_amount)
    end
end)

mod:add_buff_function("update_ascending_descending_buff_stacks_on_time", function(owner_unit, buff, params)
    if not Unit.alive(owner_unit) then
		return
	end

	local t = params.t
	local template = buff.template

	if not buff.buff_ids then
		buff.ascending = true
		buff.buff_ids = {}
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local buff_to_add = template.buff_to_add
	local max_sub_buff_stacks = template.max_sub_buff_stacks

	if buff.ascending then
		buff.buff_ids[#buff.buff_ids + 1] = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)

		if max_sub_buff_stacks <= #buff.buff_ids then
			buff.ascending = false
		end
	else
		local buff_to_remove = table.remove(buff.buff_ids, 1)

		buff_system:remove_server_controlled_buff(owner_unit, buff_to_remove)

		if #buff.buff_ids <= 10 then
			buff.ascending = true
		end
	end
end)
mod:add_text("sienna_scholar_ranged_power_ascending_descending_desc", "Increases ranged power level by 1%% every second up to a maximum of 20 stacks. Upon reaching maximum stacks the effect diminishes then falls to 10 stacks and starts over.")

mod:add_talent_buff_template("bright_wizard", "gs_remove_overcharge_on_melee_kills", {
    event = "on_kill",
    bonus = 3,
    buff_func = "gs_remove_overcharge_on_melee_kills_func"
})

mod:modify_talent("bw_scholar", 2, 2, {
    description = "gs_remove_overcharge_on_melee_kills_desc",
    buffs = {
        "gs_remove_overcharge_on_melee_kills"
    }
})
mod:add_text("gs_remove_overcharge_on_melee_kills_desc", "Remove overcharge on melee kills.")

mod:add_buff_function("gs_activate_scaling_buff_based_on_health_percentage", function(unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if not Unit.alive(unit) then
        return
    end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local max_health = health_extension:get_max_health()
	local current_health = health_extension:current_health()
	local health_percentage = current_health / max_health
	local stacks_to_add = 0
	local max_buff_value = template.max_buff_value

	stacks_to_add = health_percentage * max_buff_value

	local buff_to_add = template.buff_to_add
	local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	if num_buff_stacks < stacks_to_add then
		local difference = stacks_to_add - num_buff_stacks

		for i = 1, difference, 1 do
			local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
			local stack_ids = buff.stack_ids
			stack_ids[#stack_ids + 1] = buff_id
		end
	elseif stacks_to_add < num_buff_stacks then
		local difference = num_buff_stacks - stacks_to_add

		for i = 1, difference, 1 do
			local stack_ids = buff.stack_ids
			local buff_id = table.remove(stack_ids, 1)

			buff_system:remove_server_controlled_buff(unit, buff_id)
		end
	end
end)
mod:add_buff_function("gs_activate_buff_stacks_based_on_certain_health_percentage", function(unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local health_extension = ScriptUnit.extension(unit, "health_system")
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local max_health = health_extension:get_max_health()
	local current_health = health_extension:current_health()
	local health_percentage = current_health / max_health
	local stacks_to_add = 0
	if health_percentage >= 0.5 and health_percentage < 0.65 then
		stacks_to_add = 1
	elseif health_percentage >= 0.65 and health_percentage < 0.8 then
		stacks_to_add = 2
	elseif health_percentage >= 0.8 then
		stacks_to_add = 3
	end
	local buff_to_add = template.buff_to_add
	local num_chunks = stacks_to_add
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
mod:add_talent_buff_template("bright_wizard", "gs_sienna_scholar_crit_chance_above_health_threshold", {
	buff_to_add = "sienna_scholar_crit_chance_above_health_threshold_buff",
	update_func = "gs_activate_scaling_buff_based_on_health_percentage",
	update_frequency = 0.2,
	max_buff_value = 15
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_crit_chance_above_health_threshold_buff", {
	max_stacks = 15,
	icon = "sienna_scholar_crit_chance_above_health_threshold",
	stat_buff = "critical_strike_chance",
	bonus = 0.01
})
mod:modify_talent("bw_scholar", 2, 3, {
    buffs = {
        "gs_sienna_scholar_crit_chance_above_health_threshold"
    },
    description = "rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc",
    description_values = {},
})
mod:add_text("rebaltourn_sienna_scholar_crit_chance_above_health_threshold_desc", "Critical strike chance is increased by 5.0%% while above 50.0%% health, increased by 10.0%% while above 65.0%% health and increased by 15.0%% while above 80.0%% health.")

mod:modify_talent_buff_template("bright_wizard", "sienna_scholar_passive_increased_power_level_on_high_overcharge", {
	chunk_size = 25
})
mod:modify_talent_buff_template("bright_wizard", "sienna_scholar_passive_increased_power_level_on_high_overcharge_buff", {
	multiplier = 0.2
})
mod:add_text("sienna_scholar_passive_increased_power_level_on_high_overcharge_desc", "Increases ranged power by 20%% when at or above 65%% overcharge.")

mod:modify_talent("bw_scholar", 5, 2, {
	buffs = {
		"traits_ranged_remove_overcharge_on_crit"
	},
	description = "rebaltourn_traits_ranged_remove_overcharge_on_crit_desc",
	description_values = {},
})
mod:add_text("rebaltourn_traits_ranged_remove_overcharge_on_crit_desc", "Ranged critical hits refund the overcharge cost of the attack.")

mod:add_talent_buff_template("bright_wizard", "sienna_scholar_free_vent_damage", {
	stat_buff = "vent_damage",
	multiplier = -1
})
mod:add_talent_buff_template("bright_wizard", "sienna_scholar_free_vent_speed", {
	stat_buff = "vent_speed",
	multiplier = -0.5
})
mod:modify_talent("bw_scholar", 5, 3, {
	description = "pyro_5_3_desc",
	buffs = {
		"sienna_scholar_free_vent_damage",
		"sienna_scholar_free_vent_speed"
	}
})
mod:add_text("pyro_5_3_desc", "Venting no longer causes damage but the rate of venting is decreased by 50%%.")

mod:add_talent_buff_template("bright_wizard", "sienna_scholar_activated_ability_dump_overcharge_buff", {
    max_stacks = 1,
    icon = "sienna_scholar_activated_ability_dump_overcharge",
    stat_buff = "critical_strike_chance",
    bonus = 0.15,
    duration = 10,
    refresh_durations = true,
})
mod:modify_talent("bw_scholar", 6, 1, {
	description = "rebaltourn_sienna_scholar_activated_ability_dump_overcharge_buff_desc",
	description_values = {},
})
mod:add_text("rebaltourn_sienna_scholar_activated_ability_dump_overcharge_buff_desc", "The Burning Head also removes all overcharge and grants 15%% increased crit chance for 10 seconds.")
mod:add_text("sienna_scholar_activated_ability_heal_desc", "The Burning Head grants 20 temporary health when used.")


PassiveAbilitySettings.bw_1.perks = {
	{
		display_name = "career_passive_name_bw_1b",
		description = "career_passive_desc_bw_1b_2"
	},
	{
		display_name = "rebaltourn_career_passive_name_bw_1c",
		description = "rebaltourn_career_passive_desc_bw_1c_2"
	}
}

mod:add_text("rebaltourn_career_passive_name_bw_1c", "Complete Control")
mod:add_text("rebaltourn_career_passive_desc_bw_1c_2", "No longer slowed from being overcharged.")

--Unchained------------------------------------------------------------------------------------------------------------------------------------------------------------------
table.insert(PassiveAbilitySettings.bw_3.buffs, "sienna_unchained_health_to_ult")
PlayerCharacterStateOverchargeExploding.on_exit = function (self, unit, input, dt, context, t, next_state)
    if not Managers.state.network:game() or not next_state then
        return
    end

    CharacterStateHelper.play_animation_event(unit, "cooldown_end")
    CharacterStateHelper.play_animation_event_first_person(self.first_person_extension, "cooldown_end")

    local career_extension = ScriptUnit.extension(unit, "career_system")
    local career_name = career_extension:career_name()

    if self.falling and next_state ~= "falling" then
        ScriptUnit.extension(unit, "whereabouts_system"):set_no_landing()
    end
end
table.insert(PassiveAbilitySettings.bw_3.buffs, "gs_add_overcharge_on_melee_kills")
mod:add_text("career_passive_desc_bw_3c_2", "Increased melee power on high Overcharge by up to 45%. Melee kills generate overcharge when not on high heat.")
mod:add_proc_function("gs_add_overcharge_on_melee_kills_func", function(owner_unit, buff, params)
    local buff_template = buff.template
    local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")
    local overcharge_fraction = overcharge_extension:overcharge_fraction()

    if not Unit.alive(owner_unit) then
        return
    end

    if overcharge_fraction >= 0.65  then
        return
    end

    local killing_blow_data = params[1]

    if not killing_blow_data then
        return
    end

    local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

    if not attack_type or (attack_type ~= "light_attack" and attack_type ~= "heavy_attack") then
        return
    end

    local overcharge_amount = buff_template.bonus

    if overcharge_extension then
        overcharge_extension:add_charge(overcharge_amount)
    end
end)

mod:add_talent_buff_template("bright_wizard", "gs_add_overcharge_on_melee_kills", {
    event = "on_kill",
    bonus = 3,
    buff_func = "gs_add_overcharge_on_melee_kills_func"
})
mod:modify_talent_buff_template("bright_wizard", "sienna_unchained_passive_melee_power_on_overcharge", {
    multiplier = 0.09,
    max_stacks = 5
})
mod:add_buff_function("gs_sienna_unchained_health_to_cooldown_update", function (unit, buff, params)
    local t = params.t
	local frequency = 0.25

	if not buff.timer or buff.timer <= t then
		buff.timer = t + frequency
		local career_extension = ScriptUnit.has_extension(unit, "career_system")

		if career_extension and career_extension:current_ability_cooldown_percentage() > 0 then
			career_extension:reduce_activated_ability_cooldown_percent(0.1)

			local health_extension = ScriptUnit.has_extension(unit, "health_system")
			local damage = health_extension:get_max_health() / 20

			DamageUtils.add_damage_network(unit, unit, damage, "torso", "life_tap", nil, Vector3(0, 0, 0), "life_tap", nil, unit)
		end
	end
end)
mod:modify_talent_buff_template("bright_wizard", "sienna_unchained_health_to_cooldown_buff", {
    update_func = "gs_sienna_unchained_health_to_cooldown_update"
})
mod:add_talent_buff_template("bright_wizard", "gs_burning_enemies_on_headshot", {
    event = "on_hit",
    buff_to_add = "gs_burning_enemies_on_headshot_counter",
    buff_func = "add_buff_on_headshot"
})
mod:add_talent_buff_template("bright_wizard", "gs_burning_enemies_on_headshot_counter", {
    reset_on_max_stacks = true,
    max_stacks = 7,
    on_max_stacks_func = "add_remove_buffs",
    icon = "sienna_unchained_tank_unbalance",
    max_stack_data = {
        buffs_to_add = {
            "gs_burning_enemies_on_headshot_buff"
        }
    },
})
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")
mod:add_talent_buff_template("bright_wizard", "gs_burning_enemies_on_headshot_buff", {
    icon = "sienna_unchained_tank_unbalance",
    duration = 5,
    max_stacks = 1,
	refresh_durations = true,
    buff_func = "dummy_function",
    perk = buff_perks.sienna_unchained_burn_push
})
mod:modify_talent("bw_unchained", 2, 1, {
    description = "gs_burning_enemies_on_headshot_desc",
    name = "gs_burning_enemies_on_headshot_name",
	icon = "sienna_unchained_tank_unbalance",
    buffs = {
        "gs_burning_enemies_on_headshot"
    }
})
mod:add_text("gs_burning_enemies_on_headshot_name","Flaming Weapons")
mod:add_text("gs_burning_enemies_on_headshot_desc","Hitting 7 headshots makes your melee attacks cause burn for 5 seconds.")
mod:add_talent_buff_template("bright_wizard", "gs_exploding_enemies_on_kill", {
    event = "on_kill_elite_special",
    name = "explosive_kills_on_elite_kills",
    buff_to_add = "elites_on_kill_explosion_buff",
    buff_func = "add_buff_on_melee_kills_proc",
    amount_of_explosions = 1
})
mod:add_talent_buff_template("bright_wizard", "gs_exploding_enemies_on_kill_buff", {
    sound_event = "morris_power_ups_exploding_enemy",
    name = "elites_on_kill_explosion_buff",
    authority = "server",
    buff_func = "elites_on_kill_explosion",
    power_scale = 2,
    event = "on_kill",
    max_stacks = 1,
    explosion_template = "buff_explosion",
    icon = "explosive_kills_on_elite_kills",
})
ExplosionTemplates.buff_explosion.explosion = {
    use_attacker_power_level = true,
    radius = 3,
    max_damage_radius = 1.5,
    alert_enemies_radius = 10,
    attacker_power_level_offset = 0.5,
    effect_name = "fx/cw_enemy_explosion",
    attack_template = "grenade",
    sound_event_name = "fireball_big_hit",
    damage_profile_glance = "melee_kill_explosion_glance",
    alert_enemies = true,
    damage_profile = "melee_kill_explosion",
    no_friendly_fire = true,
    camera_effect = {
        near_distance = 5,
        near_scale = 1,
        shake_name = "frag_grenade_explosion",
        far_scale = 0.15,
        far_distance = 20
    }
}
mod:add_buff_template("long_burn_low_damage", {
    duration = 4,
    name = "burning dot",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    death_flow_event = "burn_death",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    time_between_dot_damages = 0.75,
    damage_type = "burninating",
    damage_profile = "dot_low_damage",
    update_func = "apply_dot_damage",
    perk = buff_perks.burning
})
mod:add_buff_template("long_burn_extra_low_damage", {
    duration = 4,
    name = "burning dot",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    death_flow_event = "burn_death",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    time_between_dot_damages = 0.75,
    damage_type = "burninating",
    damage_profile = "dot_low_low_damage",
    update_func = "apply_dot_damage",
    perk = buff_perks.burning
})
DotTypeLookup.long_burn_low_damage = "burning_dot"
DotTypeLookup.long_burn_extra_low_damage = "burning_dot"
mod:add_buff_template("burning_magma_dot", {
        duration = 3,
        name = "burning_magma_dot",
        remove_buff_func = "remove_dot_damage",
        end_flow_event = "smoke",
        start_flow_event = "burn",
        reapply_start_flow_event = true,
        apply_buff_func = "start_dot_damage",
        death_flow_event = "burn_death",
        time_between_dot_damages = 1.5,
        refresh_durations = true,
        damage_type = "burninating",
        damage_profile = "burning_dot",
        update_func = "apply_dot_damage",
        reapply_buff_func = "reapply_dot_damage",
        max_stacks = 15,
        perk = buff_perks.burning
})
mod:add_buff_template("sienna_adept_ability_trail", {
    leave_linger_time = 1.5,
    name = "sienna_adept_ability_trail",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    on_max_stacks_overflow_func = "reapply_buff",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    update_start_delay = 0.25,
    death_flow_event = "burn_death",
    time_between_dot_damages = 0.75,
    damage_type = "burninating",
    damage_profile = "burning_dot",
    update_func = "apply_dot_damage",
    max_stacks = 1,
    perk = buff_perks.burning
})

mod:add_buff_template("burning_1W_dot_unchained_push", {
    duration = 5,
    name = "burning dot",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    death_flow_event = "burn_death",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    time_between_dot_damages = 0.75,
	update_start_delay = 0.25,
    damage_type = "burninating",
    damage_profile = "burning_dot",
    update_func = "apply_dot_damage",
	max_stacks = 2,
    perk = buff_perks.burning
})
mod:add_buff_template("burning_1W_dot_unchained_team_burn", {
    duration = 5,
    name = "burning dot",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    death_flow_event = "burn_death",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    time_between_dot_damages = 1,
	update_start_delay = 0.5,
    damage_type = "burninating",
    damage_profile = "dot_low_damage",
    update_func = "apply_dot_damage",
	max_stacks = 3,
    perk = buff_perks.burning
})
DotTypeLookup.burning_1W_dot_unchained_team_burn = "burning_dot"
mod:add_buff_template("zealot_burning_debuff", {
    duration = 5,
    name = "burning dot",
    end_flow_event = "smoke",
    start_flow_event = "burn",
    death_flow_event = "burn_death",
    remove_buff_func = "remove_dot_damage",
    apply_buff_func = "start_dot_damage",
    time_between_dot_damages = 1,
	update_start_delay = 0.5,
    damage_type = "burninating",
    damage_profile = "dot_low_damage",
    update_func = "apply_dot_damage",
	max_stacks = 1,
    perk = buff_perks.burning,
	stat_buff = "damage_taken",
	multiplier = 0.1,
	max_stacks = 3,
})
DotTypeLookup.zealot_burning_debuff = "burning_dot"

mod:add_buff_template("warrior_priest_fury_burn", {
	duration = 10,
	name = "burn for sigmar",
	stat_buff = "damage_taken",
	multiplier = 0.2,
	max_stacks = 2,
	remove_buff_func = "kerillian_thorn_sister_remove_buff_from_attacker",
	apply_buff_func = "start_dot_damage_kerillian",
	update_start_delay = 0.8,
	refresh_durations = true,
	time_between_dot_damages = 0.8,
	hit_zone = "neck",
	damage_profile = "thorn_sister_poison",
	update_func = "apply_dot_damage",
	perk = buff_perks.burning
})
DotTypeLookup.warrior_priest_fury_burn = "burning_dot"

mod:modify_talent("bw_unchained", 2, 2, {
    description = "sienna_unchained_explosion_kill_desc",
    buffs = {
        "gs_exploding_enemies_on_kill"
    }
})
mod:add_text("sienna_unchained_explosion_kill_desc", "Killing an elite makes your next melee kill explode.")

mod:modify_talent_buff_template("bright_wizard", "sienna_unchained_exploding_burning_enemies", {
    proc_chance = 1,
    buff_func = "gs_sienna_on_melee_kill_explosion"
})
mod:add_text("sienna_unchained_exploding_burning_enemies_desc", "Killing burning enemies in melee makes them explode.")

ExplosionTemplates.sienna_unchained_burning_enemies_explosion.explosion = {
    use_attacker_power_level = true,
    max_damage_radius_min = 0.5,
    effect_name = "fx/wpnfx_flaming_flail_hit_01",
    radius_max = 2.5,
    sound_event_name = "fireball_big_hit",
    attacker_power_level_offset = 0.01,
    radius_min = 1,
    alert_enemies_radius = 3,
    max_damage_radius_max = 2,
    alert_enemies = true,
    damage_profile = "long_burn_explosion",
    damage_profile_glance = "long_burn_explosion_glance",
    no_friendly_fire = true
}
mod:modify_talent("bw_unchained", 4, 1, {
    description = "gs_sienna_unchained_attack_speed_on_high_overcharge_desc",
    name = "sienna_unchained_attack_speed_on_high_overcharge",
    num_ranks = 1,
    icon = "sienna_unchained_attack_speed_on_high_overcharge",
    description_values = {
        {
            value_type = "percent",
            value = 0.15
        }
    },
    buffs = {
        "sienna_unchained_attack_speed_on_high_overcharge"
    }
})
mod:add_text("gs_sienna_unchained_attack_speed_on_high_overcharge_desc", "Increases attackspeed by 15%% on high overcharge.")
mod:modify_talent("bw_unchained", 4, 2, {
    description = "sienna_flaming_weapons_to_allies",
	buffer = "both",
    buffs = {
        "gs_sienna_flaming_weapons_to_allies"
    }
})
mod:add_text("sienna_flaming_weapons_to_allies", "Killing enemies worth 60 kill thp grants flaming weapons to allies.")

mod:add_talent_buff_template("bright_wizard", "gs_sienna_unchained_increase_max_health_on_kill", {
    buff_to_add = "gs_sienna_unchained_increase_max_health_on_kill_buff",
	event = "on_kill",
    buff_func = "gs_sienna_increase_max_health_on_burning_enemy_killed"
})
mod:add_talent_buff_template("bright_wizard", "gs_sienna_unchained_increase_max_health_on_kill_buff", {
    multiplier = 0.03,
	max_stacks = 10,
	refresh_durations = true,
	duration = 10,
    stat_buff = "max_health",
	icon = "sienna_unchained_reduced_vent_damage"
})

mod:add_talent_buff_template("empire_soldier", "gs_sienna_flaming_weapons_to_allies", {
    event = "on_kill",
    buff_func = "gs_sienna_add_flaming_weapons_to_allies",
    ammo_bonus_fraction = 0.05,
	buff_to_add = "gs_sienna_flaming_weapons_to_allies_buff",
    required_kills = 60,
	display_buff = "gs_display_buff_unchained_flaming_weapons"
})
mod:add_talent_buff_template("empire_soldier", "gs_display_buff_unchained_flaming_weapons", {
    max_stacks = 100,
	icon = "sienna_unchained_increased_vent_speed"
})
mod:add_talent_buff_template("bright_wizard", "gs_sienna_flaming_weapons_to_allies_buff", {
    icon = "sienna_unchained_increased_vent_speed",
    duration = 10,
    max_stacks = 1,
	refresh_durations = true,
    proc_weight = 5,
	buff_func = "thorn_sister_add_melee_poison",
	event = "on_hit",
	poison = "burning_1W_dot_unchained_team_burn"
})

table.insert(require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names"), "team_burn")

mod:add_proc_function("gs_sienna_add_flaming_weapons_to_allies", function (owner_unit, buff, params)
	local buff_template = buff.template
	local required_kills = buff_template.required_kills
	local buff_to_add = buff_template.buff_to_add
	local buff_system = Managers.state.entity:system("buff_system")

	if not Unit.alive(owner_unit) then
		return
	end

	local killing_blow_data = params[1]

	if not killing_blow_data then
		return
	end

	local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

	if not attack_type or (attack_type ~= "light_attack" and attack_type ~= "heavy_attack") then
		return
	end

	local killed_unit_breed_data = params[2]
	local amount = killed_unit_breed_data.bloodlust_health

	if not buff.counter then
		buff.counter = 0
	end

	local counter = buff.counter

	if counter >= required_kills then
		local side = Managers.state.side.side_by_unit[owner_unit]
		local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
		local num_units = #player_and_bot_units

		for i = 1, num_units, 1 do
			local unit = player_and_bot_units[i]

			if Unit.alive(unit) then
				buff_system:add_buff(unit, buff_to_add, owner_unit, false)
			end
		end

		buff.counter = counter - required_kills
	end

	if amount then
		buff.counter = buff.counter + amount
	end

	if not Managers.state.network.is_server then
		return
	end

	local display_buff = buff_template.display_buff
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local num_buff_stacks = buff_extension:num_buff_type(display_buff)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	local distance = required_kills - counter

	if num_buff_stacks < distance then
		local difference = distance - num_buff_stacks

		for i = 1, difference, 1 do
			local buff_id = buff_system:add_buff(owner_unit, display_buff, owner_unit, true)
			local stack_ids = buff.stack_ids
			stack_ids[#stack_ids + 1] = buff_id
		end
	elseif distance < num_buff_stacks then
		local difference = num_buff_stacks - distance

		for i = 1, difference, 1 do
			local stack_ids = buff.stack_ids
			local buff_id = table.remove(stack_ids, 1)

			buff_system:remove_server_controlled_buff(owner_unit, buff_id)
		end
	end
end)

mod:add_proc_function("gs_sienna_increase_max_health_on_burning_enemy_killed", function (owner_unit, buff, params)
	local killing_blow_data = params[1]
	local killed_unit = params[3]
	local template = buff.template

	local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

    if not attack_type or (attack_type ~= "light_attack" and attack_type ~= "heavy_attack") then
        return
    end

	if Unit.alive(killed_unit) then
		local killed_unit_buff_extension = ScriptUnit.has_extension(killed_unit, "buff_system")

		if killed_unit_buff_extension and killed_unit_buff_extension:has_buff_perk("burning") then
			local buff_system = Managers.state.entity:system("buff_system")
			local buff_to_add = template.buff_to_add

			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		end
	end
end)

mod:add_proc_function("gs_sienna_on_melee_kill_explosion", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end
	
    local killed_unit = params[3]
    local killing_blow_data = params[1]

    if not killing_blow_data then
        return
    end

    if Unit.alive(owner_unit) then
        local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

        if not attack_type or (attack_type ~= "light_attack" and attack_type ~= "heavy_attack") then
            return
        end
        local ai_buff_extension = ScriptUnit.has_extension(killed_unit, "buff_system")
        local buff_template = buff.template
        local proc_chance = buff_template.proc_chance

        if math.random() <= proc_chance and ai_buff_extension and ai_buff_extension:has_buff_perk("burning") then
            local career_extension = ScriptUnit.has_extension(owner_unit, "career_system")
            local area_damage_system = Managers.state.entity:system("area_damage_system")
            local position = POSITION_LOOKUP[killed_unit]
            local damage_source = "buff"
            local explosion_template = "sienna_unchained_burning_enemies_explosion"
            local rotation = Quaternion.identity()
            local career_power_level = career_extension:get_career_power_level()
            local scale = 1
            local is_critical_strike = false

            area_damage_system:create_explosion(owner_unit, position, rotation, explosion_template, scale, damage_source, career_power_level, is_critical_strike)
        end
    end
end)
mod:modify_talent("bw_unchained", 5, 2, {
    description = "sienna_unchained_overcharged_blocks_desc",
    name = "sienna_unchained_overcharged_blocks",
    buffer = "both",
    num_ranks = 1,
    icon = "sienna_unchained_reduced_vent_damage",
    description_values = {
        {
            value_type = "percent",
            value = 0.5
        }
    },
    buffs = {
        "sienna_unchained_passive_overcharged_blocks"
    }
})
mod:add_talent_buff_template("bright_wizard", "sienna_unchained_thorn_skin", {
    event = "on_damage_taken",
	name = "thorn_skin",
	explosion_template = "thorn_skin",
	buff_func = "thorn_skin_effect"
})
mod:modify_talent("bw_unchained", 4, 3, {
    description = "sienna_unchained_reduced_overcharge_desc",
	name = "sienna_unchained_reduced_overcharge",
	num_ranks = 1,
	icon = "sienna_unchained_reduced_overcharge",
	description_values = {
		{
			value_type = "percent",
			value = -0.1
		}
	},
	buffs = {
		"sienna_unchained_reduced_overcharge_decay",
		"sienna_unchained_increased_ult_cooldown"
	}
})
mod:add_text("sienna_unchained_reduced_overcharge_desc", "Reduces overcharge decay by 50%% and increases cooldown regen on high Overcharge by up to 50%%.")

mod:add_talent_buff_template("bright_wizard", "sienna_unchained_reduced_overcharge_decay", {
    stat_buff = "overcharge_regen",
	max_stacks = 1,
	multiplier = -0.5
})
mod:add_talent_buff_template("bright_wizard", "sienna_unchained_increased_ult_cooldown",{
	buff_to_add = "sienna_unchained_ult_cooldown_on_overcharge",
	update_func = "activate_server_buff_stacks_based_on_overcharge_chunks",
	chunk_size = 6
})
mod:add_talent_buff_template("bright_wizard", "sienna_unchained_ult_cooldown_on_overcharge",{
	stat_buff = "cooldown_regen",
	icon = "sienna_unchained_reduced_overcharge",
	max_stacks = 5,
	multiplier = 0.1
})
mod:modify_talent("bw_unchained", 5, 3, {
    description = "sienna_unchained_reduced_damage_taken_after_venting_desc_2",
	name = "sienna_unchained_reduced_damage_taken_after_venting_2",
	num_ranks = 1,
	icon = "sienna_unchained_reduced_damage_taken_after_venting",
	description_values = {
		{
			value_type = "percent",
			value = -0.1
		}
	},
	buffs = {
		"sienna_unchained_reduced_overcharge",
		"sienna_unchained_increased_health"
	}
})
mod:add_text("sienna_unchained_reduced_damage_taken_after_venting_desc_2", "Increases Sienna's health by 50%% but reduces the damage taken transferred by Blood Magic to 25%%.")
mod:add_talent_buff_template("bright_wizard", "sienna_unchained_reduced_overcharge", {
	stat_buff = "damage_taken_to_overcharge",
	multiplier = 0.25,
	max_stacks = 1
})
mod:add_talent_buff_template("bright_wizard", "sienna_unchained_increased_health", {
	stat_buff = "max_health",
	multiplier = 0.5,
	max_stacks = 1
})

mod:add_text("gs_increased_overcharge_desc", "Taking damage deals damage to nearby enemies.")
DamageProfileTemplates.thorn_skin.armor_modifier.attack = { 0.5, 0.1, 1, 1, 0.25, 0 }
DamageProfileTemplates.thorn_skin.default_target.dot_template_name = "long_burn_low_damage"
DamageProfileTemplates.thorn_skin.default_target.attack_template = "burning"
DamageProfileTemplates.thorn_skin.default_target.damage_type = "burn"

mod:add_talent_buff_template("bright_wizard", "gs_sienna_unchained_reduced_cd", {
    multiplier = -0.4,
    stat_buff = "activated_cooldown",
})

mod:modify_talent("bw_unchained", 6, 1, {
    buffs = {
        "gs_sienna_unchained_reduced_cd"
    }
})
mod:add_text("sienna_unchained_activated_ability_power_on_enemies_hit_desc", "Reduces the cooldown of Living Bomb by 40.0%%.")

mod:modify_talent("bw_unchained", 6, 2, {
    buffs = {
        "sienna_unchained_activated_ability_power_on_enemies_hit"
    }
})
mod:add_text("sienna_unchained_activated_ability_fire_aura_desc", "Living Bomb grants Sienna a scorching aura that ignites nearby enemies for 10 seconds, causing damage over time. Increases the stagger power of Living Bomb. Each enemy hit by Living Bomb increases power by 5.0%% for 15 seconds. Stacks up to 5 times.")


