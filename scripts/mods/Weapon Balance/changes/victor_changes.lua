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

--WHC
ExplosionTemplates.victor_captain_activated_ability_stagger.explosion = {
    no_prop_damage = true,
    radius = 10,
    use_attacker_power_level = true,
    max_damage_radius = 3,
    always_hurt_players = false,
    alert_enemies = true,
    alert_enemies_radius = 15,
    attack_template = "drakegun",
    damage_type = "grenade",
    damage_profile = "ability_push",
    ignore_attacker_unit = true,
    no_friendly_fire = true,
    attacker_power_level_offset = 0.01,
}
mod:modify_talent("wh_captain", 2, 1, {
	buffs = {
		"victor_witchhunter_guaranteed_crit_on_timed_block_add",
        "gs_whc_power"
	}
})
mod:add_talent_buff_template("witch_hunter", "gs_whc_power", {
    event = "on_push",
    buff_to_add = "gs_whc_power_buff",
    buff_func = "add_buff"
})
mod:add_talent_buff_template("witch_hunter", "gs_whc_power_buff", {
    stat_buff = "power_level_melee",
    duration = 5,
    refresh_durations = true,
    icon = "victor_witchhunter_guaranteed_crit_on_timed_block",
    multiplier = 0.15,
    max_stacks = 1
})
mod:modify_talent_buff_template("witch_hunter", "victor_witchhunter_guaranteed_crit_on_timed_block_add", {
    event = "on_timed_block_long",
})
mod:modify_talent_buff_template("witch_hunter", "victor_witchhunter_guaranteed_crit_on_timed_block_buff", {
    duration = 3
})

mod:add_text("victor_witchhunter_guaranteed_crit_on_timed_block_desc", "Blocking just as an enemy attack is about to hit causes your next melee or ranged attack within 3 seconds to be a guaranteed critical hit. Pushing an enemy increases melee power by 15.0%% for 5 seconds. ")

mod:modify_talent("wh_captain", 5, 3, {
	description = "gs_whc_ammo_on_melee_kills_desc",
    buffer = "both",
	buffs = {
		"gs_whc_ammo_on_melee_kills"
	}
})
mod:add_text("gs_whc_ammo_on_melee_kills_desc", "Enemy kills each grant a value (equal to on-kill THP), each time the value exceeds 60, gain 5%% ammo.")

mod:add_talent_buff_template("witch_hunter", "gs_whc_ammo_on_melee_kills", {
    event = "on_kill",
    buff_func = "gs_ammo_on_melee_kills",
    ammo_bonus_fraction = 0.05,
    required_kills = 60,
    display_buff = "gs_display_buff_whc_ammo"
})
mod:add_talent_buff_template("witch_hunter", "gs_display_buff_whc_ammo", {
    max_stacks = 100,
	icon = "victor_witchhunter_max_ammo"
})

--Zealot
mod:add_text("career_passive_desc_wh_1a", "Melee power increased by 20%. Damaging multiple enemies in one swing with a melee weapon causes Zealot to take damage when above 25% hp. 0.5 damage per enemy hit.")
PassiveAbilitySettings.wh_1.buffs = {
    "gs_victor_zealot_health_increase",
	"victor_zealot_passive_uninterruptible_heavy",
	"victor_zealot_gain_invulnerability_on_lethal_damage_taken",
	"victor_zealot_ability_cooldown_on_hit",
    "victor_zealot_ability_cooldown_on_damage_taken",
    "gs_infinite_wounds",
    "gs_victor_zealot_damage_on_hit",
    "gs_deus_reckless_swings"
}
PassiveAbilitySettings.wh_1.perks = {
    {
        display_name = "career_passive_name_wh_1b",
        description = "career_passive_desc_dr_2c"
    },
    {
        display_name = "career_passive_name_wh_1c",
        description = "career_passive_desc_wh_1c"
    },
    {
        display_name = "career_passive_name_wh_1d",
        description = "career_passive_desc_wh_1d"
    },
}
mod:add_text("career_passive_name_wh_1d", "Hard to kill.")
mod:add_text("career_passive_desc_wh_1d", "Healing received increased by 50% when below 25% health. Does not get wounded after going down.")

mod:add_talent_buff_template("witch_hunter", "gs_infinite_wounds", {
    perks = { buff_perks.infinite_wounds }
})

mod:add_talent_buff_template("witch_hunter", "gs_deus_reckless_swings", {
    stat_buff = "power_level_melee",
    max_stacks = 1,
    multiplier = 0.2,
    icon = "deus_reckless_swings"
})

local function is_local(unit)
	local player = Managers.player:owner(unit)

	return player and not player.remote
end

mod:add_buff_function("activate_buff_on_health_percent_zealot_passive", function (unit, buff, params)
    local template = buff.template
    local buff_to_add = template.buff_to_add
    local owner_unit = unit
    local targets = {}
    local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
    local local_player = is_local(owner_unit)
    local activation_health = template.activation_health
    local activate_below = template.activate_below
    local health_extension = ScriptUnit.extension(unit, "health_system")
    local health_percent = health_extension:current_health_percent()
    local adding_buff = nil
    local has_buff = buff_extension:get_non_stacking_buff("gs_victor_heal_block_buff")

    if (health_percent < activation_health and activate_below and not has_buff) or (activation_health < health_percent and not activate_below) then
        adding_buff = true
    end

    local buff_system = Managers.state.entity:system("buff_system")
    local buff = buff_extension:get_non_stacking_buff(buff_to_add)

    if not adding_buff and buff then
        if local_player then
            buff_extension:remove_buff(buff.id)
        else
            local server_id = buff.server_id

            buff_system:remove_server_controlled_buff(owner_unit, server_id)
        end
    elseif adding_buff and not buff then
        if local_player then
            buff_extension:add_buff(buff_to_add)
        else
            local server_buff_id = buff_system:add_buff(owner_unit, buff_to_add, owner_unit, true)
            local buff = buff_extension:get_non_stacking_buff(buff_to_add)

            if buff then
                buff.server_id = server_buff_id
            end
        end
    end
end)
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_health_increase", {
    activation_health = 0.25,
    activate_below = true,
    buff_to_add = "gs_victor_zealot_health_increase_buff",
    update_func = "activate_buff_on_health_percent_zealot_passive"
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_health_increase_buff", {
    icon = "victor_zealot_passive_healing_received",
    stat_buff = "healing_received",
    max_stacks = 1,
    multiplier = 0.5
})

mod:add_proc_function("gs_zealot_damage", function(owner_unit, buff, params, world)
    if not Managers.state.network.is_server then
        return
    end
    
    local target_num = params[4]
    local attack_type = params[2] == "light_attack" or params[2] == "heavy_attack"
    local template = buff.template
    local damage_to_deal = template.damage_to_deal
    local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

    if talent_extension:has_talent("victor_zealot_passive_damage_taken", "witch_hunter", true) then
        damage_to_deal = 0.75
    elseif talent_extension:has_talent("victor_zealot_passive_healing_received", "witch_hunter", true) then
        damage_to_deal = 0.25
    end

    if target_num <= 5 and attack_type then
        DamageUtils.add_damage_network(owner_unit, owner_unit, damage_to_deal, "torso", "life_drain", nil, Vector3(0, 0, 0), "life_drain", nil, owner_unit)
    end
end)

mod:add_proc_function("victor_zealot_gain_invulnerability", function(owner_unit, buff, params)
    local status_extension = ScriptUnit.extension(owner_unit, "status_system")

    if ALIVE[owner_unit] and not status_extension:is_knocked_down() then
        local health_extension = ScriptUnit.extension(owner_unit, "health_system")
        local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
        local already_unkillable = buff_extension:has_buff_perk("invulnerable") or buff_extension:has_buff_perk("ignore_death")

        if already_unkillable then
            return false
        end

        local damage = params[2]
        local current_health = health_extension:current_health()
        local killing_blow = current_health <= damage
        local template = buff.template
        local buff_to_add = template.buff_to_add

        if killing_blow or current_health <= 1 then
            buff_extension:add_buff(buff_to_add)

            return true
        end
    end
end)

mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_damage_on_hit", {
    buff_to_add = "gs_victor_zealot_damage_on_hit_buff",
    authority = "server",
    update_func = "update_server_buff_on_health_percent",
    update_frequency = 0.5,
    health_threshold = 0.25
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_damage_on_hit_buff", {
    multiplier = -0.05,
    max_targets = 5,
    buff_func = "gs_zealot_damage",
    event = "on_hit",
    bonus = 0.25,
    damage_to_deal = 0.5
})

