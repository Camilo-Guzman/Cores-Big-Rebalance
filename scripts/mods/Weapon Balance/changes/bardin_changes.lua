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

local buff_perks = require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names")

--Iron Breaker
mod:add_text("career_active_desc_dr_1", "Bardin taunts all nearby man-sized enemies and takes -50% damage (stacks with Dwarf-Forged) for the next 10 seconds")
mod:hook_origin(CareerAbilityDRIronbreaker, "_run_ability", function(self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local owner_unit_id = network_manager:unit_game_object_id(owner_unit)
	local career_extension = self._career_extension
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	CharacterStateHelper.play_animation_event(owner_unit, "iron_breaker_active_ability")

	local buffs = {
		"bardin_ironbreaker_activated_ability",
		"bardin_ironbreaker_activated_ability_attack_intensity_decay_increase"
	}

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		table.clear(buffs)

		buffs = {
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration",
			"bardin_ironbreaker_activated_ability_taunt_range_and_duration_attack_intensity_decay_increase"
		}
	end
	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_bosses") then
		table.clear(buffs)

		buffs = {
			"bardin_ironbreaker_activated_ability",
			"bardin_ironbreaker_activated_ability_attack_intensity_decay_increase",
			"deus_guard_aura"
		}
	end

	local targets = FrameTable.alloc_table()
	targets[1] = owner_unit
	local range = 10
	local duration = 10

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_range_and_duration") then
		duration = 10
		range = 15
	end

	if talent_extension:has_talent("bardin_ironbreaker_activated_ability_power_buff_allies") then
		local side = Managers.state.side.side_by_unit[owner_unit]
		local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
		local num_targets = #player_and_bot_units

		for i = 1, num_targets, 1 do
			local target_unit = player_and_bot_units[i]
			local ally_position = POSITION_LOOKUP[target_unit]
			local owner_position = POSITION_LOOKUP[owner_unit]
			local distance_squared = Vector3.distance_squared(owner_position, ally_position)
			local range_squared = range * range

			if distance_squared < range_squared then
				local buff_to_add = "bardin_ironbreaker_activated_ability_power_buff"
				local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
				local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")
				local buff_template_name_id = NetworkLookup.buff_templates[buff_to_add]

				if is_server then
					target_buff_extension:add_buff(buff_to_add)
					network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
				else
					network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
				end
			end
		end
	end

	local stagger = true
	local taunt_bosses = talent_extension:has_talent("bardin_ironbreaker_activated_ability_taunt_bosses")

	if is_server then
		local target_override_extension = ScriptUnit.extension(owner_unit, "target_override_system")

		target_override_extension:taunt(range, duration, stagger, taunt_bosses)
	else
		network_transmit:send_rpc_server("rpc_taunt", owner_unit_id, range, duration, stagger, taunt_bosses)
	end

	local num_targets = #targets

	for i = 1, num_targets, 1 do
		local target_unit = targets[i]
		local target_unit_object_id = network_manager:unit_game_object_id(target_unit)
		local target_buff_extension = ScriptUnit.extension(target_unit, "buff_system")

		for j, buff_name in ipairs(buffs) do
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			if is_server then
				target_buff_extension:add_buff(buff_name, {
					attacker_unit = owner_unit
				})
				network_transmit:send_rpc_clients("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, false)
			else
				network_transmit:send_rpc_server("rpc_add_buff", target_unit_object_id, buff_template_name_id, owner_unit_id, 0, true)
			end
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("ability_shout")
		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_ironbreaker_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_bardin_ironbreaker_enter", owner_unit, 0)
	end

	self:_play_vfx()
	self:_play_vo()
	career_extension:start_activated_ability_cooldown()
end)

mod:add_text("career_passive_desc_dr_1b_2", "Reduces damage taken by 30% and removes slow from Drake Fire overcharge.")

mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_passive_increased_defence", {
	perk = buff_perks.overcharge_no_slow
})
mod:add_talent_buff_template("dwarf_ranger", "gs_ib_decreased_heat_cost", {
	stat_buff = "reduced_overcharge",
	multiplier = -0.2,
	max_stacks = 1
})
mod:add_talent_buff_template("dwarf_ranger", "gs_ib_increased_drakefire_speed", {
	stat_buff = "attack_speed_drakefire",
	multiplier = 0.2,
	max_stacks = 1
})
mod:modify_talent("dr_ironbreaker", 2, 1, {
	buffs = {
		"gs_ib_decreased_heat_cost",
		"gs_ib_increased_drakefire_speed"
	}
})
mod:add_text("bardin_ironbreaker_overcharge_increase_power_lowers_attack_speed_desc", "Drake Fire heat cost reduced by 20%% and Drake Fire attack speed increased by 20%%.")
mod:add_text("bardin_ironbreaker_party_power_on_blocked_attacks_desc", "Blocking an attack grants Bardin and his allies 3%% melee power for 15 seconds. Stacks 5 times.")
mod:add_text("bardin_ironbreaker_rising_attack_speed_desc", "Periodically generate stacks (up to 5 max) of Rising Anger every 7 seconds while Gromril is active. Each stack gives 3%% attack speed. When Gromril is lost, gain 6.0%% attack speed per stack of Rising Anger for 15 seconds.")
mod:add_text("bardin_ironbreaker_gromril_stagger_desc", "When Gromril Armour is removed all nearby enemies are knocked back. Increases the cooldown of Gromril to 25 seconds.")
mod:add_text("bardin_ironbreaker_activated_ability_taunt_range_and_duration_desc", "Increases the radius of Impenetrable's taunt by 50%%.")
mod:add_text("bardin_ironbreaker_power_on_nearby_allies_desc", "Each nearby ally increases power by 7.5%%.")


local function is_local(unit)
	local player = Managers.player:owner(unit)

	return player and not player.remote
