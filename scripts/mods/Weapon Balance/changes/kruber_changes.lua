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
local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--Mercenary
--Passive Changes
mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_ability_cooldown_on_damage_taken", {
    bonus = 0.25
})

--lvl 10
--mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_damage_on_enemy_proximity", {
--    max_stacks = 5,
--    multiplier = 0.04
--})
--mod:modify_talent("es_mercenary", 2, 1, {
--    description_values = {
--        {
--            value_type = "percent",
--            value = 0.04
--        },
--        {
--            value = 5
--        }
--    },
--})

mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_power_level_cleave", {
    multiplier = 1
})
mod:modify_talent("es_mercenary", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 1
        }
	},
})
--crit talent

mod:modify_talent("es_mercenary", 2, 3, {
	perks = {}
})
mod:add_text("markus_mercenary_crit_count_desc", "Every 5 hits grant a guaranteed critical strike.")

--lvl 20
mod:add_proc_function("gs_gain_markus_mercenary_passive_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end
	
	local owner_unit = owner_unit
	local buff_template = buff.template
	local target_number = params[4]
	local attack_type = params[2]
	local buff_to_add = buff_template.buff_to_add
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_applied = true
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	if Unit.alive(owner_unit) and target_number and 1 <= target_number and (attack_type == "light_attack" or attack_type == "heavy_attack") then
		if talent_extension:has_talent("markus_mercenary_passive_improved", "empire_soldier", true) then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_improved", owner_unit, false)
			if talent_extension:has_talent("markus_mercenary_passive_defence_on_proc", "empire_soldier", true) and buff_applied then
				buff_system:add_buff(owner_unit, "markus_mercenary_passive_defence", owner_unit, false)
			end
		end
	end

	if Unit.alive(owner_unit) and target_number and buff_template.targets <= target_number and (attack_type == "light_attack" or attack_type == "heavy_attack") then
		if talent_extension:has_talent("markus_mercenary_passive_improved", "empire_soldier", true) then
			if target_number >= 1 then
				buff_system:add_buff(owner_unit, "markus_mercenary_passive_improved", owner_unit, false)
			else
				buff_applied = false
			end
		elseif talent_extension:has_talent("markus_mercenary_passive_group_proc", "empire_soldier", true) then
			local side = Managers.state.side.side_by_unit[owner_unit]
			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
			local num_units = #player_and_bot_units

			for i = 1, num_units, 1 do
				local unit = player_and_bot_units[i]

				if Unit.alive(unit) then
					buff_system:add_buff(unit, buff_to_add, owner_unit, false)
				end
			end
		elseif talent_extension:has_talent("markus_mercenary_passive_power_level_on_proc", "empire_soldier", true) then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_power_level", owner_unit, false)
			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		else
			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		end

		if talent_extension:has_talent("markus_mercenary_passive_defence_on_proc", "empire_soldier", true) and buff_applied then
			buff_system:add_buff(owner_unit, "markus_mercenary_passive_defence", owner_unit, false)
		end
	end
end)

mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_passive_improved", {
    targets = 1
})

mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_passive", {
    buff_func = "gs_gain_markus_mercenary_passive_proc"
})

mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_passive_power_level", {
    multiplier = 0.2
})
mod:add_text("markus_mercenary_passive_improved_desc", "Paced Strikes increases attack speed by 20%%. Now requires hitting 1 target with a single attack to trigger.")
mod:modify_talent("es_mercenary", 4, 1, {
    description_values = {
        {
            value_type = "percent",
            value = 0.2
        }
	},
})

--lvl 25
--Dodge Talent
mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_dodge_range", {
	perks = { buff_perks.infinite_dodge }
})