mod:add_buff_function("gs_activate_scaling_buff_based_on_health_percentage_missing", function(unit, buff, params)
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
	local health_percentage_missing = 1 - (current_health / max_health)
	local stacks_to_add = 0
	local max_buff_value = template.max_buff_value

	stacks_to_add = health_percentage_missing * max_buff_value

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

mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_scaling", {
	buff_to_add = "gs_victor_zealot_attack_speed_scaling_buff",
	update_func = "gs_activate_scaling_buff_based_on_health_percentage_missing",
	update_frequency = 0.2,
	max_buff_value = 20,
    name = "gs_victor_zealot_attack_speed_scaling"
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_scaling_buff", {
	max_stacks = 20,
    name = "gs_victor_zealot_attack_speed_scaling_buff",
	icon = "victor_zealot_attack_speed_on_health_percent",
	stat_buff = "attack_speed",
	multiplier = 0.01
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_3", {
    activation_health = 0.3,
    activate_below = true,
    buff_to_add = "gs_victor_zealot_attack_speed_buff_3",
    update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_buff_3", {
    icon = "victor_zealot_attack_speed_on_health_percent",
    stat_buff = "attack_speed",
    max_stacks = 1,
    multiplier = 0.1
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_2", {
    activation_health = 0.5,
    activate_below = true,
    buff_to_add = "gs_victor_zealot_attack_speed_buff_2",
    update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_buff_2", {
    icon = "victor_zealot_attack_speed_on_health_percent",
    stat_buff = "attack_speed",
    max_stacks = 1,
    multiplier = 0.1
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_1", {
    activation_health = 0.8,
    activate_below = true,
    buff_to_add = "gs_victor_zealot_attack_speed_buff_1",
    update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_buff_1", {
    icon = "victor_zealot_attack_speed_on_health_percent",
    stat_buff = "attack_speed",
    max_stacks = 1,
    multiplier = 0.1
})
mod:modify_talent("wh_zealot", 2, 1, {
    description = "zealot_2_1_desc",
    buffs = {
        "gs_victor_zealot_attack_speed_scaling"
    }
})
mod:add_text("zealot_2_1_desc", "Gain up to 20%% attack speed based on missing health.")

mod:modify_talent("wh_zealot", 2, 2, {
    perks = {}
})
mod:add_text("victor_zealot_crit_count_desc", "Every 5 hits grant a guaranteed critical strike.")

mod:add_talent_buff_template("witch_hunter", "zealot_buff_on_damage_buff", {
    icon = "victor_zealot_attack_speed_on_health_percent",
    duration = 15,
    max_stacks = 1,
	refresh_durations = true,
    proc_weight = 5,
	buff_func = "thorn_sister_add_melee_poison",
	event = "on_hit",
	poison = "zealot_burning_debuff"
})
mod:add_talent_buff_template("witch_hunter", "zealot_buff_on_damage", {
	event = "on_damage_taken",
	damage_to_take = 100,
    buff_func = "gs_zealot_damage_tracking",
	buff_to_add = "zealot_buff_on_damage_buff",
	display_buff = "zealot_buff_on_damage_display"
})
mod:add_talent_buff_template("witch_hunter", "zealot_buff_on_damage_display", {
    max_stacks = 100,
	icon = "markus_mercenary_max_ammo"
})
mod:add_proc_function("gs_zealot_damage_tracking", function (owner_unit, buff, params)

	if Unit.alive(owner_unit) then
		local attacker_unit = params[1]
		local damage_amount = params[2]
		local damage_type = params[3]
		local breed = AiUtils.unit_breed(attacker_unit)
		local buff_template = buff.template
		local damage_to_take = buff_template.damage_to_take

		if breed and not breed.is_hero then
			local health_extension = ScriptUnit.has_extension(owner_unit, "health_system")

			if health_extension and damage_amount < health_extension:current_health() then
				local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
				if not buff.counter then
					buff.counter = 0
				end

				local counter = buff.counter

				if counter >= damage_to_take then
					local buff_to_add = buff_template.buff_to_add
					buff_extension:add_buff(buff_to_add)

					buff.counter = counter - damage_to_take
				end

				if damage_amount then
					buff.counter = buff.counter + damage_amount
				end

				if not Managers.state.network.is_server then
					return
				end

				local display_buff = buff_template.display_buff
				local buff_system = Managers.state.entity:system("buff_system")
				local num_buff_stacks = buff_extension:num_buff_type(display_buff)

				if not buff.stack_ids then
					buff.stack_ids = {}
				end

				local distance = damage_to_take - counter

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
			end
		end
	end
end)

mod:modify_talent("wh_zealot", 4, 1, {
    description = "zealot_4_1_desc",
    buffer = "both",
    buffs = {
        "zealot_buff_on_damage"
    }
})
mod:add_text("zealot_4_1_desc", "After taking 100 damage from enemies victor gains flaming weapons for 15 seconds that cause enemies to take 10%% more damage up to 3 stacks.")
mod:modify_talent("wh_zealot", 2, 3, {
    description = "zealot_2_3_desc",
    buffer = "both",
    buffs = {
        "gs_victor_zealot_increased_damage_to_first_target"
    }
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_increased_damage_to_first_target", {
    stat_buff = "first_melee_hit_damage",
    multiplier = 0.15
})
mod:add_text("zealot_2_3_desc", "Deal 15%% more damage to the first target hit with each attack.")
mod:modify_talent("wh_zealot", 4, 2, {
    description = "zealot_4_2_desc",
    name = "zealot_4_2_name",
    buffer = "both",
    buffs = {
        "gs_victor_zealot_attack_speed_high_health"
    }
})
mod:add_text("zealot_4_2_name", "The Good ending")
mod:add_text("zealot_4_2_desc", "Lower damage taken per enemy hit to 0.25. Gain 10%% attackspeed based on percentage of health remaining.")
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_high_buff", {
    icon = "victor_zealot_passive_healing_received",
    stat_buff = "attack_speed",
    multiplier = 0.01,
    max_stacks = 10,
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_attack_speed_high_health", {
    update_frequency = 0.2,
	max_buff_value = 10,
    buff_to_add = "gs_victor_zealot_attack_speed_high_buff",
    update_func = "gs_activate_scaling_buff_based_on_health_percentage"
})
mod:modify_talent("wh_zealot", 4, 3, {
    description = "zealot_4_3_desc",
    buffer = "both",
    buffs = {
        "gs_victor_zealot_dr",
        "gs_deus_reckless_swings_extra"
    }
})
mod:add_text("zealot_4_3_desc", "Increases Fiery Faith melee power buff to 40%% but also increases damage taken per enemy hit to 0.75. Gain 30%% dr when under 50%% health")
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_dr_buff", {
    icon = "victor_zealot_passive_damage_taken",
    stat_buff = "damage_taken",
    multiplier = -0.3,
    max_stacks = 1,
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_zealot_dr", {
    activation_health = 0.5,
    activate_below = true,
    buff_to_add = "gs_victor_zealot_dr_buff",
    update_func = "activate_buff_on_health_percent"
})
mod:add_talent_buff_template("witch_hunter", "gs_deus_reckless_swings_extra", {
    stat_buff = "power_level_melee",
    max_stacks = 1,
    multiplier = 0.1,
})
mod:modify_talent("wh_zealot", 5, 1, {
    description = "zealot_5_1_desc",
    buffer = "both",
    buffs = {
        "gs_victor_attack_speed_on_hit",
    }
})
mod:add_text("zealot_5_1_desc", "Gain 10%% attack speed for 5 seconds when taking damage.")
mod:add_talent_buff_template("witch_hunter", "gs_victor_attack_speed_on_hit", {
    event = "on_damage_taken",
    buff_to_add = "gs_victor_attack_speed_on_hit_buff",
    buff_func = "add_buff_on_non_friendly_damage_taken",
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_attack_speed_on_hit_buff", {
   stat_buff = "attack_speed",
   multiplier = 0.1,
   max_stacks = 1,
   icon = "victor_zealot_move_speed_on_damage_taken",
   duration = 5,
   refresh_durations = true
})
mod:modify_talent("wh_zealot", 5, 2, {
    description = "zealot_5_2_desc",
    buffer = "both",
    buffs = {
        "gs_victor_power_on_hit"
    }
})
mod:add_text("zealot_5_2_desc", "Gain 15% melee power for 5 seconds when taking damage.")
mod:add_talent_buff_template("witch_hunter", "gs_victor_power_on_hit", {
    event = "on_damage_taken",
    buff_to_add = "gs_victor_power_on_hit_buff",
    buff_func = "add_buff_on_non_friendly_damage_taken",
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_power_on_hit_buff", {
   stat_buff = "power_level_melee",
   multiplier = 0.15,
   max_stacks = 1,
   icon = "victor_zealot_max_stamina_on_damage_taken",
   duration = 5,
   refresh_durations = true
})
mod:modify_talent("wh_zealot", 5, 3, {
    description = "zealot_5_3_desc",
    buffer = "both",
    buffs = {
        "gs_victor_cleave_power_on_hit"
    }
})
mod:add_text("zealot_5_3_desc", "Gain 100%% cleave power for 5 seconds when taking damage.")
mod:add_talent_buff_template("witch_hunter", "gs_victor_cleave_power_on_hit", {
    event = "on_damage_taken",
    buff_to_add = "gs_victor_cleave_power_on_hit_buff",
    buff_func = "add_buff_on_non_friendly_damage_taken",
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_cleave_power_on_hit_buff", {
   stat_buff = "power_level_melee_cleave",
   multiplier = 1,
   max_stacks = 1,
   icon = "victor_zealot_reduced_damage_taken",
   duration = 5,
   refresh_durations = true
})
mod:modify_talent_buff_template("witch_hunter", "victor_zealot_activated_ability_power_on_hit_buff", {
    multiplier = 0.025,
    stat_buff = "power_level_melee"
})
mod:add_text("victor_zealot_activated_ability_power_on_hit_desc", "Attacks during Holy Fervour increase melee power by 2.5%% for 5 seconds. Stacks up to 10 times.")