end
local function is_server()
	return Managers.player.is_server
end

mod:add_proc_function("add_gromril_delay", function (owner_unit, buff, params)
	if not ALIVE[owner_unit] then
		return
	end

	if is_local(owner_unit) or is_server() then
		local buff_name = "bardin_ironbreaker_gromril_delay"
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

		if talent_extension:has_talent("bardin_ironbreaker_max_gromril_delay", "dwarf_ranger", true) then
			buff_name = "bardin_ironbreaker_gromril_delay_short"
		end

		if talent_extension:has_talent("bardin_ironbreaker_gromril_stagger", "dwarf_ranger", true) then
			buff_name = "bardin_ironbreaker_gromril_delay_long"
		end

		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		buff_extension:add_buff(buff_name)
	end
end)

mod:add_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_delay_long", {
	buff_to_add = "bardin_ironbreaker_gromril_armour",
	name = "gromril_delay_long",
	max_stacks = 1,
	refresh_durations = true,
	duration_end_func = "add_buff_local",
	is_cooldown = true,
	icon = "bardin_ironbreaker_gromril_armour",
	duration = 25
})

mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_power_on_nearby_allies", {
	range = 10,
	multiplier = 0.075
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_party_power_on_blocked_attacks_buff", {
	duration = 15, -- 0.10,
	multiplier = 0.03
})
--mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_stacking_buff_gromril", {
--	max_sub_buff_stacks = 3,
--	update_frequency = 10
--})
--mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_rising_anger", {
--	max_stacks = 3
--})
--mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_attack_speed", {
--	presentation_delay = 15,
--	duration = 15,
--	multiplier = 0.15
--})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_rising_anger", {
	stat_buff = "attack_speed",
	multiplier = 0.03
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_ironbreaker_gromril_attack_speed", {
	multiplier = 0.06,
	duration = 15
})

mod:modify_talent("dr_ironbreaker", 5, 3, {
	buffer = "both",
	buffs = {
		"bardin_engineer_piston_powered"
	}
})
mod:add_text("bardin_ironbreaker_regen_stamina_on_charged_attacks_desc", "Every 15 seconds Bardin gains a buff that grants immense Stagger to his next charged attack.")
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_piston_powered_delay", {
	icon = "bardin_ironbreaker_regen_stamina_on_charged_attacks"
})
mod:modify_talent_buff_template("dwarf_ranger", "bardin_engineer_piston_powered_ready", {
	icon = "bardin_ironbreaker_regen_stamina_on_charged_attacks"
})

--mod:add_proc_function("deus_guard_buff_on_damage", function(owner_unit, buff, params)
--	if not is_server() then
--		return
--	end
--
--
--	if ALIVE[owner_unit] then
--		local guardian_unit = buff.attacker_unit
--		local attacker_unit = params[1]
--		local damage_dealt = params[2]
--		local damage_type = params[3]
--
--		if owner_unit ~= guardian_unit and damage_type ~= "life_tap" then
--			local buff_extension = ScriptUnit.extension(guardian_unit, "buff_system")
--			local dr_amount = buff_extension:apply_buffs_to_value(1, "damage_taken")
--
--			if buff_extension:has_buff_type("deus_guard_buff") then
--				dr_amount = dr_amount / -1
--			end
--
--			damage_dealt = damage_dealt * dr_amount
--
--
--			DamageUtils.add_damage_network(guardian_unit, attacker_unit, damage_dealt, "torso", "life_tap", nil, Vector3(0, 0, 0), "life_tap", nil, owner_unit)
--		end
--	end
--end)
--
--BuffTemplates.deus_guard_buff.buffs[1].multiplier = -1
--BuffTemplates.deus_guard_aura.buffs[1].duration = 10
--BuffTemplates.deus_guard_aura.buffs[1].icon = "bardin_ironbreaker_regen_stamina_on_charged_attacks"

--Ranger Veteran--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mod:add_talent_buff_template("dwarf_ranger", "gs_increased_dupe_healing", {
	stat_buff = "not_consume_medpack",
	proc_chance = 0.1
})
mod:add_talent_buff_template("dwarf_ranger", "gs_increased_dupe_potion", {
	stat_buff = "not_consume_potion",
	proc_chance = 0.1
})
mod:add_talent_buff_template("dwarf_ranger", "gs_increased_dupe_bomb", {
	stat_buff = "not_consume_grenade",
	proc_chance = 0.1
})
mod:modify_talent("dr_ranger", 2,1, {
	buffs = {
		"gs_increased_dupe_healing",
		"gs_increased_dupe_potion",
		"gs_increased_dupe_bomb"
	}
})
mod:add_text("bardin_ranger_increased_melee_damage_on_no_ammo_desc", "Increase dupe chance of items by 10%%.")
mod:add_proc_function("gs_attack_speed_on_empty_clip_func", function (owner_unit, buff, params)
	local buff_system = Managers.state.entity:system("buff_system")
	local template = buff.template
	local buff_to_add = template.buff_to_add
	local weapon_slot = "slot_ranged"
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local slot_data = inventory_extension:get_slot_data(weapon_slot)
	local right_unit_1p = slot_data.right_unit_1p
	local left_unit_1p = slot_data.left_unit_1p
	local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
	local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
	local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
	if ammo_extension and ammo_extension:ammo_count() == 0 then
		buff_system:add_buff(owner_unit, buff_to_add, owner_unit, false)
	end
end)

