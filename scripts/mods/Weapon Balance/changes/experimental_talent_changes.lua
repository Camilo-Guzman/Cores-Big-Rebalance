local mod = get_mod("Weapon Balance")

local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
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
function mod.add_buff_function(self, name, func)
    BuffFunctionTemplates.functions[name] = func
end

Managers.package:load("resource_packages/dlcs/morris_ingame", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_skulls_of_fury", "global")
Managers.package:load("resource_packages/mutators/mutator_curse_blood_storm", "global")
Managers.package:load("resource_packages/dlcs/mutators_batch_04", "global")
Managers.package:load("resource_packages/careers/wh_priest", "global")
Managers.package:load("resource_packages/careers/bw_unchained", "global")
Managers.package:load("resource_packages/dlcs/wizards_part_2", "global")
Managers.package:load("resource_packages/levels/honduras/skittergate_common", "global")
Managers.package:load("resource_packages/levels/honduras/skittergate", "global")

NewSpawnUnitTemplates = NewSpawnUnitTemplates or {}

NewSpawnUnitTemplates.banner_unit = {
	spawn_func = function (source_unit, position, rotation, state_int)
		local UNIT_NAME = "units/props/skull_of_fury"
		local UNIT_TEMPLATE_NAME = "buff_objective_unit"
		local buff_name = "gs_deus_rally_flag_aoe_buff"
		local heal_buff = "gs_deus_rally_flag_aoe_buff_heal"
		local banner_effect = "gs_deus_rally_flag_aoe_buff_effect"
		local banner_duration = "gs_deus_rally_flag_aoe_buff_remover"
		local extra_buff_name = nil
		local extra_extra_buff_name = nil
		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")

		if source_talent_extension then
			if source_talent_extension:has_talent("kerillian_maidenguard_activated_ability_invis_duration", "wood_elf", true) then
				extra_buff_name = "gs_deus_rally_flag_aoe_buff_aoe_protection"
				extra_extra_buff_name = "gs_deus_rally_flag_buff_protection_ranged"
			elseif source_talent_extension:has_talent("kerillian_maidenguard_activated_ability_damage", "wood_elf", true) then
				buff_name = "gs_deus_rally_flag_aoe_buff_large"
				heal_buff = "gs_deus_rally_flag_aoe_buff_heal_large"
			elseif source_talent_extension:has_talent("kerillian_maidenguard_activated_ability_buff_on_enemy_hit", "wood_elf", true) then
				extra_buff_name = "gs_deus_rally_flag_aoe_buff_grabber_protection"
				banner_duration = "gs_deus_rally_flag_aoe_buff_remover_long"
			end
		end


		local extension_init_data = {
			buff_system = {
				breed = "n/a",
				initial_buff_names = {
					buff_name,
					heal_buff,
					banner_effect,
					banner_duration,
					extra_buff_name,
					extra_extra_buff_name
				}
			}
		}

		Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, rotation)
	end
}

--Setup proper linkin in NetworkLookup
for key, _ in pairs(NewSpawnUnitTemplates) do
    i = #NetworkLookup.spawn_unit_templates + 1
    NetworkLookup.spawn_unit_templates[i] = key
    NetworkLookup.spawn_unit_templates[key] = i
end
--Merge the tables together
table.merge_recursive(SpawnUnitTemplates, NewSpawnUnitTemplates)

ExplosionTemplates.fireball_charged.explosion = {
	use_attacker_power_level = true,
	radius_min = 1.25,
	sound_event_name = "fireball_big_hit",
	radius_max = 5,
	attacker_power_level_offset = 0.3,
	max_damage_radius_min = 0.5,
	alert_enemies_radius = 10,
	damage_profile_glance = "fireball_charged_explosion_glance",
	max_damage_radius_max = 3,
	alert_enemies = true,
	damage_profile = "fireball_charged_explosion",
	effect_name = "fx/wpnfx_drake_pistols_projectile_impact"
}

Weapons.staff_fireball_fireball_template_1.actions.action_one.shoot_charged.impact_data = {
	damage_profile = "staff_fireball_charged",
	aoe = ExplosionTemplates.fireball_charged
}

--Grab protection Banner
mod:hook(AiUtils, "is_of_interest_to_gutter_runner", function(func, gutter_runner_unit, enemy_unit, blackboard, ...)
	local buff_extension = ScriptUnit.extension(enemy_unit, "buff_system")
	local grab_proof = false
	if buff_extension then
		grab_proof = buff_extension:has_buff_perk("ledge_self_rescue")
	end

	if grab_proof
	then
		if blackboard.pouncing_target then
			blackboard.ninja_vanish = true
			return false
		end
	end

	return func(gutter_runner_unit, enemy_unit, blackboard, ...)
end)

mod:hook_origin(BTPackMasterAttackAction, "attack_success", function (self, unit, blackboard)
	if blackboard.active_node and blackboard.active_node == BTPackMasterAttackAction then
		local target_unit = blackboard.target_unit
		local target_status_ext = blackboard.target_unit_status_extension
		local buff_extension = ScriptUnit.extension(target_unit, "buff_system")
		local grab_proof = buff_extension:has_buff_perk("ledge_self_rescue")

		if grab_proof then
			return
		end

		if target_status_ext and (target_status_ext:get_is_dodging() or target_status_ext:is_invisible()) then
			local pos = POSITION_LOOKUP[unit]
			local dodge_pos = POSITION_LOOKUP[target_unit]
			local dir = Vector3.normalize(Vector3.flat(dodge_pos - pos))
			local forward = Quaternion.forward(Unit.local_rotation(unit, 0))
			local dot_value = Vector3.dot(dir, forward)
			local angle = math.acos(dot_value)
			local distance_squared = Vector3.distance_squared(pos, dodge_pos)

			if math.radians_to_degrees(angle) <= blackboard.action.dodge_angle and distance_squared < blackboard.action.dodge_distance * blackboard.action.dodge_distance then
				blackboard.attack_success = PerceptionUtils.pack_master_has_line_of_sight_for_attack(blackboard.physics_world, unit, target_unit)
			else
				blackboard.attack_success = false

				QuestSettings.check_pack_master_dodge(target_unit)
			end
		else
			blackboard.attack_success = PerceptionUtils.pack_master_has_line_of_sight_for_attack(blackboard.physics_world, unit, target_unit)
		end

		local first_person_extension = ScriptUnit.has_extension(blackboard.target_unit, "first_person_system")

		if blackboard.attack_success and first_person_extension then
			first_person_extension:animation_event("shake_get_hit")
		end
	end
end)

mod:hook(BTCorruptorGrabAction, "grab_player", function(func, self, t, unit, blackboard)
	local target_unit = blackboard.corruptor_target
	local buff_extension = ScriptUnit.extension(target_unit, "buff_system")
	local grab_proof = buff_extension:has_buff_perk("ledge_self_rescue")

	if grab_proof
	then
		blackboard.attack_success = false
		blackboard.attack_aborted = true
	end

	return func(self, t, unit, blackboard)
end)