mod:add_talent_buff_template("witch_hunter", "zealot_got_your_back_check", {
    buff_to_add = "zealot_got_your_back",
    name = "zealot_got_your_back_check",
    authority = "server",
    update_func = "update_server_buff_on_health_percent",
    update_frequency = 0.5,
    health_threshold = 0.25,
    duration = 10
})

mod:add_talent_buff_template("witch_hunter", "zealot_got_your_back", {
    buff_to_add = "zealot_got_your_back_buff",
    name = "zealot_got_your_back",
    disregard_self = true,
    remove_buff_func = "remove_aura_buff",
    range = 10,
    update_func = "activate_buff_on_distance",
    authority = "server",
    update_frequency = 0.5
})

mod:add_talent_buff_template("witch_hunter", "zealot_got_your_back_buff", {
    name = "zealot_got_your_back_buff",
    stat_buff = "damage_taken",
    buff_func = "deus_guard_buff_on_damage",
    max_stacks = 1,
    icon = "deus_icon_guard_aura_check",
    event = "on_damage_taken",
    multiplier = -0.5
})

mod:add_text("victor_zealot_activated_ability_ignore_death_desc", "When above 25% Health you take half of the damage inflicted on nearby allies instead of them.")

mod:hook_origin(CareerAbilityWHZealot , "_run_ability", function (self)
	self:_stop_priming()

	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit
	local status_extension = self._status_extension
	local career_extension = self._career_extension
	local buff_extension = self._buff_extension
	local buff_names = {
		"victor_zealot_activated_ability"
	}
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")

	if talent_extension:has_talent("victor_zealot_activated_ability_power_on_hit", "witch_hunter", true) then
		buff_names[#buff_names + 1] = "victor_zealot_activated_ability_power_on_hit"
	end

	if talent_extension:has_talent("victor_zealot_activated_ability_ignore_death", "witch_hunter", true) then
		buff_names[#buff_names + 1] = "zealot_got_your_back_check"
	end

	if talent_extension:has_talent("victor_zealot_activated_ability_cooldown_stack_on_hit", "witch_hunter", true) then
		buff_extension:add_buff("victor_zealot_activated_ability_cooldown_stack_on_hit", {
			attacker_unit = owner_unit
		})
	end

	for i = 1, #buff_names, 1 do
		local buff_name = buff_names[i]
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
	end

	if local_player or (is_server and self._bot_player) then
		local first_person_extension = self._first_person_extension

		first_person_extension:play_hud_sound_event("Play_career_ability_victor_zealot_enter")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_victor_zealot_enter", owner_unit, 0)
		first_person_extension:play_hud_sound_event("Play_career_ability_victor_zealot_loop")

		if local_player then
			first_person_extension:animation_event("shade_stealth_ability")
			first_person_extension:play_hud_sound_event("Play_career_ability_zealot_charge")
			first_person_extension:play_remote_unit_sound_event("Play_career_ability_zealot_charge", owner_unit, 0)
			career_extension:set_state("victor_activate_zealot")

			MOOD_BLACKBOARD.skill_zealot = true
		end
	end

	status_extension:set_noclip(true, "skill_zealot")

	status_extension.do_lunge = {
		animation_end_event = "zealot_active_ability_charge_hit",
		allow_rotation = false,
		first_person_animation_end_event = "dodge_bwd",
		first_person_hit_animation_event = "charge_react",
		falloff_to_speed = 8,
		dodge = true,
		first_person_animation_event = "shade_stealth_ability",
		first_person_animation_end_event_hit = "dodge_bwd",
		duration = 0.75,
		initial_speed = 25,
		animation_event = "zealot_active_ability_charge_start",
		damage = {
			depth_padding = 0.4,
			height = 1.8,
			collision_filter = "filter_explosion_overlap_no_player",
			hit_zone_hit_name = "full",
			ignore_shield = true,
			interrupt_on_max_hit_mass = true,
			power_level_multiplier = 0.8,
			interrupt_on_first_hit = false,
			damage_profile = "heavy_slashing_linesman",
			width = 1.5,
			allow_backstab = true,
			stagger_angles = {
				max = 90,
				min = 45
			},
			on_interrupt_blast = {
				allow_backstab = false,
				radius = 3,
				power_level_multiplier = 1,
				hit_zone_hit_name = "full",
				damage_profile = "heavy_slashing_linesman",
				ignore_shield = false,
				collision_filter = "filter_explosion_overlap_no_player"
			}
		}
	}

	career_extension:start_activated_ability_cooldown()
	self:_play_vo()
end)


-- Bounty Hunter
table.insert(PassiveAbilitySettings.wh_2.buffs, "victor_bountyhunter_activate_passive_on_melee_kill")

mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_railgun_delayed_add", {
    max_stacks = 1,
    multiplier = 0.8,
})
--Bounty Shotgun ability FF reduction
DamageProfileTemplates.shot_shotgun_ability.critical_strike.attack_armor_power_modifer = { 1, 0.1, 0.2, 0, 1, 0.025 }
DamageProfileTemplates.shot_shotgun_ability.critical_strike.impact_armor_power_modifer = { 1, 0.5, 1, 0, 1, 0.05 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.attack = { 1, 0.1, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_near.impact = { 1, 0.5, 1, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.attack = { 1, 0, 0.2, 0, 1, 0 }
DamageProfileTemplates.shot_shotgun_ability.armor_modifier_far.impact = { 1, 0.5, 1, 0, 1, 0 }
-- Bounty Hunter Talents
mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_blast_shotgun_cdr", {
    multiplier = -0.6, -- -0.25
    stat_buff = "activated_cooldown",
})
mod:modify_talent("wh_bountyhunter", 6, 3, {
    buffs = {
        "victor_bountyhunter_activated_ability_blast_shotgun_cdr"
    },
})
mod:add_text("victor_bountyhunter_activated_ability_blast_shotgun_desc", "Modifies Victor's sidearm to fire two blasts of shield-penetrating pellets in a devastating cone. Reduces the cooldown of Locked and Loaded by 60%%.")
mod:modify_talent("wh_bountyhunter", 2, 2, {
    buffs = {
        "gs_victor_bounty_melee_on_ranged"
    },
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_bounty_melee_on_ranged", {
    event = "on_hit",
    buff_to_add = "gs_victor_bounty_melee_on_ranged_counter",
    buff_func = "add_buff_on_first_target_hit_range"
})

local function is_server()
	return Managers.player.is_server
end
mod:add_proc_function("add_buff_on_first_target_hit_range", function (owner_unit, buff, params)
    if ALIVE[owner_unit] then
        local hit_data = params[5]
        local attack_type = params[2]

        if not hit_data or hit_data == "n/a" or (hit_data ~= "RANGED" and hit_data ~= "RANGED_ABILITY") then
            return
        end

        if attack_type ~= "instant_projectile" and attack_type ~= "projectile" then
            return
        end

        local target_number = params[4]

        if target_number < 2 then
            local buff_template = buff.template
            local buff_name = buff_template.buff_to_add
            local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")
            local network_manager = Managers.state.network
            local network_transmit = network_manager.network_transmit
            local unit_object_id = network_manager:unit_game_object_id(owner_unit)
            local buff_template_name_id = NetworkLookup.buff_templates[buff_name]

            if is_server() then
                buff_extension:add_buff(buff_name, {
                    attacker_unit = owner_unit
                })
                network_transmit:send_rpc_clients("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, false)
            else
                network_transmit:send_rpc_server("rpc_add_buff", unit_object_id, buff_template_name_id, unit_object_id, 0, true)
            end
        end
    end
end)
mod:add_talent_buff_template("witch_hunter", "gs_victor_bounty_melee_on_ranged_counter", {
    reset_on_max_stacks = true,
    max_stacks = 3,
    on_max_stacks_func = "add_remove_buffs",
    icon = "victor_bountyhunter_melee_damage_on_no_ammo",
    max_stack_data = {
        buffs_to_add = {
            "gs_victor_bounty_melee_on_ranged_buff"
        }
    }
})
mod:add_talent_buff_template("witch_hunter", "gs_victor_bounty_melee_on_ranged_buff", {
    icon = "victor_bountyhunter_melee_damage_on_no_ammo",
    stat_buff = "attack_speed",
    duration = 10,
    multiplier = 0.2,
    max_stacks = 1,
    refresh_durations = true
})
mod:add_text("victor_bountyhunter_power_burst_on_no_ammo_desc", "Every third ranged hit grants 20%% attack speed for 10 seconds.")

mod:add_buff_function("gs_activate_buff_stacks_based_on_clip_size", function (unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    if Unit.alive(unit) then
        local buff_extension = ScriptUnit.extension(unit, "buff_system")
        local template = buff.template
        local buff_to_add = template.buff_to_add
        local inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
        local slot_data = inventory_extension:get_slot_data("slot_ranged")
        local buff_system = Managers.state.entity:system("buff_system")
        local max_ammo = 1
        local talent_extension = ScriptUnit.extension(unit, "talent_system")

        if slot_data then
            local item_template = BackendUtils.get_item_template(slot_data.item_data)
            local ammo_data = item_template and item_template.ammo_data
            local ammo_per_clip = ammo_data and ammo_data.ammo_per_clip

            if ammo_per_clip and max_ammo < ammo_per_clip then
                max_ammo = ammo_per_clip
            end

            local clip_size = max_ammo
            local max_stacks = clip_size
            local num_buff_stacks = buff_extension:num_buff_type(buff_to_add)

            if not buff.stack_ids then
                buff.stack_ids = {}
            end

            if talent_extension:has_talent("victor_bountyhunter_party_movespeed_on_ranged_crit") then
                max_stacks = math.floor((max_stacks * 1.5) + 0.5)
            end

            if num_buff_stacks < max_stacks then
                local difference = max_stacks - num_buff_stacks

                for i = 1, difference, 1 do
                    local buff_id = buff_system:add_buff(unit, buff_to_add, unit, true)
                    local stack_ids = buff.stack_ids
                    stack_ids[#stack_ids + 1] = buff_id
                end
            elseif max_stacks < num_buff_stacks then
                local difference = num_buff_stacks - max_stacks

                for i = 1, difference, 1 do
                    local stack_ids = buff.stack_ids
                    local buff_id = table.remove(stack_ids, 1)

                    buff_system:remove_server_controlled_buff(unit, buff_id)
                end
            end
        end
    end
end)
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_power_level_on_clip_size", {
    update_func = "gs_activate_buff_stacks_based_on_clip_size"
})
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_power_level_on_clip_size_buff", {
    max_stacks = 25
})
mod:modify_talent("wh_bountyhunter", 4, 1, {
    description = "rebaltourn_victor_bountyhunter_blessed_combat_desc",
    description_values = {},
})
mod:add_text("rebaltourn_victor_bountyhunter_blessed_combat_desc", "Melee strikes makes up to the next 6 ranged shots deal 15%% more damage. Ranged hits makes up to the next 6 melee strikes deal 15%% more damage.")