mod:add_talent_buff_template("dwarf_ranger", "gs_attack_speed_on_empty_clip", {
	buff_to_add = "gs_attack_speed_on_empty_clip_buff",
	event = "on_ammo_used",
	buff_func = "gs_attack_speed_on_empty_clip_func"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_attack_speed_on_empty_clip_buff", {
	stat_buff = "attack_speed",
	multiplier = 0.05,
	duration = 15,
	icon = "bardin_ranger_attack_speed",
	max_stacks = 3,
	refresh_durations = true
})
mod:modify_talent("dr_ranger", 2, 3, {
	buffs = {
		"gs_attack_speed_on_empty_clip"
	}
})
mod:add_text("bardin_ranger_attack_speed_desc", "When Bardin empties a clip he gains 5%% attack speed for 15 seconds. Stacks 3 times.")

mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_passive", {
	buff_func = "gs_bardin_ranger_scavenge_proc"
})
mod:add_proc_function("gs_bardin_ranger_scavenge_proc", function (owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end
	
	local offset_position_1 = Vector3(0, 0.25, 0)
	local offset_position_2 = Vector3(0, -0.25, 0)

	if Unit.alive(owner_unit) then
		local drop_chance = buff.template.drop_chance
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
		local result = math.random(1, 100)

		if result < drop_chance * 100 then
			local player_pos = POSITION_LOOKUP[owner_unit] + Vector3.up() * 0.1
			local raycast_down = true
			local pickup_system = Managers.state.entity:system("pickup_system")

			if talent_extension:has_talent("bardin_ranger_passive_spawn_potions_or_bombs", "dwarf_ranger", true) then
				local counter = buff.counter
				local spawn_requirement = 9
				if counter == 5 then
					local randomness = math.random(1, 4)
					buff.counter = buff.counter + randomness
				end

				if not counter or counter >= spawn_requirement then
					local potion_result = math.random(1, 5)

					if potion_result >= 1 and potion_result <= 3 then
						local game_mode_key = Managers.state.game_mode:game_mode_key()
						local custom_potions = BardinScavengerCustomPotions[game_mode_key]
						local damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown
						local speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown
						local cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown

						if custom_potions then
							local custom_potion_result = math.random(1, #custom_potions)

							pickup_system:buff_spawn_pickup(custom_potions[custom_potion_result], player_pos, raycast_down)
						elseif (potion_result == 1 and not damage_boost_potion_cooldown) or (damage_boost_potion_cooldown and damage_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("damage_boost_potion", player_pos, raycast_down)
							buff.damage_boost_potion_cooldown = 0
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 2 and not speed_boost_potion_cooldown) or (speed_boost_potion_cooldown and speed_boost_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("speed_boost_potion", player_pos, raycast_down)
							buff.speed_boost_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if cooldown_reduction_potion_cooldown then
								buff.cooldown_reduction_potion_cooldown = buff.cooldown_reduction_potion_cooldown + 1
							else
								buff.cooldown_reduction_potion_cooldown = 2
							end
						elseif (potion_result == 3 and not cooldown_reduction_potion_cooldown) or (cooldown_reduction_potion_cooldown and cooldown_reduction_potion_cooldown >= 2) then
							pickup_system:buff_spawn_pickup("cooldown_reduction_potion", player_pos, raycast_down)
							buff.cooldown_reduction_potion_cooldown = 0
							if damage_boost_potion_cooldown then
								buff.damage_boost_potion_cooldown = buff.damage_boost_potion_cooldown + 1
							else
								buff.damage_boost_potion_cooldown = math.random(1, 2)
							end
							if speed_boost_potion_cooldown then
								buff.speed_boost_potion_cooldown = buff.speed_boost_potion_cooldown + 1
							else
								buff.speed_boost_potion_cooldown = 2
							end
						end
					elseif potion_result == 4 then
						pickup_system:buff_spawn_pickup("frag_grenade_t1", player_pos, raycast_down)
					elseif potion_result == 5 then
						pickup_system:buff_spawn_pickup("fire_grenade_t1", player_pos, raycast_down)
					end
					buff.counter = 0
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
					buff.counter = buff.counter + 1
				end
			elseif talent_extension:has_talent("bardin_ranger_passive_improved_ammo") then
				pickup_system:buff_spawn_pickup("ammo_ranger_improved", player_pos, raycast_down)
			elseif talent_extension:has_talent("bardin_ranger_passive_ale") then
				local drop_result = math.random(1, 4)

				if drop_result == 1 or drop_result == 2 then
					pickup_system:buff_spawn_pickup("bardin_survival_ale", player_pos + offset_position_1, raycast_down)
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos + offset_position_2, raycast_down)
				else
					pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
				end
			else
				pickup_system:buff_spawn_pickup("ammo_ranger", player_pos, raycast_down)
			end
		end
	end
end)
BuffTemplates.bardin_survival_ale_buff.buffs[1].multiplier = -0.05
BuffTemplates.bardin_survival_ale_buff.buffs[1].max_stacks = 2
BuffTemplates.bardin_survival_ale_buff.buffs[1].duration = 420
BuffTemplates.bardin_survival_ale_buff.buffs[2].multiplier = 0.075
BuffTemplates.bardin_survival_ale_buff.buffs[2].max_stacks = 2
BuffTemplates.bardin_survival_ale_buff.buffs[2].duration = 420
BuffTemplates.bardin_survival_ale_buff.buffs[3] = {
	time_between_heals = 1,
	heal_amount = 2,
	name = "ale_heal",
	max_stacks = 1,
	refresh_durations = true,
	update_func = "bardin_ranger_heal_smoke",
	duration = 5
}
Weapons.bardin_survival_ale.actions.action_one.default.anim_time_scale = 2

mod:add_text("bardin_ranger_passive_ale_desc", "Killing a Special grants 50%% chance to drop a bottle of ale. Ale grants 7.5%% attack speed and reduces damage taken by 5%% for 420 seconds when consumed. Also heals for 2 temporary health for 5 seconds. Can stack 2 times.")
mod:add_text("bardin_ranger_passive_spawn_potions_or_bombs_desc", "Killing a special has a 13%% chance to drop a potion or bomb instead of a Survivalist cache.")

mod:add_talent_buff_template("dwarf_ranger", "gs_dr_sniper_buff_1", {
    multiplier = -1,
    stat_buff = "reduced_spread",
})
mod:add_talent_buff_template("dwarf_ranger", "gs_dr_sniper_buff_2", {
    multiplier = -1,
    stat_buff = "reduced_spread_hit",
})
mod:add_talent_buff_template("dwarf_ranger", "gs_dr_sniper_buff_3", {
    multiplier = -3,
    stat_buff = "reduced_spread_moving",
})
mod:add_talent_buff_template("dwarf_ranger", "gs_dr_sniper_buff_4", {
    multiplier = -3,
    stat_buff = "reduced_spread_shot",
})
mod:modify_talent("dr_ranger", 5, 1, {
	description = "gs_sniper_desc",
    description_values = {},
    buffs = {
        "gs_dr_sniper_buff_1",
		"gs_dr_sniper_buff_2",
		"gs_dr_sniper_buff_3",
		"gs_dr_sniper_buff_4"
    },
})
mod:add_text("gs_sniper_desc", "Makes all ranged attacks pin point accurate and removes aim punch.")

mod:modify_talent_buff_template("dwarf_ranger", "bardin_ranger_reduced_damage_taken_headshot_buff", {
	multiplier = -0.2
})

mod:modify_talent("dr_ranger", 5, 2, {
    description_values = {
		{
			value_type = "percent",
			value = -0.2
		},
		{
			value = 7
		}
	},
})
mod:add_text("bardin_ranger_activated_ability_stealth_outside_of_smoke_desc", "Disengage's stealth does not break on moving beyond the smoke cloud. Gain additional ranged power and cleave while concealed.")
mod:hook_origin(CareerExtension, "has_ranged_boost", function(self)
	local buff_extension = self._buff_extension
	local has_murder_hobo_buff = buff_extension:has_buff_type("markus_huntsman_activated_ability") or buff_extension:has_buff_type("markus_huntsman_activated_ability_duration") or buff_extension:has_buff_type("bardin_ranger_activated_ability_stealth_outside_of_smoke")
	local has_ranger_buff = buff_extension:has_buff_type("bardin_ranger_activated_ability_buff")
	local multiplier = (has_murder_hobo_buff and 1.5) or (has_ranger_buff and 1) or 0

	return has_murder_hobo_buff or has_ranger_buff, multiplier
end)
mod:add_talent_buff_template("dwarf_ranger", "bardin_ranger_activated_ability_stealth_outside_of_smoke_pierce", {
	stat_buff = "ranged_additional_penetrations",
	bonus = 1,
	max_stacks = 1,
	refresh_durations = true,
	duration = 10
})

mod:hook_origin(ActionCareerDRRanger, "_create_smoke_screen", function (self)
	local owner_unit = self.owner_unit
	local network_manager = Managers.state.network
	local network_transmit = network_manager.network_transmit
	local status_extension = ScriptUnit.extension(owner_unit, "status_system")
	local career_extension = ScriptUnit.extension(owner_unit, "career_system")
	local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	local buff_name = "bardin_ranger_activated_ability"
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	if talent_extension:has_talent("bardin_ranger_ability_free_grenade", "dwarf_ranger", true) then
		buff_extension:add_buff("bardin_ranger_ability_free_grenade_buff")
	end

	local has_extended_duration_talent = talent_extension:has_talent("bardin_ranger_smoke_attack", "dwarf_ranger", true)

	if has_extended_duration_talent then
		buff_extension:add_buff("bardin_ranger_smoke_attack")
		buff_extension:add_buff("bardin_ranger_smoke_heal")

		return
	end

	local has_stealth_outside_of_smoke_talent = talent_extension:has_talent("bardin_ranger_activated_ability_stealth_outside_of_smoke", "dwarf_ranger", true)

	if has_stealth_outside_of_smoke_talent then
		buff_extension:add_buff("bardin_ranger_activated_ability_stealth_outside_of_smoke")
		buff_extension:add_buff("bardin_ranger_activated_ability_stealth_outside_of_smoke_pierce")

		return
	end

	buff_extension:add_buff(buff_name, {
		attacker_unit = owner_unit
	})
end)

--Slayer
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_increased_defence", {
	stat_buff = "damage_taken",
	multiplier = -0.2
})
table.insert(PassiveAbilitySettings.dr_2.buffs, "gs_bardin_slayer_increased_defence")
PassiveAbilitySettings.dr_2.perks = {
	{
		display_name = "career_passive_name_dr_2b",
		description = "career_passive_desc_dr_2b_2"
	},
	{
		display_name = "career_passive_name_dr_2c",
		description = "career_passive_desc_dr_2c"
	},
	{
		display_name = "rebaltourn_career_passive_name_dr_2d",
		description = "rebaltourn_career_passive_desc_dr_2d_2"
	}
}
mod:add_text("rebaltourn_career_passive_name_dr_2d", "Juggernaut")
mod:add_text("rebaltourn_career_passive_desc_dr_2d_2", "Reduces damage taken by 20%.")
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_damage_reduction_on_melee_charge_action_buff", {
	multiplier = -0.25
})
mod:modify_talent("dr_slayer", 5, 2, {
	description_values = {
		{
			value_type = "percent",
			value = -0.25
		},
		{
			value = 5
		}
	}
})
mod:modify_talent("dr_slayer", 2, 1, {
	description = "gs_slayer_weapon_combos_desc",
	description_values = {},
	buffs = {
		"bardin_slayer_attack_speed_on_double_one_handed_weapons",
		"bardin_slayer_power_on_double_two_handed_weapons"
	}
})
mod:add_text("gs_slayer_weapon_combos_desc", "Gain 15%% power if wielding 2 2handed weapons. Gain 10%% attackspeed if wielding 2 1handed weapons. Dead talent if not.")

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_buff", {
	icon = "victor_zealot_attack_speed_on_health_percent",
	stat_buff = "critical_strike_chance",
	max_stacks = 1,
	bonus = 0.2
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance", {
	activation_health = 0.7,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_crit_chance_buff",
	update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_buff_2", {
	icon = "victor_zealot_attack_speed_on_health_percent",
	stat_buff = "critical_strike_chance",
	max_stacks = 1,
	bonus = 0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_crit_chance_2", {
	activation_health = 0.3,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_crit_chance_buff_2",
	update_func = "activate_buff_on_health_percent"
})