local IGNORED_SHARED_DAMAGE_TYPES = {
	wounded_dot = true,
	suicide = true,
	knockdown_bleed = true
}
local INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_SOURCES = {
	temporary_health_degen = true,
	overcharge = true,
	life_tap = true,
	ground_impact = true,
	life_drain = true,
}
local INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_TYPES = {
	warpfire_face = true,
	vomit_face = true,
	vomit_ground = true,
	poison = true,
	warpfire_ground = true,
	plague_face = true,
}
local POISON_DAMAGE_TYPES = {
	aoe_poison_dot = true,
	poison = true,
	arrow_poison = true,
	arrow_poison_dot = true
}
local POISON_DAMAGE_SOURCES = {
	skaven_poison_wind_globadier = true,
	poison_dot = true
}
local INVALID_GROMRIL_DAMAGE_SOURCE = {
	temporary_health_degen = true,
	overcharge = true,
	life_tap = true,
	ground_impact = true,
	life_drain = true
}
local IGNORE_DAMAGE_REDUCTION_DAMAGE_SOURCE = {
	life_tap = true,
	suicide = true
}
local unit_get_data = Unit.get_data
local POSITION_LOOKUP = POSITION_LOOKUP

Breeds.beastmen_gor.trash = true
Breeds.beastmen_ungor.trash = true
Breeds.beastmen_ungor_archer.trash = true
Breeds.chaos_fanatic.trash = true
Breeds.chaos_marauder.trash = true
Breeds.chaos_marauder_with_shield.trash = true
Breeds.skaven_slave.trash = true
Breeds.skaven_clan_rat.trash = true
Breeds.skaven_clan_rat_with_shield.trash = true