mod:add_text("markus_mercenary_dodge_range_desc", "Increases dodge range by 20.0%% and grants infinite dodge count.")
-- Ammo Talent
mod:add_proc_function("gs_ammo_on_melee_kills", function(owner_unit, buff, params)
	local buff_template = buff.template
	local weapon_slot = "slot_ranged"
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data(weapon_slot)
	local right_unit_1p = slot_data.right_unit_1p
	local left_unit_1p = slot_data.left_unit_1p
	local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
	local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
	local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
	local ammo_bonus_fraction = buff_template.ammo_bonus_fraction
	local required_kills = buff_template.required_kills

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
		if ammo_extension then
			local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

			ammo_extension:add_ammo_to_reserve(ammo_amount)
		end

		local local_player = Managers.player:local_player()
		local local_player_unit = local_player and local_player.player_unit
		local energy_extension = ScriptUnit.has_extension(local_player_unit, "energy_system")

		if energy_extension then
			local max_energy = energy_extension:get_max()
			local energy_amount = ammo_bonus_fraction * max_energy

			energy_extension:add_energy(energy_amount)
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
	local buff_system = Managers.state.entity:system("buff_system")
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

mod:modify_talent("es_mercenary", 5, 3, {
	description = "gs_merc_ammo_on_melee_kills_desc",
	buffer = "both",
	buffs = {
		"gs_merc_ammo_on_melee_kills"
	}
})
mod:add_text("gs_merc_ammo_on_melee_kills_desc", "Enemy kills each grant a value (equal to on-kill THP), each time the value exceeds 60, gain 5%% ammo.")

mod:add_talent_buff_template("empire_soldier", "gs_merc_ammo_on_melee_kills", {
    event = "on_kill",
    buff_func = "gs_ammo_on_melee_kills",
    ammo_bonus_fraction = 0.05,
    required_kills = 60,
	display_buff = "gs_display_buff_merc_ammo"
})

mod:add_talent_buff_template("empire_soldier", "gs_display_buff_merc_ammo", {
    max_stacks = 100,
	icon = "markus_mercenary_max_ammo"
})

--lvl 30
--mod:modify_talent_buff_template("empire_soldier", "markus_mercenary_activated_ability_cooldown_no_heal", {
--    multiplier = -0.25
--})
--mod:modify_talent("es_mercenary", 6, 1, {
--    description_values = {
--        {
--            value_type = "percent",
--            value = -0.25
--        },
--    },
--})
mod:add_talent_buff_template("empire_soldier", "markus_mercenary_activated_ability_damage_reduction_revive", {
    max_stacks = 1,
    icon = "markus_mercenary_activated_ability_damage_reduction",
    stat_buff = "damage_taken",
    multiplier = -0.80,
	duration = 10
})
mod:add_text("markus_mercenary_activated_ability_revive_desc", "Morale Boost also revives knocked down allies and gives them 80%% damage reduction.")

mod:hook_origin(CareerAbilityESMercenary, "_run_ability", function(self, new_initial_speed)
	self:_stop_priming()

	local world = self._world
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	CharacterStateHelper.play_animation_event(owner_unit, "mercenary_active_ability")

	local radius = 15
	local nearby_player_units = FrameTable.alloc_table()
	local proximity_extension = Managers.state.entity:system("proximity_system")
	local broadphase = proximity_extension.player_units_broadphase

	Broadphase.query(broadphase, POSITION_LOOKUP[owner_unit], radius, nearby_player_units)

	local side_manager = Managers.state.side
	local revivable_units = FrameTable.alloc_table()

	for _, friendly_unit in pairs(nearby_player_units) do
		if not side_manager:is_enemy(self._owner_unit, friendly_unit) then
			local friendly_unit_status_extension = ScriptUnit.extension(friendly_unit, "status_system")

			if friendly_unit_status_extension:is_available_for_career_revive() then
				revivable_units[#revivable_units + 1] = friendly_unit
			end
		end
	end

	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)

	if talent_extension:has_talent("markus_mercenary_activated_ability_revive") then
		for _, player_unit in pairs(revivable_units) do
			local target_unit_go_id = network_manager:unit_game_object_id(player_unit)

			network_transmit:send_rpc_server("rpc_request_revive", target_unit_go_id, owner_unit_go_id)
			CharacterStateHelper.play_animation_event(player_unit, "revive_complete")
			local buff_system = Managers.state.entity:system("buff_system")

			buff_system:add_buff(player_unit, "markus_mercenary_activated_ability_damage_reduction_revive", self._owner_unit, false)
		end
	end

	local heal_amount = 25

	if talent_extension:has_talent("markus_mercenary_activated_ability_improved_healing") then
		heal_amount = 45
	end

	local heal_type_id = NetworkLookup.heal_types.career_skill

		for _, player_unit in pairs(nearby_player_units) do
		if not side_manager:is_enemy(self._owner_unit, player_unit) then
			local unit_go_id = network_manager:unit_game_object_id(player_unit)

			if unit_go_id then
				if talent_extension:has_talent("markus_mercenary_activated_ability_damage_reduction") then
					local buff_system = Managers.state.entity:system("buff_system")

					buff_system:add_buff(player_unit, "markus_mercenary_activated_ability_damage_reduction", self._owner_unit, false)
				end

				network_transmit:send_rpc_server("rpc_request_heal", unit_go_id, heal_amount, heal_type_id)

			end
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("ability_shout")
		first_person_extension:play_hud_sound_event("Play_career_ability_mercenary_shout_out")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_mercenary_shout_out", owner_unit, 0)
	end

	local explosion_template_name = "kruber_mercenary_activated_ability_stagger"
	local explosion_template = ExplosionTemplates[explosion_template_name]
	local scale = 1
	local damage_source = "career_ability"
	local is_husk = false
	local rotation = Quaternion.identity()
	local career_power_level = career_extension:get_career_power_level()
	local side = Managers.state.side.side_by_unit[owner_unit]
	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
	local num_player_units = #player_and_bot_units

	for i = 1, num_player_units, 1 do
		local player_unit = player_and_bot_units[i]
		local friendly_attack_intensity_extension = ScriptUnit.has_extension(player_unit, "attack_intensity_system")

		if friendly_attack_intensity_extension then
			friendly_attack_intensity_extension:add_attack_intensity("normal", 20, 20)
		end
	end

	self:_play_vo()
	self:_play_vfx()
	career_extension:start_activated_ability_cooldown()

	local position = POSITION_LOOKUP[owner_unit]
	local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
	local damage_source_id = NetworkLookup.damage_sources[damage_source]

	if is_server then
		network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	else
		network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	end

	DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false, owner_unit)
end)

