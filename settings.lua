-- 设置阶段：处理mod的配置选项

-- 掉落率设置（1-100，表示百分比）
data:extend({
  {
    type = "int-setting",
    name = "nest-reward-chest-drop-rate",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 1,
    maximum_value = 100,
    order = "a"
  }
})

-- 悬崖炸药掉落数量设置
data:extend({
  {
    type = "int-setting",
    name = "nest-reward-chest-cliff-explosives-count",
    setting_type = "runtime-global",
    default_value = 3,
    minimum_value = 0,
    maximum_value = 50,
    order = "b"
  }
})

-- 瓶子（科技包）掉落数量设置
data:extend({
  {
    type = "int-setting",
    name = "nest-reward-chest-science-pack-count",
    setting_type = "runtime-global",
    default_value = 10,
    minimum_value = 0,
    maximum_value = 100,
    order = "c"
  }
})