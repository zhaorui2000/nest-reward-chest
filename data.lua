-- 数据阶段：定义科技和相关物品

-- 定义虫巢奖励
data:extend({
  {
    type = "technology",
    name = "nest-reward-tech",
    icon = "__nest-reward-chest__/graphics/nest-reward-icon.png",
    icon_size = 512,
    enabled = true,
    research_trigger = {
      type = "scripted",
      trigger_description = {"technology-trigger-description.nest-reward-tech-trigger"}
    },
    order = "a-a-a"
  }
})