mod:modify_talent("dr_slayer", 2, 3, {
	description = "gs_bardin_slayer_crit_chance_desc",
	buffs = {
		"gs_bardin_slayer_crit_chance",
		"gs_bardin_slayer_crit_chance_2"
	}
})
mod:add_text("gs_bardin_slayer_crit_chance_desc", "Gain 10%% extra crit chance if under 70%% total health. Gain 50%% extra crit chance if under 30%% total health.")
mod:add_proc_function("gs_add_bardin_slayer_passive_buff", function(owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end
	
	local buff_system = Managers.state.entity:system("buff_system")

	if Unit.alive(owner_unit) then
		local buff_name = "bardin_slayer_passive_stacking_damage_buff"
		local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		if talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_name = "gs_bardin_slayer_passive_increased_max_stacks"
		end
		buff_system:add_buff(owner_unit, buff_name, owner_unit, false)

		if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(owner_unit, "bardin_slayer_passive_movement_speed", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_range", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_speed", owner_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_movement_speed", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_movement_speed_extra", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_range_extra", owner_unit, false)
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_dodge_speed_extra", owner_unit, false)
		end

		if talent_extension:has_talent("gs_bardin_slayer_passive_stacking_crit_buff", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_stacking_crit_buff", owner_unit, false)
		end

		if talent_extension:has_talent("gs_bardin_slayer_passive_stacking_crit_buff", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_stacking_crit_buff_extra", owner_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) == false then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_cooldown_reduction", owner_unit, false)
		end

		if talent_extension:has_talent("bardin_slayer_passive_cooldown_reduction_on_max_stacks", "dwarf_ranger", true) and talent_extension:has_talent("gs_bardin_slayer_passive_increased_max_stacks", "dwarf_ranger", true) then
			buff_system:add_buff(owner_unit, "gs_bardin_slayer_passive_cooldown_reduction_extra", owner_unit, false)
		end
	end
end)
mod:modify_talent_buff_template("dwarf_ranger", "bardin_slayer_passive_stacking_damage_buff_on_hit", {
	buff_func = "gs_add_bardin_slayer_passive_buff"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_increased_max_stacks", {
	max_stacks = 4,
	multiplier = 0.1,
	duration = 2,
	refresh_durations = true,
	icon = "bardin_slayer_passive",
	stat_buff = "increased_weapon_damage"
})

mod:add_talent("dr_slayer", 2, 2, "gs_bardin_slayer_passive_increased_max_stacks",{
	description = "bardin_slayer_passive_increased_max_stacks_desc",
	name = "bardin_slayer_passive_increased_max_stacks",
	buffer = "server",
	num_ranks = 1,
	icon = "bardin_slayer_passive_increased_max_stacks",
	description_values = {
		{
			value = 1
		}
	},
	buffs = {}
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_movement_speed_extra", {
	max_stacks = 4,
	multiplier = 1.1,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"move_speed"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_range", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_range_extra", {
	max_stacks = 4,
	multiplier = 1.05,
	duration = 2,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"distance_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_speed", {
	max_stacks = 3,
	multiplier = 1.05,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_dodge_speed_extra", {
	max_stacks = 4,
	multiplier = 1.05,
	duration = 2,
	remove_buff_func = "remove_movement_buff",
	apply_buff_func = "apply_movement_buff",
	refresh_durations = true,
	path_to_movement_setting_to_modify = {
		"dodging",
		"speed_modifier"
	}
})
mod:add_text("bardin_slayer_passive_movement_speed_desc", "Each stack of Trophy Hunter increases movement speed by 10.0%% and dodge range by 5%%.")
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_stacking_crit_buff", {
	max_stacks = 3,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	refresh_durations = true,
	stat_buff = "power_level_melee_cleave",
	duration = 2,
	multiplier = 0.25
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_stacking_crit_buff_extra", {
	max_stacks = 4,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	refresh_durations = true,
	stat_buff = "power_level_melee_cleave",
	duration = 2,
	multiplier = 0.25
})
mod:add_talent("dr_slayer", 4, 2, "gs_bardin_slayer_passive_stacking_crit_buff", {
	description = "bardin_slayer_passive_stacking_crit_buff_desc",
	name = "bardin_slayer_passive_stacking_crit_buff_name",
	buffer = "server",
	num_ranks = 1,
	icon = "bardin_slayer_passive_stacking_damage_buff_grants_defence",
	description_values = {},
	buffs = {}
})
mod:add_text("bardin_slayer_passive_stacking_crit_buff_desc", "Each stack of Trophy Hunter increases melee cleave by 25%%.")
mod:add_text("bardin_slayer_passive_stacking_crit_buff_name", "Blood Drunk")
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_cooldown_reduction", {
	icon = "bardin_slayer_passive_cooldown_reduction_on_max_stacks",
	stat_buff = "cooldown_regen",
	max_stacks = 3,
	refresh_durations = true,
	duration = 2,
	multiplier = 0.67
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_passive_cooldown_reduction_extra", {
	icon = "bardin_slayer_passive_cooldown_reduction_on_max_stacks",
	stat_buff = "cooldown_regen",
	max_stacks = 4,
	refresh_durations = true,
	duration = 2,
	multiplier = 0.67
})
mod:modify_talent("dr_slayer", 4, 3, {
	description = "gs_bardin_slayer_passive_cooldown_reduction_desc",
	description_values = {}
})
mod:add_text("gs_bardin_slayer_passive_cooldown_reduction_desc", "Each stack of Trophy Hunter increases cooldown regeneration by 67%%.")

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_buff", {
	icon = "bardin_slayer_push_on_dodge",
	stat_buff = "damage_taken",
	max_stacks = 1,
	multiplier = -0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling", {
	activation_health = 0.3,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_dr_scaling_buff",
	update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_buff_2", {
	icon = "bardin_slayer_push_on_dodge",
	stat_buff = "damage_taken",
	max_stacks = 1,
	multiplier = -0.3
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_dr_scaling_2", {
	activation_health = 0.5,
	activate_below = true,
	buff_to_add = "gs_bardin_slayer_dr_scaling_buff_2",
	update_func = "activate_buff_on_health_percent"
})