mod:hook_origin(DamageUtils, "apply_buffs_to_damage", function(current_damage, attacked_unit, attacker_unit, damage_source, victim_units, damage_type, buff_attack_type, first_hit)
	local damage = current_damage
	local network_manager = Managers.state.network
	local attacked_player = Managers.player:owner(attacked_unit)
	local attacker_player = Managers.player:owner(attacker_unit)

	if attacked_player then
		damage = Managers.state.game_mode:modify_player_base_damage(attacked_unit, attacker_unit, damage, damage_type)
	end

	victim_units[#victim_units + 1] = attacked_unit
	local health_extension = ScriptUnit.extension(attacked_unit, "health_system")

	if health_extension:has_assist_shield() and not IGNORED_SHARED_DAMAGE_TYPES[damage_source] then
		local attacked_unit_id = network_manager:unit_game_object_id(attacked_unit)

		network_manager.network_transmit:send_rpc_clients("rpc_remove_assist_shield", attacked_unit_id)
	end

	if ScriptUnit.has_extension(attacked_unit, "buff_system") then
		local buff_extension = ScriptUnit.extension(attacked_unit, "buff_system")

		if SKAVEN[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_skaven")
		elseif CHAOS[damage_source] or BEASTMEN[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_chaos")
		end

		if DAMAGE_TYPES_AOE[damage_type] then
			damage = buff_extension:apply_buffs_to_value(damage, "protection_aoe")
		end

		if not IGNORE_DAMAGE_REDUCTION_DAMAGE_SOURCE[damage_source] then
			damage = buff_extension:apply_buffs_to_value(damage, "damage_taken")

			if ELITES[damage_source] then
				damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_elites")
			end
		end

		if RangedAttackTypes[buff_attack_type] then
			damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_ranged")
		end

		local status_extension = attacked_player and ScriptUnit.has_extension(attacked_unit, "status_system")

		if status_extension then
			local is_knocked_down = status_extension:is_knocked_down()

			if is_knocked_down then
				damage = (damage_type ~= "overcharge" and buff_extension:apply_buffs_to_value(damage, "damage_taken_kd")) or 0
			end

			local is_disabled = status_extension:is_disabled()

			if not is_disabled then
				local valid_damage_to_overheat = not INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_SOURCES[damage_source] and not INVALID_DAMAGE_TO_OVERHEAT_DAMAGE_TYPES[damage_type]
				local unit_side = Managers.state.side.side_by_unit[attacked_unit]
				local player_and_bot_units = unit_side.PLAYER_AND_BOT_UNITS
				local shot_by_friendly = false
				local allies = (player_and_bot_units and #player_and_bot_units) or 0

				for i = 1, allies, 1 do
					local ally_unit =  player_and_bot_units[i]
					if ally_unit == attacker_unit then
						shot_by_friendly = true
					end
				end

                local is_poison_damage = POISON_DAMAGE_TYPES[damage_type] or POISON_DAMAGE_SOURCES[damage_source]
                local is_ranged_attack = RangedAttackTypes[buff_attack_type]

				if valid_damage_to_overheat and damage > 0 and not shot_by_friendly and not is_knocked_down and not is_poison_damage and not is_ranged_attack then
					local original_damage = damage
					local new_damage = buff_extension:apply_buffs_to_value(damage, "damage_taken_to_overcharge")

					if new_damage < original_damage then
						local damage_to_overcharge = original_damage - new_damage
						damage_to_overcharge = buff_extension:apply_buffs_to_value(damage_to_overcharge, "reduced_overcharge_from_passive")
						damage_to_overcharge = DamageUtils.networkify_damage(damage_to_overcharge)

						if attacked_player.remote then
							local peer_id = attacked_player.peer_id
							local unit_id = network_manager:unit_game_object_id(attacked_unit)
							local channel_id = PEER_ID_TO_CHANNEL[peer_id]

							RPC.rpc_damage_taken_overcharge(channel_id, unit_id, damage_to_overcharge)
						else
							DamageUtils.apply_damage_to_overcharge(attacked_unit, damage_to_overcharge)
						end

						damage = new_damage
					end
				end
			end
		end

		local attacker_unit_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

		if attacker_unit_buff_extension then
			local has_burning_perk = attacker_unit_buff_extension:has_buff_perk("burning")

			if has_burning_perk then
				local side_manager = Managers.state.side
				local side = side_manager.side_by_unit[attacked_unit]

				if side then
					local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
					local num_units = #player_and_bot_units

					for i = 1, num_units, 1 do
						local unit = player_and_bot_units[i]
						local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

						if talent_extension and talent_extension:has_talent("sienna_unchained_burning_enemies_reduced_damage") then
							damage = damage * (1 + BuffTemplates.sienna_unchained_burning_enemies_reduced_damage.buffs[1].multiplier)

							break
						end
					end
				end
			end
		end

		local boss_elite_damage_cap = buff_extension:get_buff_value("max_damage_taken_from_boss_or_elite")
		local all_damage_cap = buff_extension:get_buff_value("max_damage_taken")
		local breed = ALIVE[attacker_unit] and unit_get_data(attacker_unit, "breed")

		local has_trash_dr = buff_extension:has_buff_type("kerillian_maidenguard_ress_time")

		if breed and breed.trash and has_trash_dr then
			damage = damage * 0.7
		end

		if breed and (breed.boss or breed.elite) then
			local min_damage_cap = nil
			min_damage_cap = (not boss_elite_damage_cap or not all_damage_cap or math.min(boss_elite_damage_cap, all_damage_cap)) and ((boss_elite_damage_cap and boss_elite_damage_cap) or all_damage_cap)

			if min_damage_cap and min_damage_cap <= damage then
				damage = math.max(damage * 0.5, min_damage_cap)
			end
		elseif all_damage_cap and all_damage_cap <= damage then
			damage = math.max(damage * 0.5, all_damage_cap)
		end

		if buff_extension:has_buff_type("shared_health_pool") and not IGNORED_SHARED_DAMAGE_TYPES[damage_source] then
			local attacked_side = Managers.state.side.side_by_unit[attacked_unit]
			local player_and_bot_units = attacked_side.PLAYER_AND_BOT_UNITS
			local num_player_and_bot_units = #player_and_bot_units
			local num_players_with_shared_health_pool = 1

			for i = 1, num_player_and_bot_units, 1 do
				local friendly_unit = player_and_bot_units[i]

				if friendly_unit ~= attacked_unit then
					local friendly_buff_extension = ScriptUnit.extension(friendly_unit, "buff_system")

					if friendly_buff_extension:has_buff_type("shared_health_pool") then
						num_players_with_shared_health_pool = num_players_with_shared_health_pool + 1
						victim_units[#victim_units + 1] = friendly_unit
					end
				end
			end

			damage = damage / num_players_with_shared_health_pool
		end

		local talent_extension = ScriptUnit.has_extension(attacked_unit, "talent_system")

		if talent_extension and talent_extension:has_talent("bardin_ranger_reduced_damage_taken_headshot") then
			local has_position = POSITION_LOOKUP[attacker_unit]

			if has_position and AiUtils.unit_is_flanking_player(attacker_unit, attacked_unit) and not buff_extension:has_buff_type("bardin_ranger_reduced_damage_taken_headshot_buff") then
				damage = damage * (1 + BuffTemplates.bardin_ranger_reduced_damage_taken_headshot_buff.buffs[1].multiplier)
			end
		end

		local is_invulnerable = buff_extension:has_buff_perk("invulnerable")
		local has_gromril_armor = buff_extension:has_buff_type("bardin_ironbreaker_gromril_armour")
		local has_metal_mutator_gromril_armor = buff_extension:has_buff_type("metal_mutator_gromril_armour")
		local valid_damage_source = not INVALID_GROMRIL_DAMAGE_SOURCE[damage_source]
		local unit_side = Managers.state.side.side_by_unit[attacked_unit]

		if unit_side and unit_side:name() == "dark_pact" then
			is_invulnerable = is_invulnerable or damage_source == "ground_impact"
		end

		local shot_by_friendly = false

		if unit_side then
			local player_and_bot_units = unit_side.PLAYER_AND_BOT_UNITS
			local shot_by_friendly = false
			local allies = (player_and_bot_units and #player_and_bot_units) or 0

			for i = 1, allies, 1 do
				local ally_unit =  player_and_bot_units[i]
				if ally_unit == attacker_unit then
					shot_by_friendly = true
				end
			end
		end

		if is_invulnerable or ((has_gromril_armor or has_metal_mutator_gromril_armor) and valid_damage_source) and not shot_by_friendly then
			damage = 0
		end

		if has_gromril_armor and valid_damage_source and current_damage > 0 and not shot_by_friendly then
			local buff = buff_extension:get_non_stacking_buff("bardin_ironbreaker_gromril_armour")
			local id = buff.id

			buff_extension:remove_buff(id)
			buff_extension:trigger_procs("on_gromril_armour_removed")

			local attacked_unit_id = network_manager:unit_game_object_id(attacked_unit)

			network_manager.network_transmit:send_rpc_clients("rpc_remove_gromril_armour", attacked_unit_id)
		end

		if buff_extension:has_buff_type("invincibility_standard") then
			local buff = buff_extension:get_non_stacking_buff("invincibility_standard")

			if not buff.applied_damage then
				buff.stored_damage = (not buff.stored_damage and damage) or buff.stored_damage + damage
				damage = 0
			end
		end
	end

	local buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")
	if buff_extension then
		local item_data = rawget(ItemMasterList, damage_source)
		local weapon_template_name = item_data and item_data.template
		local attacked_buff_extension = ScriptUnit.has_extension(attacked_unit, "buff_system")

		if attacker_player then

			if weapon_template_name then
				local weapon_template = Weapons[weapon_template_name]
				local buff_type = weapon_template.buff_type

				if buff_type then
					damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage")

					if buff_extension:has_buff_perk("missing_health_damage") then
						local attacked_health_extension = ScriptUnit.extension(attacked_unit, "health_system")
						local missing_health_percentage = 1 - attacked_health_extension:current_health_percent()
						local damage_mult = 1 + missing_health_percentage / 2
						damage = damage * damage_mult
					end
				end

				local is_melee = MeleeBuffTypes[buff_type]
				local is_ranged = RangedBuffTypes[buff_type]

				if is_melee then
					damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee")

					if buff_type == "MELEE_1H" then
						damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee_1h")
					elseif buff_type == "MELEE_2H" then
						damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_melee_2h")
					end

					if buff_attack_type == "heavy_attack" then
						damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_heavy_attack")
					end

					if first_hit then
						damage = buff_extension:apply_buffs_to_value(damage, "first_melee_hit_damage")
					end
				elseif is_ranged then
					damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_ranged")
					local attacked_health_extension = ScriptUnit.extension(attacked_unit, "health_system")

					if attacked_health_extension:current_health_percent() <= 0.9 or attacked_health_extension:current_max_health_percent() <= 0.9 then
						damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_ranged_to_wounded")
					end

					if first_hit then
						damage = buff_extension:apply_buffs_to_value(damage, "first_ranged_hit_damage")
					end
				end

				local weapon_type = weapon_template.weapon_type

				if weapon_type then
					local stat_buff = WeaponSpecificStatBuffs[weapon_type].damage
					damage = buff_extension:apply_buffs_to_value(damage, stat_buff)
				end

				if is_melee or is_ranged then
					damage = buff_extension:apply_buffs_to_value(damage, "reduced_non_burn_damage")
				end
			end

			if attacked_buff_extension then
				local has_poison_or_bleed = attacked_buff_extension:has_buff_perk("poisoned") or attacked_buff_extension:has_buff_perk("bleeding")
				local has_burn = attacked_buff_extension:has_buff_perk("burning")

				if has_poison_or_bleed then
					damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_poisoned_or_bleeding")
				end
				if has_burn then
					damage = buff_extension:apply_buffs_to_value(damage, "increased_weapon_damage_burning")
				end
			end

			if damage_type == "burninating" then
				damage = buff_extension:apply_buffs_to_value(damage, "increased_burn_dot_damage")
			end
		end

		damage = buff_extension:apply_buffs_to_value(damage, "damage_dealt")


		local has_balefire, applied_this_frame = Managers.state.status_effect:has_status(attacked_unit, StatusEffectNames.burning_balefire)
		if has_balefire and not applied_this_frame then
			damage = buff_extension:apply_buffs_to_value(damage, "increased_damage_to_balefire")
		end

	end

	local attacker_buff_extension = ScriptUnit.has_extension(attacker_unit, "buff_system")

	if attacker_buff_extension then
		damage = attacker_buff_extension:apply_buffs_to_value(damage, "damage_dealt")
	end

	Managers.state.game_mode:damage_taken(attacked_unit, attacker_unit, damage, damage_source, damage_type)

	return damage
end)

NEW_TANK_HIT_MASS_COUNT = NEW_TANK_HIT_MASS_COUNT or {}
NEW_TANK_HIT_MASS_COUNT.skaven_plague_monk = 0.5
table.merge_recursive(TANK_HIT_MASS_COUNT, NEW_TANK_HIT_MASS_COUNT)

NewExplosionTemplates = NewExplosionTemplates or {}

NewExplosionTemplates.overcharge_explosion_skull = {}
NewExplosionTemplates.overcharge_explosion_skull.explosion = {
	use_attacker_power_level = true,
	radius = 4,
	alert_enemies = true,
	max_damage_radius = 2,
	alert_enemies_radius = 10,
	attacker_power_level_offset = 0.25,
	always_hurt_players = false,
	attack_template = "drakegun",
	no_friendly_fire = true,
	damage_profile_glance = "overcharge_explosion_glance_ability",
	sound_event_name = "player_combat_weapon_staff_overcharge_explosion",
	damage_profile = "overcharge_explosion",
	ignore_attacker_unit = true,
	effect_name = "fx/cw_enemy_explosion"
}
NewExplosionTemplates.engineer_heavy_explosion = {}
NewExplosionTemplates.engineer_heavy_explosion.explosion = {
	use_attacker_power_level = true,
	max_damage_radius_min = 0.2,
	alert_enemies_radius = 3,
	radius_max = 2.5,
	effect_name = "fx/thornwall_poison_spikes",
	radius_min = 0.2,
	dot_template_name = "long_burn_low_damage",
	max_damage_radius_max = 2.5,
	alert_enemies = true,
	damage_profile = "thorn_sister_talent_explosion",
	no_friendly_fire = true
}

NewExplosionTemplates.waystalker_poison_explosion = {}
NewExplosionTemplates.waystalker_poison_explosion.explosion = {
	use_attacker_power_level = true,
	radius = 2,
	no_prop_damage = true,
	sound_event_name = "thorn_hit_poison",
	damage_profile = "heavy_poison_aoe",
	effect_name = "fx/thornwall_poison_spikes",
	no_friendly_fire = true
}
NewExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion_no_apply = {}
NewExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion_no_apply.explosion = {
	use_attacker_power_level = true,
	radius = 5.5,
	explosion_right_scaling = 0.1,
	hit_sound_event = "thorn_wall_damage_heavy",
	effect_name = "fx/thornwall_spike_damage",
	sound_event_name = "career_ability_kerilian_sister_wall_spawn_damage",
	hit_sound_event_cap = 1,
	alert_enemies = true,
	no_friendly_fire = true,
	alert_enemies_radius = 10,
	damage_type = "kinetic",
	damage_profile = "thorn_wall_explosion_improved_damage",
	explosion_forward_scaling = 0.5
}
NewExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion = {}
NewExplosionTemplates.we_thornsister_career_skill_explosive_wall_explosion.explosion = {
	use_attacker_power_level = true,
	radius = 6.5,
	explosion_right_scaling = 0.1,
	hit_sound_event = "thorn_wall_damage_heavy",
	dot_template_name = "thorn_sister_passive_poison",
	effect_name = "fx/thornwall_spike_damage",
	sound_event_name = "career_ability_kerilian_sister_wall_spawn_damage",
	hit_sound_event_cap = 1,
	alert_enemies = true,
	no_friendly_fire = true,
	alert_enemies_radius = 10,
	damage_type = "kinetic",
	damage_profile = "thorn_wall_explosion_improved_damage",
	explosion_forward_scaling = 0.5
}
NewExplosionTemplates.handmaiden_banner_explosion = {}
NewExplosionTemplates.handmaiden_banner_explosion.explosion = {
	use_attacker_power_level = true,
	radius = 5,
	alert_enemies = true,
	max_damage_radius = 3,
	alert_enemies_radius = 10,
	attacker_power_level_offset = 0.25,
	always_hurt_players = false,
	attack_template = "drakegun",
	no_friendly_fire = true,
	damage_profile_glance = "overcharge_explosion_glance_ability",
	sound_event_name = "career_ability_priest_explosion",
	damage_profile = "handmaiden_banner_explosion_damage",
	ignore_attacker_unit = true,
	effect_name = "fx/wp_explosion_allies"
}
NewExplosionTemplates.warrior_priest_lightning_explosion = {}
NewExplosionTemplates.warrior_priest_lightning_explosion.explosion = {
	use_attacker_power_level = true,
	radius = 10,
	alert_enemies = true,
	max_damage_radius = 3,
	alert_enemies_radius = 30,
	attacker_power_level_offset = 1,
	always_hurt_players = false,
	attack_template = "drakegun",
	no_friendly_fire = true,
	damage_profile_glance = "overcharge_explosion_glance_ability",
	sound_event_name = "Play_mutator_enemy_split_large",
	damage_profile = "warrior_priest_explosion_damage",
	ignore_attacker_unit = true,
	buildup_effect_name = "fx/magic_wind_heavens_lightning_strike_02",
	effect_name = "fx/magic_wind_heavens_lightning_strike_01",
	camera_effect = {
		near_distance = 5,
		near_scale = 1,
		shake_name = "lightning_strike",
		far_scale = 0.15,
		far_distance = 20
	}
}

NewExplosionTemplates.warrior_priest_lightning_explosion_strong = {}
NewExplosionTemplates.warrior_priest_lightning_explosion_strong.explosion = {
	use_attacker_power_level = true,
	radius = 10,
	alert_enemies = true,
	max_damage_radius = 3,
	alert_enemies_radius = 30,
	attacker_power_level_offset = 1,
	always_hurt_players = false,
	attack_template = "drakegun",
	no_friendly_fire = true,
	damage_profile_glance = "overcharge_explosion_glance_ability",
	sound_event_name = "Play_mutator_enemy_split_large",
	damage_profile = "warrior_priest_explosion_damage_strong",
	ignore_attacker_unit = true,
	buildup_effect_name = "fx/magic_wind_heavens_lightning_strike_02",
	effect_name = "fx/magic_wind_heavens_lightning_strike_01",
	camera_effect = {
		near_distance = 5,
		near_scale = 1,
		shake_name = "lightning_strike",
		far_scale = 0.15,
		far_distance = 20
	}
}

NewExplosionTemplates.witch_hunter_tag_explosion = {}
NewExplosionTemplates.witch_hunter_tag_explosion.explosion = {
	use_attacker_power_level = true,
	radius = 100,
	no_prop_damage = true,
	max_damage_radius = 2,
	always_hurt_players = false,
	alert_enemies = true,
	alert_enemies_radius = 15,
	attack_template = "drakegun",
	damage_type = "grenade",
	damage_profile = "dummy",
	ignore_attacker_unit = true,
	no_friendly_fire = true,
}

NewExplosionTemplates.warp_lightning_strike_delayed = {}
NewExplosionTemplates.warp_lightning_strike_delayed = {
	time_to_explode = 2,
	follow_time = 3,
	explosion = {
		always_hurt_players = true,
		radius = 2,
		alert_enemies = false,
		sound_event_name = "fireball_big_hit",
		max_damage_radius_min = 0.5,
		attack_template = "chaos_magic_missile",
		max_damage_radius_max = 1,
		damage_type = "grenade",
		damage_interval = 0,
		power_level = 1000,
		effect_name = "fx/warp_lightning_bolt_impact",
		immune_breeds = {
			all = true
		}
	}
}


for name, templates in pairs(NewExplosionTemplates) do
	templates.name = name
end

for key, _ in pairs(NewExplosionTemplates) do
    i = #NetworkLookup.explosion_templates + 1
    NetworkLookup.explosion_templates[i] = key
    NetworkLookup.explosion_templates[key] = i
end
--Merge the tables together
table.merge_recursive(ExplosionTemplates, NewExplosionTemplates)

Weapons.sienna_scholar_career_skill_weapon.actions.action_career_release.default.impact_data = { damage_profile = "fire_spear_trueflight", aoe = ExplosionTemplates.overcharge_explosion_skull  }

DamageProfileTemplates.overcharge_explosion.stagger_duration_modifier = 3
DamageProfileTemplates.overcharge_explosion.default_target.power_distribution.attack = 0.15
DamageProfileTemplates.overcharge_explosion.armor_modifier.attack = { 1, 0.5, 2.5, 1, 0.5, 0.25 }
DamageProfileTemplates.overcharge_explosion.armor_modifier.impact = { 0.5, 0.5, 1, 0.5, 1.5, 0.5 }
DamageProfileTemplates.overcharge_explosion.default_target.power_distribution.impact = 1
ActivatedAbilitySettings.bw_1[1].cooldown = 40
ActivatedAbilitySettings.es_1[1].cooldown = 60
ActivatedAbilitySettings.we_3[1].cooldown = 50

mod:add_talent_buff_template("wood_elf", "gs_dash_ult_toggle", {
	icon = "kerillian_maidenguard_activated_ability",
	max_stacks = 1,
	debuff = true
})

mod:add_talent_buff_template("wood_elf", "gs_dash_ult_toggle_function", {
	update_func = "toggle_ult_type",
	max_stacks = 1,
	buff_to_add = "gs_dash_ult_toggle",
})

mod:add_buff_function("toggle_ult_type", function (unit, buff, params)
	local input_extension = ScriptUnit.extension(unit, "input_system")

	if not input_extension then
		return
	end

	if input_extension:get("action_three") then
		local buff_extension = ScriptUnit.has_extension(unit, "buff_system")
		local status_extension = ScriptUnit.has_extension(unit, "status_system")
        local buff_system = Managers.state.entity:system("buff_system")
		local zooming = status_extension:is_zooming()

		if buff_extension and not zooming then
            local buff_template = buff.template
			local buff_to_add = buff_template.buff_to_add

			local ult_swap_buff = buff._ult_swap_buff

			if not ult_swap_buff then
				local buff_id = buff_extension:add_buff("gs_dash_ult_toggle")
				ult_swap_buff = buff_extension:get_buff_by_id(buff_id)
				buff._ult_swap_buff = ult_swap_buff

			elseif ult_swap_buff then
				buff_extension:remove_buff(ult_swap_buff.id)

				buff._ult_swap_buff = nil
			end
		end
	end
end)

--Shooting trough allies still gives ult back
mod:add_proc_function("victor_bounty_hunter_reduce_activated_ability_cooldown_railgun", function (owner_unit, buff, params)

	if ALIVE[owner_unit] then
		local hit_zone = params[3]
		local target_number = params[4]
		local buff_type = params[5]
		local damage_dealt = params[2]

		if target_number then
			buff.can_trigger = true
		end

		if buff.can_trigger and buff_type == "RANGED_ABILITY" and (hit_zone == "head" or hit_zone == "neck") then
			local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
			local buff_to_add = buff.template.buff_to_add

			buff_extension:add_buff(buff_to_add)

			buff.can_trigger = false
		end
	end
end)
mod:add_proc_function("kerillian_waywatcher_reduce_activated_ability_cooldown", function (owner_unit, buff, params)

	if Unit.alive(owner_unit) then
		local hit_zone = params[3]
		local target_number = params[4]
		local buff_type = params[5]

		if target_number then
			buff.can_trigger = true
		end

		if buff.can_trigger and buff_type == "RANGED_ABILITY" and (hit_zone == "head" or hit_zone == "neck") then
			local career_extension = ScriptUnit.extension(owner_unit, "career_system")

			career_extension:reduce_activated_ability_cooldown_percent(buff.multiplier)

			buff.can_trigger = false
		end
	end
end)

mod:add_talent_buff_template("wood_elf", "gs_wall_ult_toggle", {
	icon = "kerillian_thornsister_activated_ability",
	max_stacks = 1,
	perks = "wall_swap",
	debuff = true
})
table.insert(require("scripts/unit_extensions/default_player_unit/buffs/settings/buff_perk_names"), "wall_swap")

mod:hook_origin(PassiveAbilityThornsister, "extensions_ready", function(self, world, unit)
	self._career_extension = ScriptUnit.has_extension(unit, "career_system")
	self._buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	self._input_extension = ScriptUnit.has_extension(unit, "input_system")

	local ability_init_data = self._ability_init_data

	self._career_extension:setup_extra_ability_uses(0, ability_init_data.cooldown, ability_init_data.starting_stack_count, ability_init_data.max_stacks)

	local talent_extension = ScriptUnit.has_extension(unit, "talent_system")

	self:_update_extra_abilities_info(talent_extension)
	self:_register_events()
end)

mod:hook_origin(PassiveAbilityThornsister, "update", function (self, dt, t)
	local career_ext = self._career_extension

	if not career_ext then
		return
	end

	career_ext:modify_extra_ability_charge(dt)

	local buff_extension = self._buff_extension

	if buff_extension then
		local extra_ability_uses, extra_ability_uses_max = career_ext:get_extra_ability_uses()
		local extra_ability_use_charge, extra_ability_use_required_charge = career_ext:get_extra_ability_charge()
		local cooldown_buff = self._cooldown_buff

		if cooldown_buff and cooldown_buff.is_stale then
			cooldown_buff = nil
		end

		if extra_ability_uses < extra_ability_uses_max then
			if not cooldown_buff then
				local buff_id = buff_extension:add_buff("kerillian_thorn_sister_free_ability_cooldown")
				cooldown_buff = buff_extension:get_buff_by_id(buff_id)
				self._cooldown_buff = cooldown_buff
			end

			cooldown_buff.start_time = t - extra_ability_use_charge
			cooldown_buff.duration = extra_ability_use_required_charge
		elseif cooldown_buff then
			buff_extension:remove_buff(cooldown_buff.id)

			self._cooldown_buff = nil
		end

		local stack_buffs = self._stack_buffs
		local num_stacks = self._num_stack_buffs

		if num_stacks < extra_ability_uses then
			for i = 1, extra_ability_uses - num_stacks, 1 do
				stack_buffs[num_stacks + i] = buff_extension:add_buff("kerillian_thorn_sister_free_ability_stack")
			end
		elseif extra_ability_uses < num_stacks then
			for i = 1, num_stacks - extra_ability_uses, 1 do
				local index = num_stacks - i + 1

				buff_extension:remove_buff(stack_buffs[index])

				stack_buffs[index] = nil
			end
		end

		self._num_stack_buffs = extra_ability_uses
	end

	local input_extension = self._input_extension

	if not input_extension then
		return
	end

	if input_extension:get("action_three") then
		local owner_unit = self._owner_unit
		local status_extension = ScriptUnit.extension(owner_unit, "status_system")
		local zooming = status_extension:get_is_aiming()

		if buff_extension and not zooming then
			local ult_swap_buff = self._ult_swap_buff

			if not ult_swap_buff then
				local buff_id = buff_extension:add_buff("gs_wall_ult_toggle")
				ult_swap_buff = buff_extension:get_buff_by_id(buff_id)
				self._ult_swap_buff = ult_swap_buff

			elseif ult_swap_buff then
				buff_extension:remove_buff(ult_swap_buff.id)

				self._ult_swap_buff = nil
			end
		end
	end
end)

local WALL_SHAPES = table.enum("linear", "radial")
mod:hook_origin(ActionCareerWEThornsisterTargetWall, "init", function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerWEThornsisterTargetWall.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self._first_person_extension = ScriptUnit.has_extension(owner_unit, "first_person_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self.status_extension = ScriptUnit.extension(owner_unit, "status_system")
	self._inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self._weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")
	self._decal_unit = nil
	self._unit_spawner = Managers.state.unit_spawner
	self._target_pos = Vector3Box()
	self._target_rot = QuaternionBox()
	self._segment_positions = {
		{
			num_segments = 0
		},
		{
			num_segments = 0
		}
	}
	self._valid_segment_positions_idx = 0
	self._current_segment_positions_idx = 1
	self._num_segments = 0
	self._max_segments = 0
	self._wall_left_offset = 0
	self._wall_right_offset = 0
	self._wall_shape = WALL_SHAPES.linear
end)

mod:hook_origin(ActionCareerWEThornsisterTargetWall, "client_owner_start_action", function(self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWEThornsisterTargetWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	self._valid_segment_positions_idx = 0
	self._current_segment_positions_idx = 1

	self._weapon_extension:set_mode(false)

	self._target_sim_gravity = new_action.target_sim_gravity
	self._target_sim_speed = new_action.target_sim_speed
	self._target_width = new_action.target_width
	self._target_thickness = new_action.target_thickness
	self._vertical_rotation = new_action.vertical_rotation
	self._wall_shape = WALL_SHAPES.linear

	if self.talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
		if self.buff_extension:has_buff_type("gs_wall_ult_toggle") then
			local half_thickness = self._target_thickness / 2
			self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
			self._bot_target_unit = false
		else
			self._target_thickness = 7
			self._target_width = 7
			self._wall_shape = WALL_SHAPES.radial
			self._num_segmetns_to_check = 3
			self._radial_center_offset = 0.5
			self._bot_target_unit = true
		end
	elseif self.talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
		if self.buff_extension:has_buff_type("gs_wall_ult_toggle") then
			self._target_thickness = 7
			self._target_width = 7
			self._wall_shape = WALL_SHAPES.radial
			self._num_segmetns_to_check = 3
			self._radial_center_offset = 0.5
			self._bot_target_unit = true
		else
			self._target_width = 8
			local half_thickness = self._target_thickness / 2
			self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
			self._bot_target_unit = false
		end
	else
		if self.buff_extension:has_buff_type("gs_wall_ult_toggle") then
			self._target_thickness = 7
			self._target_width = 7
			self._wall_shape = WALL_SHAPES.radial
			self._num_segmetns_to_check = 3
			self._radial_center_offset = 0.5
			self._bot_target_unit = true
		else
			local half_thickness = self._target_thickness / 2
			self._num_segmetns_to_check = math.floor(self._target_width / half_thickness)
			self._bot_target_unit = false
		end
	end

	local max_segments = self._max_segments
	local segment_count = self._num_segmetns_to_check

	if max_segments < segment_count then
		local segment_positions = self._segment_positions

		for i = max_segments, segment_count, 1 do
			for idx = 1, 2, 1 do
				segment_positions[idx][i + 1] = Vector3Box()
			end
		end

		self._max_segments = segment_count
	end

	local status_extension = self.status_extension

	status_extension:set_is_aiming(true)

	self:_update_targeting()
end)

mod:hook_origin(ActionCareerWEThornsisterTargetWall, "finish", function (self, reason)
	if self._decal_unit then
		self._unit_spawner:mark_for_deletion(self._decal_unit)

		self._decal_unit = nil
	end

	local status_extension = self.status_extension

	status_extension:set_is_aiming(false)

	if reason == "new_interupting_action" then
		if self._valid_segment_positions_idx > 0 then
			self._weapon_extension:set_mode(true)

			local targeting_data = {
				position = self._target_pos,
				rotation = self._target_rot,
				segments = self._segment_positions[self._valid_segment_positions_idx],
				num_segments = self._segment_positions[self._valid_segment_positions_idx].num_segments
			}

			return targeting_data
		end
	else
		self._inventory_extension:wield_previous_non_level_slot()
	end

	return nil
end)


mod:hook_origin(ActionCareerWEThornsisterWall, "init", function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerWEThornsisterWall.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self.career_extension = ScriptUnit.extension(owner_unit, "career_system")
	self.inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self.talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	self.buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
	self._wall_index = 0
end)
local WALL_FORWARD_OFFSET_RANGE = 0.1
local WALL_RIGHT_OFFSET_RANGE = 0.05

mod:hook_origin(ActionCareerWEThornsisterWall, "client_owner_start_action", function(self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWEThornsisterWall.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local target_data = chain_action_data
	local num_segments = (target_data and target_data.num_segments) or 0

	if num_segments > 0 then
		self:_play_vo()

		local position = target_data.position:unbox()
		local rotation = target_data.rotation:unbox()
		local segments = target_data.segments
		local explosion_template = "we_thornsister_career_skill_wall_explosion"
		local scale = 1
		local career_extension = self.career_extension
		local career_power_level = career_extension:get_career_power_level()
		local area_damage_system = Managers.state.entity:system("area_damage_system")

		if self.talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
			if not self.buff_extension:has_buff_type("gs_wall_ult_toggle") then
				if self.talent_extension:has_talent("kerillian_thorn_sister_double_poison") then
					explosion_template = "we_thornsister_career_skill_explosive_wall_explosion_improved"
				else
					explosion_template = "we_thornsister_career_skill_explosive_wall_explosion"
				end
			end
		elseif self.buff_extension:has_buff_type("gs_wall_ult_toggle") then
			explosion_template = "we_thornsister_career_skill_explosive_wall_explosion_no_apply"
		elseif self.talent_extension:has_talent("kerillian_thorn_sister_wall_push") then
			explosion_template = nil
		end

		if explosion_template then
			self:_spawn_wall(num_segments, segments, rotation)
			area_damage_system:create_explosion(self.owner_unit, position, rotation, explosion_template, scale, "career_ability", career_power_level, false)
		else
			local damage_wave_template_name = "thornsister_thorn_wall_push"
			local damage_wave_template_id = NetworkLookup.damage_wave_templates[damage_wave_template_name]
			local network_manager = Managers.state.network
			local source_unit_id = network_manager:unit_game_object_id(self.owner_unit)
			local forward = Quaternion.forward(rotation)
			local right = Quaternion.right(rotation)
			local segment_arr = {}

			for i = 1, num_segments, 1 do
				segment_arr[i] = segments[i]:unbox() + forward * (math.random() * WALL_FORWARD_OFFSET_RANGE * 2 - WALL_FORWARD_OFFSET_RANGE) + right * (math.random() * WALL_RIGHT_OFFSET_RANGE * 2 - WALL_RIGHT_OFFSET_RANGE)
			end

			local wall_index = self:_get_next_wall_index()

			network_manager.network_transmit:send_rpc_server("rpc_create_thornsister_push_wave", source_unit_id, POSITION_LOOKUP[self.owner_unit], position, damage_wave_template_id, career_power_level, segment_arr, wall_index)
		end

		career_extension:start_activated_ability_cooldown()
	end
end)

local UNIT_NAMES = {
	default = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01",
	bleed = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_bleed",
	poison = "units/beings/player/way_watcher_thornsister/abilities/ww_thornsister_thorn_wall_01_poison"
}
local WALL_TYPES = table.enum("default", "bleed", "poison")
SpawnUnitTemplates.thornsister_thorn_wall_unit = {
	spawn_func = function (source_unit, position, rotation, state_int, group_spawn_index)
		local UNIT_NAME = UNIT_NAMES[WALL_TYPES.default]
		local UNIT_TEMPLATE_NAME = "thornsister_thorn_wall_unit"
		local wall_index = state_int
		local despawn_sound_event = "career_ability_kerillian_sister_wall_disappear"
		local life_time = 6
		local area_damage_params = {
			aoe_dot_damage = 0,
			radius = 0.3,
			area_damage_template = "we_thornsister_thorn_wall",
			invisible_unit = false,
			nav_tag_volume_layer = "temporary_wall",
			create_nav_tag_volume = true,
			aoe_init_damage = 0,
			damage_source = "career_ability",
			aoe_dot_damage_interval = 0,
			damage_players = false,
			source_attacker_unit = source_unit,
			life_time = life_time
		}
		local props_params = {
			life_time = life_time,
			owner_unit = source_unit,
			despawn_sound_event = despawn_sound_event,
			wall_index = wall_index
		}
		local health_params = {
			health = 20
		}
		local buffs_to_add = nil
		local source_talent_extension = ScriptUnit.has_extension(source_unit, "talent_system")
		local source_buff_extension = ScriptUnit.has_extension(source_unit, "buff_system")

		if source_talent_extension then
			if source_talent_extension:has_talent("kerillian_thorn_sister_tanky_wall") then
				if source_buff_extension and (source_buff_extension:has_buff_type("gs_wall_ult_toggle") or source_buff_extension:has_buff_perk("wall_swap")) then
					local life_time_mult = 0.17
					local life_time_bonus = 0
					area_damage_params.create_nav_tag_volume = false
					area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
					props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
					UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
				else
					local life_time_mult = 1
					local life_time_bonus = 4.2
					area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
					props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
				end
			elseif source_talent_extension:has_talent("kerillian_thorn_sister_debuff_wall") then
				if not source_buff_extension:has_buff_type("gs_wall_ult_toggle") then
					local life_time_mult = 0.17
					local life_time_bonus = 0
					area_damage_params.create_nav_tag_volume = false
					area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
					props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
					UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
				end
			elseif source_talent_extension:has_talent("kerillian_thorn_sister_wall_push") and source_buff_extension:has_buff_type("gs_wall_ult_toggle") then
				local life_time_mult = 0.17
				local life_time_bonus = 0
				area_damage_params.create_nav_tag_volume = false
				area_damage_params.life_time = area_damage_params.life_time * life_time_mult + life_time_bonus
				props_params.life_time = props_params.life_time * life_time_mult + life_time_bonus
				UNIT_NAME = UNIT_NAMES[WALL_TYPES.bleed]
			end
		end

		local extension_init_data = {
			area_damage_system = area_damage_params,
			props_system = props_params,
			health_system = health_params,
			death_system = {
				death_reaction_template = "thorn_wall",
				is_husk = false
			},
			hit_reaction_system = {
				is_husk = false,
				hit_reaction_template = "level_object"
			}
		}
		local wall_unit = Managers.state.unit_spawner:spawn_network_unit(UNIT_NAME, UNIT_TEMPLATE_NAME, extension_init_data, position, rotation)
		local random_rotation = Quaternion(Vector3.up(), math.random() * 2 * math.pi - math.pi)

		Unit.set_local_rotation(wall_unit, 0, random_rotation)

		local buff_extension = ScriptUnit.has_extension(wall_unit, "buff_system")

		if buff_extension and buffs_to_add then
			for i = 1, #buffs_to_add, 1 do
				buff_extension:add_buff(buffs_to_add[i])
			end
		end

		local thorn_wall_extension = ScriptUnit.has_extension(wall_unit, "props_system")

		if thorn_wall_extension then
			thorn_wall_extension.group_spawn_index = group_spawn_index
		end
	end
}
mod:hook_origin(ActionMeleeStart, "client_owner_post_update", function (self, dt, t, world)
	local action = self.current_action
	local owner_unit = self.owner_unit
	local action_start_time = self.action_start_t
	local blocking_charge = action.blocking_charge
	local status_extension = self.status_extension

	if not status_extension.blocking and blocking_charge and t > action_start_time + self._block_delay then
		local go_id = Managers.state.unit_storage:go_id(owner_unit)

		if not LEVEL_EDITOR_TEST then
			if self.is_server then
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, true)
				Managers.state.network.network_transmit:send_rpc_clients("rpc_set_charge_blocking", go_id, true)
			else
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", go_id, true)
				Managers.state.network.network_transmit:send_rpc_server("rpc_set_charge_blocking", go_id, true)
			end
		end

		status_extension:set_blocking(true)
		status_extension:set_charge_blocking(true)

		status_extension.timed_block = t + 0.5
		status_extension.timed_block_long = t + 1
	end

	if self.zoom_condition_function and self.zoom_condition_function(action.lookup_data) then
		local input_extension = self.input_extension
		local buff_extension = self.buff_extension

		if not status_extension:is_zooming() and self.aim_zoom_time <= t then
			status_extension:set_zooming(true, action.default_zoom)
		end

		if buff_extension:has_buff_perk("increased_zoom") and status_extension:is_zooming() and input_extension:get("action_three") then
			status_extension:switch_variable_zoom(action.buffed_zoom_thresholds)
		end
	end
end)

mod:hook_origin(ActionBlock, "client_owner_start_action", function (self, new_action, t)
	ActionBlock.super.client_owner_start_action(self, new_action, t)

	self.current_action = new_action
	self.action_time_started = t
	local input_extension = ScriptUnit.extension(self.owner_unit, "input_system")

	input_extension:reset_input_buffer()

	local owner_unit = self.owner_unit
	local go_id = Managers.state.unit_storage:go_id(owner_unit)

	if not LEVEL_EDITOR_TEST then
		if self.is_server then
			Managers.state.network.network_transmit:send_rpc_clients("rpc_set_blocking", go_id, true)
		else
			Managers.state.network.network_transmit:send_rpc_server("rpc_set_blocking", go_id, true)
		end
	end

	Unit.flow_event(self.first_person_unit, "sfx_block_started")

	local status_extension = self._status_extension

	status_extension:set_blocking(true)

	status_extension.timed_block = t + 0.5
	status_extension.timed_block_long = t + 1
end)

mod:hook_origin(GenericStatusExtension, "init", function (self, extension_init_context, unit, extension_init_data)
	self.world = extension_init_context.world
	self.profile_id = extension_init_data.profile_id

	fassert(self.profile_id)

	self.unit = unit
	self.pacing_intensity = 0
	self.pacing_intensity_decay_delay = 0
	self.move_speed_multiplier = 1
	self.move_speed_multiplier_timer = 1
	self.invisible = {}
	self.crouching = false
	self.blocking = false
	self.override_blocking = nil
	self.charge_blocking = false
	self.catapulted = false
	self.catapulted_direction = nil
	self.pounced_down = false
	self.on_ladder = false
	self.is_ledge_hanging = false
	self.left_ladder_timer = 0
	self.aim_unit = nil
	self.revived = false
	self.dead = false
	self.pulled_up = false
	self.overpowered = false
	self.overpowered_template = nil
	self.overpowered_attacking_unit = nil
	self._has_blocked = false
	self.my_dodge_cd = 0
	self.my_dodge_jump_override_t = 0
	self.dodge_cooldown = 0
	self.dodge_cooldown_delay = 0
	self.is_aiming = false
	self.dodge_count = 2
	self.combo_target_count = 0
	self.fatigue = 0
	self.last_fatigue_gain_time = 0
	self.show_fatigue_gui = false
	self.max_fatigue_points = 100
	self.next_hanging_damage_time = 0
	self.block_broken = false
	self.block_broken_at_t = -math.huge
	self.stagger_immune = false
	self.pushed = false
	self.pushed_at_t = -math.huge
	self.push_cooldown = false
	self.push_cooldown_timer = false
	self.timed_block = nil
	self.timed_block_long = nil
	self.shield_block = nil
	self.charged = false
	self.charged_at_t = -math.huge
	self.interrupt_cooldown = false
	self.interrupt_cooldown_timer = nil
	self.inside_transport_unit = nil
	self.using_transport = false
	self.dodge_position = Vector3Box(0, 0, 0)
	self.overcharge_exploding = false
	self.fall_height = nil
	self.under_ratling_gunner_attack = nil
	self.last_catapulted_time = 0
	self.grabbed_by_tentacle = false
	self.grabbed_by_tentacle_status = nil
	self.grabbed_by_chaos_spawn = false
	self.grabbed_by_chaos_spawn_status = nil
	self.in_vortex = false
	self.in_vortex_unit = nil
	self.near_vortex = false
	self.near_vortex_unit = nil
	self.in_liquid = false
	self.in_liquid_unit = nil
	self.in_hanging_cage_unit = nil
	self.in_hanging_cage_state = nil
	self.in_hanging_cage_animations = nil
	self.wounds = extension_init_data.wounds

	if self.wounds == -1 then
		self.wounds = math.huge
	end

	self._base_max_wounds = self.wounds
	self._num_times_grabbed_by_pack_master = 0
	self._num_times_hit_by_globadier_poison = 0
	self._num_times_knocked_down = 0
	self.is_server = Managers.player.is_server
	self.update_funcs = {}

	self:set_spawn_grace_time(5)

	self.ready_for_assisted_respawn = false
	self.assisted_respawning = false
	self.player = extension_init_data.player
	self.is_bot = self.player.bot_player
	self.in_end_zone = false
	self.is_husk = self.player.remote

	if self.is_server then
		self.conflict_director = Managers.state.conflict
	end

	self._intoxication_level = 0
	self.noclip = {}
	self._incapacitated_outline_ids = {}
	self._assisted_respawn_outline_id = -1
	self._invisible_outline_id = -1
end)

--Increase window for proccing parry based buffs
mod:hook_origin(GenericStatusExtension, "blocked_attack", function (self, fatigue_type, attacking_unit, fatigue_point_costs_multiplier, improved_block, attack_direction)
	local unit = self.unit
	local inventory_extension = self.inventory_extension
	local equipment = inventory_extension:equipment()
	local blocking_unit = nil

	self:set_has_blocked(true)

	local player = self.player

	if player then
		local buff_extension = self.buff_extension
		local all_blocks_parry_buff = "power_up_deus_block_procs_parry_exotic"
		local all_blocks_parry = buff_extension:has_buff_type(all_blocks_parry_buff)
		local is_timed_block = false
		local t = Managers.time:time("game")

		if self.timed_block and (t < self.timed_block or all_blocks_parry) then
			buff_extension:trigger_procs("on_timed_block", attacking_unit)
			is_timed_block = true
		end

		if self.timed_block_long and (t < self.timed_block_long or all_blocks_parry) then
			buff_extension:trigger_procs("on_timed_block_long", attacking_unit)
		end

		if not player.remote then
			local first_person_extension = ScriptUnit.extension(unit, "first_person_system")
			local first_person_unit = first_person_extension:get_first_person_unit()

			if Managers.state.controller_features and player.local_player then
				Managers.state.controller_features:add_effect("rumble", {
					rumble_effect = "block"
				})
			end

			blocking_unit = equipment.right_hand_wielded_unit or equipment.left_hand_wielded_unit
			local weapon_template_name = equipment.wielded.template or equipment.wielded.temporary_template
			local weapon_template = Weapons[weapon_template_name]

			if is_timed_block then
				first_person_extension:play_hud_sound_event("Play_player_parry_success", nil, false)
			end

			self:add_fatigue_points(fatigue_type, attacking_unit, blocking_unit, fatigue_point_costs_multiplier, is_timed_block)

			local parry_reaction = "parry_hit_reaction"

			if improved_block then
				local amount = PlayerUnitStatusSettings.fatigue_point_costs[fatigue_type]

				if amount <= 2 and (attack_direction == "left" or attack_direction == "right") then
					parry_reaction = "parry_deflect_" .. attack_direction
				end

				local block_arc_event = (weapon_template and weapon_template.sound_event_block_within_arc) or "Play_player_block_ark_success"

				first_person_extension:play_hud_sound_event(block_arc_event, nil, false)
			else
				local wwise_world = Managers.world:wwise_world(self.world)
				local enemy_pos = POSITION_LOOKUP[attacking_unit]

				if enemy_pos then
					local player_pos = first_person_extension:current_position()
					local dir_to_enemy = Vector3.normalize(enemy_pos - player_pos)

					WwiseWorld.trigger_event(wwise_world, "Play_player_combat_out_of_arc_block", player_pos + dir_to_enemy)
				end
			end

			Unit.animation_event(first_person_unit, parry_reaction)
			QuestSettings.handle_bastard_block(unit, attacking_unit, true)
		else
			blocking_unit = equipment.right_hand_wielded_unit_3p or equipment.left_hand_wielded_unit_3p

			QuestSettings.handle_bastard_block(unit, attacking_unit, true)
			self:add_fatigue_points(fatigue_type, attacking_unit, blocking_unit, fatigue_point_costs_multiplier, is_timed_block)
			Unit.animation_event(unit, "parry_hit_reaction")
		end

		Managers.state.entity:system("play_go_tutorial_system"):register_block()
	end

	if blocking_unit then
		local unit_pos = POSITION_LOOKUP[blocking_unit]
		local unit_rot = Unit.world_rotation(blocking_unit, 0)
		local particle_position = unit_pos + Quaternion.up(unit_rot) * Math.random() * 0.5 + Quaternion.right(unit_rot) * 0.1

		World.create_particles(self.world, "fx/wpnfx_sword_spark_parry", particle_position)
	end
end)

table.insert(ProcEvents, "on_timed_block_long")

mod:hook_origin(GenericStatusExtension, "set_wounded", function (self, wounded, reason, t)
	if not self.buff_extension:has_buff_perk("infinite_wounds") then
		if wounded then
			self.wounds = self.wounds - 1
		elseif reason == "healed" then
			self.wounds = self:get_max_wounds()
		end

		if self.player.local_player and not Managers.state.game_mode:has_activated_mutator("instant_death") then
			MOOD_BLACKBOARD.wounded = self.wounds == 1

			if not MOOD_BLACKBOARD.wounded then
				MOOD_BLACKBOARD.bleeding_out = wounded
			else
				MOOD_BLACKBOARD.bleeding_out = false
			end
		end
	end
end)

NewStatBuffApplicationMethods = NewStatBuffApplicationMethods or {}

NewStatBuffApplicationMethods = {
	first_ranged_hit_damage = "stacking_multiplier"
}

table.merge_recursive(StatBuffApplicationMethods, NewStatBuffApplicationMethods)