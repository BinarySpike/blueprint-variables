-- data.raw["gui-style"].default.bv_sprite_style = {
--     type = "image_style",
--     name = "bv_sprite_style",
--     width = 32,
--     height = 32,
--     vertically_stretchable = "on",
--     horizontally_stretchable = "on",
--     stretch_image_to_widget_size = true,
-- }

data:extend({
    {
        type = "item-group",
        icons = {
            {
                icon = "__base__/graphics/icons/signal/signal_yellow.png",
                icon_size = 64, icon_mipmaps = 4,
            },
            {
                icon = "__base__/graphics/icons/blueprint-book.png",
                scale = 0.625,
            }
        },
        icon_size = 64, icon_mipmaps = 4,
        name = "blueprint-variables",
        order = "fa", -- directly after signals
    }
})


local function createBlueprintVariable(name)
    data:extend({
        {
            type = "item-subgroup",
            group = "blueprint-variables",
            name = string.format("blueprint-variable-%s", name);
        },
        { -- entity
            type = "item",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-entity", name),
            stack_size = 50,
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = "__blueprint-variables__/graphics/entity.png",
                    icon_size = 32,
                    icon_mipmaps = 3,
                    scale = 0.625
                }
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "a",
        },
        { -- furnace result
            type = "item",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-furnace-result", name),
            stack_size = 1,
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                  icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                  scale = 0.25,
                  shift = { -9, -9 }
                },
                {
                  icon = "__base__/graphics/icons/steel-furnace.png",
                  icon_size = 64, icon_mipmaps = 4,
                  scale = 0.3125
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = 'b',
        },
        { -- stack size
            type = "item",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-stack-size", name),
            stack_size = 1,
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                    icon = "__blueprint-variables__/graphics/stack.png",
                    scale = 0.375,
                    icon_size = 64,
                    icon_mipmaps = 4,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "c",
        },
        { -- fluid
            type = "fluid",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-fluid", name),
            default_temperature = 25,
            heat_capacity = "1KJ",
            base_color = {r=0.4, g=0.6, b=0.1},
            flow_color = { r=0.6, g=0.8, b=0.2},
            max_temperature = 100,
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = "__base__/graphics/icons/fluid/crude-oil.png",
                    icon_size = 64, icon_mipmaps = 4,
                    scale = 0.3125
                }
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "d",
        },
        { -- Circuit 1
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-circuit-1", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                  icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                  scale = 0.25,
                  shift = { -9, -9 }
                },
                {
                  icon = "__base__/graphics/icons/red-wire.png",
                  icon_size = 64, icon_mipmaps = 4,
                  scale = 0.3125
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "e",
        },
        { -- Circuit 2
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-circuit-2", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                    icon_size = 64, icon_mipmaps = 4,
                },
                {
                  icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                  scale = 0.25,
                  shift = { -9, -9 }
                },
                {
                  icon = "__base__/graphics/icons/green-wire.png",
                  icon_size = 64, icon_mipmaps = 4,
                  scale = 0.3125
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "f",
        },
    })
end

createBlueprintVariable(1)
createBlueprintVariable(2)
createBlueprintVariable(3)
createBlueprintVariable(4)
createBlueprintVariable(5)
createBlueprintVariable(6)
createBlueprintVariable(7)
createBlueprintVariable(8)
createBlueprintVariable(9)