mod:modify_talent("dr_slayer", 5, 3, {
	description = "gs_bardin_slayer_push_on_dodge_desc",
	server = "both",
	buffs = {
		"bardin_slayer_push_on_dodge",
		"gs_bardin_slayer_dr_scaling",
		"gs_bardin_slayer_dr_scaling_2"
	}
})
mod:add_text("gs_bardin_slayer_push_on_dodge_desc", "Effective dodges pushes nearby small enemies out of the way. When below 50%% total health you gain 30%% damage reduction. When below 30%% you gain 60%% damage reduction.")

DamageProfileTemplates.slayer_leap_landing_impact.default_target.power_distribution.impact = 1

mod:hook_origin(CareerAbilityDRSlayer, "_do_common_stuff", function(self)
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local career_extension = self._career_extension
	local talent_extension = self._talent_extension
	local buffs = {
		"bardin_slayer_activated_ability"
	}

	if talent_extension:has_talent("bardin_slayer_activated_ability_movement") then
		buffs[#buffs + 1] = "bardin_slayer_activated_ability_movement"
	end

	local unit_object_id = network_manager:unit_game_object_id(owner_unit)

	if is_server then
		local buff_extension = self._buff_extension

		for i = 1, #buffs, 1 do
			local buff_name = buffs[i]
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			buff_extension:add_buff(buff_name, {
				attacker_unit = owner_unit
			})
			network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
		end
	else
		for i = 1, #buffs, 1 do
			local buff_name = buffs[i]
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

			network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
		end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_slayer_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_bardin_slayer_enter", owner_unit, 0)
		first_person_extension:play_hud_sound_event("Play_career_ability_bardin_slayer_loop")

		if local_player then
			career_extension:set_state("bardin_activate_slayer")

			MOOD_BLACKBOARD.skill_slayer = true
		end
	end

	if talent_extension:has_talent("bardin_slayer_activated_ability_leap_damage") then
		if local_player or (is_server and bot_player) then
			local buff_extension = self._buff_extension

			if buff_extension then
				local buff = buff_extension:get_buff_type("gs_bardin_slayer_double_ability")

				if buff then
					buff.aborted = true

					buff_extension:remove_buff(buff.id)
					career_extension:start_activated_ability_cooldown()
					career_extension:set_abilities_always_usable(false, "gs_bardin_slayer_double_ability")
				else
					buff_extension:add_buff("gs_bardin_slayer_double_ability")
					career_extension:set_abilities_always_usable(true, "gs_bardin_slayer_double_ability")
				end
			end
		end
	else
		career_extension:start_activated_ability_cooldown()
	end

	self:_play_vo()
end)

mod:add_proc_function("gs_bardin_slayer_double_start_ability_cooldown", function (unit, buff, params)
	if ALIVE[unit] and not buff._already_removed and is_local(unit) then
		local career_extension = ScriptUnit.extension(unit, "career_system")

		career_extension:set_abilities_always_usable(false, "gs_bardin_slayer_double_ability")
		career_extension:stop_ability("cooldown_triggered")
		career_extension:start_activated_ability_cooldown()
	end

	buff._already_removed = true
end)

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_double_ability", {
	buff_to_add = "gs_bardin_slayer_double_ability_remove",
	icon = "bardin_slayer_activated_ability_leap_damage",
	remove_buff_func = "sienna_adept_double_trail_talent_start_ability_cooldown_add",
	max_stacks = 1,
	perk = buff_perks.free_ability
})
mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_slayer_double_ability_remove", {
	max_stacks = 1,
	duration = 0,
	remove_buff_func = "gs_bardin_slayer_double_start_ability_cooldown"
})
mod:add_text("bardin_slayer_activated_ability_leap_damage_desc", "Increases attack damage while airborne during leap by 150%%. Leap can be activated a second time within 10 seconds.")