PassiveAbilitySettings.wh_2.perks = {
	{
		display_name = "career_passive_name_wh_2b",
		description = "career_passive_desc_wh_2b_2"
	},
	{
		display_name = "career_passive_name_wh_2c",
		description = "career_passive_desc_wh_2c_2"
	},
	{
		display_name = "rebaltourn_career_passive_name_wh_2d",
		description = "rebaltourn_career_passive_desc_wh_2d_2"
	}
}
Weapons.repeating_pistol_template_1.ammo_data.ammo_per_reload = 12
Weapons.crossbow_template_1.ammo_data.ammo_per_reload = 2
Weapons.repeating_crossbow_template_1.ammo_data.ammo_per_reload = 23
mod:modify_talent("wh_bountyhunter", 5, 1, {
    buffs = {
        "gs_victor_bounty_clip_size_buff"
    },
})
mod:add_text("victor_bountyhunter_party_movespeed_on_ranged_crit_desc", "Increases clip size by 50%%.")
mod:add_talent_buff_template("witch_hunter", "gs_victor_bounty_clip_size_buff", {
    stat_buff = "clip_size",
    multiplier = 0.5,
})
mod:add_proc_function("gs_victor_bounty_hunter_ammo_fraction_gain_out_of_ammo", function (owner_unit, buff, params)

    if player and player.remote then
        return
    end

    if Unit.alive(owner_unit) then
        local killed_unit_breed_data = params[2]

        if killed_unit_breed_data.elite or killed_unit_breed_data.special then
            local buff_template = buff.template
            local weapon_slot = "slot_ranged"
            local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
            local slot_data = inventory_extension:get_slot_data(weapon_slot)
            local right_unit_1p = slot_data.right_unit_1p
            local left_unit_1p = slot_data.left_unit_1p
            local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
            local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
            local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
            local current_ammo = ammo_extension:remaining_ammo()
            local clip_ammo = ammo_extension:ammo_count()

            if current_ammo < 1 and clip_ammo < 1 then
                local ammo_bonus_fraction = buff_template.ammo_bonus_fraction
                local ammo_amount = math.max(math.round(ammo_extension:max_ammo() * ammo_bonus_fraction), 1)

                if ammo_extension then
                    ammo_extension:add_ammo_to_reserve(ammo_amount)
                end
            end
        end
    end
end)

mod:hook_origin(GenericAmmoUserExtension, "clip_full", function (self)
	return self:ammo_count() >= self._ammo_per_clip
end)

mod:add_proc_function("gs_victor_bounty_hunter_reload_on_kill", function (owner_unit, buff, params)

    if player and player.remote then
        return
    end

    if Unit.alive(owner_unit) then
        local killing_blow = params[1]
        local damage_source_name = killing_blow[DamageDataIndex.DAMAGE_SOURCE_NAME]
        local weapon_slot = "slot_melee"
        local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
        local slot_data = inventory_extension:get_slot_data(weapon_slot)

        if not slot_data then
            return
        end

        local item_data = slot_data.item_data

        if damage_source_name ~= item_data.name then
            return
        end

        local weapon_slot = "slot_ranged"
        local inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
        local slot_data = inventory_extension:get_slot_data(weapon_slot)
        local right_unit_1p = slot_data.right_unit_1p
        local left_unit_1p = slot_data.left_unit_1p
        local right_hand_ammo_extension = ScriptUnit.has_extension(right_unit_1p, "ammo_system")
        local left_hand_ammo_extension = ScriptUnit.has_extension(left_unit_1p, "ammo_system")
        local ammo_extension = right_hand_ammo_extension or left_hand_ammo_extension
        local current_ammo = ammo_extension:remaining_ammo()
        local clip_ammo = ammo_extension:ammo_count()
        local buff_template = buff.template

        if current_ammo >= 1 and ammo_extension and not ammo_extension:clip_full() then
            local ammo_bonus_fraction = buff_template.ammo_bonus_fraction
            local ammo_amount = math.max(math.round(ammo_extension:clip_size() * ammo_bonus_fraction), 1)
            if ammo_amount < 1 then
                ammo_amount = 1
            end

            ammo_extension._ammo_immediately_available = true

            ammo_extension:add_ammo(ammo_amount)

            ammo_extension._ammo_immediately_available = false

            ammo_extension:remove_ammo(ammo_amount)
        end
    end
end)


mod:add_text("victor_bountyhunter_reload_on_kill_desc", "Killing an elite while out of ammunition restores 15%% of max ammo. Melee kills reload ammo into Victor's ranged weapon.")
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_reload_on_kill", {
    buff_func = "gs_victor_bounty_hunter_reload_on_kill",
    ammo_bonus_fraction = 0.17
})
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_restore_ammo_on_elite_kill", {
    ammo_bonus_fraction = 0.15,
    buff_func = "gs_victor_bounty_hunter_ammo_fraction_gain_out_of_ammo"
})
mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_stacking_damage_reduction_on_elite_or_special_kill_buff", {
	max_stacks = 20
})

mod:modify_talent("wh_bountyhunter", 5, 3, {
    description_values = {
		{
			value_type = "percent",
			value = -0.01
		},
		{
			value = 20
		}
	},
})

mod:add_text("rebaltourn_career_passive_name_wh_2d", "Blessed Kill")
mod:add_text("rebaltourn_career_passive_desc_wh_2d_2", "Melee kills reset the cooldown of Blessed Shots.")

mod:modify_talent("wh_bountyhunter", 6, 1, {
    buffer = "both",
    buffs = {
        "victor_bountyhunter_activated_ability_passive_cooldown_reduction",
        "victor_bountyhunter_heal_on_ult_kill"
    }
})

mod:add_talent_buff_template("witch_hunter", "victor_bountyhunter_heal_on_ult_kill", {
    event = "on_kill",
    buff_func = "victor_bounty_heal_on_ult_kill_func"
})

mod:add_proc_function("victor_bounty_heal_on_ult_kill_func", function (owner_unit, buff, params)
    if not Managers.state.network.is_server then
        return
    end

    if not is_local(owner_unit) then
        return
    end

	if ALIVE[owner_unit] then
		local killing_blow = params[1]
        local damage_source_name = killing_blow[DamageDataIndex.DAMAGE_SOURCE_NAME]

        if damage_source_name ~= "victor_bountyhunter_career_skill_weapon" then
            return
        end

        local breed = params[2]

        if breed and breed.bloodlust_health and not breed.is_hero then
            local heal_amount = (breed.bloodlust_health) or 0

            DamageUtils.heal_network(owner_unit, owner_unit, heal_amount, "heal_from_proc")
		end
	end
end)