--Footknight--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Passive Changes
ActivatedAbilitySettings.es_2[1].cooldown = 40
mod:hook_origin(CareerAbilityESKnight, "_run_ability", function(self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local status_extension = self._status_extension
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
	local buff_name = "markus_knight_activated_ability"

	buff_extension:add_buff(buff_name, {
		attacker_unit = owner_unit
	})

	if talent_extension:has_talent("markus_knight_ability_invulnerability", "empire_soldier", true) then
		buff_name = "markus_knight_ability_invulnerability_buff"

		buff_extension:add_buff(buff_name, {
			attacker_unit = owner_unit
		})

		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		end
	end
	
	if talent_extension:has_talent("markus_knight_wide_charge", "empire_soldier", true) then
		buff_name = "markus_knight_heavy_buff"

		buff_extension:add_buff(buff_name, {
			attacker_unit = owner_unit
		})

		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if is_server then
			network_transmit:send_rpc_clients("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		else
			network_transmit:send_rpc_server("rpc_add_buff", owner_unit_id, buff_template_name_id, owner_unit_id, 0, false)
		end
	end

	status_extension:set_noclip(true, "skill_knight")

	local hold_duration = 0.03
	local windup_duration = 0.15
	status_extension.do_lunge = {
		animation_end_event = "foot_knight_ability_charge_hit",
		allow_rotation = false,
		falloff_to_speed = 5,
		first_person_animation_end_event = "foot_knight_ability_charge_hit",
		dodge = true,
		first_person_animation_event = "foot_knight_ability_charge_start",
		first_person_hit_animation_event = "charge_react",
		damage_start_time = 0.3,
		duration = 1.5,
		initial_speed = 20,
		animation_event = "foot_knight_ability_charge_start",
		lunge_events = self._lunge_events,
		speed_function = function (lunge_time, duration)
			local end_duration = 0.25
			local rush_time = lunge_time - hold_duration - windup_duration
			local rush_duration = duration - hold_duration - windup_duration - end_duration
			local start_speed = 0
			local windup_speed = -3
			local end_speed = 20
			local rush_speed = 15
			local normal_move_speed = 2

			if rush_time <= 0 and hold_duration > 0 then
				local t = -rush_time / (hold_duration + windup_duration)

				return math.lerp(0, -1, t)
			elseif rush_time < windup_duration then
				local t_value = rush_time / windup_duration
				local interpolation_value = math.cos((t_value + 1) * math.pi * 0.5)

				return math.min(math.lerp(windup_speed, start_speed, interpolation_value), rush_speed)
			elseif rush_time < rush_duration then
				local t_value = rush_time / rush_duration
				local acceleration = math.min(rush_time / (rush_duration / 3), 1)
				local interpolation_value = math.cos(t_value * math.pi * 0.5)
				local offset = nil
				local step_time = 0.25

				if rush_time > 8 * step_time then
					offset = 0
				elseif rush_time > 7 * step_time then
					offset = (rush_time - 1.4) / step_time
				elseif rush_time > 6 * step_time then
					offset = (rush_time - 6 * step_time) / step_time
				elseif rush_time > 5 * step_time then
					offset = (rush_time - 5 * step_time) / step_time
				elseif rush_time > 4 * step_time then
					offset = (rush_time - 4 * step_time) / step_time
				elseif rush_time > 3 * step_time then
					offset = (rush_time - 3 * step_time) / step_time
				elseif rush_time > 2 * step_time then
					offset = (rush_time - 2 * step_time) / step_time
				elseif step_time < rush_time then
					offset = (rush_time - step_time) / step_time
				else
					offset = rush_time / step_time
				end

				local offset_multiplier = 1 - offset * 0.4
				local speed = offset_multiplier * acceleration * acceleration * math.lerp(end_speed, rush_speed, interpolation_value)

				return speed
			else
				local t_value = (rush_time - rush_duration) / end_duration
				local interpolation_value = 1 + math.cos((t_value + 1) * math.pi * 0.5)

				return math.lerp(normal_move_speed, end_speed, interpolation_value)
			end
		end,
		damage = {
			offset_forward = 2.4,
			height = 1.8,
			depth_padding = 0.6,
			hit_zone_hit_name = "full",
			ignore_shield = false,
			collision_filter = "filter_explosion_overlap_no_player",
			interrupt_on_max_hit_mass = true,
			power_level_multiplier = 1,
			interrupt_on_first_hit = false,
			damage_profile = "markus_knight_charge",
			width = 2,
			allow_backstab = false,
			stagger_angles = {
				max = 80,
				min = 25
			},
			on_interrupt_blast = {
				allow_backstab = false,
				radius = 3,
				power_level_multiplier = 1,
				hit_zone_hit_name = "full",
				damage_profile = "markus_knight_charge_blast",
				ignore_shield = false,
				collision_filter = "filter_explosion_overlap_no_player"
			}
		}
	}

	status_extension.do_lunge.damage.width = 5
	status_extension.do_lunge.damage.interrupt_on_max_hit_mass = false


	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end)

-- Footknight---------------------------------------------------------------------------------------------------------
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_damage_reduction", {
    multiplier = -0.15
})
mod:add_text("career_passive_desc_es_2c_2", "Reduces damage taken by 15%.")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_ability_cooldown_on_damage_taken", {
   bonus = 0.35
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura_range", {
    multiplier = -0.1
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_defence_aura", {
    multiplier = -0.1
})
mod:add_text("career_passive_desc_es_2a_2", "Aura that reduces damage taken by 10%.")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive", {
    range = 15
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_passive_range", {
    buff_to_add = "markus_knight_passive_defence_aura_range",
	update_func = "activate_buff_on_distance",
	remove_buff_func = "remove_aura_buff",
	range = 30
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard_defence", {
	buff_to_add = "markus_knight_guard_defence_buff",
	stat_buff = "damage_taken",
	update_func = "activate_buff_on_closest_distance",
	remove_buff_func = "remove_aura_buff",
	range = 15
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_guard", {
	buff_to_add = "markus_knight_passive_power_increase_buff",
	stat_buff = "power_level",
	remove_buff_func = "remove_aura_buff",
	icon = "markus_knight_passive_power_increase",
	update_func = "activate_buff_on_closest_distance",
	range = 15
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity", {
	buff_to_add = "markus_knight_damage_taken_ally_proximity_buff",
	range = 15,
	update_func = "activate_party_buff_stacks_on_ally_proximity",
	chunk_size = 1,
	max_stacks = 3,
	remove_buff_func = "remove_party_buff_stacks"
})
mod:add_buff_function("activate_party_buff_stacks_on_ally_proximity", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local range = 15
	local range_squared = range * range
	local chunk_size = template.chunk_size
	local buff_to_add = template.buff_to_add
	local max_stacks = template.max_stacks
	local side = Managers.state.side.side_by_unit[owner_unit]

	if not side then
		return
	end

	local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
	local own_position = POSITION_LOOKUP[owner_unit]
	local num_nearby_allies = 0
	local allies = #player_and_bot_units

	for i = 1, allies do
		local ally_unit = player_and_bot_units[i]

		if ally_unit ~= owner_unit then
			local ally_position = POSITION_LOOKUP[ally_unit]
			local distance_squared = Vector3.distance_squared(own_position, ally_position)

			if distance_squared < range_squared then
				num_nearby_allies = num_nearby_allies + 1
			end

			if math.floor(num_nearby_allies / chunk_size) == max_stacks then
				break
			end
		end
	end

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	for i = 1, allies do
		local unit = player_and_bot_units[i]

		if ALIVE[unit] then
			if not buff.stack_ids[unit] then
				buff.stack_ids[unit] = {}
			end

			local unit_position = POSITION_LOOKUP[unit]
			local distance_squared = Vector3.distance_squared(own_position, unit_position)
			local buff_extension = ScriptUnit.extension(unit, "buff_system")

			if range_squared < distance_squared then
				local stack_ids = buff.stack_ids[unit]

				for i = 1, #stack_ids do
					local stack_ids = buff.stack_ids[unit]
					local buff_id = table.remove(stack_ids)

					buff_system:remove_server_controlled_buff(unit, buff_id)
				end
			else
				local num_chunks = math.floor(num_nearby_allies / chunk_size)
				local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

				if num_buff_stacks < num_chunks then
					local difference = num_chunks - num_buff_stacks
					local stack_ids = buff.stack_ids[unit]

					for i = 1, difference do
						local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
						stack_ids[#stack_ids + 1] = buff_id
					end
				elseif num_chunks < num_buff_stacks then
					local difference = num_buff_stacks - num_chunks
					local stack_ids = buff.stack_ids[unit]

					for i = 1, difference do
						local buff_id = table.remove(stack_ids)

						buff_system:remove_server_controlled_buff(unit, buff_id)
					end
				end
			end
		end
	end
end)

--lvl 10
mod:modify_talent_buff_template("empire_soldier", "markus_knight_power_level_on_stagger_elite_buff", {
    duration = 15
})
mod:modify_talent("es_knight", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.multiplier
        },
        {
            value = 15 --BuffTemplates.markus_knight_power_level_on_stagger_elite_buff.duration
        }
    },
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_attack_speed_on_push_buff", {
    duration = 5
})
mod:modify_talent("es_knight", 2, 3, {
    description_values = {
        {
            value_type = "percent",
            value = 0.15 --BuffTemplates.markus_knight_attack_speed_on_push_buff.multiplier
        },
        {
            value = 5 --BuffTemplates.markus_knight_attack_speed_on_push_buff.duration
        }
    },
})