--Engineer Talents
mod:add_text("career_passive_desc_dr_4a", "Killing enemies in melee restores 10% Ammo, 30% Ability bar and removes 30% of max overcharge. Kills needed depends on the health of the enemies. Charged Critical melee attacks cause an Explosion that spreads burn.")
mod:add_text("career_passive_name_dr_4a", "Scrap Collector")
mod:add_text("career_active_desc_dr_4", "Unleash the fearsome firepower of Bardin's custom creation. Shots reduce the Ability Bar. Holding reload with the Steam-Assisted Crank Gun (Mk II) equipped builds Pressure. Each stack of Pressure lasts for 12 seconds and gradually restores the Ability Bar. Stacks up to 5 times.")
mod:add_text("career_passive_desc_dr_4b", "Increases max Ammo by 50%. Drake Fire weapons generate 30% less overheat.")

mod:modify_talent_buff_template( "dwarf_ranger", "bardin_engineer_pump_buff", {
	icon = "bardin_engineer_passive",
	on_max_stacks_func = "add_remove_buffs",
	stat_buff = "cooldown_regen",
	on_max_stacks_overflow_func = "add_remove_buffs",
	max_stacks = 5,
	duration = 10,
	refresh_durations = true,
	remove_buff_func = "remove_1_stack",
	display_buff = "bardin_engineer_pump_buff",
	max_stack_data = {
		talent_buffs_to_add = {
			bardin_engineer_power_on_max_pump = {
				buff_to_add = "bardin_engineer_power_on_max_pump_buff",
				rpc_sync = true
			}
		}
	}
})