mod:modify_talent_buff_template("witch_hunter", "victor_bountyhunter_activated_ability_passive_cooldown_reduction", {
    multiplier = 0.15
})

mod:add_text("victor_bountyhunter_activated_ability_reset_cooldown_on_stacks_2_desc", "Killing enemies with Locked and Loaded grants temporary health. Ranged critical hits reduces the cooldown of Locked and Loaded by 15%%. Can only trigger once every 10 seconds.")

--Warrior Priest---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DamageProfileTemplates.victor_priest_activated_ability_nuke_explosion.default_target.dot_template_name = nil
DamageProfileTemplates.victor_priest_activated_ability_nuke_explosion.default_target.power_distribution.impact = 1
DamageProfileTemplates.victor_priest_activated_ability_nuke_explosion.armor_modifier.impact = { 0.5, 0.5, 1, 0.5, 1.5, 0.5}

mod:modify_talent_buff_template("witch_hunter", "victor_priest_super_armour_damage", {
    multiplier = 0.5
})
mod:add_talent_buff_template("witch_hunter", "victor_priest_monster_damage", {
    stat_buff = "power_level_large",
    multiplier = 0.25
})
mod:add_text("career_passive_desc_wh_priest_a", "50% bonus to Power vs Super Armor and 25% bonus to power vs monsters.")
mod:modify_talent_buff_template("witch_hunter", "victor_priest_2_2_buff", {
    max_stacks = 5,
    multiplier = 0.1
})
mod:modify_talent_buff_template("witch_hunter", "victor_priest_2_3_buff", {
    max_stacks = 4,
    duration = 15,
    bonus = 0.05
})
mod:modify_talent("wh_priest", 2, 2, {
    description_values = {
        {
            value_type = "percent",
            value = 0.1
        },
        {
            value = 5
        }
    },
})
mod:modify_talent("wh_priest", 2, 3, {
    description_values = {
        {
            value_type = "percent",
            value = 0.05
        },
        {
            value = 15
        },
        {
            value = 4
        }
    },
})

mod:modify_talent_buff_template("witch_hunter", "victor_priest_5_1_buff", {
    stat_buff = "power_level_melee_cleave",
    multiplier = 0.2
})
mod:modify_talent_buff_template("witch_hunter", "victor_priest_5_2_buff", {
    stat_buff = "attack_speed",
    multiplier = 0.05
})
mod:add_text("victor_priest_5_1_desc", "Bless the party with 20%% increased Melee Cleave Power.")
mod:add_text("victor_priest_5_2_desc", "Bless the party with 5%% increased Attack Speed.")

BuffTemplates.victor_priest_activated_ability_invincibility_improved.buffs[1].duration = 5
BuffTemplates.victor_priest_activated_ability_nuke_improved.buffs[1].duration = 5
BuffTemplates.victor_priest_activated_noclip_improved.buffs[1].duration = 5
BuffTemplates.victor_priest_passive_aftershock.buffs[1].stat_buff = "hit_force"
BuffTemplates.victor_priest_passive_aftershock.buffs[1].multiplier = 10

local stagger_types = require("scripts/utils/stagger_types")

mod:add_buff_template("victor_priest_activated_noclip", {
    stagger_distance = 1,
    name = "victor_priest_activated_noclip_improved",
    refresh_durations = true,
    remove_buff_func = "victor_priest_activated_noclip_remove",
    apply_buff_func = "victor_priest_activated_noclip_apply",
    push_cooldown = 1,
    push_radius = 1.5,
    duration = 5,
    icon = "victor_priest_6_1",
    max_stacks = 1,
    update_func = "victor_priest_activated_noclip_update",
    update_frequency = 0.1,
    perks= { buff_perks.no_ranged_knockback },
    stagger_impact = {
        stagger_types.medium,
        stagger_types.none,
        stagger_types.none,
        stagger_types.none,
        stagger_types.none
    },
    no_clip_filter = {
        true,
        false,
        false,
        false,
        false,
        false
    }
})

mod:add_text("victor_priest_6_1_desc", "Shield of Faith now lasts 12 seconds")
mod:modify_talent_buff_template("witch_hunter", "victor_priest_6_3_buff", {
    heal_window = 4
})
mod:add_text("victor_priest_6_3_desc", "Shield of Faith revives and heals an amount equal to all Damage suffered last 4 seconds.")
mod:modify_talent("wh_priest", 6, 1, {
    description_values  = {
        {
            value = 4
        }
    },
})

mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_1_cooldown", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_6_1",
	duration = 60,
	name = "victor_priest_prayer_1_cooldown",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_2_cooldown", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_2_3",
	duration = 60,
	name = "victor_priest_prayer_2_cooldown",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_3_cooldown", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_4_1",
	duration = 60,
	name = "victor_priest_prayer_3_cooldown",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_global_cooldown", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_passive",
	duration = 30,
	name = "victor_priest_prayer_global_cooldown",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_1_cooldown_short", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_6_1",
	duration = 50,
	name = "victor_priest_prayer_1_cooldown_short",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_2_cooldown_short", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_2_3",
	duration = 50,
	name = "victor_priest_prayer_2_cooldown_short",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_3_cooldown_short", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_4_1",
	duration = 50,
	name = "victor_priest_prayer_3_cooldown_short",
	is_cooldown = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_global_cooldown_short", {
	max_stacks = 1,
	refresh_durations = true,
	icon = "victor_priest_5_3",
	duration = 20,
	name = "victor_priest_passive",
	is_cooldown = true
})

mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_dr", {
	stat_buff = "damage_taken",
	max_stacks = 1,
	refresh_durations = true,
	multiplier = -0.3,
	icon = "victor_priest_6_1",
	duration = 15,
	name = "victor_priest_prayer_dr"
})
mod:add_talent_buff_template("witch_hunter", "victor_priest_prayer_attack_speed", {
	stat_buff = "attack_speed",
	max_stacks = 1,
	refresh_durations = true,
	multiplier = 0.2,
	icon = "victor_priest_2_3",
	duration = 15,
	name = "victor_priest_prayer_attack_speed"
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_dr_strong", {
	stat_buff = "damage_taken",
	max_stacks = 1,
	refresh_durations = true,
	multiplier = -0.36,
	icon = "victor_priest_6_1",
	duration = 15,
	name = "victor_priest_prayer_dr"
})
mod:add_talent_buff_template("witch_hunter", "victor_priest_prayer_attack_speed_strong", {
	stat_buff = "attack_speed",
	max_stacks = 1,
	refresh_durations = true,
	multiplier = 0.24,
	icon = "victor_priest_2_3",
	duration = 15,
	name = "victor_priest_prayer_attack_speed"
})

table.insert(PassiveAbilitySettings.wh_priest.buffs, "gs_priest_prayer_toggle_function")
table.insert(PassiveAbilitySettings.wh_priest.buffs, "victor_priest_4_3")

mod:add_talent_buff_template("witch_hunter", "gs_priest_prayer_toggle_function", {
	update_func = "toggle_prayer_type",
	max_stacks = 1,
})

mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_1", {
	max_stacks = 1,
	icon = "victor_priest_6_1",
    debuff = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_2", {
	max_stacks = 1,
	icon = "victor_priest_2_3",
    debuff = true
})
mod:add_talent_buff_template("witch_hunter","victor_priest_prayer_3", {
	max_stacks = 1,
	icon = "victor_priest_4_1",
    debuff = true
})

mod:add_buff_function("toggle_prayer_type", function (unit, buff, params)
	local input_extension = ScriptUnit.extension(unit, "input_system")

	if not input_extension then
		return
	end

	if input_extension:get("interact") then
		local buff_extension = ScriptUnit.has_extension(unit, "buff_system")

		if buff_extension then
			local prayer_1 = buff._prayer_1
			local prayer_2 = buff._prayer_2
			local prayer_3 = buff._prayer_3

			if not prayer_1 and not prayer_2 then
				local buff_id = buff_extension:add_buff("victor_priest_prayer_1")
				prayer_1 = buff_extension:get_buff_by_id(buff_id)
				buff._prayer_1 = prayer_1

				if prayer_3 then
					buff_extension:remove_buff(prayer_3.id)
					buff._prayer_3 = nil
				end
			elseif not prayer_2 and not prayer_3 then
				local buff_id = buff_extension:add_buff("victor_priest_prayer_2")
				prayer_2 = buff_extension:get_buff_by_id(buff_id)
				buff._prayer_2 = prayer_2

				buff_extension:remove_buff(prayer_1.id)
				buff._prayer_1 = nil
			elseif not prayer_1 and not prayer_3 then
				local buff_id = buff_extension:add_buff("victor_priest_prayer_3")
				prayer_3 = buff_extension:get_buff_by_id(buff_id)
				buff._prayer_3 = prayer_3

				buff_extension:remove_buff(prayer_2.id)
				buff._prayer_2 = nil
			end
		end
	end
end)