mod:add_text("markus_knight_damage_taken_ally_proximity_desc_2", "Increases damage protection from Protective Presence by 3.33%% for each nearby ally")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_damage_taken_ally_proximity_buff", {
	multiplier = -0.033
})

--lvl 25
mod:modify_talent("es_knight", 5, 2, {
	buffer = "both",
    buffs = {
		"gs_fk_piston"
	}
})

mod:add_text("markus_knight_free_pushes_on_block_desc", "Performing 8 charged attacks grants immense Stagger to Kruber's next charged attack.")

mod:add_talent_buff_template("empire_soldier", "gs_fk_piston", {
    event = "on_hit",
    buff_func = "heavies_give_buff",
	buff_to_add = "gs_fk_piston_power",
	required_heavies = 8,
	display_buff = "gs_display_buff_fk_heavies"
})

mod:add_talent_buff_template("empire_soldier", "gs_display_buff_fk_heavies", {
    max_stacks = 100,
	icon = "markus_knight_free_pushes_on_block"
})

local buff_params = {}
mod:add_proc_function("heavies_give_buff", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local attack_type = params[2]
	local target_number = params[4]

	if target_number > 1 then
		return
	end

	if attack_type ~= "heavy_attack" then
		return
	end

	local t = Managers.time:time("game")
	local delay = buff.delay

	if t and delay then
		if t < delay then
			return
		end
	end

	buff.delay = t + 0.2

	if not buff.counter then
		buff.counter = 0
	end

	local counter = buff.counter

	local buff_template = buff.template
	local required_heavies = buff_template.required_heavies

	if Unit.alive(owner_unit) and counter >= required_heavies then
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		buff_extension:add_buff("gs_fk_piston_power", buff_params)
		counter = 0
	end

	buff.counter = counter + 1

	local display_buff = buff_template.display_buff
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local num_buff_stacks = buff_extension:num_buff_type(display_buff)

	if not buff.stack_ids then
		buff.stack_ids = {}
	end

	local distance = required_heavies - counter

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

mod:add_talent_buff_template("empire_soldier", "gs_fk_piston_power", {
    event = "on_hit",
	buff_func = "markus_knight_piston_power_add",
	apply_buff_func = "bardin_engineer_piston_power_add_apply",
	buff_to_add = "bardin_engineer_piston_powered_buff",
	buff_to_remove = "markus_knight_piston_powered_ready",
	buffs_to_remove_on_remove = {
		"markus_knight_piston_powered_ready"
	}
})

mod:add_talent_buff_template("empire_soldier", "markus_knight_piston_powered_ready",{
	max_stacks = 1,
	icon = "markus_knight_free_pushes_on_block",
	event = "on_start_action",
	buff_func = "bardin_engineer_piston_power_sound"
})

mod:add_proc_function("markus_knight_piston_power_add", function (owner_unit, buff, params)

	if ALIVE[owner_unit] then
		local attack_type = params[2]

		if attack_type ~= "heavy_attack" then
			return
		end

		local template = buff.template
		local buff_to_add = template.buff_to_add
		local buff_to_remove = template.buff_to_remove
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		if buff_extension:has_buff_type(buff_to_remove) then
			local has_buff_to_remove = buff_extension:get_non_stacking_buff(buff_to_remove)

			if has_buff_to_remove then
				buff_extension:remove_buff(has_buff_to_remove.id)
			end

			local buff_system = Managers.state.entity:system("buff_system")

			buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
		end
	end
end)

local function is_server()
	return Managers.player.is_server
end

mod:add_proc_function("gs_block_gives_buff", function(owner_unit, buff, params)
	
	if ALIVE[owner_unit] then
		if not buff.counter then
			buff.counter = 0
		end

		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
		local buff_template = buff.template
		local buff_name = buff_template.buff_to_add
		local buff_name_check = buff_template.buff_name_check

		if buff_extension:has_buff_type(buff_name_check) then
			return
		end

		local counter = buff.counter
		local required_blocks = buff_template.required_blocks
		local network_manager = Managers.state.network
		local network_transmit = network_manager.network_transmit
		local unit_object_id = network_manager:unit_game_object_id(owner_unit)
		local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

		if counter >= required_blocks then
			counter = 0
			if is_server() then
				buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
			end
		end

		buff.counter = counter + 1
	end
end)
mod:modify_talent_buff_template("empire_soldier", "markus_knight_free_pushes_on_block_buff", {
	duration = 2
})
mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_on_stagger_elite", {
    buff_func = "buff_on_stagger_enemy"
})
mod:add_buff_function("markus_knight_movespeed_on_incapacitated_ally", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local num_units = #player_and_bot_units
    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
    local buff_system = Managers.state.entity:system("buff_system")
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local disabled_allies = 0

    for i = 1, num_units, 1 do
        local unit = player_and_bot_units[i]
        local status_extension = ScriptUnit.extension(unit, "status_system")
        local is_disabled = status_extension:is_disabled()

        if is_disabled then
            disabled_allies = disabled_allies + 1
        end
    end

	if not buff.disabled_allies then
		buff.disabled_allies = 0
	end

    if buff_extension:has_buff_type(buff_to_add) then
        if disabled_allies <= buff.disabled_allies then
            local buff_id = buff.buff_id

            if buff_id then
                buff_system:remove_server_controlled_buff(owner_unit, buff_id)

                buff.buff_id = nil
            end
        end
    elseif disabled_allies > 0 and disabled_allies > buff.disabled_allies then
        buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
    end

	buff.disabled_allies = disabled_allies
end)