mod:add_buff_function("remove_1_stack", function (unit, buff, params)
	local buff_template = buff.template
	local display_buff = buff_template.display_buff
	local buff_extension = ScriptUnit.extension(unit, "buff_system")
	local buff_id = buff_extension:add_buff(display_buff)
	buff_extension:remove_buff(buff_id)
end)

require("scripts/managers/challenges/pickup_spawn_type")
mod:add_proc_function("gs_engineer_passive", function(owner_unit, buff, params)

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
		buff.bomb_counter = 0
	end

	local counter = buff.counter
	local bomb_counter = buff.bomb_counter
	local buff_template = buff.template
	local required_kills = buff_template.required_kills
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local career_extension = ScriptUnit.has_extension(owner_unit, "career_system")
	local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	local multiplier = 0.3
	local ammo_bonus_fraction = 0.10
	local network_transmit = Managers.state.network.network_transmit
	local pickup_system = Managers.state.entity:system("pickup_system")

	if counter >= required_kills then
		if talent_extension:has_talent("bardin_engineer_power_on_max_pump", "dwarf_ranger", true) then
			ammo_bonus_fraction = 0.2
		elseif talent_extension:has_talent("bardin_engineer_stacks_stay", "dwarf_ranger", true) then
			multiplier = 1
		elseif talent_extension:has_talent("bardin_engineer_pump_buff_long", "dwarf_ranger", true) then
			if bomb_counter >= 2 and Managers.state.network.is_server then
				local options = { "frag_grenade_t2", "fire_grenade_t2" }
				local pickup_name = options [ math.random( #options) ]
				local pickup_settings = AllPickups[pickup_name]
				local slot_name = pickup_settings.slot_name
				local item_name = pickup_settings.item_name
				local slot_data = inventory_extension:get_slot_data(slot_name)

				if slot_data then
					local position = POSITION_LOOKUP[owner_unit] + Vector3.up() * 0.1

					pickup_system:buff_spawn_pickup(pickup_name, position, true)
				else
					local go_id = Managers.state.unit_storage:go_id(owner_unit)
					local slot_id = NetworkLookup.equipment_slots[slot_name]
					local item_id = NetworkLookup.item_names[item_name]
					local weapon_skin_id = NetworkLookup.weapon_skins["n/a"]
					local player_1 = Managers.player:owner(owner_unit)
					local is_remote = player_1 and player_1.remote

					if is_remote then
						network_transmit:send_rpc("rpc_add_inventory_slot_item", player_1.peer_id, go_id, slot_id, item_id, weapon_skin_id)
					else
						network_transmit:queue_local_rpc("rpc_add_inventory_slot_item", go_id, slot_id, item_id, weapon_skin_id)
					end
				end
				buff.bomb_counter = 0
			else
				buff.bomb_counter = bomb_counter + 1
			end
		end

		local weapon_slot = "slot_ranged"
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

		local overcharge_extension = ScriptUnit.extension(owner_unit, "overcharge_system")

		if overcharge_extension then
			local max_overcharge = overcharge_extension:get_max_value()
			local overcharge_amount = max_overcharge * ammo_bonus_fraction * 2
			overcharge_extension:remove_charge(overcharge_amount)
		end

		if career_extension then
			career_extension:reduce_activated_ability_cooldown_percent(multiplier)
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

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_engineer_passive", {
	event = "on_kill",
    buff_func = "gs_engineer_passive",
    required_kills = 60,
	display_buff = "gs_display_buff_engi_ammo"
})
mod:add_talent_buff_template("empire_soldier", "gs_display_buff_engi_ammo", {
    max_stacks = 100,
	icon = "bardin_engineer_passive"
})

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_engineer_decreased_heat_cost", {
	stat_buff = "reduced_overcharge",
	multiplier = -0.3,
	max_stacks = 1
})
table.insert(PassiveAbilitySettings.dr_4.buffs, "gs_bardin_engineer_passive")
table.insert(PassiveAbilitySettings.dr_4.buffs, "gs_bardin_engineer_passive_heavy_explosion")
table.insert(PassiveAbilitySettings.dr_4.buffs, "bardin_engineer_stacks_stay")
table.insert(PassiveAbilitySettings.dr_4.buffs, "gs_bardin_engineer_decreased_heat_cost")

CareerSettings.dr_engineer.attributes.max_hp = 125
CareerSettings.dr_engineer.attributes.base_critical_strike_chance = 0.1

mod:add_proc_function("gs_engineer_heavy_explosion", function(owner_unit, buff, params)
	if not Managers.state.network.is_server then
		return
	end

	local attack_type = params[2]

	if attack_type ~= "heavy_attack" then
		return
	end
	
	local hit_num = params[4]

	if ALIVE[owner_unit] and hit_num <= 1 then
		local area_damage_system = Managers.state.entity:system("area_damage_system")
		local career_extension = ScriptUnit.extension(owner_unit, "career_system")
		local power_level = career_extension:get_career_power_level()
		local hit_unit = params[1]
		local position = POSITION_LOOKUP[hit_unit]
		local damage_source = "buff"
		local explosion_template = "engineer_heavy_explosion"

		local rotation = Quaternion.identity()
		local scale = 1
		local is_critical_strike = false

		local world_manager = Managers.world
		local world = world_manager:world("level_world")

		local first_person_extension = ScriptUnit.has_extension(owner_unit, "first_person_system")

		if first_person_extension then
			first_person_extension:play_hud_sound_event("Play_career_ability_unchained_fire")
			first_person_extension:play_remote_unit_sound_event("Play_career_ability_unchained_fire", owner_unit, 0)
		end

		area_damage_system:create_explosion(owner_unit, position, rotation, explosion_template, scale, damage_source, power_level, is_critical_strike)
	end
end)

