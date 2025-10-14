local utils = require "utils"
--------------------------------------------------------------------------------
-- 控制阶段：处理虫巢被消灭时的事件
--------------------------------------------------------------------------------

-- 工具函数：检查实体是否是虫巢或虫族生成器
local function is_enemy_spawner(entity_name)
  local spawners = {
    "biter-spawner",
    "spitter-spawner",
    "biter-nest",
    "spitter-nest"
  }

  for _, spawner in pairs(spawners) do
    if entity_name == spawner then
      return true
    end
  end

  return false
end

-- 工具函数：创建奖励箱子
local function create_reward_chest(surface, position)
  local reward_chest = surface.create_entity {
    name = "wooden-chest",
    position = position,
    force = "player"
  }
  return reward_chest
end

local function insert_items(reward_chest, items)
  for item_name, count in pairs(items) do
    reward_chest.insert({ name = item_name, count = math.random(count * 2 - 1) })
  end
end

-- 检查科技表中是否全部已研究的科技
local function is_all_tech_researched(tech_names)
  local player_force = game.forces["player"]
  for _, tech_name in ipairs(tech_names) do
    if not player_force.technologies[tech_name].researched then
      return false
    end
  end
  return true
end

local function add_tech_reward(reward_chest, count)
  tech_reward_tiers = {
    { "automation-science-pack" },
    { "logistic-science-pack" },
    { "military-science-pack",   "chemical-science-pack" },
    { "production-science-pack", "utility-science-pack" },
    { "space-science-pack" },
  }
  for _, tier in ipairs(tech_reward_tiers) do
    if not is_all_tech_researched(tier) then
      local items = {}
      for _, item in ipairs(tier) do
        items[item] = (is_all_tech_researched({ item }) and 0 or 1)
      end
      insert_items(reward_chest, { [next(utils.random_choice_weighted(items, 1))] = count })
      return true
    end
  end
  return false
end

-- 主事件处理函数
script.on_event(defines.events.on_entity_died, function(event)
  -- 检查死亡的实体是否是虫巢或虫族生成器
  if is_enemy_spawner(event.entity.name) then
    local reward_chest = create_reward_chest(event.entity.surface, event.entity.position)
    if reward_chest then
      insert_items(reward_chest, { ["cliff-explosives"] = 1.5 })
    end
    add_tech_reward(reward_chest, 3)
  end
end)