mod:add_buff_function("markus_knight_cooldown_on_incapacitated_ally", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    local side = Managers.state.side.side_by_unit[owner_unit]
    local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
    local num_units = #player_and_bot_units
    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
    local buff_system = Managers.state.entity:system("buff_system")
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local disabled_allies = nil

    for i = 1, num_units, 1 do
        local unit = player_and_bot_units[i]
        local status_extension = ScriptUnit.extension(unit, "status_system")
        local is_disabled = status_extension:is_disabled()

        if is_disabled then
            disabled_allies = true
        end
    end

    if buff_extension:has_buff_type(buff_to_add) then
        if not disabled_allies then
            local buff_id = buff.buff_id

            if buff_id then
                buff_system:remove_server_controlled_buff(owner_unit, buff_id)

                buff.buff_id = nil
            end
        end
    elseif disabled_allies then
        buff.buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
    end
end)

mod:modify_talent_buff_template("empire_soldier", "markus_knight_movement_speed_on_incapacitated_allies", {
    buff_to_add = "markus_knight_cooldown_on_incapacitated_allies_buff",
    update_func = "markus_knight_cooldown_on_incapacitated_ally"
})

mod:add_talent_buff_template("empire_soldier", "markus_knight_cooldown_on_incapacitated_allies_buff", {
    multiplier = 10,
    stat_buff = "cooldown_regen"
})

