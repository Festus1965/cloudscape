-- Cloudscape deco.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


local newnode = cloudscape.clone_node("default:dirt")
newnode.description = "Cloud"
newnode.tiles = {'cloudscape_cloud.png'}
newnode.sunlight_propagates = true
minetest.register_node("cloudscape:cloud", newnode)

newnode = cloudscape.clone_node("default:dirt")
newnode.description = "Storm Cloud"
newnode.tiles = {'cloudscape_storm_cloud.png'}
--newnode.sunlight_propagates = true
minetest.register_node("cloudscape:storm_cloud", newnode)

minetest.register_node("cloudscape:wispy_cloud", {
	description = "Wispy Cloud",
	tiles = {'cloudscape_wisp.png'},
	sunlight_propagates = true,
	use_texture_alpha = true,
	drawtype = "glasslike",
	paramtype = 'light',
	walkable = false,
	buildable_to = true,
	pointable = false,
})

minetest.register_node("cloudscape:moon_weed", {
	description = "Moon Weed",
	drawtype = "plantlike",
	tiles = {"cloudscape_moon_weed.png"},
	inventory_image = "cloudscape_moon_weed.png",
	waving = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 8,
	walkable = false,
	groups = {snappy=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("cloudscape:leaves_lumin", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png^[colorize:#FFDF00:150"},
	special_tiles = {"default_leaves_simple.png^[colorize:#FFDF00:150"},
	paramtype = "light",
	is_ground_content = false,
	light_source = 8,
	groups = {snappy = 3, leafdecay = 4, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			--{
			--	-- player will get sapling with 1/20 chance
			--	items = {'default:sapling'},
			--	rarity = 20,
			--},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'cloudscape:leaves_lumin'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("cloudscape:lumin_tree", {
	description = "Lumin Tree",
	tiles = {
		"default_tree_top.png", "default_tree_top.png", "cloudscape_lumin_tree.png"
	},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed", 
		fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

newnode = cloudscape.clone_node("default:stone_with_iron")
newnode.description = "Silver Lining"
newnode.tiles = {'cloudscape_cloud.png^default_mineral_coal.png^[colorize:#FFFFFF:175'}
newnode.drop = "cloudscape:silver_lump"
minetest.register_node("cloudscape:silver_lining", newnode)

minetest.register_craftitem("cloudscape:silver_lump", {
	description = "Lump of Silver",
	inventory_image = 'default_coal_lump.png^[colorize:#FFFFFF:175',
})

minetest.register_craftitem("cloudscape:silver_ingot", {
	description = "Silver Ingot",
	inventory_image = 'default_steel_ingot.png^[colorize:#FFFFFF:175',
})

minetest.register_craft({
	type = "cooking",
	output = "cloudscape:silver_ingot",
	recipe = "cloudscape:silver_lump",
})


local dangerous = cloudscape.dangerous_terrain
cloudscape.decorations = {}


cloudscape.biomes = {}
local biomes = cloudscape.biomes
local biome_names = {}
do
  biomes["toxic_forest"] = {
    name = "toxic_forest",
    node_top = "cloudscape:polluted_dirt",
    danger = 3,
    depth_top = 1,
    node_filler = "cloudscape:polluted_dirt",
    depth_filler = 1,
    node_riverbed = "cloudscape:polluted_dirt",
    depth_riverbed = 1,
    node_water = "cloudscape:water_poison_source",
    node_river_water = "cloudscape:water_poison_source",
    special_trees = {"decaying_tree"},
    y_min = 1,
    y_max = cloudscape.max_height,
    heat_point = 20,
    humidity_point = 50,
  }

  cloudscape.decorations[#cloudscape.decorations+1] = {
    deco_type = "simple",
    place_on = {"default:dirt_with_grass"},
    sidelen = 80,
    fill_ratio = 0.1,
    biomes = {"desertstone_grassland", },
    y_min = 1,
    y_max = cloudscape.max_height,
    decoration = "default:junglegrass",
  }
end


local function register_flower(name, desc, biomes, chance)
  local groups = {}
  groups.snappy = 3
  groups.flammable = 2
  groups.flower = 1
  groups.flora = 1
  groups.attached_node = 1

  minetest.register_node("cloudscape:" .. name, {
    description = desc,
    drawtype = "plantlike",
    waving = 1,
    tiles = {"cloudscape_" .. name .. ".png"},
    inventory_image = "cloudscape_" .. name .. ".png",
    wield_image = "flowers_" .. name .. ".png",
    sunlight_propagates = true,
    paramtype = "light",
    walkable = false,
    buildable_to = true,
    stack_max = 99,
    groups = groups,
    sounds = default.node_sound_leaves_defaults(),
    selection_box = {
      type = "fixed",
      fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
    }
  })

  local bi = {}
  if biomes then
    bi = {}
    for _, b in pairs(biomes) do
      bi[b] = true
    end
  end

  cloudscape.decorations[#cloudscape.decorations+1] = {
    deco_type = "simple",
    place_on = {"default:dirt_with_grass"},
    biomes = bi,
    fill_ratio = chance,
    flower = true,
    decoration = "cloudscape:"..name,
  }
end

--register_flower("orchid", "Orchid", {"rainforest", "rainforest_swamp"}, 0.025)
--register_flower("bird_of_paradise", "Bird of Paradise", {"rainforest", "desertstone_grassland"}, 0.025)
--register_flower("gerbera", "Gerbera", {"savanna", "rainforest", "desertstone_grassland"}, 0.005)


local function register_decoration(deco, place_on, biomes, chance)
  local bi = {}
  if biomes then
    bi = {}
    for _, b in pairs(biomes) do
      bi[b] = true
    end
  end

  cloudscape.decorations[#cloudscape.decorations+1] = {
    deco_type = "simple",
    place_on = place_on,
    biomes = bi,
    fill_ratio = chance,
    decoration = deco,
  }
end


register_decoration('cloudscape:blackened_shrub', 'cloudscape:polluted_dirt', {'toxic_forest'}, 0.05)


local function get_decoration(biome_name)
  for i, deco in pairs(cloudscape.decorations) do
    if not deco.biomes or deco.biomes[biome_name] then
      if deco.deco_type == "simple" then
        if deco.fill_ratio and math.random(1000) - 1 < deco.fill_ratio * 1000 then
          return deco.decoration
        end
      end
    end
  end
end
cloudscape.get_decoration = get_decoration