mod:hook_origin(PassiveAbilityWarriorPriest, "init", function (self, extension_init_context, unit, extension_init_data, ability_init_data)
	self._owner_unit = unit
	self._player = extension_init_data.player
	self._ability_init_data = ability_init_data
	self._is_active = false
	self._not_in_combat = true
	self._current_resource = 0
	self._max_resource = 100
	self._time_to_ooc = 5
	self._activation_time = 0
	self.uses_resource = true
	self._is_local_human = self._player.local_player
	self._is_local_player = self._is_local_human or self._player.bot_player
	self._is_server = self._player.is_server
	self._game = Managers.state.network:game()
end)

mod:hook_origin(PassiveAbilityWarriorPriest, "extensions_ready", function (self, world, unit)
	self._buff_system = Managers.state.entity:system("buff_system")
	self._buff_extension = ScriptUnit.has_extension(unit, "buff_system")
	self._talent_extension = ScriptUnit.has_extension(unit, "talent_system")
	self._first_person_extension = ScriptUnit.has_extension(unit, "first_person_system")
	self._inventory_extension = ScriptUnit.has_extension(unit, "inventory_system")
	self._input_extension = ScriptUnit.has_extension(unit, "input_system")
	self._status_extension = ScriptUnit.extension(unit, "status_system")
	self._career_extension = ScriptUnit.extension(unit, "career_system")
	self.world = world

	if self._first_person_extension then
		local fp_unit = self._first_person_extension:get_first_person_unit()
		self._fp_unit = fp_unit
		self._anim_var_id = Unit.animation_find_variable(fp_unit, "talent_anim_type")
		self._anim_var_3p_id = Unit.animation_find_variable(unit, "talent_anim_type")

		self:on_talents_changed(unit, self._talent_extension)
	end

	self:_register_events()
end)

mod:hook_origin(PassiveAbilityWarriorPriest, "modify_resource", function (self, amount, unit)
	local has_changed = self._current_resource ~= self._max_resource

	local client_multiplier = 1

	if not Managers.state.network.is_server then
		client_multiplier = 1.75
	end

	if amount > 0 then
		self:set_in_combat()

		local difficulty = Managers.state.difficulty:get_difficulty()

		if difficulty then
			self._difficulty_rank = DifficultySettings[difficulty].rank
			local difficulty_tweak = {
				1,
				1.5,
				1.2,
				1,
				1,
				1,
				1,
				0.7
			}
			amount = amount * difficulty_tweak[self._difficulty_rank] * client_multiplier
		end
	end

	self._current_resource = math.clamp(self._current_resource + amount, 0, self._max_resource)

	local input_extension = self._input_extension
	local buff_extension = self._buff_extension

	if buff_extension:has_buff_type("victor_priest_fury_on_ult") then
		self._current_resource = 101
		self:set_in_combat()
	end

	if self._max_resource <= self._current_resource and has_changed then
		self:activate_buff()
	end

	if not buff_extension:has_buff_type("victor_priest_prayer_global_cooldown") and  not buff_extension:has_buff_type("victor_priest_prayer_global_cooldown_short") and input_extension and input_extension:get("weapon_reload") and self._current_resource >= 80 then
		local owner_unit = self._owner_unit
		local is_server = self._is_server
		local is_local_player = self._is_local_player
		local is_local_human = self._is_local_human
		local network_manager =  Managers.state.network
		local network_transmit = network_manager.network_transmit
		local buff_to_add = nil
		local talent_extension = self._talent_extension

		if not buff_extension:has_buff_type("victor_priest_prayer_1_cooldown") and not buff_extension:has_buff_type("victor_priest_prayer_1_cooldown_short") and buff_extension:has_buff_type("victor_priest_prayer_1") then
			if talent_extension:has_talent("victor_priest_4_1", "witch_hunter", true) then
				buff_to_add = "victor_priest_prayer_dr_strong"
			else
				buff_to_add = "victor_priest_prayer_dr"
			end
			if talent_extension:has_talent("victor_priest_4_1", "witch_hunter", true) then
				buff_extension:add_buff("victor_priest_prayer_1_cooldown_short")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown_short")
			else
				buff_extension:add_buff("victor_priest_prayer_1_cooldown")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown")
			end
		elseif not buff_extension:has_buff_type("victor_priest_prayer_2_cooldown") and not buff_extension:has_buff_type("victor_priest_prayer_2_cooldown_short") and buff_extension:has_buff_type("victor_priest_prayer_2") then
			if talent_extension:has_talent("victor_priest_4_1", "witch_hunter", true) then
				buff_to_add = "victor_priest_prayer_attack_speed_strong"
			else
				buff_to_add = "victor_priest_prayer_attack_speed"
			end
			if talent_extension:has_talent("victor_priest_4_1", "witch_hunter", true) then
				buff_extension:add_buff("victor_priest_prayer_2_cooldown_short")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown_short")
			else
				buff_extension:add_buff("victor_priest_prayer_2_cooldown")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown")
			end
		end

		if buff_to_add then
			local proximity_extension = Managers.state.entity:system("proximity_system")
			local broadphase = proximity_extension.player_units_broadphase
			local nearby_player_units = FrameTable.alloc_table()
			local side_manager = Managers.state.side
			local radius = 15

			Broadphase.query(broadphase, POSITION_LOOKUP[owner_unit], radius, nearby_player_units)

			for _, player_unit in pairs(nearby_player_units) do
				if not side_manager:is_enemy(self._owner_unit, player_unit) then
					local unit_go_id = network_manager:unit_game_object_id(player_unit)
					local buff_system = self._buff_system

					if unit_go_id then
						buff_system:add_buff(player_unit, buff_to_add, self._owner_unit, false)
					end
				end
			end
			if talent_extension:has_talent("victor_priest_4_2", "witch_hunter", true) then
				self._current_resource = 50
			else
				self._current_resource = 0
			end

            if is_local_player or is_local_human then
                local first_person_extension = self._first_person_extension

                first_person_extension:animation_event("bless_target_other")
                first_person_extension:play_hud_sound_event("career_ability_priest_explosion")
                first_person_extension:play_remote_unit_sound_event("career_ability_priest_explosion", owner_unit, 0)
		    end
		end

		if not buff_extension:has_buff_type("victor_priest_prayer_3_cooldown") and not buff_extension:has_buff_type("victor_priest_prayer_3_cooldown_short") and buff_extension:has_buff_type("victor_priest_prayer_3") then
			local world = self.world
			local career_extension = self._career_extension
			local player_position = POSITION_LOOKUP[owner_unit]
			local player_rotation = Unit.local_rotation(owner_unit, 0)
			local forward = Quaternion.forward(player_rotation)
			local rotation = Quaternion.identity()
			local position = player_position + forward * 3
			local explosion_template_name = "warrior_priest_lightning_explosion"

			if talent_extension:has_talent("victor_priest_4_3", "witch_hunter", true) then
				explosion_template_name = "warrior_priest_lightning_explosion_strong"
			end

			local explosion_template = ExplosionTemplates[explosion_template_name]
			local scale = 1
			local damage_source = "career_ability"
			local is_husk = false
			local career_power_level = career_extension:get_career_power_level()
			local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
			local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
			local damage_source_id = NetworkLookup.damage_sources[damage_source]

			if is_server then
				network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
			else
				network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
			end

			DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false, owner_unit)

			if talent_extension:has_talent("victor_priest_4_1", "witch_hunter", true) then
				buff_extension:add_buff("victor_priest_prayer_3_cooldown_short")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown_short")
			else
				buff_extension:add_buff("victor_priest_prayer_3_cooldown")
				buff_extension:add_buff("victor_priest_prayer_global_cooldown")
			end

			if talent_extension:has_talent("victor_priest_4_2", "witch_hunter", true) then
				self._current_resource = 50
			else
				self._current_resource = 0
			end

            if is_local_player or is_local_human then
                local first_person_extension = self._first_person_extension

                first_person_extension:animation_event("bless_target_other")
                first_person_extension:play_hud_sound_event("career_ability_priest_explosion")
                first_person_extension:play_remote_unit_sound_event("career_ability_priest_explosion", owner_unit, 0)
		    end
		end
	end

	return self._current_resource
end)

mod:modify_talent("wh_priest", 4, 1, {
	buffs = {}
})
mod:modify_talent("wh_priest", 4, 3, {
	buffs = {}
})

mod:add_proc_function("add_buff_to_hit_enemy", function (owner_unit, buff, params, world)
	local hit_unit = params[1]
	local attack_type = params[7]

	if ALIVE[owner_unit] and ALIVE[hit_unit] and attack_type and (attack_type == "light_attack" or attack_type == "heavy_attack") then
		local buff_to_add = buff.template.buff_to_add
		local target_buff_extension = ScriptUnit.has_extension(hit_unit, "buff_system")

		if target_buff_extension then
			local values = {
				external_optional_value = params[3],
				attacker_unit = owner_unit
			}

			target_buff_extension:add_buff(buff_to_add, values)
		end
	end
end)