mod:add_text("markus_knight_charge_reset_on_incapacitated_allies_desc", "When an ally is incapacitated the cooldown of Valiant Charge is accelerated by 1000%%. ")

mod:modify_talent_buff_template("empire_soldier", "markus_knight_cooldown_buff", {
    duration = 1.5,
    multiplier = 2,
	icon = "markus_knight_improved_passive_defence_aura"
})
mod:add_text("markus_knight_cooldown_on_stagger_elite_desc", "Staggering an elite accelerates the cooldown of Valiant charge by 200%% for 1.5 seconds")

--lvl 30
mod:add_text("markus_knight_ability_invulnerability_desc", "Valiant Charge grants invulnerability and disabler immunity for 4 seconds.")
mod:modify_talent_buff_template("empire_soldier", "markus_knight_ability_invulnerability_buff", {
	duration = 4,
	perks = { buff_perks.ledge_self_rescue }
})

mod:add_talent_buff_template("empire_soldier", "markus_knight_heavy_buff", {
    max_stacks = 1,
    stat_buff = "power_level_melee",
    icon = "markus_knight_ability_hit_target_damage_taken",
    multiplier = 0.5,
    duration = 6,
    refresh_durations = true,
})
mod:modify_talent("es_knight", 6, 2, {
    description = "rebaltourn_markus_knight_heavy_buff_desc",
    description_values = {},
})
mod:add_text("rebaltourn_markus_knight_heavy_buff_desc", "Valiant Charge increases Melee Power by 50.0%% for 6 seconds.")

--Huntsman
--Passive Changes
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_passive_crit_aura", {
    range = 15
})
mod:add_talent_buff_template("empire_soldier", "markus_huntsman_reload_passive", {
    stat_buff = "reload_speed",
	max_stacks = 1,
	multiplier = -0.15
})

table.insert(PassiveAbilitySettings.es_1.buffs, "kerillian_waywatcher_passive_increased_zoom")
mod:add_text("career_passive_desc_es_1b", "Double effective range for ranged weapons and 15% increased reload speed.")

mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed", {
	multiplier = -0.25
})
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability_increased_reload_speed_duration", {
	multiplier = -0.25
})
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_activated_ability", {
	reload_speed_multiplier = -0.25
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_1", {
    multiplier = -1,
    stat_buff = "reduced_spread",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_2", {
    multiplier = -1,
    stat_buff = "reduced_spread_hit",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_3", {
    multiplier = -3,
    stat_buff = "reduced_spread_moving",
})
mod:add_talent_buff_template("empire_soldier", "gs_sniper_buff_4", {
    multiplier = -3,
    stat_buff = "reduced_spread_shot",
})
mod:modify_talent("es_huntsman", 5, 3, {
    num_ranks = 1,
	description = "gs_sniper_desc",
    description_values = {},
    buffs = {
        "gs_sniper_buff_1",
		"gs_sniper_buff_2",
		"gs_sniper_buff_3",
		"gs_sniper_buff_4"
    },
})
mod:add_text("gs_sniper_desc", "Makes all ranged attacks pin point accurate and removes aim punch.")

mod:modify_talent("es_huntsman", 2, 2, {
	description = "gs_hs_2_2_desc",
	name = "gs_hs_2_2_name",
	buffer = "both",
	buffs = {
		"gs_haste"
	}
})
mod:add_text("gs_hs_2_2_desc", "Every ranged hit has a 10%% chance to activate Haste. When Haste is active you gain 40%% attack speed and your reloads dont consume ammo for 7 seconds.")
mod:add_text("gs_hs_2_2_name", "Haste")

mod:add_proc_function("gs_proc_haste", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local buff_system = Managers.state.entity:system("buff_system")
	local hit_unit = params[1]
	local target_number = params[4]
	local buff_type = params[5]
	local has_procced = buff.has_procced
	local breed = AiUtils.unit_breed(hit_unit)
	local template = buff.template
	local proc_chance = template.proc_chance

	if target_number == 1 then
		buff.has_procced = false
		has_procced = false
	end

	if Unit.alive(owner_unit) and math.random(1, 100) <= proc_chance and breed and buff_type == "RANGED" and not has_procced then
		buff.has_procced = true
		buff_system:add_buff(owner_unit, "gs_haste_buff", owner_unit, false)
		buff_system:add_buff(owner_unit, "no_ammo_consumed", owner_unit, false)
	end
end)

mod:add_talent_buff_template("empire_soldier", "gs_haste", {
	event = "on_hit",
	proc_chance = 10,
	buff_func = "gs_proc_haste"
})
mod:add_talent_buff_template("empire_soldier", "gs_haste_buff", {
	duration = 7,
	max_stacks = 1,
	stat_buff = "attack_speed",
	multiplier = 0.4,
	icon = "markus_huntsman_debuff_defence_on_crit",
	refresh_durations = true
})
mod:add_talent_buff_template("empire_soldier", "no_ammo_consumed", {
	duration = 7,
	max_stacks = 1,
})

mod:add_proc_function("gs_heal_on_ranged_kill", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	if ALIVE[owner_unit] then
		local killing_blow_data = params[1]

		if not killing_blow_data then
			return
		end

		local attack_type = killing_blow_data[DamageDataIndex.ATTACK_TYPE]

		if attack_type and (attack_type == "projectile" or attack_type == "instant_projectile") then
			local breed = params[2]

			if breed and breed.bloodlust_health and not breed.is_hero then
				local heal_amount = (breed.bloodlust_health * 0.25) or 0

				DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
			end
		end
	end
end)
mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_passive_temp_health_on_headshot", {
	bonus = nil,
	event = "on_kill",
	buff_func = "gs_heal_on_ranged_kill"
})
mod:modify_talent("es_huntsman", 4, 3, {
	description = "gs_hs_4_3_desc",
})
mod:add_text("gs_hs_4_3_desc", "Ranged kills restore thp equal to a quarter of bloodlust.")
--
--mod:modify_talent_buff_template("empire_soldier", "markus_huntsman_defence_buff", {
--	multiplier = -0.05,
--	duration = 15
--})
--mod:modify_talent("es_huntsman", 5, 2, {
--	description = "gs_hs_5_2_desc",
--	buffs = {
--		"markus_huntsman_stacking_damage_reduction_on_kills"
--	}
--})
--mod:add_text("gs_hs_5_2_desc", "Gain 5%% dr when killing elites or specials for 15 seconds. Stacks 4 times.")


--Grail Knight
--Passive Changes
ActivatedAbilitySettings.es_4[1].cooldown = 60
DamageProfileTemplates.questing_knight_career_sword.cleave_distribution.attack = 0.2
DamageProfileTemplates.questing_knight_career_sword_stab.cleave_distribution.attack = 0.2
DamageProfileTemplates.questing_knight_career_sword_tank.cleave_distribution.attack = 0.75
DamageProfileTemplates.questing_knight_career_sword.critical_strike.attack_armor_power_modifer[3] = 1
DamageProfileTemplates.questing_knight_career_sword_stab.critical_strike.attack_armor_power_modifer[3] = 1.25
DamageProfileTemplates.questing_knight_career_sword_tank.critical_strike.attack_armor_power_modifer[3] = 1
DamageProfileTemplates.questing_knight_career_sword.default_target.boost_curve_coefficient_headshot = 1
DamageProfileTemplates.questing_knight_career_sword_stab.default_target.boost_curve_coefficient_headshot = 1
DamageProfileTemplates.questing_knight_career_sword_tank.default_target.boost_curve_coefficient_headshot = 1