mod:add_talent_buff_template("dwarf_ranger", "gs_bardin_engineer_passive_heavy_explosion", {
	event = "on_critical_hit",
	buff_func = "gs_engineer_heavy_explosion"
})
mod:add_text("bardin_engineer_power_on_max_pump_desc", "Increases ammo gain from Scrap Collector to 20%% and increases overcharge removal to 60%% of max overcharge.")
mod:add_text("bardin_engineer_power_on_max_pump", "Superior Scrap")
mod:add_text("bardin_engineer_stacks_stay_desc", "Increase Ult gain from Scrap Collector to 100%%.")
mod:add_text("bardin_engineer_pump_buff_long_desc", "Scrap Collector also gives a bomb every 3 procs.")
mod:add_text("bardin_engineer_pump_buff_long", "Bombardier")
mod:modify_talent("dr_engineer", 4, 1, {
	icon = "bardin_engineer_fast_ability_charge",
	buffs = {}
})
mod:modify_talent("dr_engineer", 4, 2, {
	icon = "bardin_engineer_passive_ability_charge",
	buffs = {}
})
mod:modify_talent("dr_engineer", 4, 3, {
	icon = "bardin_engineer_upgraded_grenades",
	buffs = {}
})
mod:modify_talent("dr_engineer", 5, 1, {
	buffs = {
		"bardin_engineer_increased_damage_on_burning_enemy"
	}
})
StatBuffApplicationMethods.increased_weapon_damage_burning = "stacking_multiplier"
mod:add_talent_buff_template("dwarf_ranger","bardin_engineer_increased_damage_on_burning_enemy", {
	stat_buff = "increased_weapon_damage_burning",
	multiplier = 0.2
})
mod:add_text("bardin_engineer_stacking_damage_reduction_desc", "Increase damage against burning enemies by 20%%.")
mod:add_text("bardin_engineer_stacking_damage_reduction", "Fucking Fire")

mod:modify_talent("dr_engineer", 5, 2, {
	icon = "bardin_engineer_party_ability_charge",
	buffs = {
		"bardin_engineer_power_on_max_pump_buff_on_remove"
	}
})
mod:add_text("bardin_engineer_upgraded_grenades_desc", "Upon reaching 5 stacks of Pressure, Bardin gains 15.0%% Power for 10 seconds.")
mod:add_text("bardin_engineer_upgraded_grenades", "Full Head of Steam")

mod:modify_talent("dr_engineer", 5, 3, {
	buffs = {
		"bardin_engineer_melee_power_on_elite_kill"
	}
})
mod:add_talent_buff_template("dwarf_ranger","bardin_engineer_melee_power_on_elite_kill", {
	buff_to_add = "melee_power_buff",
	event = "on_elite_killed",
	buff_func = "add_buff_on_elite_kill"
})
mod:add_talent_buff_template("dwarf_ranger","melee_power_buff", {
	refresh_durations = true,
	stat_buff = "power_level_melee",
	duration = 10,
	max_stacks = 4,
	multiplier = 0.05,
	icon = "bardin_engineer_no_overheat_explosion"
})
mod:add_text("bardin_engineer_piston_powered_desc", "Killing an elite enemy grants 5%% melee power for 10 seconds. Max stacks 4.")
mod:modify_talent("dr_engineer", 6, 2, {
	buffs = {
		"bardin_engineer_attack_speed_per_cooldown"
	}
})
mod:add_talent_buff_template("dwarf_ranger","bardin_engineer_attack_speed_per_cooldown", {
	stat_buff = "attack_speed",
	update_func = "update_attack_speed_per_cooldown",
	value = 0.2,
	icon = "bardin_engineer_reduced_ability_fire_slowdown"
})
mod:add_text("bardin_engineer_reduced_ability_fire_slowdown_desc", "Gain up to 20%% Attack Speed based on your missing Ability bar.")

Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.base_fire.ammo_usage = 1.25

Weapons.bardin_engineer_career_skill_weapon_special.default_spread_template = "repeating_handgun"
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.range = 100
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.ammo_usage = 3
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.max_rps = 5
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.armor_pierce_initial_rounds_per_second = 2
Weapons.bardin_engineer_career_skill_weapon_special.actions.action_one.armor_pierce_fire.rps_loss_per_second = 1.5
Weapons.bardin_engineer_career_skill_weapon_special.custom_data.windup_loss_per_second = (5 - 2) / 1.5

mod:modify_talent_buff_template("dwarf_ranger","bardin_engineer_increased_ability_bar", {
	remove_buff_func = nil,
	apply_buff_func = nil,
	multiplier = nil
})

mod:add_text("bardin_engineer_increased_ability_bar_desc", "Killing a Special makes the Steam-Assisted Crank Gun (Mk II) not consume the Ability Bar for the next 4 seconds.")

mod:hook_origin(ActionCareerDREngineerCharge, "init", function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerDREngineerCharge.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self.weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")
	self.career_extension = ScriptUnit.extension(owner_unit, "career_system")
	self.buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.owner_unit = owner_unit
	self.audio_loop_id = "engineer_weapon_charge"
	self._buff_to_add = "bardin_engineer_pump_buff"
end)