mod:add_proc_function("victor_priest_4_3_heal_on_kill", function (owner_unit, buff, params, world)
	if not Managers.state.network.is_server then
		return
	end

	if ALIVE[owner_unit] then
		local buff_extension = ScriptUnit.extension(owner_unit, "buff_system")

		if not buff_extension or not buff_extension:has_buff_type("victor_priest_passive_aftershock") then
			return
		end

		local killing_blow_data = params[1]

		if not killing_blow_data then
			return
		end

		local breed = params[2]

		if breed and not breed.is_hero then
			local heal_amount = breed.bloodlust_health or 0
			local owner_position = POSITION_LOOKUP[owner_unit]
			local side = Managers.state.side.side_by_unit[owner_unit]

			if not side then
				return
			end

			local player_and_bot_units = side.PLAYER_AND_BOT_UNITS
			local num_units = #player_and_bot_units
			heal_amount = heal_amount * 0.35

			for i = 1, num_units, 1 do
				local unit = player_and_bot_units[i]

				if ALIVE[unit] then
					DamageUtils.heal_network(unit, owner_unit, heal_amount, "career_passive")
				end
			end
		end
	end
end)

mod:add_text("career_passive_desc_wh_priest", "Saltzpyre gains Fury when enemies die nearby. At 100% Fury he briefly enters Righteous Fury, his attacks Smite the enemy for 20% of weapon damage and He can use three different Battle Prayers. Battle Prayers can be cycled trough with the Interact hotkey and used with the Reload hotkey. Prayers deplete Fury and have a cooldown of 30 seconds.")
mod:add_text("career_passive_desc_wh_priest_b", "During Righteous Fury kills restore health to the party based on the health of the slain enemy.")
mod:add_text("victor_priest_4_1_desc", "Lower cooldown of prayers by 10 seconds")
mod:add_text("victor_priest_4_2_desc", "Reduce Prayer cost from 100 to 50 Fury")
mod:add_text("victor_priest_4_3_desc", "Increase Prayer strength by 20%%")
mod:add_text("victor_priest_6_1_desc", "Fury set to 100%% while ult is active.")

mod:hook_origin(ActionCareerWHPriestTarget, "init", function (self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)
	ActionCareerWHPriestTarget.super.init(self, world, item_name, is_server, owner_unit, damage_unit, first_person_unit, weapon_unit, weapon_system)

	self.first_person_extension = ScriptUnit.extension(owner_unit, "first_person_system")
	self.inventory_extension = ScriptUnit.extension(owner_unit, "inventory_system")
	self._outline_system = Managers.state.entity:system("outline_system")
	self._weapon_extension = ScriptUnit.extension(weapon_unit, "weapon_system")
	self._status_extension = ScriptUnit.extension(owner_unit, "status_system")
	self._marked_target = {}
end)

local spell_data = {
	"victor_priest_activated_ability_invincibility",
	"victor_priest_activated_ability_nuke",
    "victor_priest_activated_noclip"
}
local spell_data_improved = {
	"victor_priest_activated_ability_invincibility_improved",
	"victor_priest_activated_ability_nuke_improved",
	"victor_priest_activated_noclip_improved"
}

mod:hook_origin(ActionCareerWHPriest, "client_owner_start_action", function (self, new_action, t, chain_action_data, power_level, action_init_data)
	action_init_data = action_init_data or {}

	ActionCareerWHPriest.super.client_owner_start_action(self, new_action, t, chain_action_data, power_level, action_init_data)

	local spell_target = chain_action_data and chain_action_data.target

	if new_action.target_self and not self.is_bot then
		spell_target = self.owner_unit
	end

	if ALIVE[spell_target] then
		local current_spell = spell_data

		if self.talent_extension:has_talent("victor_priest_6_1") then
			current_spell = spell_data_improved
		end

		self:_cast_spells(current_spell, spell_target)
		self.career_extension:start_activated_ability_cooldown()
		CharacterStateHelper.play_animation_event(self.owner_unit, "witch_hunter_active_ability")
		self:_play_vo()

		local owner_unit = self.owner_unit
		local network_manager =  Managers.state.network
		local network_transmit = network_manager.network_transmit
		local talent_extension = self.talent_extension
		if talent_extension:has_talent("victor_priest_6_1", "witch_hunter", true) then
			local buff_extension = ScriptUnit.has_extension(owner_unit, "buff_system")
			local buff_name = "victor_priest_fury_on_ult"
			local unit_object_id = network_manager:unit_game_object_id(owner_unit)
			local buff_template_name_id = NetworkLookup.buff_templates[buff_name]
			buff_extension:add_buff(buff_name, { attacker_unit = self.owner_unit })
		end
	end
end)

mod:add_talent_buff_template("witch_hunter", "victor_priest_fury_on_ult", {
	duration = 5,
	name = "victor_priest_fury_on_ult",
})

mod:add_proc_function("tag_on_hit_whc", function (owner_unit, buff, params)
	local target_unit = params[1]
    local attack_type = params[2]


	if Unit.alive(owner_unit) and Unit.alive(target_unit) and attack_type == "ability" then
        local network_manager = Managers.state.network
        local pinger_unit_id = network_manager:unit_game_object_id(owner_unit)
        local pinged_unit_id, is_level_unit = network_manager:game_object_or_level_id(target_unit)
        network_manager.network_transmit:send_rpc_server("rpc_ping_unit", pinger_unit_id, pinged_unit_id, is_level_unit, false, PingTypes.PING_ONLY, 1)
	end
end)

mod:add_talent_buff_template("witch_hunter", "victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit_tag", {
	event = "on_hit",
	buff_func = "tag_on_hit_whc"
})

mod:modify_talent("wh_captain", 6, 1, {
    buffs = {
        "victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit_tag",
    }
})