--lvl 10
--crit talent
mod:add_talent_buff_template("empire_soldier", "gs_extra_crit_2_2", {
    bonus = 0.1,
    stat_buff = "critical_strike_chance"
})

mod:modify_talent("es_questingknight", 2, 2, {
	description = "gs_markus_questing_knight_crit_can_insta_kill_desc",
	buffer = "both",
	buffs = {
		"markus_questing_knight_crit_can_insta_kill"
	},
})
mod:add_text("gs_markus_questing_knight_crit_can_insta_kill_desc", "Critical strikes instantly slay enemies if their current health is less than 4 times the amount of damage of the critical strike. Half effect versus Lords and monsters.")

mod:modify_talent("es_questingknight", 2, 3, {
    num_ranks = 1,
    icon = "markus_questing_knight_charged_attacks_increased_power",
    description = "gs_markus_questing_knight_first_target_increase_desc",
    description_values = {
        {
            value_type = "multiplier",
            value = 0.45
        }
    },
    buffs = {
        "gs_markus_questing_knight_first_target_increase"
    },
})
mod:add_text("gs_markus_questing_knight_first_target_increase_desc", "Increases first target damage bonus by 45%%.")

mod:add_talent_buff_template("empire_soldier", "gs_markus_questing_knight_first_target_increase", {
    stat_buff = "first_melee_hit_damage",
    multiplier = 0.45,
})

--lvl 20
--potion quest
mod:add_text("markus_questing_knight_parry_increased_power_desc", "Increases dodge range by 20%% and grants infinite effective dodges.")
mod:modify_talent("es_questingknight", 5, 2,{
	buffs = {
		"markus_mercenary_dodge_range",
		"markus_mercenary_dodge_speed"
	}
})


--lvl 30
mod:modify_talent("es_questingknight", 6, 2, {
    buffs = {
		"gs_markus_cooldown_reduction",
	}
})
mod:add_talent_buff_template("empire_soldier", "gs_markus_cooldown_reduction", {
	stat_buff = "activated_cooldown",
	multiplier = -0.3
})
mod:modify_talent_buff_template("empire_soldier", "markus_questing_knight_ability_buff_on_kill_movement_speed", {
	perks = { buff_perks.no_ranged_knockback }
})
mod:add_text("markus_questing_knight_ability_buff_on_kill_desc", "Killing an enemy with Blessed Blade increases movement speed by 35%% for 15 seconds and grants immunity to ranged knockback. Reduces cooldown by 30%%.")

mod:hook_origin(ActionCareerESQuestingKnight, "client_owner_post_update" , function (self, dt, t, world, can_damage, current_time_in_action)
	ActionCareerESQuestingKnight.super.client_owner_post_update(self, dt, t, world, can_damage, current_time_in_action)

	if not self._hit_fx_triggered and self._started_damage_window then
		self._hit_fx_triggered = true
		local first_person_extension = ScriptUnit.extension(self.owner_unit, "first_person_system")
		local rot = first_person_extension:current_rotation()
		local direction = Vector3.flat(Quaternion.forward(rot))
		local network_manager = Managers.state.network
		local effect_name = "fx/grail_knight_active_ability"
		local effect_name_id = NetworkLookup.effects[effect_name]
		local node_id = 0
		local vfx_settings = self.current_action.vfx_settings
		local forward_offset = vfx_settings.forward or 0
		local up_offset = vfx_settings.up or 0
		local start_position = POSITION_LOOKUP[self.owner_unit] + direction * forward_offset + Vector3.up() * up_offset
		local rotation_offset = vfx_settings.pitch and Quaternion.multiply(rot, Quaternion(Vector3.right(), vfx_settings.pitch)) or Quaternion.identity()

		network_manager:rpc_play_particle_effect(nil, effect_name_id, NetworkConstants.invalid_game_object_id, node_id, start_position, rotation_offset, false)
		local talent_extension = self.talent_extension

		if talent_extension:has_talent("markus_questing_knight_ability_buff_on_kill", "empire_soldier", true) then
			local owner_unit = self.owner_unit
			local buff_system = Managers.state.entity:system("buff_system")

			buff_system:add_buff(owner_unit, "markus_questing_knight_ability_buff_on_kill_movement_speed", owner_unit, false)
		end
	end
end)

local side_quest_challenge_gs = {
	reward = "markus_questing_knight_passive_strength_potion",
	type = "kill_enemies",
	amount = {
		1,
		100,
		125,
		150,
		175,
		200,
		250,
		300
	}
}

mod:hook_origin(PassiveAbilityQuestingKnight, "_get_side_quest_challenge", function(self)
	local side_quest_challenge = side_quest_challenge_gs

	return side_quest_challenge
end)

