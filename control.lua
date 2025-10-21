local utils = require "utils"
--------------------------------------------------------------------------------
-- 控制阶段：处理虫巢被消灭时的事件
--------------------------------------------------------------------------------

-- 更新科技可见性
local function update_tech_visibility()
  local auto_research = settings.global["nest-reward-tech-auto-research"].value
  local player_force = game.forces["player"]
  local tech = player_force.technologies["nest-reward-tech"]
  
  if tech then
    tech.enabled = auto_research
  end
end

-- 当游戏加载时更新科技可见性
script.on_load(function()
  if game then
    random.set_seed(game.map_gen_settings.seed)
    update_tech_visibility()
  end
end)

-- 当游戏初始化时更新科技可见性
script.on_init(function()
  update_tech_visibility()
end)

-- 工具函数：检查实体是否是虫巢或虫族生成器
local function is_enemy_spawner(entity_name)
  local spawners = {
    "biter-spawner",
    "spitter-spawner"
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
  if is_enemy_spawner(event.entity.name) then
    -- 获取设置值
    local drop_rate = settings.global["nest-reward-chest-drop-rate"].value
    local cliff_explosives_count = settings.global["nest-reward-chest-cliff-explosives-count"].value
    local science_pack_count = settings.global["nest-reward-chest-science-pack-count"].value
    local auto_research = settings.global["nest-reward-tech-auto-research"].value
    
    -- 检查和研究科技
    local player_force = game.forces["player"]
    local tech = player_force.technologies["nest-reward-tech"]
    
    -- 如果科技未研究且启用了自动研究，则研究科技
    if tech and not tech.researched and auto_research then
      tech.researched = true
      game.print({"message.nest-reward-tech-completed"})
    end
    
    -- 如果科技已研究，则根据概率生成奖励箱子
    if tech and tech.researched then
      if math.random(100) <= drop_rate then
        local reward_chest = create_reward_chest(event.entity.surface, event.entity.position)
        if reward_chest then
          -- 使用设置的悬崖炸药数量
          if cliff_explosives_count > 0 then
            insert_items(reward_chest, { ["cliff-explosives"] = cliff_explosives_count })
          end
          
          -- 使用设置的科技包数量
          if science_pack_count > 0 then
            add_tech_reward(reward_chest, science_pack_count)
          end
        end
      end
    end
  end
end)