mod:hook_origin(CareerAbilityWHCaptain, "_run_ability", function (self, new_initial_speed)
	self:_stop_priming()

	local career_extension = self._career_extension

	career_extension:start_activated_ability_cooldown()

	local world = self._world
	local owner_unit = self._owner_unit
	local is_server = self._is_server
	local local_player = self._local_player
	local bot_player = self._bot_player
	local talent_extension = ScriptUnit.extension(owner_unit, "talent_system")
	local buff_system = Managers.state.entity:system("buff_system")
	local buff_to_add = "victor_witchhunter_activated_ability_crit_buff"
	local network_manager = self._network_manager
	local network_transmit = network_manager.network_transmit

	CharacterStateHelper.play_animation_event(owner_unit, "witch_hunter_active_ability")

	local radius = 10
	local position = POSITION_LOOKUP[owner_unit]

	if not talent_extension:has_talent("victor_witchhunter_activated_ability_guaranteed_crit_self_buff") then
		local nearby_player_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.player_units_broadphase

		Broadphase.query(broadphase, position, radius, nearby_player_units)

		local side_manager = Managers.state.side

		for _, player_unit in pairs(nearby_player_units) do
			if Unit.alive(player_unit) and not side_manager:is_enemy(owner_unit, player_unit) then
				buff_system:add_buff(player_unit, buff_to_add, owner_unit)
			end
		end
	else
		buff_to_add = "victor_witchhunter_activated_ability_guaranteed_crit_self_buff"

		buff_system:add_buff(owner_unit, buff_to_add, owner_unit)
	end

	local explosion_template_name = "victor_captain_activated_ability_stagger"
	local explosion_template = ExplosionTemplates[explosion_template_name]

	if talent_extension:has_talent("victor_captain_activated_ability_stagger_ping_debuff", "witch_hunter", true) then
		if talent_extension:has_talent("victor_witchhunter_improved_damage_taken_ping", "witch_hunter", true) then
			explosion_template_name = "victor_captain_activated_ability_stagger_ping_debuff_improved"
			explosion_template = ExplosionTemplates[explosion_template_name]
		else
			explosion_template_name = "victor_captain_activated_ability_stagger_ping_debuff"
			explosion_template = ExplosionTemplates[explosion_template_name]
		end
	end

	local scale = 1
	local damage_source = "career_ability"
	local is_husk = false
	local rotation = Quaternion.identity()
	local career_power_level = career_extension:get_career_power_level()

	DamageUtils.create_explosion(world, owner_unit, position, rotation, explosion_template, scale, damage_source, is_server, is_husk, owner_unit, career_power_level, false, owner_unit)

	local owner_unit_go_id = network_manager:unit_game_object_id(owner_unit)
	local explosion_template_id = NetworkLookup.explosion_templates[explosion_template_name]
	local damage_source_id = NetworkLookup.damage_sources[damage_source]

	if is_server then
		network_transmit:send_rpc_clients("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	else
		network_transmit:send_rpc_server("rpc_create_explosion", owner_unit_go_id, false, position, rotation, explosion_template_id, scale, damage_source_id, career_power_level, false, owner_unit_go_id)
	end

	if talent_extension:has_talent("victor_witchhunter_activated_ability_refund_cooldown_on_enemies_hit") then
		local nearby_enemy_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.enemy_broadphase

		Broadphase.query(broadphase, position, radius, nearby_enemy_units)

		local target_number = 1
		local side_manager = Managers.state.side

		for _, enemy_unit in pairs(nearby_enemy_units) do
			if Unit.alive(enemy_unit) and side_manager:is_enemy(owner_unit, enemy_unit) then
				DamageUtils.buff_on_attack(owner_unit, enemy_unit, "ability", false, "torso", target_number, false, "n/a")

				target_number = target_number + 1
			end
		end
	end

    if talent_extension:has_talent("victor_captain_activated_ability_stagger_ping_debuff") then
		local nearby_enemy_units = FrameTable.alloc_table()
		local proximity_extension = Managers.state.entity:system("proximity_system")
		local broadphase = proximity_extension.enemy_broadphase

        radius = 100

		Broadphase.query(broadphase, position, radius, nearby_enemy_units)

		local target_number = 1
		local side_manager = Managers.state.side

		for _, enemy_unit in pairs(nearby_enemy_units) do
			if Unit.alive(enemy_unit) and side_manager:is_enemy(owner_unit, enemy_unit) then
				DamageUtils.buff_on_attack(owner_unit, enemy_unit, "ability", false, "torso", target_number, false, "n/a")

				target_number = target_number + 1
			end
		end

        local nearby_player_units = FrameTable.alloc_table()
        local broadphase_2 = proximity_extension.player_units_broadphase

        Broadphase.query(broadphase_2, position, radius, nearby_player_units)

        for _, player_unit in pairs(nearby_player_units) do
            if not side_manager:is_enemy(self._owner_unit, player_unit) then
                local unit_go_id = network_manager:unit_game_object_id(player_unit)

                if unit_go_id then
                    buff_system:add_buff(owner_unit, "victor_witchhunter_activated_ability_mute_ping", self._owner_unit, false)
                end
            end
        end
	end

	if (is_server and bot_player) or local_player then
		local first_person_extension = self._first_person_extension

		first_person_extension:animation_event("ability_shout")
		first_person_extension:play_hud_sound_event("Play_career_ability_captain_shout_out")
		first_person_extension:play_remote_unit_sound_event("Play_career_ability_captain_shout_out", owner_unit, 0)
	end

	self:_play_vo()
	self:_play_vfx()
end)

mod:add_talent_buff_template("witch_hunter", "victor_witchhunter_activated_ability_mute_ping", {
	duration = 5,
    name = "victor_witchhunter_activated_ability_mute_ping",
    icon = "victor_priest_4_1"
})

mod:hook_origin(PingSystem, "_remove_ping", function (self, pinger_unit)
	if not pinger_unit then
		return
	end

    local buff_extension = ScriptUnit.has_extension(pinger_unit, "buff_system")

    if buff_extension and buff_extension:has_buff_type("victor_witchhunter_activated_ability_crit_buff") then
        return
    end

	local data = self._pinged_units[pinger_unit]
	local world_marker = self._world_markers[pinger_unit]
	local world_marker_id = world_marker and world_marker.id
	self._pinged_units[pinger_unit] = nil
	self._world_markers[pinger_unit] = nil

	if not data then
		return
	end

	if self.is_server then
		local party = Managers.party:get_party(data.party_id)
		local pinger_unit_id = data.pinger_unit_id

		self.network_transmit:send_rpc_party_clients("rpc_remove_ping", party, true, pinger_unit_id)
	end

	local pinged_unit = data.pinged_unit

	if ALIVE[pinged_unit] then
		local ping_extension = ScriptUnit.has_extension(pinged_unit, "ping_system")

		if ping_extension and ping_extension.set_pinged and ping_extension:pinged() then
			local apply_outline = self:_is_outline_enabled(pinged_unit)

			ping_extension:set_pinged(false, nil, pinger_unit, apply_outline)
		end
	end

	local sender_player = Managers.player:unit_owner(pinger_unit)

	if sender_player and sender_player.local_player then
		Managers.state.event:trigger("boss_health_bar_clear_prioritized_unit", "ping")
	end

	if self._world_markers_enabled and world_marker_id then
		Managers.state.event:trigger("remove_world_marker", world_marker_id)
	end

	local child_pings = data.child_pings
    local career_extension = ScriptUnit.has_extension(pinger_unit, "career_system")
    local career_name = career_extension and career_extension:career_name()

	if child_pings and not career_name == "wh_bountyhunter" then
		for i = 1, #child_pings, 1 do
			local child_pinger_unit = child_pings[i]

			self:_remove_ping(child_pinger_unit)
		end
	elseif data.parent_pinger_unit then
		local world_marker = self._world_markers[data.parent_pinger_unit]

		if world_marker then
			local widget = world_marker.widget
			local world_marker_response_index = data.world_marker_response_index
			local id = WORLD_MARKER_CONTENT_LOOKUP[world_marker_response_index]
			widget.content[id].show = false
		end
	end
end)

mod:hook_origin(PingSystem, "_handle_ping", function (self, ping_type, social_wheel_event_id, sender_player, pinger_unit, pinged_unit, position, flash, parent_pinger_unit)
	if self._pinged_units[pinger_unit] then
		self:_remove_ping(pinger_unit)
	end

	if pinged_unit and not Unit.alive(pinged_unit) then
		return
	end

	if pinged_unit then
		local buff_ext = ScriptUnit.has_extension(pinged_unit, "buff_system")

		if buff_ext and buff_ext:has_buff_type("mutator_shadow_damage_reduction") then
			return
		end
	end

	if not ping_type or ping_type == PingTypes.CANCEL or ping_type == PingTypes.CHAT_ONLY then
		return
	end

	local party = sender_player:get_party()

	if not party then
		return
	end

	local world_marker_response_index = nil

	if parent_pinger_unit then
		local parent_data = self._pinged_units[parent_pinger_unit]

		if parent_data then
			local child_pings = parent_data.child_pings or {}
			child_pings[#child_pings + 1] = pinger_unit
			self._pinged_units[parent_pinger_unit].child_pings = child_pings
			local profile_index = sender_player:profile_index()
			local career_index = sender_player:career_index()
			local career = SPProfiles[profile_index].careers[career_index]
			local color = Colors.get_color_table_with_alpha(career.display_name, 255)
			local world_marker = self._world_markers[parent_pinger_unit]

			if world_marker then
				local widget = world_marker.widget
				local content = widget.content

				for i = 1, 3 do
					local id = WORLD_MARKER_CONTENT_LOOKUP[i]

					if not content[id].show then
						world_marker_response_index = i

						break
					end
				end

				local icon_id = WORLD_MARKER_ICON_LOOKUP[world_marker_response_index]
				local style = widget.style[icon_id]
				style.color = table.clone(color)
				style.default_color = widget.style.icon.color
				local id = WORLD_MARKER_CONTENT_LOOKUP[world_marker_response_index]
				content[id] = {
					show = true,
					timer = 0
				}
			end
		end
	end

	local t = Managers.time:time("game")
	local network_manager = Managers.state.network
	local pinger_unit_id = network_manager:unit_game_object_id(pinger_unit)
	local pinged_unit_id, is_level_unit = nil

    if pinged_unit then
		pinged_unit_id, is_level_unit = network_manager:game_object_or_level_id(pinged_unit)
	end

	self._pinged_units[pinger_unit] = {
		start_time = t,
		pinged_unit = pinged_unit,
		flash = flash,
		party_id = party.party_id,
		pinger_unique_id = sender_player:unique_id(),
		pinger_unit_id = pinger_unit_id,
		pinged_unit_id = pinged_unit_id,
		ping_type = ping_type,
		parent_pinger_unit = parent_pinger_unit,
		world_marker_response_index = world_marker_response_index,
		position = position and {
			Vector3.to_elements(position)
		},
		social_wheel_event_id = social_wheel_event_id
	}

	Managers.telemetry_events:ping_used(sender_player, parent_pinger_unit == nil, table.find(PingTypes, ping_type), pinged_unit, POSITION_LOOKUP[pinger_unit])

	if self.is_server then
		if pinged_unit then
			self.network_transmit:send_rpc_party_clients("rpc_ping_unit", party, true, pinger_unit_id, pinged_unit_id, is_level_unit, flash, ping_type, social_wheel_event_id)
			self:_play_ping_vo(pinger_unit, pinged_unit, ping_type, social_wheel_event_id)
		elseif position then
			self.network_transmit:send_rpc_party_clients("rpc_ping_world_position", party, true, pinger_unit_id, position, ping_type, social_wheel_event_id)
		end
	end

	if not DEDICATED_SERVER then
		local local_player = Managers.player:local_player()
		local unique_player_id = local_player:unique_id()

		if Managers.party:is_player_in_party(unique_player_id, party.party_id) then
			if pinged_unit then
				self:_add_unit_ping(pinger_unit, pinged_unit, flash, ping_type)
			end

			if self._world_markers_enabled then
				self:_add_world_marker(pinger_unit, pinged_unit, position, ping_type, social_wheel_event_id)
			end

			local event = (pinged_unit and Unit.get_data(pinged_unit, "breed") and "hud_ping_enemy") or "hud_ping"

            local buff_extension = ScriptUnit.has_extension(pinger_unit, "buff_system")

            if buff_extension and buff_extension:has_buff_type("victor_witchhunter_activated_ability_crit_buff") then
                return
            end

			self:_play_sound(event)
		end
	end
end)