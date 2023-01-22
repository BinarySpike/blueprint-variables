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
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-entity", name),
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
                    icon = "__blueprint-variables__/graphics/entity.png",
                    icon_size = 32,
                    icon_mipmaps = 3,
                    scale = 0.625
                }
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "a",
        },
        { -- stack size
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-stack-size", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
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
            order = "b",
        },
        {
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-arithmetic-1", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                },
                {
                    icon = "__blueprint-variables__/graphics/arithmetic.png",
                    scale = 0.375,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/1.png", name),
                    scale = 0.25,
                    shift = { 9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "c",
        },
        {
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-arithmetic-2", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                },
                {
                    icon = "__blueprint-variables__/graphics/arithmetic.png",
                    scale = 0.375,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/2.png", name),
                    scale = 0.25,
                    shift = { 9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "d",
        },
        {
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-arithmetic-3", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                },
                {
                    icon = "__blueprint-variables__/graphics/arithmetic.png",
                    scale = 0.375,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/3.png", name),
                    scale = 0.25,
                    shift = { 9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "e",
        },
        {
            type = "virtual-signal",
            subgroup = string.format("blueprint-variable-%s", name),
            name = string.format("blueprint-variable-%s-arithmetic-4", name),
            icons = {
                {
                    icon = "__base__/graphics/icons/signal/signal_yellow.png",
                },
                {
                    icon = "__blueprint-variables__/graphics/arithmetic.png",
                    scale = 0.375,
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/%s.png", name),
                    scale = 0.25,
                    shift = { -9, -9 }
                },
                {
                    icon = string.format("__blueprint-variables__/graphics/icons/blueprint-variables/4.png", name),
                    scale = 0.25,
                    shift = { 9, -9 }
                },
            },
            icon_size = 64, icon_mipmaps = 4,
            order = "f",
        }
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
